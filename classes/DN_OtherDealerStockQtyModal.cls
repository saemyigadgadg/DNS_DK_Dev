/** 
 * @Class :  DN_OtherDealerStockQtyModal
 * 
 * @Test: DN_OtherDealerStockQtyModal_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 01. 06. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-06 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_OtherDealerStockQtyModal {
    
    public DN_OtherDealerStockQtyModal() {}

    /*
    * @ Description : 현재 유저 정보
    */
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    
    /*
    * @ Method : getPartInfos
    * @ Description : 타대리점 선택 품번 및 최종 대체품 정보 조회
    */
    @AuraEnabled
    public static Map<String,Object> getPartInfos(Map<String, DealerStock> requestStockMap){
        Map<String,Object> result = new Map<String,Object>();
        StatusInfo resultStatus = new StatusInfo();
        try {
            String excludeAgencyId = currentUser.getAgencyId();
            String salesOranization = currentUser.getSalesOranization();
            String distributionChannel = currentUser.getDistributionChannel();
            String division = currentUser.getDivision();
            // 2025 03 31 CRM에 부품코드가 없는 경우 바로 리턴
            List<Product2> productCheckList = [SELECT Id, Name, ProductCode FROM Product2 WHERE ProductCode IN:requestStockMap.keySet()];
            if(productCheckList.size() ==0) {
                resultStatus.setError('부품코드가 올바르지 않습니다.', null);
                result.put('status', resultStatus);
                return result;
            }

            // String customerCode = currentUser.getAgencyCustomerCode();
            Set<DealerStock> stockSet = new Set<DealerStock>();
            Map<String, List<DealerStock>> replacingStockListMap = new Map<String, List<DealerStock>>();
            Set<String> partIdList = new Set<String>();

            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req req = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();
            req.I_LANGU = 'ko'; //TODO 낼 확인 필요
            System.debug('첫번째 I/F 호출 req I_LANGU :: '+ req.I_LANGU);
            List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL> D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();
            
            for(String partCode : requestStockMap.keySet()) {
                IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
                D_DETAIL.MATNR = partCode;
                D_DETAIL_List.add(D_DETAIL);
            }
            req.D_DETAIL = D_DETAIL_List;
            
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
            I_USERINFO.KUNNR        = currentUser.getAgencyCustomerCode();
            I_USERINFO.VKORG        = currentUser.getSalesOranization();
            I_USERINFO.VTWEG        = currentUser.getDistributionChannel();
            I_USERINFO.SPART        = currentUser.getDivision();
            I_USERINFO.LAND1        = currentUser.getCountry();
            I_USERINFO.DF_CHK       = 'X';
            req.I_USERINFO        = I_USERINFO;

            IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
            instance.interfaceUtil.isInsertLog = false;
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res ifResult = instance.IF_PARTS_022(req);
            
            Set<String> partCodeSet = new Set<String>();
            Set<String> replacingPartCodeSet = new Set<String>();
            Map<String, DealerStock> needToPriceReplacingPartMap = new Map<String, DealerStock>();
            if('S'.equals(ifResult.O_RETURN.TYPE)) {
                for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL partInfo : ifResult.D_DETAIL) {
                    partCodeSet.add(partInfo.MATNR);

                    DealerStock stock = requestStockMap.get(partInfo.MATNR);
                    stock.customerPrice = Decimal.valueOf(partInfo.NETPR); //고객판매가 //COND_VALUE
                    //소바자가격 NETPR_ETC //COND_VALUE
                    //단가(소비가격에 대리점 등급 할인율 적용) NETPR //

                    if(!replacingStockListMap.containsKey(partInfo.MATNR)) {
                        DealerStock mainStock = stock.clone();
                        mainStock.replacingPartName = partInfo.MATNR;
                        replacingStockListMap.put(partInfo.MATNR, new List<DealerStock>{mainStock});
                    }

                    if(String.isNotBlank(partInfo.SUB_MATERIAL)) {        
                        DealerStock replacingStock = stock.clone();
                        replacingStock.replacingPartName    = partInfo.SUB_MATERIAL;
                        replacingStockListMap.get(partInfo.MATNR).add(replacingStock);

                        needToPriceReplacingPartMap.put(replacingStock.replacingPartName, replacingStock);
                        
                        replacingPartCodeSet.add(partInfo.SUB_MATERIAL);
                    }
                    
                }
            }
            //대체품 한번더 조회 필요

            D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();
            for(String partCode : replacingPartCodeSet) {
                IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
                D_DETAIL.MATNR = partCode;
                D_DETAIL_List.add(D_DETAIL);
            }
            req.I_LANGU = 'ko';
            req.D_DETAIL = D_DETAIL_List;
            System.debug('두번째 I/F 호출 req I_LANGU :: '+ req.I_LANGU);
            ifResult = instance.IF_PARTS_022(req);
            
            if('S'.equals(ifResult.O_RETURN.TYPE)) {
                for(IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res_D_DETAIL partInfo : ifResult.D_DETAIL) {
                    partCodeSet.add(partInfo.MATNR);
                    System.debug('partInfo: ' + JSON.serialize(partInfo));
                    System.debug(partInfo.NETPR);
                    DealerStock stock = needToPriceReplacingPartMap.get(partInfo.MATNR);
                    if(stock != null)
                    stock.customerPrice = Decimal.valueOf(partInfo.NETPR); 
                }
            }

            
            //대체품 코드정보로 다시 ProductId 값 가져오기 위해 다시 한번 조회
            if(replacingPartCodeSet.size() > 0) partCodeSet.addAll(replacingPartCodeSet);

            //Key: ProductCode
            Map<String, Product2> partMap = new Map<String, Product2>();
            for(Product2 part :[    
                SELECT Id, Name, ProductCode, FM_MaterialDetails__c
                FROM Product2 WHERE ProductCode IN :partCodeSet AND RecordType.DeveloperName = 'Part'
            ]) {
                partIdList.add(part.Id);
                partMap.put(part.ProductCode, part);
            }


            List<DealerStock> replacingStockList = new List<DealerStock>();
            if(replacingStockListMap.size() > 0) {
                for(String key : replacingStockListMap.keySet()) {
                    replacingStockList.addAll(replacingStockListMap.get(key));
                }
            }
            Set<String> salesDealerGrade = new Set<String>(); //판매대리점 등급
            Set<String> dealerIdSet = new Set<String>();
            Map<String, DealerStock__c> partDealerStockMap = DN_DealerStockManager.getAvailableStockMapExcludeCurrent(excludeAgencyId, salesOranization, distributionChannel, division, partIdList);
            if(partDealerStockMap.size() > 0) {
                
                for(String key : partDealerStockMap.keySet()) {
                    List<String> keyCharList = key.split('_');
                    String partId = keyCharList[0];     //
                    String agencyId = keyCharList[1];
                    System.debug('agencyId :: '+ agencyId);
                    dealerIdSet.add(agencyId);

                    DealerStock__c dealerStock = partDealerStockMap.get(key);
                    salesDealerGrade.add(dealerStock.Dealer__r.DealerGrade_Parts__c); // DealerGrade__c > DealerGrade_Parts__c
                    Product2 partInfo = partMap.get(dealerStock.Part__r.ProductCode);
                    for(DealerStock replacingInfo : replacingStockList) {
                        if(partInfo.ProductCode != replacingInfo.replacingPartName) continue;

                        Product2 sourcePartInfo = partMap.get(replacingInfo.partName);
                        DealerStock showStock = replacingInfo.clone();
                        showStock.dealerGrade          = dealerStock.Dealer__r.DealerGrade_Parts__c;// DealerGrade__c > DealerGrade_Parts__c
                        showStock.replacingPart        = partInfo.Id;
                        showStock.replacingPartDetails = partInfo.FM_MaterialDetails__c;

                        showStock.part        = sourcePartInfo.Id;
                        showStock.partDetails = sourcePartInfo.FM_MaterialDetails__c;

                        showStock.dealer = agencyId;
                        System.debug('showStock.dealer :: '+ showStock.dealer);
                        showStock.avaiableQuantity = dealerStock.AvailableQuantity__c;
                        stockSet.add(showStock);
                    }
                }
            }

            Map<String, Decimal> purchasingGradeMap = new Map<String, Decimal>();
             for(DealerDiscountRate__c rate : [ SELECT
                        PurchasingDealerGrade__c,
                        SalesDealerGrade__c,
                        Rate__c
                FROM DealerDiscountRate__c 
                WHERE 
                    SalesDealerGrade__c IN :salesDealerGrade
                    AND PurchasingDealerGrade__c = :currentUser.getDealerGrade()  ]) {
                        purchasingGradeMap.put(rate.SalesDealerGrade__c, rate.Rate__c);
            }
            System.debug('purchasingGradeMap :: ');
            System.debug(JSON.serializePretty(purchasingGradeMap));
            Map<String, DealerCustomer__c> dealerMap = new Map<String, DealerCustomer__c>();
            for(DealerCustomer__c dealer :[
                SELECT 
                    Id, Name, SourceAccount__c, CustomerCode__c
                FROM DealerCustomer__c
                WHERE SourceAccount__c IN :dealerIdSet
            ]) {
                dealerMap.put(dealer.SourceAccount__c, dealer);
            }

            for(DealerStock availableStock : stockSet) {
                System.debug('dealerMap.get(availableStock.dealer) : '+ dealerMap.get(availableStock.dealer)?.Name);
                DealerCustomer__c dealer = dealerMap.get(availableStock.dealer);
                if(dealer != null) {
                    availableStock.dealer = dealer.Id;
                    availableStock.dealerName = dealer.Name;
                    availableStock.dealerCode = dealer.CustomerCode__c;
                    //대리점간 할인율 조회
                    System.debug('availableStock.dealerGrade :: '+availableStock.dealerGrade);
                    System.debug('availableStock.dealerCode : '+ availableStock.dealerCode);
                    availableStock.discountRate = purchasingGradeMap.get(availableStock.dealerGrade);
                }
                System.debug('availableStock.dealerName : '+ availableStock.dealerName);
            }

             

            result.put('availableStockList' , stockSet);

            instance.interfaceUtil.saveInterfaceLog();
            
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug(e.getStackTraceString());
            System.debug('errorMessage :: ' +errorMessage);
            resultStatus.setError(errorMessage, null);
        }
        result.put('status', resultStatus);
        return result;
    }

    /*
    * @ Class : DealerStock
    * @ Description : DealerStock Class
    */
    public class DealerStock {
        @AuraEnabled public String  dealer               {get; set;}
        @AuraEnabled public String  dealerCode           {get; set;}
        @AuraEnabled public String  dealerName           {get; set;}
        @AuraEnabled public String  dealerGrade          {get; set;}
        @AuraEnabled public String  part                 {get; set;}
        @AuraEnabled public String  partName             {get; set;}
        @AuraEnabled public String  partDetails          {get; set;}
        @AuraEnabled public String  replacingPart        {get; set;}
        @AuraEnabled public String  replacingPartName    {get; set;}
        @AuraEnabled public String  replacingPartDetails {get; set;}
        @AuraEnabled public Decimal requestQuantity      {
            get {
                if(requestQuantity == null) requestQuantity = 0;
                return requestQuantity;
            }
            set;
        }//요청재고
        @AuraEnabled public Decimal avaiableQuantity     {
            get{
                if(avaiableQuantity == null) avaiableQuantity = 0;
                return avaiableQuantity;
            } 
            set;
        } //가용재고
        @AuraEnabled public Decimal customerPrice        {
            get {
                if(customerPrice == null) customerPrice = 0;
                return customerPrice;
            }
            set;
        } //판매가(고객 판매가)
        @AuraEnabled public Decimal discountPrice        {
            get{
                if(discountPrice == null) discountPrice = 0;
                return discountPrice;
            } 
            set;
        } //
        @AuraEnabled public Decimal discountRate         {
            get {
                if(discountRate == null) discountRate = 0;
                return discountRate;
            }
            set;
        }
        
        @AuraEnabled public Boolean isSelected = false;
        public DealerStock() {}
    }

    /*
    * @ Class : StatusInfo
    * @ Description : StatusInfo Class
    */
    public enum StatusCode { SUCCESS, ERROR }

    public class StatusInfo {
        @AuraEnabled public Integer code      {get; set;}
        @AuraEnabled public String msg        {get; set;}
        @AuraEnabled public StatusCode status {get; set;}
        /*
        * @ 생성자 : StatusInfo
        * @ Description : 상태정보 반환
        */
        public StatusInfo() {
            code = 200;
            status = StatusCode.SUCCESS;
        }

        /*
        * @ Method : setCode
        * @ Description : 상태 코드 반환
        */
        public void setCode(Integer code) {
            this.code = code;
        }

        /*
        * @ Method : setMessage
        * @ Description : 상태 메세지 반환
        */
        public void setMessage(String msg) {
            this.msg = msg;
        }

        /*
        * @ Method : setError
        * @ Description : 에레 정보 반환
        */
        public void setError(String msg, Integer code) {
            this.status = StatusCode.ERROR;
            this.code = (code == null) ? 400 : code;
            setMessage(msg);
        }

    }

    public class CustomException extends Exception {}
}