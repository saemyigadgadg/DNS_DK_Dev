/** 
 * @Class : DN_SimulationManager
 * 
 * @Test: DN_SimulationManager_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2024. 12. 28. 
 * @Version : 1.0 
 * @Modified :  
 * @Description : 대리점 재고 관리의 견적 및 고객 주문서 생성시 사용되는 Simulation 기능
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-28 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_SimulationManager {
    
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
    * @ Method : DN_SimulationManager
    * @ Description : 고객 주문 생성 및 견적서, 타대리점 구매요청 생성일경우 단건 생성자
    */
    public DN_SimulationManager(Type simulationType, List<String> partCodeList, String agencyId) {
        this.simulationType = simulationType;
        this.partCodeList = partCodeList;
        this.agencyId = agencyId;
    }

    public enum Type {
        QUOTE, CUSTOMERORDER
    }
    private Type simulationType {get;set;}
    private List<String> partCodeList {
        get {
            if(partCodeList == null) partCodeList = new List<String>();
            return partCodeList;
        }
        set;
    }
    private String agencyId     {get; set;} //대리점 AccountId
    public set<String> noPartList {
        get {
            if(noPartList ==null) noPartList = new set<String>();
            return noPartList;
        }
        set;
    } // CRM에서 조회되지 않는 파츠목록

    /*
    * @ Method : singleSimulation
    * @ Description : 단건 시뮬레이션(부품 가격 정보 조회)
    */
    public Map<String,PartDetails> singleSimulation() {
        System.debug(partCodeList + ' :::vpartCodeList');
        Map<String,PartDetails> partDetailMap = new Map<String,PartDetails>();
        
        List<Product2> prodList =[SELECT
                                        Id
                                        , Name
                                        , ProductCode
                                        , FM_MaterialDetails__c
                                        , Unit__c
                                        , ProductSpec__c 
                                        FROM Product2
                                        WHERE ProductCode IN :partCodeList];
        for(Product2 part : prodList) {
            PartDetails supplyPart = new PartDetails(part);
            partDetailMap.put(part.ProductCode, supplyPart);
        }
        List<DealerStock__c> stockList = [select Id,CurrentStockQuantity__c,AvailableQuantity__c,Part__r.ProductCode from DealerStock__c WHERE Dealer__c =:currentUser.getAgencyId() AND Part__r.ProductCode IN :partDetailMap.keySet()];
        for(DealerStock__c stock : stockList) {
            PartDetails pas = partDetailMap.get(stock.Part__r.ProductCode);
            System.debug(pas + ' < ==pas');
            pas.avaiableQuantity = stock.AvailableQuantity__c;
            pas.currentStockQuantity = stock.CurrentStockQuantity__c;
            partDetailMap.put(stock.Part__r.ProductCode, pas);
        }
        System.debug(partDetailMap+'<===partDetailMap');
        return partDetailMap;
    }

    /*
    * @ Method : simulation
    * @ Description : 부품별 가격 정보 조회
    */
    public Map<String, List<PartDetails>> simulation(DN_UserDetails currentUserDetail, Map<String,String> partDealerMap) {
        //입력 품번별 대체품
        Map<String, List<PartDetails>> supplierPartMap = new Map<String, List<PartDetails>>();
        
        //주문용일 경우 가용재고, 판매단위 고객판매가 병합용
        //Key: 대체품 코드
        Map<String, PartDetails> partDetailsMap = new Map<String, PartDetails>();
        

        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res simulationResult = simualtionIf(currentUserDetail, partDealerMap);
        for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res_ET_MAT partInfo : simulationResult.ET_MAT) {
            if(!supplierPartMap.containsKey(partInfo.MATNR))
                supplierPartMap.put(partInfo.MATNR, new List<PartDetails>());

                PartDetails simulationData = new PartDetails();
                simulationData.partName = partInfo.MATNR;
                simulationData.unit = partInfo.KMEIN;
                simulationData.customerPrice = Decimal.valueOf(partInfo.KBETR);
                simulationData.replacingPartName = partInfo.REPNR;
                simulationData.partDetails = simulationData.replacingPartDetails = partInfo.MAKTX;
                String salesUnit = partInfo.KPEIN?.trim();
                simulationData.salesUnit = Decimal.valueOf(salesUnit); // < TODO 문의
                if(simulationData.salesUnit == 0) simulationData.salesUnit = 1;
                supplierPartMap.get(partInfo.MATNR).add(simulationData);

                partDetailsMap.put(partInfo.REPNR, simulationData);
        }

        Set<String> productIds = new Set<String>();
        if(partDetailsMap.size() > 0) {

            // 자재마스터에서 Unit , 품명, Id 가져오기
            Map<String, Product2> productMap = new Map<String, Product2>();
            for(Product2 part : [ 
             SELECT
                Id
                , Name
                , ProductCode
                , FM_MaterialDetails__c
                , Unit__c
                , ProductSpec__c 
              FROM Product2
              WHERE ProductCode IN :partDetailsMap.keySet() AND RecordType.DeveloperName = 'Part'
            ]) {
                productMap.put(part.ProductCode, part);
                productIds.add(part.Id);
            }

            for(PartDetails simulationData : partDetailsMap.values()) {
                if(productMap.containsKey(simulationData.partName)) {
                    simulationData.part = productMap.get(simulationData.partName).Id;
                    simulationData.unit = productMap.get(simulationData.partName).Unit__c;
                }
                if(productMap.containsKey(simulationData.replacingPartName)) {
                    simulationData.replacingPart = productMap.get(simulationData.replacingPartName).Id;
                }
                if(partDealerMap != null && partDealerMap.containsKey(simulationData.partName)) {
                    partDealerMap.put(simulationData.replacingPartName , partDealerMap.get(simulationData.partName));
                }
            }
        }
        System.debug(simulationType + ' :: simulationType');
        if(Type.CUSTOMERORDER == simulationType) {
            //고객 주문일 경우 가용재고
            System.debug('agencyId : '+ agencyId);

            if(partDealerMap != null && partDealerMap.size() > 0) {
                System.debug(JSON.serializePretty(partDealerMap) + ' :: partDealerMap');
                
                //추가
                Map<String, DealerStock__c> delearStockMap = DN_DealerStockManager.getAvailableStockMapMutipleForCode(null, currentUserDetail.getSalesOranization(), currentUserDetail.getDistributionChannel(), currentUserDetail.getDivision(), partDetailsMap.keySet());
                if(delearStockMap.size() > 0) {
                   for(DealerStock__c stockInfo : delearStockMap.values()) {
                        String partCode = stockInfo.Part__r.ProductCode;
                        if(partDetailsMap.containsKey(partCode)) {
                            PartDetails partDetail = partDetailsMap.get(stockInfo.Part__r.ProductCode);
                            partDetail.part = stockInfo.Part__c;
                            partDetail.partDetails = stockInfo.Part__r.FM_MaterialDetails__c;
                            partDetail.unit = stockInfo.Part__r.Unit__c;
                            System.debug('partCode : '+partCode);
                            System.debug(stockInfo.Dealer__r.CustomerCode__c + ' / '+ partDealerMap.get(partCode));
                            if(partDealerMap?.containsKey(partCode) && stockInfo.Dealer__r.CustomerCode__c == partDealerMap.get(partCode)) {
                                partDetail.avaiableQuantity     = stockInfo.AvailableQuantity__c;
                                partDetail.currentStockQuantity = stockInfo.CurrentStockQuantity__c;
                                continue;
                            }
                        }

                   }
                }
            }else {
                for(DealerStock__c stockInfo : [ 
                    SELECT
                        Part__c
                        ,Part__r.Name
                        ,Part__r.ProductCode
                        ,Part__r.Unit__c
                        ,Part__r.FM_MaterialDetails__c
                        ,AvailableQuantity__c       //가용재고
                        ,CurrentStockQuantity__c    //현재고
                        ,OrderRequiredQuantity__c
                        ,WarrantyRequiredQuantity__c
                        ,BlockQuantity__c
                        ,Note__c
                    FROM DealerStock__c
                    WHERE Dealer__c = :agencyId AND Part__r.ProductCode IN :partDetailsMap.keySet()
                ]) {
                    if(partDetailsMap.containsKey(stockInfo.Part__r.ProductCode)) {
                        PartDetails partDetail = partDetailsMap.get(stockInfo.Part__r.ProductCode);
                        partDetail.part = stockInfo.Part__c;
                        partDetail.partDetails = stockInfo.Part__r.FM_MaterialDetails__c;
                        partDetail.unit = stockInfo.Part__r.Unit__c;
                        partDetail.avaiableQuantity = stockInfo.AvailableQuantity__c;
                        partDetail.currentStockQuantity = stockInfo.CurrentStockQuantity__c;
                    }
                }
            }
        }


        for(String key : supplierPartMap.keySet()) {
            List<Integer> removeIdxs = new List<Integer>();
            Integer idx = 0;
            List<PartDetails> supplierParts = supplierPartMap.get(key);
            for(PartDetails supplierPart : supplierPartMap.get(key)) {
                if(String.isBlank(supplierPart.part) ||  String.isBlank(supplierPart.replacingPart)) 
                    removeIdxs.add(idx);
                idx++;
            }
            System.debug('removeIdxs : '+ JSON.serialize(removeIdxs));
            //Product2 마스터에 관리되지 않을 경우 제거
            for(Integer startIdx = removeIdxs.size()-1; startIdx >= 0; startIdx--) {
                supplierParts.remove(removeIdxs.get(startIdx));
            }
        }

        // CRM에 파츠가 없는게 있는경우
        for(String noPart:noPartList) {
            PartDetails partDetails = new PartDetails();
            partDetails.partName = noPart;
            partDetails.unit ='';
            partDetails.replacingPartName = '';
            partDetails.partDetails = '';
            partDetails.salesUnit =0;
            partDetails.avaiableQuantity =0;
            partDetails.currentStockQuantity = 0;
            partDetails.customerPrice = 0;
            partDetails.part = '';
            partDetails.partSpec ='';
            partDetails.replacingPart = '';
            partDetails.replacingPartDetails='';
            partDetails.replacingPartName = '';
            
            supplierPartMap.put(noPart, new List<PartDetails>{partDetails});
        }
        System.debug(supplierPartMap + ' :: supplierPartMap');

        System.debug(JSON.serializePretty(supplierPartMap));
        return supplierPartMap;
    }

    private IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Res simualtionIf(DN_UserDetails currentUser, Map<String,String> partDealerMap) {
        IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req req = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req();

        req.I_USERINFO = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req_I_USERINFO();
        req.I_USERINFO.BNAME        = UserInfo.getUserId();
        req.I_USERINFO.RNAME        = UserInfo.getLastName();
        req.I_USERINFO.HIER         = 'A';
        req.I_USERINFO.KUNNR        = currentUser.getAgencyCustomerCode();
        req.I_USERINFO.VKORG        = currentUser.getSalesOranization();
        req.I_USERINFO.VTWEG        = currentUser.getDistributionChannel();
        req.I_USERINFO.SPART        = currentUser.getDivision();
        req.I_USERINFO.LAND1        = 'KR';
        // req.I_USERINFO.DF_CHK       = 'X';

        Set<String> availablePartCodeList = new Set<String>();
        Map<String,String> partMap = new Map<String,String>();
        for(Product2 part : [
            SELECT ProductCode FROM Product2 WHERE ProductCode IN :partCodeList AND RecordType.DeveloperName = 'Part'
        ]) {
            availablePartCodeList.add(part.ProductCode);
            partMap.put(part.ProductCode,part.ProductCode);
        }
        // noPartList
        for(String part : partCodeList) {
            if(partMap.get(part) ==null) {
                noPartList.add(part);
                if(partDealerMap !=null && partDealerMap.get(part) !=null) {
                    partDealerMap.remove(part);
                } 
            }
        }

        for(String partCode : availablePartCodeList) {
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req_IT_ITEM IT_ITEM1 = new IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_010_Req_IT_ITEM();
            IT_ITEM1.MATNR       = partCode;
            
            //타대리점 정보
            if(partDealerMap != null && partDealerMap.containsKey(partCode)) 
                IT_ITEM1.KUNNR       = partDealerMap.get(partCode);
                
            req.IT_ITEM.add(IT_ITEM1);
        }
        IF_ERP_DealerStock instance = new IF_ERP_DealerStock();
        return instance.IF_DEALERSTOCK_010(req);
    }

    /*
    * @ Class : PartDetails
    * @ Description : 부품 상세 정보
    */
    public class PartDetails {
        @AuraEnabled public String part                 {get; set;} 
        @AuraEnabled public String partName             {get; set;}
        @AuraEnabled public String partDetails          {get; set;} //품명
        @AuraEnabled public String partSpec             {get; set;} //품명
        @AuraEnabled public String replacingPart        {get; set;}
        @AuraEnabled public String replacingPartName    {get; set;}
        @AuraEnabled public String replacingPartDetails {get; set;} //품명
        @AuraEnabled public String unit                 {get; set;}
        @AuraEnabled public Decimal salesUnit           {get; set;}
        @AuraEnabled public Decimal avaiableQuantity    {
            get {
                if(avaiableQuantity == null) avaiableQuantity = 0;
                return avaiableQuantity;
            }
            set;
        } //가용재고
        @AuraEnabled public Decimal currentStockQuantity    {
            get {
                if(currentStockQuantity == null) currentStockQuantity = 0;
                return currentStockQuantity;
            }
            set;
        } //현재고
        @AuraEnabled public Decimal customerPrice       {
            get {
                if(customerPrice == null) customerPrice = 0;
                return customerPrice;
            }
            set;
        } //고객판매가
        public PartDetails() {}
        public PartDetails(Product2 partDetail) {
            part                 = partDetail.Id;
            partName             = partDetail.ProductCode;
            partDetails          = partDetail.FM_MaterialDetails__c;
            partSpec             = partDetail.ProductSpec__c;
            //최초 공급품번은 동일하게
            replacingPart        = partDetail.Id;
            replacingPartName    = partDetail.ProductCode;
            replacingPartDetails = partDetail.FM_MaterialDetails__c;
            unit                 = partDetail.Unit__c;
        }
    }
    public class CustomException extends Exception {}    
}