/** 
 * @Class : DN_DealerStockManager
 * 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2024. 12. 30. 
 * @Version : 1.0 
 * @Modified :  
 * @Description : 대리점 재고 관리의 재고의 계산 및 입고,출고 계산식
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-28 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_DealerStockManager {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    public DN_DealerStockManager() {}


    /**
     * @Description
     * 	- 특정 대리점의 재고
    **/ 
    public static Map<String,DealerStock__c> getAvailableStockMap(String agencyId, String salesOranization, String distributionChannel, String division, Set<String> partIdList) {
        //품목별 재고 변환
        Map<String, DealerStock__c> stockMap = new Map<String, DealerStock__c>();
        for(DealerStock__c dealerStock :[
            SELECT
                Id
                , LastExportDateTime__c
                , LastImportDateTime__c
                , AvailableQuantity__c
                , CurrentStockQuantity__c
                , Part__c
                , Part__r.Name
                , Dealer__c
                , Dealer__r.CustomerCode__c
                , Division__c
                , DistributionChannel__c
                , SalesOrganization__c
                , DealerLocation__c
                , OrderRequiredQuantity__c
                , WarrantyRequiredQuantity__c
                , BlockQuantity__c
                , Note__c
                , FM_Unit__c
                , ExternalKey__c
                , DealerLocation__r.FM_Loc__c
            FROM DealerStock__c
            WHERE Dealer__c = :agencyId AND Part__c IN :partIdList
            AND SalesOrganization__c = :salesOranization
            AND DistributionChannel__c = :distributionChannel
            AND Division__c = :division
            FOR UPDATE
        ]) {
            stockMap.put(dealerStock.Part__c, dealerStock);
        }

        return stockMap;
    }

    /**
     * @Description
     * 	- 여러 대리점 품목별 재고 반환
    **/ 
    public static Map<String, DealerStock__c> getAvailableStockMapMutipleForCode(Set<String> agencyCodeList, String salesOranization, String distributionChannel, String division, Set<String> partCodeList) {
        Map<String, DealerStock__c> dealerStockMap = new Map<String, DealerStock__c>();
        Set<String> agencyCodeSinglQuoteSet = new Set<String>();
        
        if(agencyCodeList != null) {
            for(String agencyCode  : agencyCodeList) {
                agencyCodeSinglQuoteSet.add('\''+agencyCode+'\'');
            }
        }

        Set<String> partCodeSinglQuoteSet = new Set<String>();
        for(String partCode  : partCodeList) {
            partCodeSinglQuoteSet.add('\''+partCode+'\'');
        }

        AllAccessRecord allAccess = new AllAccessRecord();
        String query = ' SELECT '
        +'         Id '
        +'         , LastExportDateTime__c '
        +'         , LastImportDateTime__c '
        +'         , AvailableQuantity__c '
        +'         , CurrentStockQuantity__c '
        +'         , Part__c '
        +'         , Part__r.Name '
        +'         , Part__r.ProductCode '
        +'         , Part__r.FM_MaterialDetails__c '
        +'         , Part__r.Unit__c '
        +'         , Dealer__c '
        +'         , Dealer__r.CustomerCode__c '
        +'         , Dealer__r.DealerGrade__c '
        +'         , Dealer__r.DealerGrade_Parts__c '
        +'         , Division__c '
        +'         , DistributionChannel__c '
        +'         , SalesOrganization__c '
        +'         , DealerLocation__c '
        +'         , OrderRequiredQuantity__c '
        +'         , WarrantyRequiredQuantity__c '
        +'         , BlockQuantity__c '
        +'         , Note__c '
        +'         , FM_Unit__c '
        +'         , ExternalKey__c '
        +'         , DealerLocation__r.FM_Loc__c '
        +'     FROM DealerStock__c '
        +'     WHERE Id != null '
        +'     AND Part__r.ProductCode IN ('+  String.join(partCodeSinglQuoteSet, ',') +')' 
        +'     AND SalesOrganization__c = \''+salesOranization +'\''
        +'     AND DistributionChannel__c = \''+distributionChannel +'\''
        +'     AND Division__c = \''+division+'\'';
        if(agencyCodeSinglQuoteSet.size() > 0 ) query += ' AND Dealer__c != null  AND Dealer__r.CustomerCode__c IN  ('+  String.join(agencyCodeSinglQuoteSet, ',') +')';

        query += '     FOR UPDATE ';
        for(DealerStock__c dealerStock : (List<DealerStock__c>) allAccess.query(query)) {
            String key = dealerStock.Part__r.ProductCode +'_'+ dealerStock.Dealer__r.CustomerCode__c;

            dealerStockMap.put(key, dealerStock);
        }

        return dealerStockMap;
    }

    /**
     * @Description
     * 	- 여러 대리점 품목별 재고 반환
    **/ 
    public static Map<String, Map<String, DealerStock__c>> getAvailableStockMapMutiple(Set<String> agencyIdList, String salesOranization, String distributionChannel, String division, Set<String> partIdList) {
        //여러 대리점 품목별 재고 변환
        Map<String, Map<String, DealerStock__c>> dealerStockMap = new Map<String, Map<String, DealerStock__c>>();
        Set<String> agencyIdSinglQuoteSet = new Set<String>();
        
        if(agencyIdList != null) {
            for(String agencyId  : agencyIdList) {
                agencyIdSinglQuoteSet.add('\''+agencyId+'\'');
            }
        }

        Set<String> partIdSinglQuoteSet = new Set<String>();
        for(String partId  : partIdList) {
            partIdSinglQuoteSet.add('\''+partId+'\'');
        }

        AllAccessRecord allAccess = new AllAccessRecord();
        String query = ' SELECT '
        +'         Id '
        +'         , LastExportDateTime__c '
        +'         , LastImportDateTime__c '
        +'         , AvailableQuantity__c '
        +'         , CurrentStockQuantity__c '
        +'         , Part__c '
        +'         , Part__r.Name '
        +'         , Dealer__c '
        +'         , Dealer__r.CustomerCode__c '
        +'         , Dealer__r.DealerGrade__c '
        +'         , Dealer__r.DealerGrade_Parts__c '
        +'         , Division__c '
        +'         , DistributionChannel__c '
        +'         , SalesOrganization__c '
        +'         , DealerLocation__c '
        +'         , OrderRequiredQuantity__c '
        +'         , WarrantyRequiredQuantity__c '
        +'         , BlockQuantity__c '
        +'         , Note__c '
        +'         , FM_Unit__c '
        +'         , ExternalKey__c '
        +'         , DealerLocation__r.FM_Loc__c '
        +'     FROM DealerStock__c '
        +'     WHERE Id != null '
        +'     AND Part__c IN ('+  String.join(partIdSinglQuoteSet, ',') +')' 
        +'     AND SalesOrganization__c = \''+salesOranization +'\''
        +'     AND DistributionChannel__c = \''+distributionChannel +'\''
        +'     AND Division__c = \''+division+'\'';
        if(agencyIdSinglQuoteSet.size() > 0 ) query += '     AND Dealer__c IN  ('+  String.join(agencyIdSinglQuoteSet, ',') +')';

        query += '     FOR UPDATE ';
        for(DealerStock__c dealerStock : (List<DealerStock__c>) allAccess.query(query)) {
            if(!dealerStockMap.containsKey(dealerStock.Dealer__c)) {
                dealerStockMap.put(dealerStock.Dealer__c, new Map<String, DealerStock__c>());
            }

            dealerStockMap.get(dealerStock.Dealer__c).put(dealerStock.Part__c, dealerStock);
        }

        return dealerStockMap;
    }

    /**
     * @Description
     * 	- 특정 대리점 제외한 재고 조회
    **/ 
    public static Map<String, DealerStock__c> getAvailableStockMapExcludeCurrent(String excludeAgencyId, String salesOranization, String distributionChannel, String division, Set<String> partIdList) {
        //품목별 대리점별 재고 변환
        //Key = partId_dealerId
        Map<String, DealerStock__c> dealerStockMap = new Map<String, DealerStock__c>();

        Set<String> partIdSinglQuoteSet = new Set<String>();
        for(String partId  : partIdList) {
            partIdSinglQuoteSet.add('\''+partId+'\'');
        }

        AllAccessRecord allAccess = new AllAccessRecord();
        String query = ' SELECT '
        +'         Id '
        +'         , LastExportDateTime__c '
        +'         , LastImportDateTime__c '
        +'         , AvailableQuantity__c '
        +'         , CurrentStockQuantity__c '
        +'         , Part__c '
        +'         , Part__r.Name '
        +'         , Part__r.ProductCode '
        +'         , Dealer__c '
        +'         , Dealer__r.CustomerCode__c '
        +'         , Dealer__r.DealerGrade__c '
        +'         , Dealer__r.DealerGrade_Parts__c '
        +'         , Division__c '
        +'         , DistributionChannel__c '
        +'         , SalesOrganization__c '
        +'         , DealerLocation__c '
        +'         , OrderRequiredQuantity__c '
        +'         , WarrantyRequiredQuantity__c '
        +'         , BlockQuantity__c '
        +'         , Note__c '
        +'         , FM_Unit__c '
        +'         , ExternalKey__c '
        +'         , DealerLocation__r.FM_Loc__c '
        +'     FROM DealerStock__c '
        +'     WHERE Id != null '
        +'     AND AvailableQuantity__c > 0 '
        +'     AND Dealer__c !=  \''+ excludeAgencyId +'\''
        +'     AND Dealer__c IN ( SELECT AccountId FROM User where UserType = \'PowerPartner\'  and Profile.Name = \'DNS CS Parts_Partner\' AND IsActive = true ) '
        +'     AND Part__c IN ('+  String.join(partIdSinglQuoteSet, ',') +')' 
        +'     AND SalesOrganization__c = \''+salesOranization +'\''
        +'     AND DistributionChannel__c = \''+distributionChannel +'\''
        +'     AND Division__c = \''+division+'\'';
        // +'     FOR UPDATE ';

        System.debug('getAvailableStockMapExcludeCurrent query :: ');
        System.debug(query);
        for(DealerStock__c dealerStock : (List<DealerStock__c>) allAccess.query(query)) {
            String key = dealerStock.Part__c+'_'+dealerStock.Dealer__c;
            dealerStockMap.put(key, dealerStock);
        }

        return dealerStockMap;
    }

    /**
     * @Description
     * 	- 가용재고 계산식에 맞게 계산하여 반환
    **/ 
    public static Decimal getAvailableStock(DealerStock__c stock) {
        Decimal availbleQty = stock.CurrentStockQuantity__c - stock.OrderRequiredQuantity__c - stock.WarrantyRequiredQuantity__c - stock.BlockQuantity__c;
        return availbleQty;
    }


    /**
     * @Description
     * 	- 대리점 재고 관리 - 가용재고 (대리점 자재 종합조회에서 사용)
    **/ 
    public static Decimal getAvailable(DealerStock__c stock) {
        // 기존 가용재고 불러오기
        DealerStock__c forupdateStock = [select Id, Name, CurrencyIsoCode, SourceSystem__c, LastExportDateTime__c, LastImportDateTime__c, 
                                            AvailableQuantity__c, CurrentStockQuantity__c, Part__c, Dealer__c,Dealer__r.Name,
                                            Division__c, DistributionChannel__c, SalesOrganization__c, DealerLocation__c, 
                                            OrderRequiredQuantity__c, WarrantyRequiredQuantity__c, BlockQuantity__c from DealerStock__c where Id=:stock.Id FOR UPDATE];
        Decimal availbleQty = forupdateStock.CurrentStockQuantity__c - forupdateStock.OrderRequiredQuantity__c - forupdateStock.WarrantyRequiredQuantity__c - stock.BlockQuantity__c;
        return availbleQty;
    }

    /**
     * @Description
     * 	- 대리점 재고 관리 - 입고 출고에 따른 가용재고 설정,가용재고 업데이트처리
    **/ 
    public static List<DealerStock__c> getAvailable(Map<String,Decimal> gRMap, String type, String dealerCode) {
        System.debug(gRMap + ' <==gRMap');
        List<DealerStock__c> insertStockList = new List<DealerStock__c>();
        Map<String,Product2> productMap = new Map<String,Product2>();
        Map<String,DealerStock__c> sotckMap = new Map<String,DealerStock__c>();
        
        
        List<Product2> productList = [select Id, Unit__c,ProductCode from Product2 where Id IN:gRMap.keySet()];
        for(Product2 prod : productList) {
            productMap.put(prod.Id,prod);
        }
        List<DealerStock__c> stockList = [select Id, Name, CurrencyIsoCode, SourceSystem__c, LastExportDateTime__c, LastImportDateTime__c, 
                                            AvailableQuantity__c, CurrentStockQuantity__c, Part__c, Dealer__c,Dealer__r.Name,
                                            Division__c, DistributionChannel__c, SalesOrganization__c, DealerLocation__c, ExternalKey__c,
                                            OrderRequiredQuantity__c, WarrantyRequiredQuantity__c, BlockQuantity__c from DealerStock__c where Part__c IN: gRMap.keySet() AND Dealer__c=:currentUser.getAgencyId() FOR UPDATE];
        for(DealerStock__c currentStock : stockList) {
            sotckMap.put(currentStock.Part__c, currentStock);
        }
        
        for(String partId : gRMap.keySet()) {
            Decimal currentStockQty = sotckMap.get(partId) ==null ? 0 : sotckMap.get(partId).CurrentStockQuantity__c;
            Decimal availableQty = sotckMap.get(partId) ==null ? 0 : sotckMap.get(partId).AvailableQuantity__c;
            Decimal orderRequiredQuantity = sotckMap.get(partId) ==null ? 0 : sotckMap.get(partId).OrderRequiredQuantity__c;
            Decimal warrantyRequiredQuantity = sotckMap.get(partId) ==null ? 0 : sotckMap.get(partId).WarrantyRequiredQuantity__c;
            Decimal blockQuantity = sotckMap.get(partId) ==null ? 0 : sotckMap.get(partId).BlockQuantity__c;

            DealerStock__c stock = new DealerStock__c();
            System.debug(partId + ' ::: partId');
            Product2 prodt = productMap.get(partId);
            System.debug(prodt + ' :: prodt');
            switch on type { //OtherGI
                when 'GR' {
                    stock.LastImportDateTime__c = DateTime.now();
                    stock.CurrentStockQuantity__c = gRMap.get(partId) + currentStockQty;
                    stock.AvailableQuantity__c = stock.CurrentStockQuantity__c - orderRequiredQuantity - warrantyRequiredQuantity - blockQuantity;
                }
                when 'GI' {
                    stock.LastExportDateTime__c = DateTime.now();
                    stock.CurrentStockQuantity__c = (gRMap.get(partId) + currentStockQty);
                    stock.OrderRequiredQuantity__c = orderRequiredQuantity + gRMap.get(partId); 
                    stock.AvailableQuantity__c = stock.CurrentStockQuantity__c - stock.OrderRequiredQuantity__c - warrantyRequiredQuantity - blockQuantity;

                }
                when 'OtherGI' {
                    stock.LastExportDateTime__c = DateTime.now();
                    stock.CurrentStockQuantity__c = (gRMap.get(partId) + currentStockQty);
                    stock.AvailableQuantity__c = stock.CurrentStockQuantity__c - orderRequiredQuantity - warrantyRequiredQuantity - blockQuantity;
                }
                when 'GICancel' {
                    stock.LastImportDateTime__c = DateTime.now();
                    stock.CurrentStockQuantity__c = (gRMap.get(partId) + currentStockQty);
                    stock.AvailableQuantity__c = stock.CurrentStockQuantity__c - orderRequiredQuantity - warrantyRequiredQuantity - blockQuantity;
                }
                when 'GIWaiting' {

                }
                when else {
                    stock.OrderRequiredQuantity__c = gRMap.get(partId) + orderRequiredQuantity;
                    stock.AvailableQuantity__c = currentStockQty - stock.OrderRequiredQuantity__c - warrantyRequiredQuantity - blockQuantity;
                }
            } 
            stock.Part__c = partId;
            stock.Dealer__c = currentUser.getAgencyId();
            stock.Division__c = currentUser.getDivision();
            stock.DistributionChannel__c = currentUser.getDistributionChannel();
            stock.SalesOrganization__c = currentUser.getSalesOranization();
            stock.ExternalKey__c = currentUser.getSalesOranization()+'-'+currentUser.getDistributionChannel()+'-'+currentUser.getDivision()+'-'+currentUser.getAgencyCustomerCode()+'-'+prodt.ProductCode;
            insertStockList.add(stock);   
        }
        System.debug(insertStockList +  ' ::: insertStockList');
        upsert insertStockList ExternalKey__c;
        return insertStockList;
    }

    /**
     * @Description
     * 	- 대리점 재고 관리 - 입고 생성 시 discountAmount(입고 금액) 
    **/ 
    public static Decimal getDiscountAmount(Decimal discountPrice, Decimal quantity) { 
        return (discountPrice * quantity);
    }


    /**
     * @Description
     * 	- without이 필요한 경우 해당 메소드 사용
    **/ 
    public without sharing class AllAccessRecord {
        public List<SObject> query(String query) {
            return Database.query(query);
        }
    }

    /**
     * @Description
     * 	- 멀티 부품 파츠 조회 
    **/ 
    public static IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res getPartSearch(set<String> partCode) {
        //try {
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req req = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();
            req.I_LANGU = currentUser.getLanguageLocaleKey().subString(0,2);//user.LanguageLocaleKey;
            List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL> D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>(); 
            for(String part : partCode) {
                IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
                D_DETAIL.MATNR = part;
                D_DETAIL_List.add(D_DETAIL);
            }
            req.D_DETAIL = D_DETAIL_List;
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
            I_USERINFO.KUNNR        = currentUser.getAgencyCustomerCode();
            I_USERINFO.VKORG        = currentUser.getSalesOranization();
            I_USERINFO.VTWEG        = currentUser.getDistributionChannel();
            I_USERINFO.SPART        = currentUser.getDivision();
            I_USERINFO.LAND1        = currentUser.getLanguageLocaleKey().subString(0,2);//currentUser.getLanguageLocaleKey(); //user.get('Country__c') ==null ? 'KR' : user.Country__c;
            I_USERINFO.DF_CHK       = 'X';
            req.I_USERINFO        = I_USERINFO;

            IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res result = instance.IF_PARTS_022(req);

            return result;
      
    }

    /**
    *  SFDC interface Id   : IF-DEALERSTOCK-011
     * New I/F              : ZCRM_EP_SAFETY_STOCK_ADD
     * Description          : 기타입고
    * @author iltae.seo | 2025-02-07 
    * @param  set<String> partIds
    * @return IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res
    **/
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res  dealerStock011(set<String> partIds) {        
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req();
        req.I_USERINFO              = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req_I_USERINFO();
        //req.I_USERINFO.HIER         = 'A';
        req.I_USERINFO.KUNNR        = currentUser.getAgencyCustomerCode();
        req.I_USERINFO.VKORG        = currentUser.getSalesOranization();
        req.I_USERINFO.VTWEG        = currentUser.getDistributionChannel();
        req.I_USERINFO.SPART        = currentUser.getDivision();
        req.I_USERINFO.LAND1        = currentUser.getLanguageLocaleKey().subString(0,2);
        req.I_USERINFO.DF_CHK       = 'X';
        req.IT_MAT = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req_IT_MAT>{};
        for(String part : partIds) {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req_IT_MAT IT_MAT1 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Req_IT_MAT();
            IT_MAT1.MATNR               = part;
            req.IT_MAT.add(IT_MAT1);
        }
        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res res = instance.IF_DEALERSTOCK_011(req);
        return res;
    }

    /**
    *  SFDC interface Id   : IF-DEALERSTOCK-012
     * New I/F              : ZCRM_EP_SAFETY_STOCK_ADD2
     * Description          : 기타출고
    * @author iltae.seo | 2025-02-07 
    * @param  set<String> partIds
    * @return IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res
    **/
    public static IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res  dealerStock012(set<String> partIds) {
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req();
        req.I_USERINFO              = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req_I_USERINFO();
        //req.I_USERINFO.HIER         = 'A';
        req.I_USERINFO.KUNNR        = currentUser.getAgencyCustomerCode();
        req.I_USERINFO.VKORG        = currentUser.getSalesOranization();
        req.I_USERINFO.VTWEG        = currentUser.getDistributionChannel();
        req.I_USERINFO.SPART        = currentUser.getDivision();
        req.I_USERINFO.LAND1        = currentUser.getLanguageLocaleKey().subString(0,2);
        req.I_USERINFO.DF_CHK       = 'X';
        req.IT_MAT = new List<IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req_IT_MAT>{};
        for(String part : partIds) {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req_IT_MAT IT_MAT1 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Req_IT_MAT();
            IT_MAT1.MATNR               = part;
            req.IT_MAT.add(IT_MAT1);
        }

        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res res = instance.IF_DEALERSTOCK_012(req);
        return res;
    }

    /**
     * @Description
     * 	- 중복데이터 체크
    **/ 
    public static Map<String,Object> duplicationCheck(String query, String dmlQuery) {
        List<sObject> dmlList = Database.query(dmlQuery);
        System.debug(query + ' :: query');
        List<AggregateResult> sObjectList = Database.query(query);
        Map<String,Object> isCheckMap = new Map<String,Object>();
        isCheckMap.put('isCheck',false);
        for(AggregateResult inven : sObjectList) {
            System.debug(inven + ' ::: inven');
            Decimal qty = (Decimal)inven.get('QTY');
            Decimal orderQTY = (Decimal)inven.get('orderQTY');
            Decimal giQTY = (Decimal)inven.get('GIQTY');
            //if((qty+giQTY) > orderQTY) {
            if(qty == giQTY) {
                isCheckMap.put('isCheck',true);
                isCheckMap.put('orders',inven);
            } 
            isCheckMap.put((String)isCheckMap.get('Parrent'), inven);
        }
        return isCheckMap;
    }

    /**
    * @description yyyymm변환
    * @author iltae.seo | 2025-02-07 
    * @param  DateTime targetTime
    * @return String YYYYMM
    **/
    public static String getPastMonths(DateTime targetTime, Integer monthsAgo) {
        DateTime pastDate = targetTime.addMonths(monthsAgo);
        return pastDate.format('yyyyMM');
    }

}