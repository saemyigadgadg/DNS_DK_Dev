/** 
 * @Test: 
 * @Author : iltae Seo 
 * @Date : 2025. 01. 08. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-01-08 | Iltae seo      | 최초작성 
 */ 
public with sharing class DN_OtherGIController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }

    /**
     * @Description
     * 	- 기타출고 생성
    **/ 
    @AuraEnabled
    public static ExcelHeader insertGI(List<DealerInventoryMovements__c> insertGIList){
        try {
            
            RecordType recType = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType='DealerInventoryMovements__c' AND DeveloperName='GoodsIssue'];
            System.debug(insertGIList + ' ::::insertGIList');
            Map<String,String> partMap = new Map<String,String>();
            for(DealerInventoryMovements__c movem : insertGIList) {
                partMap.put(movem.Part__c, '');
            }
            //저장위치
            List<DealerStock__c> stockList = 
            [   select Part__c,DealerLocation__r.FM_Loc__c, DealerLocation__c
                    from DealerStock__c 
                    where Dealer__c =:currentUser.getAgencyId()
                    AND Part__c IN : partMap.keySet()
            ];
            for(DealerStock__c stock : stockList) {       
                //String location = stock.get('DealerLocation__c') == null? '': (String) stock.DealerLocation__c;
                partMap.put(stock.Part__c,stock.Id);
            }
            //채번
            SequenceGenerator seqGenerator = new SequenceGenerator('DealerInventoryMovements__c');
            String grNumber = seqGenerator.generate(recType.DeveloperName);
            //추가로 필요한 데이터 매핑
            for(DealerInventoryMovements__c movem : insertGIList) {
                movem.Type__c ='O';
                movem.SalesOrganization__c = currentUser.getSalesOranization();
                movem.DistributionChannel__c = currentUser.getDistributionChannel();
                movem.Division__c = currentUser.getDivision();
                movem.Dealer__c = currentUser.getAgencyId();
                if(partMap.get(movem.Part__c) !=null) {
                    // movem.Location__c = partMap.get(movem.Part__c);
                    movem.DealerStock__c = partMap.get(movem.Part__c);
                }
                
                movem.RecordTypeId = recType.Id;
                movem.InventoryChange__c ='H';
                movem.CurrencyIsoCode = 'KRW';
                movem.InventoryNumber__c = grNumber;
            }
            insert insertGIList;

            set<String> recordIds = new set<String>();
            for(DealerInventoryMovements__c dml: insertGIList) {
                recordIds.add(dml.Id);
            }
            List<DealerInventoryMovements__c> returnList = 
            [
                select Id,Name,
                    DealerStock__r.DealerLocation__r.FM_Loc__c,
                    Dealer__r.Name,InventoryNumber__c,
                    CreatedDate,InventoryItemNumber__c,
                    toLabel(Type__c) Type__c,Part__c,Part__r.Name,
                    Part__r.FM_MaterialDetails__c,
                    Part__r.ProductCode,Quantity__c
                    from DealerInventoryMovements__c 
                    where Id IN : recordIds 
                    FOR UPDATE
            ];
            ExcelHeader returnExcel = new ExcelHeader();
            returnExcel.agencyName = currentUser.getAgencyName();
            Decimal index = 1;
            Map<String,Decimal> partByQtyMap = new Map<String,Decimal>();
            for(DealerInventoryMovements__c inventory : returnList) {
                returnExcel.docNumber = inventory.InventoryNumber__c;
                returnExcel.createDate = inventory.CreatedDate.format('YYYY.MM.dd');
                returnExcel.createTime = inventory.CreatedDate.format('HH:mm:ss');

                Decimal quantity = partByQtyMap.get(inventory.Part__c)==null ? inventory.Quantity__c : partByQtyMap.get(inventory.Part__c) + inventory.Quantity__c;
                System.debug(quantity + ' ::: quantity');
                partByQtyMap.put(inventory.Part__c, quantity);
                ExcelData excelData = new ExcelData(inventory,index);
                returnExcel.excelDataList.add(excelData);
                index ++;
            }
            System.debug(partByQtyMap + ' :::: partByQtyMap');
            //마이너스로 넣어두기
            for(String partKey : partByQtyMap.keySet()) {
                Decimal qty = partByQtyMap.get(partKey);
                partByQtyMap.put(partKey, -qty);
            }
            // 채번 업데이트
            seqGenerator.updateNextSequenceInfo();
            DN_DealerStockManager.getAvailable(partByQtyMap,'OtherGI','');
            return returnExcel;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: e.getMessage()');
            System.debug(e.getStackTraceString()+ ' :: getStackTraceString()');
            throw new DN_OtherGIControllerException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- 가격 조회 - 시뮬레이션
    **/ 
    @AuraEnabled
    public static Map<String,DN_SimulationManager.PartDetails> simulation(List<String> partCode){
        try {
            System.debug(partCode + ' ::: partCode');
            DN_SimulationManager simulation = new DN_SimulationManager(DN_SimulationManager.Type.CUSTOMERORDER,partCode,currentUser.getAgencyId());
            Map<String,DN_SimulationManager.PartDetails> simulationMap = simulation.singleSimulation();
            
            // IF NETPR = 고객판매가
            IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res res = DN_DealerStockManager.dealerStock012(new set<String>(partCode));
            for(IF_ERP_DealerStock_Classes.IF_DEALERSTOCK_012_Res_ET_LIST et : res.ET_LIST) {
                if(simulationMap.get(et.MATNR) != null) {
                    simulationMap.get(et.MATNR).customerPrice = Decimal.valueOf(et.NETPR);
                }
            }   
            return simulationMap;
        } catch (Exception e) {
            System.debug(e.getMessage() + ' :: e.getMessage()');
            System.debug(e.getStackTraceString()+ ' :: getStackTraceString()');

            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @Description
     * 	- ExcelHeader : 엑셀 다운로드 시 엑셀의 헤더부분
    **/ 
    public class ExcelHeader {
        @AuraEnabled public String id {get;set;} 
        @AuraEnabled public String agencyName {get;set;} 
        @AuraEnabled public String docNumber {get;set;} 
        @AuraEnabled public String createDate {get;set;} 
        @AuraEnabled public String createTime {get;set;}
        @AuraEnabled public List<ExcelData> excelDataList {get;set;}
        public ExcelHeader() {
            this.excelDataList = new List<ExcelData>();
        }
    }

    /**
     * @Description
     * 	- ExcelData : 엑셀 다운로드 시 데이터 목록
    **/ 
    public class ExcelData {
        @AuraEnabled public Decimal itemNum {get;set;} 
        @AuraEnabled public String type {get;set;} 
        @AuraEnabled public String dcoNumber {get;set;} 
        @AuraEnabled public String partNumber {get;set;} 
        @AuraEnabled public String partName {get;set;} 
        @AuraEnabled public Decimal quantity {get;set;} 
        @AuraEnabled public String location {get;set;} 
        public ExcelData(DealerInventoryMovements__c inventory, Decimal index) {
            this.itemNum = index;
            this.type = inventory.Type__c;
            this.dcoNumber = inventory.InventoryNumber__c;
            this.partNumber = inventory.Part__r.ProductCode;
            this.partName = inventory.Part__r.FM_MaterialDetails__c;
            this.quantity = inventory.Quantity__c;
            this.location = inventory.DealerStock__r.DealerLocation__r.FM_Loc__c ==null ? '' : inventory.DealerStock__r.DealerLocation__r.FM_Loc__c;
        }
    }
    
    

    public class DN_OtherGIControllerException extends Exception {}
}