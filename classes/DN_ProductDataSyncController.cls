/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-09-01
 * @last modified by  : JangJunHee
**/
public with sharing class DN_ProductDataSyncController {
    
    private ApexPages.standardController controller;
    public String productCodeLabel      { get; set; }
    public String confirmLabel          { get; set; }
    public String cancelLabel           { get; set; }
    public String cancelUrl             { get; set; }
    public String productCodeValue      { get; set; }
    
    public String redirectUrl      { get; set; }

    //toast
    public String errorMessage          { get; set; }

    //product
    private static final Id partRT      = SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
    private static Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private static Schema.SObjectField prdEField    = schemaMap.get('Product2').getDescribe().fields.getMap().get('ERP_Key__c');
    private static Schema.SObjectField pbeEField    = schemaMap.get('PriceBookEntry').getDescribe().fields.getMap().get('ProductCode_Currency_Key__c');
    private static Schema.SObjectField pbpEField    = schemaMap.get('ProductByPlant__c').getDescribe().fields.getMap().get('ExternalKey__c');

    // 리스트뷰에서 버튼을 달기위한 ApexPage생성자
    public DN_ProductDataSyncController(ApexPages.standardController controller) {
        this.controller = controller;
        this.productCodeLabel = System.Label.DNS_PDS_ProductCode;
        this.confirmLabel = System.Label.DNS_PDS_Confirm;
        this.cancelLabel = System.Label.DNS_PDS_Cancel;
        this.productCodeValue = '';

        String host = URL.getOrgDomainUrl().getHost();
        this.cancelUrl = 'https://' + host + '/lightning/o/Product2/list?filterName=__Recent';
        System.debug('cancelUrl ::: ' + this.cancelUrl);
    }

    // 취소시 전 화면으로 가기
    public PageReference clickCancel() {
        PageReference ref = new PageReference(this.cancelUrl); // Visualforce 페이지 이름
        ref.setRedirect(true); // 리다이렉트 (브라우저 URL 변경)
        return ref;
    }

    // 확인 버튼 클릭시 입력한 제품을 Interface로 조회해서 upsert하는 메서드
    public PageReference clickConfirm() {

        System.debug('Confirm button clicked!');
        System.debug('productCodeValue ::: ' + this.productCodeValue);

        String procudtCode = this.productCodeValue;

        if (procudtCode == '' || procudtCode == null) {
            // Error
            this.errorMessage = 'Enter Product Code';
            return null;
        }

        Product2 upsertProduct = new Product2();

        try {

            List<Product2> productList = [SELECT Id, ProductCode, RecordType.Name, recordTypeId FROM Product2 WHERE (RecordType.Name = 'Part' OR RecordType.Name = 'Service Package') AND ProductCode = :procudtCode];

            Map<String, Product2> productMap = new Map<String, Product2>();
            Map<String, Product2> serviceProductMap = new Map<String, Product2>();
            if (productList.size() > 0) {
                for (Product2 pro : productList) {
                    if (pro.RecordType.Name == 'Part') {
                        productMap.put(pro.ProductCode, pro);
                    } else {
                        serviceProductMap.put(pro.ProductCode, pro);
                    }
                }
            }
            
            IF_ERP_Product_Classes.IF_OPTY_002_Req req = new IF_ERP_Product_Classes.IF_OPTY_002_Req();
    
            Date today = Date.today();
    
            req.I_SDATE     = '2000-01-01';
            req.I_EDATE     =  today.year() + '-' + String.valueOf(today.month()).leftPad(2, '0') + '-' + String.valueOf(today.day()).leftPad(2, '0');
            req.I_CODE      = 'I';
    
            IF_ERP_Product_Classes.IF_OPTY_002_Req_IT_MATNR matnr = new IF_ERP_Product_Classes.IF_OPTY_002_Req_IT_MATNR();
            matnr.matnr = procudtCode;
            req.IT_MATNR.add(matnr);
    
            IF_ERP_Product call = new IF_ERP_Product();
            IF_ERP_Product_Classes.IF_OPTY_002_Res response = call.IF_OPTY_002(req);
    
            System.debug('response!!! ::: ' + response);
            System.debug('response.O_RETURN!!! ::: ' + response.O_RETURN);
            System.debug('response.T_LIST!!! ::: ' + response.T_LIST);
    
            if (response.O_RETURN.TYPE == 'F') {
                // Error
                this.errorMessage = '\" ' + procudtCode + '\" is ' + response.O_RETURN.MESSAGE;
                return null;
            } else {
                
                if (response.T_LIST[0].MTART == 'PKMT' || response.T_LIST[0].MTART == 'FPRO') {
                    // Error
                    this.errorMessage = 'No Part';
                    return null;
                }

                upsertProduct = generatePrd(response.T_LIST[0]);

                if (productMap.containsKey(procudtCode)) upsertProduct.Id = productMap.get(procudtCode).Id;

                Set<String> plants = new Set<String>();

                for (IF_ERP_Product_Classes.IF_OPTY_002_Res_T_LIST t_list : response.T_LIST) {
                    plants.add(t_list.WERKS);
                }

                List<String> plantList = new List<String>(plants);


                upsertProduct.Plant__c = String.join(plantList, ';');


                Map<String, ProductByPlant__c> productByPlantForEKey    = new Map<String, ProductByPlant__c>();
                Map<String, PricebookEntry> pbeForEKey                  = new Map<String, PricebookEntry>();

                Database.SaveResult ur;
                if (upsertProduct.Id == null) {
                    ur = Database.insert(upsertProduct, true);
                } else {
                    ur = Database.update(upsertProduct, true);
                }
                if (ur.isSuccess()) {
                    System.debug('성공');
                    if (serviceProductMap.containsKey(procudtCode)) {
                        Product2 partPrd = upsertProduct;
                        partPrd.Id              = serviceProductMap.get(procudtCode).Id;
                        partPrd.recordTypeId    = serviceProductMap.get(procudtCode).recordTypeId;
                        Database.update(partPrd, true);
                    }

                    for (String plant : plantList) {
                        ProductByPlant__c pbp = new ProductByPlant__c();
                        pbp.Part__c         = ur.getId();
                        pbp.Plant__c        = plant;
                        pbp.ExternalKey__c  = procudtCode + '_' + plant;
    
                        productByPlantForEKey.put(pbp.ExternalKey__c, pbp);
                    }

                    // ProductByPlant upsert
                    if (productByPlantForEKey.keySet().size() > 0) Database.upsert(productByPlantForEKey.values(), pbpEField, true);

                    String pbId = Test.isRunningTest() ? Test.getStandardPricebookId() : [
                        SELECT  Id, Name 
                        FROM    Pricebook2 
                        WHERE   isStandard = true 
                        LIMIT 1
                    ].Id;

                    List<PricebookEntry> pbeIds = [SELECT Id FROM PricebookEntry WHERE Product2Id =:ur.getId()];
                    PricebookEntry pbe = new PricebookEntry();
                    if (pbeIds.size() > 0) {
                        pbe.Id = pbeIds[0].Id;
                    } else {
                        pbe.Pricebook2Id    = pbId;
                        pbe.Product2Id      = ur.getId();
                        pbe.CurrencyIsoCode = 'KRW';
                    }
                    pbe.IsActive        = true;
                    pbe.UnitPrice       = 0;
                    pbe.ProductCode_Currency_Key__c = procudtCode + '_' + pbe.CurrencyIsoCode;
    
                    pbeForEKey.put(pbe.ProductCode_Currency_Key__c, pbe);

                    try {
                        if (!pbeForEKey.values().isEmpty()) {
                            if (pbe.Id != null) {
                                Database.update(pbeForEKey.values(), false);
                            } else {
                                Database.insert(pbeForEKey.values(), false);
                            }
                        }
                    } catch (Exception e) {
                        System.debug('pbe upsert 시 발생하는 정상적인 오류입니다.');
                    }

                    String host = URL.getOrgDomainUrl().getHost();
                    String successUrl = 'https://' + host + '/lightning/r/Product2/' + ur.getId() + '/view';
                    this.redirectUrl = successUrl;
                    this.errorMessage = null;
                    return null;

                } else {
                    System.debug('실패');
                    this.errorMessage = 'Upsert Fail';
                    return null;
                }
            }

        } catch (Exception e) {
                // Error
                this.errorMessage = e.getMessage();
                return null;
        }
    }

    // 제품의 정보를 담는 메서드
    private Product2 generatePrd(IF_ERP_Product_Classes.IF_OPTY_002_Res_T_LIST ifPrd){
        Product2 prd = new Product2();
        prd.recordTypeId       = partRT;
        prd.ERP_Key__c         = ifPrd.MATNR;
        
        prd.Name               = ifPrd.MATNR;
        prd.ProductCode        = ifPrd.MATNR;
        prd.MaterialDetailsEN__c    = ifPrd.MAKTX;
        prd.MaterialDetailsKO__c    = ifPrd.MAKTX;
        prd.Unit__c            = ifPrd.MEINS;

        prd.Weight__c              = ifPrd.NTGEW != null ? Decimal.valueOf(ifPrd.NTGEW) : 0; 
        prd.WeightUnit__c          = ifPrd.GEWEI; 
        prd.MaterialGroupCode__c   = ifPrd.MATKL; 
        prd.MaterialGroupName__c   = ifPrd.WGBEZ;
        prd.IsActive               = true;

        if(ifPrd.HE_INDICATOR      == 'HE') prd.HEIndicator__c = true;
        else if(ifPrd.HE_INDICATOR == 'CP') prd.HEIndicator__c = false;
        
        return prd;
    }

}