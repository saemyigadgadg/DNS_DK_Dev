/** 
 * @Class : DN_DealerPortalPrintController
 * 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2024. 12. 31. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2024-12-31 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_OtherGRTableController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 가격 조회
    **/
    @AuraEnabled
    public static Map<String,DN_SimulationManager.PartDetails> simulation(List<String> partCodeList){
        try {
            DN_SimulationManager simulator = new DN_SimulationManager(
                DN_SimulationManager.Type.CUSTOMERORDER
                , partCodeList
                ,currentUser.getAgencyId()
            );
            Map<String,DN_SimulationManager.PartDetails> partSimulationMap  = simulator.singleSimulation();
            // IF
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res res = DN_DealerStockManager.dealerStock011(new set<String>(partCodeList));
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_011_Res_ET_LIST et : res.ET_LIST) {
                if(partSimulationMap.get(et.MATNR) != null) {
                    partSimulationMap.get(et.MATNR).customerPrice = Decimal.valueOf(et.NETPR);
                }
            }
            return partSimulationMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 입고처리
    **/
    @AuraEnabled
    public static GRExcel insertGRList(List<DealerInventoryMovements__c> inventoryList){
        try {
            Map<String,String> partCodeMap = new Map<String,String>();
            set<String> partCodeSet = new set<String>();
            for(DealerInventoryMovements__c inven : inventoryList) {
                partCodeSet.add(inven.Part__c);
            }
            List<DealerStock__c> stockList = [
                select Id,Part__r.ProductCode,Part__r.Name,AvailableQuantity__c
                from DealerStock__c
                where Dealer__c=:currentUser.getAgencyId() and Part__c IN:partCodeSet
            ];
            for(DealerStock__c stock : stockList) {
                partCodeMap.put(stock.Part__c, stock.Id);
            }
            List<DealerInventoryMovements__c> dmlInventoryList = new List<DealerInventoryMovements__c>();
            RecordType recType = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='DealerInventoryMovements__c' AND DeveloperName='GoodsReceipt'];
            
            GRExcel returnExcel = new GRExcel();
            returnExcel.agencyName = currentUser.getAgencyName();
            //채번
            SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
            String grNumber = seqGenerator.generate('GoodsReceipt');
            
            for(DealerInventoryMovements__c dealer : inventoryList) {
                System.debug(dealer.Comment__c+ ' ::: dealer.Comment__c');
                DealerInventoryMovements__c dealerInventory = new DealerInventoryMovements__c();
                dealerInventory.RecordTypeId                                = recType.Id;
                dealerInventory.Dealer__c                                   = currentUser.getAgencyId();
                dealerInventory.SalesOrganization__c                        = currentUser.getSalesOranization();
                dealerInventory.DistributionChannel__c                      = currentUser.getDistributionChannel();
                dealerInventory.Division__c                                 = currentUser.getDivision();
                dealerInventory.InventoryNumber__c                          = grNumber;
                returnExcel.doc = grNumber;
                dealerInventory.Type__c                                     ='3';
                dealerInventory.InventoryChange__c                          ='S';
                dealerInventory.Part__c                                     = dealer.Part__c;              
                dealerInventory.Quantity__c                                 = dealer.Quantity__c;          
                dealerInventory.CustomerPrice__c                            = dealer.CustomerPrice__c;                 
                dealerInventory.DiscountPrice__c                            = dealer.DiscountPrice__c;                 
                dealerInventory.DiscountAmount__c                           = dealer.DiscountAmount__c;                
                dealerInventory.CurrencyIsoCode                             = 'KRW';//dealer.CurrencyIsoCode;                 
                dealerInventory.Reason__c                                   = dealer.Reason__c;                
                dealerInventory.Comment__c                                  = String.valueOf(dealer.Comment__c);
                dealerInventory.InventoryItemNumber__c                      = dealer.InventoryItemNumber__c;     
                dealerInventory.DealerStock__c                              = partCodeMap.get(dealer.Part__c);
                dmlInventoryList.add(dealerInventory);
            }
            insert dmlInventoryList;
            Map<String,Decimal> stockMap = new Map<String,Decimal>();
            set<String> invenIds = new set<String>();
            for(DealerInventoryMovements__c inven : dmlInventoryList) {
                stockMap.put(inven.Part__c, inven.Quantity__c);
                invenIds.add(inven.Id);
            }
            List<DealerInventoryMovements__c> grList = [
                select Id,InventoryNumber__c,
                Part__r.ProductCode,Part__r.Name,
                Quantity__c,Location__r.FM_Loc__c,
                Location__c,Part__r.FM_MaterialDetails__c,
                DealerStock__r.DealerLocation__r.FM_Loc__c
                from DealerInventoryMovements__c 
                where Id IN:invenIds
            ];
            
            returnExcel.returnGRList = grList;
            // 재고 업설트 처리
            DN_DealerStockManager.getAvailable(stockMap, 'GR','');
            DateTime created = DateTime.now();
            returnExcel.createdDate = created.format('YYYY-MM-dd');
            returnExcel.createdTime = created.format('HH:mm:ss');
            // 채번 업데이트
            seqGenerator.updateNextSequenceInfo();
            return returnExcel;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' message ');
            System.debug(e.getStackTraceString() + ' getStackTraceString ');
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 입고 생성 후 입고 액셀 데이터
    **/
    public class GRExcel {
        @AuraEnabled public String agencyName {get;set;} // 대리점명
        @AuraEnabled public String doc {get;set;} // 참고문서
        @AuraEnabled public String createdDate {get;set;} 
        @AuraEnabled public String createdTime {get;set;} 
        @AuraEnabled public List<DealerInventoryMovements__c> returnGRList {get;set;} 
        public GRExcel() {
            this.returnGRList = new List<DealerInventoryMovements__c>();
        }
    }

}