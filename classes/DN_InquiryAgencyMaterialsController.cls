/**
 * @author            : iltae.seo
 * @last modified on  : 2025-03-21
 * @last modified by  : iltae.seo
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   2024-12-19   iltae.seo     Initial Version
**/
public without sharing class DN_InquiryAgencyMaterialsController {
    public static List<ProductByPlant__c> replacingPartList = new List<ProductByPlant__c>();
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    
    /**
     * @Description
     * 	- 현재 유저의 AgencyName 반환
    **/ 
    @AuraEnabled
    public static String getCurrentAgency(){
        try {
            System.debug(currentUser.getAgencyName() + ' :: currentUser');
            
            return currentUser.getAgencyName();
        } catch (Exception e) {
            throw new DN_InquiryAgencyMaterialsControllerException(e.getMessage());
        }
    }
    
    
    /**
     * @Description
     * 	- 대리점 자재 종합조회 - 검색
    **/ 
    @AuraEnabled
    public static StockInfo getStock(String productCode){
        StockInfo returnStockInfo = new StockInfo();
        try {
            System.debug(productCode + ' :: productCode');
            System.debug('getStock ::: getStock');
            if(String.isBlank(productCode)) {
                throw new DN_InquiryAgencyMaterialsControllerException('부품 번호를 입력하세요');
            } else {
                List<Product2> prodCheck = [SELECT Id,Name FROM Product2 WHERE ProductCode =:productCode AND RecordType.DeveloperName ='Part'];
                if(prodCheck.size() ==0) {
                    throw new DN_InquiryAgencyMaterialsControllerException('부품 번호가 올바르지 않습니다.');
                }
            }
            
            // DNS 서비스 자재현황 (Multipart)
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res res = getPartSearch(productCode.toUpperCase());
            returnStockInfo.ifRes = res;

            // 최종 대체품 조회
            List<ProductByPlant__c> prodByPlant = 
                [
                    select Id, Plant__c,ReplacingPart__c,Part__c,Part__r.Name,Part__r.ProductCode,ReplacingPart__r.ProductCode
                    from ProductByPlant__c  
                    where ReplacingPart__c !=null 
                    AND Part__r.ProductCode =:productCode
                    AND Plant__c ='1846' limit 1
                ];
            // 대리점 재고 조회
            List<DealerStock__c> dealerStockList = [select Id, CurrentStockQuantity__c,AvailableQuantity__c,DealerLocation__r.FM_Loc__c,BlockQuantity__c,Note__c,WarrantyRequiredQuantity__c,Part__r.ProductCode,
                                                        format(LastImportDateTime__c)LastImportDateTime__c,format(LastExportDateTime__c) LastExportDateTime__c,OrderRequiredQuantity__c,Dealer__r.Name
                                                        from DealerStock__c 
                                                        where Part__r.ProductCode =:productCode
                                                        AND Dealer__c =:currentUser.getAgencyId()];//currentUser.Contact.AccountId
            // 타대리점 재고 조회
            List<DealerStock__c> otherDealerStockList = [select Id, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                                            SystemModstamp, SourceSystem__c, LastExportDateTime__c, LastImportDateTime__c, 
                                                            AvailableQuantity__c, CurrentStockQuantity__c, Part__c, Dealer__c,Dealer__r.Name,
                                                            Division__c, DistributionChannel__c, SalesOrganization__c, DealerLocation__c, 
                                                            OrderRequiredQuantity__c, WarrantyRequiredQuantity__c, BlockQuantity__c 
                                                            from DealerStock__c 
                                                            where Part__r.ProductCode =:productCode AND CurrentStockQuantity__c >0
                                                            AND Dealer__c !=:currentUser.getAgencyId() 
                                                            AND Dealer__c IN ( SELECT AccountId FROM User where UserType = 'PowerPartner'  AND Profile.Name ='DNS CS Parts_Partner' AND IsActive =true)
                                                            ];  //currentUser.Contact.AccountId
            // DNS Sales Order 수량
            Decimal dnsPurchaseQTY =0;
            // 1년간 구매 실적
            Decimal dnsGIPerformanceQTY = 0;
            Decimal dealerGIPerformanceQTY = 0;
            List<AggregateResult> salesOrder = 
                [ select 
                    SupplyPartId__c,
                    SUM(Quantity__c) QTY ,SUM(CompletedQty__c) GIQTY
                    from PurchaseOrderItems__c  
                    where PurchaseOrder__r.Buyer__c =:currentUser.getAgencyId()
                    AND SupplyPartId__r.ProductCode=:productCode
                    AND PurchaseOrder__r.CreatedDate = LAST_N_DAYS:365
                    group by SupplyPartId__c
                ];
            if(salesOrder.size() > 0 ) {
                Decimal giQTY = salesOrder[0].get('GIQTY') ==null ? 0 : (Decimal) salesOrder[0].get('GIQTY');
                dnsGIPerformanceQTY = giQTY;
                dnsPurchaseQTY = salesOrder[0].get('QTY') == null ? 0 : (Decimal)salesOrder[0].get('QTY');
                dnsPurchaseQTY = dnsPurchaseQTY - giQTY;
                System.debug(dnsGIPerformanceQTY + ' :":: dnsGIPerformanceQTY');
            }
            returnStockInfo.performance.dnsPurchaseQTY = dnsPurchaseQTY;
            // 타대리점 구매 수량
            //구매 요청 수량
            Decimal purQty = 0;
            Decimal giQty = 0;
            List<AggregateResult> purchaseOrderQty = 
                [ select 
                    Part__c, 
                    SUM(Quantity__c) QTY
                    from DealerPurchaseOrderItem__c 
                    where Delete__c ='N' 
                    AND CreatedDate = LAST_N_DAYS:365
                    AND DealerPurchaseOrder__r.Dealer__c =:currentUser.getAgencyId() 
                    AND Part__r.ProductCode =:productCode
                    group by Part__c 
                ];
            if(purchaseOrderQty.size() > 0) {
                purQty = (Decimal) purchaseOrderQty[0].get('QTY');
                returnStockInfo.performance.otherDealerPurchaseQTY = purQty;
            }
            //타 대리점 출고 수량
            List<AggregateResult> purchaseOrderGIQty = 
                [ select 
                    Part__c, 
                    SUM(GICompletedQuantity__c) GIQTY
                    from DealerPurchaseOrderItem__c 
                    where Delete__c ='N' 
                    AND CreatedDate = LAST_N_DAYS:365
                    AND DealerPurchaseOrder__r.Dealer__c =:currentUser.getAgencyId() 
                    AND Part__r.ProductCode =:productCode
                    group by Part__c 
                ];
            if(purchaseOrderGIQty.size() > 0) {
                giQty = (Decimal) purchaseOrderGIQty[0].get('GIQTY');
                System.debug(purchaseOrderGIQty + ' :::purchaseOrderGIQty');
                System.debug(purQty + ' :::purQty');
                System.debug(giQty + ' :::giQty');
                returnStockInfo.performance.otherDealerPurchaseQTY = purQty == 0? giQty : (purQty - giQty);
            }

            // 총 출고 실적
            List<AggregateResult> totalGIQTY = 
                [ select 
                    Part__c, 
                    SUM(Quantity__c) QTY
                    from DealerInventoryMovements__c 
                    where RecordType.DeveloperName ='GoodsIssue' 
                    AND InventoryChange__c ='H' 
                    AND Dealer__c =:currentUser.getAgencyId()
                    AND Part__r.ProductCode =:productCode
                    group by Part__c
                ];
            if(totalGIQTY.size() > 0) {
                returnStockInfo.performance.totalPerformance = (Decimal)totalGIQTY[0].get('QTY');
            }

            
            // 타 대리점 출고 수량
            List<AggregateResult> dealerGIPerformance = 
                [ select 
                    Part__c,  
                    SUM(Quantity__c) QTY
                    from DealerInventoryMovements__c 
                    where RecordType.DeveloperName ='GoodsIssue' 
                    AND DealerPurchaseOrderItem__c  !=null 
                    AND InventoryChange__c ='H' 
                    AND Part__r.ProductCode =:productCode
                    AND CreatedDate = LAST_N_DAYS:365
                    group by Part__c
                ];
            if(dealerGIPerformance.size() > 0) {
                dealerGIPerformanceQTY = (Decimal) dealerGIPerformance[0].get('QTY');
            }
            returnStockInfo.performance.yearPurchasePerformance = dnsGIPerformanceQTY +dealerGIPerformanceQTY;
            
            //1년간 출고 실적
            List<AggregateResult> yearTotalGIQTY = 
                [ select 
                    Part__c, 
                    SUM(Quantity__c) QTY
                    from DealerInventoryMovements__c 
                    where RecordType.DeveloperName ='GoodsIssue' 
                    AND InventoryChange__c ='H' 
                    AND Dealer__c =:currentUser.getAgencyId()
                    AND Part__r.ProductCode =:productCode
                    AND CreatedDate = LAST_N_DAYS:365
                    group by Part__c
                ];
            if(yearTotalGIQTY.size() > 0) {
                returnStockInfo.performance.yearGoodsIsPerformance = (Decimal)yearTotalGIQTY[0].get('QTY');
            }
            
            // MPPS 여부
            List<DealerPartMasterByMPPS__c> mppsList = 
            [ select Id 
                from DealerPartMasterByMPPS__c 
                where Part__r.ProductCode=:productCode
            ];
            if(mppsList.size() >0) {
                returnStockInfo.isMpps = 'Y';
                //MPPS 데이터
                List<DealerPartMasterByMPPS__c> dealerMppsList = 
                [ select Id, 
                    Plant__c, 
                    AmountGrade__c, 
                    FrequencyGrade__c, 
                    ABCIndicator__c, 
                    MRPType__c, 
                    SafetyStock__c, 
                    MaximumStock__c, 
                    ReorderPoint__c, 
                    RoundingValue__c, 
                    MinimumLotSize__c, 
                    FM_Unit__c, 
                    FM_ExtentionDate__c, 
                    TargetServiceLevel__c, 
                    ServiceFactor__c, 
                    AMD__c, 
                    WAMD__c, 
                    STDEV__c,
                    Weight__c, 
                    IsFixedROP__c, 
                    Part__c, 
                    Dealer__c from DealerPartMasterByMPPS__c where Dealer__c =:currentUser.getAgencyId()
                    AND Part__r.ProductCode =:productCode
                ];
                if(dealerMppsList.size()>0) {
                    DealerPartMasterByMPPS__c mpps              = dealerMppsList[0];
                    returnStockInfo.dealerMPPS.mrpType          = mpps.MRPType__c;
                    returnStockInfo.dealerMPPS.amd              = mpps.AMD__c;
                    returnStockInfo.dealerMPPS.abcIndicator     = mpps.ABCIndicator__c;
                    returnStockInfo.dealerMPPS.reOrderPoint     = mpps.ReorderPoint__c;
                    returnStockInfo.dealerMPPS.maximumStock     = mpps.MaximumStock__c;
                    returnStockInfo.dealerMPPS.roundingValue    = mpps.RoundingValue__c;
                    returnStockInfo.dealerMPPS.minimumLotSize   = mpps.MinimumLotSize__c;
                } 
            }
            //타대리점 재고
            if(otherDealerStockList.size() > 0) {
                returnStockInfo.otherDealerStockList    = otherDealerStockList;
            }

            //returnStockInfo.currentUser             = currentUser;
            // 딜러스톡 정보
            if(dealerStockList.size() >0) {
                returnStockInfo.dealerStockInfo         = dealerStockList[0];
                if(prodByPlant.size() > 0) {
                    returnStockInfo.prodByPlant = prodByPlant[0];
                }
                return returnStockInfo;
            } else {
                return returnStockInfo;
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' < ==e.getMessage()');
            System.debug(e.getLineNumber() + ' < ==e.getLineNumber()');
            System.debug(e.getStackTraceString() + ' < ==e.getStackTraceString()');
            throw new DN_InquiryAgencyMaterialsControllerException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- 대리점 자재 종합조회 - 저장
    **/ 
    @AuraEnabled
    public static DealerStock__c stockSave(DealerStock__c stock){
        try {
            System.debug(stock + ' < ==stock');
            if(stock.CurrentStockQuantity__c <stock.BlockQuantity__c) {
                throw new AuraHandledException('Block수량은 창고재고 수량보다 많이 입력할 수 없습니다.');
            }
            Decimal available = DN_DealerStockManager.getAvailable(stock);
            stock.AvailableQuantity__c = available;
            
            update stock; //OrderRequiredQuantity__c,WarrantyRequiredQuantity__c
            DealerStock__c currentStock = [select CurrentStockQuantity__c,AvailableQuantity__c,DealerLocation__r.FM_Loc__c,BlockQuantity__c,Note__c,WarrantyRequiredQuantity__c,Part__c, Part__r.ProductCode,
                                                format(LastImportDateTime__c)LastImportDateTime__c,format(LastExportDateTime__c) LastExportDateTime__c,OrderRequiredQuantity__c,Dealer__r.Name
                                                from DealerStock__c
                                                where Id=:stock.Id];//currentUser.Contact.AccountId]
            return currentStock;
        } catch (Exception e) {
            throw new DN_InquiryAgencyMaterialsControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 대체품 조회
    **/ 
    @AuraEnabled
    public static IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res replacingPart(String productCode){
        try {
            System.debug(productCode + ' :::: productCode');
            List<Product2> prodCheck = [SELECT Id,Name FROM Product2 WHERE ProductCode =:productCode AND RecordType.DeveloperName ='Part'];
            if(prodCheck.size() ==0) {
                throw new DN_InquiryAgencyMaterialsControllerException('부품 번호가 올바르지 않습니다.');
            }
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO i_userinfo = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req_I_USERINFO();
            i_userinfo.KUNNR = currentUser.getAgencyCustomerCode();
            i_userinfo.VKORG = currentUser.getSalesOranization();
            i_userinfo.VTWEG = currentUser.getDistributionChannel();
            i_userinfo.SPART = currentUser.getDivision();
        
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req req = new IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Req();

            req.I_MATNR = productCode.toUpperCase();
            req.I_LANGU = currentUser.getLanguageLocaleKey().subString(0,2);//user.LanguageLocaleKey;
            //req.I_REPLACE = 'X'; //??? 

            req.I_USERINFO = i_userinfo;
            Map<String,String> getStockQTYMap = new Map<String,String>();
            IF_ERP_Service_PartsDetail method = new IF_ERP_Service_PartsDetail();
            IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res result = method.IF_SERVICE_037(req);
            System.debug(result.ET_CROSS + ' ::::result.ET_CROSS');
            for(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS cross : result.ET_CROSS) {
                getStockQTYMap.put(cross.MATNR, '0');
            }
            List<DealerStock__c> stockList = [
                select Id, Name, 
                Part__r.productCode,
                Part__c, 
                CurrentStockQuantity__c 
                from DealerStock__c 
                where Part__r.productCode IN :getStockQTYMap.keySet()
                AND Dealer__c =:currentUser.getAgencyId()
            ];
            //재고정보 매핑
            for(DealerStock__c stock : stockList) {
                getStockQTYMap.put(stock.Part__r.productCode, String.valueOf(stock.CurrentStockQuantity__c));
            }
            // CRM 재고정보로 변경
            for(IF_ERP_Service_PartsDetail_Classes.IF_SERVICE_037_Res_ET_CROSS crossSet : result.ET_CROSS) {
                crossSet.LABST = getStockQTYMap.get(crossSet.MATNR);
            }
            
            return result;
        } catch (Exception e) {
            throw new DN_InquiryAgencyMaterialsControllerException(e.getMessage());
        }
    }


    /**
     * @Description
     * 	- MPPS 확장
    **/ 
    @AuraEnabled
    public static void insertMpps(String productCode){
        try {
            System.debug(productCode + ' ::: productCode');
            if(String.isBlank(productCode)) {
                throw new DN_InquiryAgencyMaterialsControllerException('부품 번호를 입력하세요');
            }
            // MPPS 여부
            List<DealerPartMasterByMPPS__c> mppsList = 
            [ select Id 
                from DealerPartMasterByMPPS__c 
                where Part__r.ProductCode=:productCode
            ];
            System.debug(mppsList + ' ::: mppsList');
            if(mppsList.size() > 0 ) {
                throw new DN_InquiryAgencyMaterialsControllerException('이미 확장되어있습니다.');
            }
            List<Product2> productList = [select Id,Name,CurrencyIsoCode,ProductCode from Product2 where ProductCode =:productCode AND RecordType.DeveloperName ='Part' ];
            Product2 product = new Product2();
            if(productList.size() ==0) {
                throw new DN_InquiryAgencyMaterialsControllerException('부품 번호가 올바르지 않습니다.');
            } else {
                product = [select Id,Name,CurrencyIsoCode,ProductCode from Product2 where ProductCode =:productCode LIMIT 1];
            }
            
            User currentUser = [select Id,Name,Plant__c,Account.Name,AccountId, Contact.AccountId,Contact.Account.Name from User where Id=:UserInfo.getUserId()];
            List<AreaPartMasterByMPPS__c> areaMppsList = new List<AreaPartMasterByMPPS__c>();
            List<DealerPartMasterByMPPS__c> dealerMppsList = new List<DealerPartMasterByMPPS__c>();
            //AreaByMPPS__c 지역별,
            List<AreaByMPPS__c> areaByMPPSList = [select Id, Name, Area__c from AreaByMPPS__c];
            System.debug(areaByMPPSList + ' ::::areaByMPPSList');
            //DealerAreaByMPPS__c, 대리점별 - 
            List<DealerAreaByMPPS__c> dealerByMppsList = [select Id, Dealer__c,Dealer__r.CustomerCode__c, Area__c from DealerAreaByMPPS__c];
            System.debug( dealerByMppsList + ' :::: dealerByMppsList');
            for(DealerAreaByMPPS__c dealer: dealerByMppsList) {
                DealerPartMasterByMPPS__c dealerMpps = new DealerPartMasterByMPPS__c();
                dealerMpps.Plant__c = '1846';
                dealerMpps.Part__c = product.Id;
                dealerMpps.Dealer__c = dealer.Dealer__c;
                dealerMpps.MRPType__c ='ND';
                dealerMpps.RoundingValue__c = 1;
                dealerMpps.MinimumLotSize__c = 1;
                dealerMpps.ExternalKey__c = product.ProductCode +'_'+dealer.Dealer__r.CustomerCode__c;
                dealerMpps.CurrencyIsoCode = product.CurrencyIsoCode;
                dealerMppsList.add(dealerMpps);
            }
            System.debug(dealerMppsList + ' ::: dealerMppsLIst');
            insert dealerMppsList;
            //지역별 MPPS 생성
            for(AreaByMPPS__c area : areaByMPPSList) {
                AreaPartMasterByMPPS__c areaMpps = new AreaPartMasterByMPPS__c();
                areaMpps.Plant__c = '1846';
                areaMpps.Area__c = area.Id;
                areaMpps.Part__c = product.Id;
                areaMpps.CurrencyIsoCode = product.CurrencyIsoCode;
                areaMpps.MRPType__c ='ND';
                areaMpps.RoundingValue__c = 1;
                areaMpps.MinimumLotSize__c = 1;
                areaMpps.ExternalKey__c = product.ProductCode+'_'+area.Area__c;
                areaMppsList.add(areaMpps);
            }
            System.debug(areaMppsList + ' ::: areaMppsList');
            insert areaMppsList; 
        } catch (Exception e) {
            System.debug('Emsg :: '+e.getMessage());
            System.debug('Line :: '+e.getLineNumber());
            System.debug('Stack :: '+e.getStackTraceString());
            throw new DN_InquiryAgencyMaterialsControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 멀티 부품 파츠 조회 - 대리점 자재 종합 조회 시 인터페이스 데이터
    **/ 
    public static IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res getPartSearch(String partCode) {
        try {
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req req = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req();
            req.I_LANGU = 'en';//currentUser.getLanguageLocaleKey().subString(0,2);//user.LanguageLocaleKey;
            List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL> D_DETAIL_List = new List<IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL>();
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL D_DETAIL = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_D_DETAIL();
            D_DETAIL.MATNR = partCode;
            D_DETAIL_List.add(D_DETAIL);
            req.D_DETAIL = D_DETAIL_List;
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO I_USERINFO = new IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Req_I_USERINFO();
            I_USERINFO.KUNNR        = currentUser.getAgencyCustomerCode();
            I_USERINFO.VKORG        = currentUser.getSalesOranization();
            I_USERINFO.VTWEG        = currentUser.getDistributionChannel();
            I_USERINFO.SPART        = currentUser.getDivision();
            I_USERINFO.LAND1        = 'en';//currentUser.getLanguageLocaleKey().subString(0,2);//currentUser.getLanguageLocaleKey(); //user.get('Country__c') ==null ? 'KR' : user.Country__c;
            I_USERINFO.DF_CHK       = 'X';
            req.I_USERINFO        = I_USERINFO;

            IF_ERP_Parts_Multipart instance = new IF_ERP_Parts_Multipart();
            IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res result = instance.IF_PARTS_022(req);

            return result;
        } catch (Exception e) {
            System.debug('Emsg :: '+e.getMessage());
            System.debug('Line :: '+e.getLineNumber());
            System.debug('Stack :: '+e.getStackTraceString());
            throw new DN_InquiryAgencyMaterialsControllerException(e.getMessage());
        } 
    }

    /**
     * @Description
     * 	- StockInfo 클래스
    **/
    public class StockInfo {
        @AuraEnabled public DealerStock__c dealerStockInfo {get;set;}
        @AuraEnabled public List<DealerStock__c> otherDealerStockList {get;set;}
        @AuraEnabled public ProductByPlant__c prodByPlant {get;set;}
        @AuraEnabled public Performance performance {get;set;}
        @AuraEnabled public IF_ERP_Parts_Multipart_Classes.IF_PARTS_022_Res ifRes {get;set;}
        @AuraEnabled public String isMpps {get;set;}
        @AuraEnabled public MPPS dealerMPPS {get;set;}

        /**
         * @Description
         * 	- StockInfo 초기값 설정
        **/
        public StockInfo() {
            this.dealerStockInfo = new DealerStock__c();
            this.otherDealerStockList = new List<DealerStock__c>();
            this.prodByPlant = new ProductByPlant__c();
            this.performance = new Performance();
            this.isMpps = 'N';
            this.dealerMPPS = new MPPS();
        }
    }

    /**
     * @Description
     * 	- MPPS 클래스
    **/
    public class MPPS {
        @AuraEnabled public String mrpType {get;set;} // MRP Type
        @AuraEnabled public Decimal amd {get;set;} // MRP Type
        @AuraEnabled public String abcIndicator {get;set;} // ABCIndicator
        @AuraEnabled public Decimal reOrderPoint {get;set;} // ReorderPoint__c
        @AuraEnabled public Decimal maximumStock {get;set;} // MaximumStock__c
        @AuraEnabled public Decimal roundingValue {get;set;} // RoundingValue__c
        @AuraEnabled public Decimal minimumLotSize {get;set;} // MinimumLotSize__c
        /**
         * @Description
         * 	- MPPS 초기값 설정
        **/
        public MPPS() {
            this.mrpType        = '';
            this.amd            = 0;
            this.abcIndicator   = '';
            this.reOrderPoint   = 0;
            this.maximumStock   = 0;
            this.roundingValue  = 0;
            this.minimumLotSize = 0;
        }
    }

    /**
     * @Description
     * 	- DNS, 출고 등등
    **/
    public class Performance {
        @AuraEnabled public Decimal dnsPurchaseQTY {get;set;} // DNS 구매수량
        @AuraEnabled public Decimal otherDealerPurchaseQTY {get;set;} // 타대리점 구매수량
        @AuraEnabled public Decimal totalPerformance {get;set;} // 총 출고 실적
        @AuraEnabled public Decimal yearPurchasePerformance {get;set;} // 1년간 구매 실적
        @AuraEnabled public Decimal yearGoodsIsPerformance {get;set;} // 1년간 출고 실적

        /**
         * @Description
         * 	- 초기값 설정
        **/
        public Performance() {
            this.dnsPurchaseQTY = 0;
            this.otherDealerPurchaseQTY = 0;
            this.totalPerformance = 0;
            this.yearPurchasePerformance = 0;
            this.yearGoodsIsPerformance = 0;
        }
    }
    


    public class DN_InquiryAgencyMaterialsControllerException extends Exception {}
}