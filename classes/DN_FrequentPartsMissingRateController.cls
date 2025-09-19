public with sharing class DN_FrequentPartsMissingRateController {
    private static DN_UserDetails currentUser {
        get {
            if(currentUser == null) currentUser = new DN_UserDetails();        
            return currentUser;
        } 
        set;
    }
    /*- DNS 구매 내역 조회	
    - 다빈도 품번이란 등급이 A, B, C, D, E, F 에 해당하는 품번	
    - 전체 주문 중 다빈도 품번이 주문된 Rate 계산	
    -------------------------------------------------
    기간	VBAK-AUDAT | 주문유형	"VBAK-AUART (YDOR - Odinary, YDEO - Emergency)"
    ------------------------------------------------- search
    SOTYPE	                |   "VBAK-AUART  (YDOR - Odinary, YDEO - Emergency)"
    Doc.Date                |	VBAK-AUDAT
    SO No.                  |   VBAK-VBELN
    Item	                |   VBAP-POSNR
    Order Material          |   VBAP-MATWA
    ABC Ind. 	            |   "ZSPT2420-MAABC  주문 품번에 대한 대리점 품번 등급"  DealerPartMasterByMPPS__c.ABCIndicator__c
    Status	Order material  |   다빈도 품번(A, B, C, D, E, F) 경우 O 아닐 경우 X
    Supply Material		    |   VBAP-MATNR
    ABC Ind. 	            |   "ZSPT2420-MAABC 공급 품번에 대한 대리점 품번 등급"  DealerPartMasterByMPPS__c.ABCIndicator__c
    Status                  |   Supply material 이 다빈도 품번(A, B, C, D, E, F) O 아닐 경우 X
    Supply Material Desc.   |   Material master 의 품명
    Order Qty.              |   VBAP-KWMENG
    Unit per Price          |   VBAP-NETPR / VBAP-KPEIN
    -------------------------------------------------
    */
    @AuraEnabled
    public static Map<String,Object> getDataList(String orderType ,Date orderDateStart ,Date orderDateEnd ,String customerId){
        Map<String,Object> result = new Map<String,Object>();
        try {
            System.debug('customerId >>> '+customerId);
            Schema.DescribeSObjectResult dc = DealerCustomer__c.sObjectType.getDescribe();
            String keyPrefix = dc.getKeyPrefix();
            System.debug('keyPrefix >>> '+keyPrefix );
           
           
            if(String.isNotBlank(customerId) && customerId.startsWith(keyPrefix)) {
                DealerCustomer__c deal = [SELECT SourceAccount__c FROM DealerCustomer__c WHERE Id = :customerId AND IsActive__c = true AND IsDealer__c = true LIMIT 1];
                customerId = deal.SourceAccount__c;
            } 

            if(String.isBlank(customerId) && currentUser.getIsAdmin()) {
                customerId = currentUser.getAgencyId();
            }

            List<POWrapper> dataList = new List<POWrapper>();
            List<POWrapper> dataListSet = new List<POWrapper>();
            String queryS = 'SELECT ';
            String queryF = '  Id '
                           +' ,ItemNo__c ,OrderPartNo__c ,Part__c ,OrderPartId__c '
                           +' ,SupplyPartNo__c ,SupplyPartId__c ,SupplyPartId__r.FM_MaterialDetails__c '
                           +' ,Quantity__c , Unit__c, UnitPrice__c '
                           +' ,PurchaseOrder__c '
                           +' ,PurchaseOrder__r.Buyer__c ,PurchaseOrder__r.Buyer__r.Name '
                           +' ,PurchaseOrder__r.OrderType__c  ,PurchaseOrder__r.FM_OrderDate__c '
                           +' ,PurchaseOrder__r.PartOrderNo__c ,PurchaseOrder__r.OrderQty__c '
                           +' ,PurchaseOrder__r.ItemsAmount__c ,PurchaseOrder__r.TotalItems__c ' 
                           +' ,PurchaseOrder__r.CreatedDate ';
            String queryFW =' FROM  PurchaseOrderItems__c  '
                           +' WHERE PurchaseOrder__r.RecordType.DeveloperName = \'Order\' '
                           +' AND ( PurchaseOrder__r.FM_OrderDate__c >= :orderDateStart AND PurchaseOrder__r.FM_OrderDate__c <= :orderDateEnd ) ';
            String queryAdd = ''; //검색조건
            if(!'All'.equals(orderType)) {
                queryAdd += ' AND PurchaseOrder__r.OrderType__c = :orderType ';
            } else {
                queryAdd += ' AND PurchaseOrder__r.OrderType__c IN (\'YDOR\',\'YDEO\')';
            }
                
            if(String.isNotBlank(customerId) && !'All'.equals(customerId)) {
                queryAdd += ' AND PurchaseOrder__r.Buyer__c = :customerId ';
            }
            String queryAll = queryS + queryF + queryFW + queryAdd +' ORDER BY PurchaseOrder__r.CreatedDate ASC '; 
            System.debug('쿼리전');
            Set<String> partsId = new Set<String>();
            Map<String,Decimal> orderNoByGroup = new Map<String,Decimal>();
            for( PurchaseOrderItems__c order : Database.query(queryAll)){
                //POWrapper po = new POWrapper(order);
                System.debug('inside for');
                dataList.add(new POWrapper(order));
                // dataList.add(List<POWrapper);
                System.debug(order.OrderPartId__c);
                if(order.OrderPartId__c != null){
                    partsId.add(order.OrderPartId__c);
                }
                System.debug(order.SupplyPartId__c);
                if(order.SupplyPartId__c != null){
                    partsId.add(order.SupplyPartId__c);
                }
                
                
            }
            System.debug('partsId >> '+partsId);
            Map<String, DealerPartMasterByMPPS__c> mppsMap = new Map<String, DealerPartMasterByMPPS__c>();
            for(DealerPartMasterByMPPS__c mppsObj :[SELECT Id ,ABCIndicator__c ,Part__c FROM DealerPartMasterByMPPS__c WHERE Part__c =:partsId ]){
                mppsMap.put(mppsObj.part__c, mppsObj);
            }
            
            for(POWrapper pow : dataList) {
                DealerPartMasterByMPPS__c orderPart = mppsMap.get(pow.orderPartId);
                DealerPartMasterByMPPS__c supplyPart = mppsMap.get(pow.supplyPartId);
                if(orderPart != null) {
                    pow.orderAbc = orderPart.ABCIndicator__c;
                    pow.orderStatus = setStatus(orderPart.ABCIndicator__c);
                }
                if(supplyPart != null) {
                    pow.supplyAbc = supplyPart.ABCIndicator__c;
                    pow.supplyStatus = setStatus(supplyPart.ABCIndicator__c);
                }
                
            }
            
            dataList.sort();
            result.put('resultList', dataList);
        } catch (Exception e) {
            String errorMessage = 'Exception : ' + e.getMessage();
            System.debug('errorMessage :: ' +errorMessage);
            System.debug(e.getStackTraceString());
        }
        return result;
    }

    public class POWrapper implements Comparable  {
        @AuraEnabled public String   poId              {get;set;} //Purchase Order Id 
        @AuraEnabled public String   dealerName        {get;set;} //Sold-to Name
        @AuraEnabled public String   soType            {get;set;} //SO Type
        @AuraEnabled public Date     docDate           {get;set;} //Doc Date
        @AuraEnabled public String   soNo              {get;set;} //SO No
        @AuraEnabled public String   orderAbc          {get;set;} //Order ABC Ind.
        @AuraEnabled public String   orderStatus       {get;set;} //Order Material Status
        @AuraEnabled public String   supplyAbc         {get;set;} //Supply ABC Ind.
        @AuraEnabled public String   supplyStatus      {get;set;} //Supply Material Status
        @AuraEnabled public Datetime createdTime       {get;set;} //정렬기능 
        @AuraEnabled public Decimal  totalItemOrderQty {get;set;} // purchase order의 아이템 총 주문수량
        @AuraEnabled public Decimal  totalItemsAmount  {get;set;} // purchase order의 아이템 총 금액합
        @AuraEnabled public Decimal  totalItems        {get;set;} // purchase order의 아이템 총 수량
        @AuraEnabled public String   poItId            {get;set;} //PurchaseOrderItem Id
        @AuraEnabled public String   item              {get;set;} //Itme 끝에 두자리만
        @AuraEnabled public String   orderPartId       {get;set;} //Order Part Id
        @AuraEnabled public String   orderMaterial     {get;set;} //Order Material
        @AuraEnabled public String   supplyPartId      {get;set;} //Supply Part Id
        @AuraEnabled public String   supplyMaterial    {get;set;} //Supply Material
        @AuraEnabled public String   supplyDesc        {get;set;} //Supply Material Description
        @AuraEnabled public String   unit              {get;set;} //unit
        @AuraEnabled public String   qtyUnit           {get;set;} //Order Quantity + Unit
        @AuraEnabled public Decimal  orderQty          {  //Order Quantity
            get{
                if(orderQty == null) orderQty = 0;
                return orderQty;
            }
            set;
        }
        @AuraEnabled public Decimal unitPerPrice         { //Unit Per Price
            get{
                if(unitPerPrice == null) unitPerPrice = 0;
                return unitPerPrice;
            }
            set;
        }

        public POWrapper(){}
        public POWrapper(PurchaseOrderItems__c psObj) { 
            this.poItId             = psObj.Id;
            this.item               = psObj?.ItemNo__c.replaceFirst('^0+', '');
            this.orderPartId        = psObj.OrderPartId__c;
            this.orderMaterial      = psObj.OrderPartNo__c;
            this.supplyPartId       = psObj.SupplyPartId__c;
            this.supplyMaterial     = psObj.SupplyPartNo__c;
            this.supplyDesc         = psObj.SupplyPartId__r.FM_MaterialDetails__c;
            this.unit               = psObj.Unit__c;
            this.unitPerPrice       = psObj.UnitPrice__c;
            this.orderQty           = psObj.Quantity__c;
            this.qtyUnit            = String.valueOf(psObj.Quantity__c)+' '+psObj.Unit__c;
            this.poId               = psObj.PurchaseOrder__c;
            this.dealerName         = psObj.PurchaseOrder__r.Buyer__r.Name;
            this.soType             = psObj.PurchaseOrder__r.OrderType__c;
            this.docDate            = psObj.PurchaseOrder__r.FM_OrderDate__c;   
            this.soNo               = psObj.PurchaseOrder__r.PartOrderNo__c;
            this.createdTime        = psObj.PurchaseOrder__r.CreatedDate;
            this.totalItemOrderQty  = psObj.PurchaseOrder__r.OrderQty__c;
            this.totalItemsAmount   = psObj.PurchaseOrder__r.ItemsAmount__c;
            this.totalItems         = psObj.PurchaseOrder__r.TotalItems__c;
            this.orderStatus        = 'X';
            this.supplyStatus       = 'X';
        }

        public Integer compareTo(Object compareTo) {
            POWrapper compareToEmp = (POWrapper)compareTo;
            
            if (createdTime < compareToEmp.createdTime) return 1;
            if (createdTime > compareToEmp.createdTime) return -1;

            return 0;
        }
    }

    private static String setStatus(String indt) {
        String statusName = 'X';
        switch on indt {
            when 'A','B','C','D','E','F' { 
                statusName = 'O';
            }
            when else { statusName = 'X'; }
        }
        return statusName;
    }
    
}