/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * 
 *  - Order의 Amount의 합산을 Dealer Sales Plan의 Actual에 Update하는 Batch
 *  - Update 대상이 되는 Order Amount 기준
 *    DNS   : Status ('Confirmed', 'OrderMapped', 'Delivery'), OrderConfirmedDate__c
 *    DNSA  : Status ('OrderConfirmed'), RequestedShipDate__c
 *  - DNS Korea, DNSA : RelatedDealer__c를 기준으로 집계
 *  - DNS Global : SoldTo__c를 기준으로 집계 (2025-05-08)
 *  - Order의 SalesChannelType__c를 기준으로 Korea/Global(Domestic/Overseas) 구분
 * 
 * @last modified on  : 2025-05-12
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-10-29   yuhyun.park@sbtglobal.com   Initial Version
**/
public class DN_DealerSalesPlanBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

  private static final Id   dnsKRT      = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNS_Korea').getRecordTypeId();
  private static final Id   dnsGRT      = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNS_Global').getRecordTypeId();
  private static final Id   dnsaRT      = SObjectType.DealerSalesPlan__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
  private static final Id   dnsaGoalRT  = SObjectType.DealerSalesGoal__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();
  private static final Id   dealerRT    = SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
  private static final Id   dnsOrderRT  = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNS').getRecordTypeId();
  private static final Id   dnsaOrderRT = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId();

  private Map<String, Decimal> dspOrderAmountMap            = new Map<String, Decimal>();
  private Map<String, Integer> dspOrderUnitMap              = new Map<String, Integer>();
  private Map<String, Integer> dspHEOrderUnitMap            = new Map<String, Integer>();
  private Map<String, Decimal> dspAvgMachineSalesPriceMap   = new Map<String, Decimal>();
  private Map<String, Integer> dspAvgMachineSalesPriceCount = new Map<String, Integer>();
  private Map<String, Decimal> dsgAvgMachineSalesPriceMap   = new Map<String, Decimal>();
  private Map<String, Integer> dsgAvgMachineSalesPriceCount = new Map<String, Integer>();

  private Map<String, DealerSalesPlan__c> dspRecordMap  = new Map<String, DealerSalesPlan__c>();
  private List<DealerSalesPlan__c> dspToUpdate          = new List<DealerSalesPlan__c>();
  private Map<String, DealerSalesGoal__c> dsgRecordMap  = new Map<String, DealerSalesGoal__c>();
  private List<DealerSalesGoal__c> dsgToUpdate          = new List<DealerSalesGoal__c>();


    public Database.QueryLocator start(Database.BatchableContext bc) {
      // 1) 공통 조건
      String baseWhere = 
            'Status IN (\'Confirmed\', \'OrderMapped\', \'Delivery\', \'OrderConfirmed\') '
          + 'AND FinalOrderAmount__c > 0 '
          + 'AND ('
          // 2) 글로벌 : SoldTo__c 기준 (SalesChannelType__c = 'Overseas')
          + '  (SalesChannelType__c = \'Overseas\' '
          + '   AND SoldTo__c != null '
          // + '   AND SoldTo__r.IsGlobalDealer__c = true '
          + '   AND (SoldTo__r.IsGlobalDealer__c = true OR Is_Third_Party_Trade__c = true) '
          + '   AND SoldTo__r.RecordTypeId = \'' + dealerRT + '\') '
          + '  OR '
          // 3) 한국·DNSA : RelatedDealer__c 기준 (SalesChannelType__c <> 'Overseas')
          + '  (SalesChannelType__c <> \'Overseas\' '
          + '   AND RelatedDealer__c != null '
          + '   AND Is_Third_Party_Trade__c = false '
          + '   AND RelatedDealer__r.IsDNSDirectAccount__c != true '
          + '   AND RelatedDealer__r.RecordTypeId = \'' + dealerRT + '\') '
          + ') '
          // 4) 레코드 타입별 날짜 조건
          + 'AND ('
          + '  (RecordTypeId = \'' + dnsOrderRT  + '\' AND OrderConfirmedDate__c = THIS_YEAR)'
          + '  OR '
          + '  (RecordTypeId = \'' + dnsaOrderRT + '\' AND RequestedShipDate__c = THIS_YEAR)'
          + ')';
  
      String query = ''
        + 'SELECT Id, OrderNumber, Status, SalesChannelType__c, Is_Third_Party_Trade__c,'
        + '       RelatedDealer__r.CustomerCode__c, SoldTo__r.CustomerCode__c,ShipTo__r.CustomerCode__c, '
        + '       FinalOrderAmount__c, '
        + '       OrderConfirmedDate__c, RequestedShipDate__c, '
        + '       Type, RecordTypeId '
        + 'FROM Order '
        + 'WHERE ' + baseWhere + ' '
        + 'ORDER BY Id';
  
      return Database.getQueryLocator(query);
  }
  
  
    public void execute(Database.BatchableContext bc, List<Order> scope){
      
      Set<String> bypassSet = new Set<String>{'DealerSalesGoalTriggerHandler', 'DealerSalesPlanTriggerHandler'};
      TriggerHandler.bypassedHandlers = bypassSet; 

      for(Order order : scope){
        System.debug('scope :: ' + order.OrderNumber);
      }
      
      System.debug('scope :: ' + scope);

      Set<Id> orderIds = new Set<Id>();
      for (Order order : scope) {
          if (order.Id != null) {
              orderIds.add(order.Id);
          }
      }

      Map<Id, List<OrderItem>> orderItemsMap = new Map<Id, List<OrderItem>>();
      if (!orderIds.isEmpty()) {
          List<OrderItem> orderItems = [
              SELECT OrderId, UnitPrice, ItemCategory__c
              FROM OrderItem
              WHERE OrderId IN :orderIds AND ItemCategory__c = 'Product' AND  Order.RecordTypeId = :dnsaOrderRT
          ];
          for (OrderItem item : orderItems) {
              if (!orderItemsMap.containsKey(item.OrderId)) {
                  orderItemsMap.put(item.OrderId, new List<OrderItem>());
              }
              orderItemsMap.get(item.OrderId).add(item);
          }
      }
      
      for(Order order : scope){

        // DNS는 OrderConfirmedDate__c, DNSA는 RequestedShipDate__c
        Date keyDate;
        keyDate = (order.RecordTypeId == dnsOrderRT) ? order.OrderConfirmedDate__c : order.RequestedShipDate__c;

        // SalesChannelType__c 로 Korea/Global 구분 (DNS Korea는 RelatedDealer__c 기준, DNS Global은 SoldTo__c 기준) 2025-05-08
        String office = (order.SalesChannelType__c != null) ? order.SalesChannelType__c : null;
        String dealerRel = 'RelatedDealer__r';
        if ('Overseas'.equals(office)){
          if(order.Is_Third_Party_Trade__c == true){
            dealerRel = 'ShipTo__r'; //중개무역이면 Shipto 2025-06-26
          }else{
            dealerRel = 'SoldTo__r';
          }
        } 

        System.debug('dealerRel :: ' + dealerRel);
        SObject dealerObj = order.getSObject(dealerRel);

        String custCode;
        if(dealerObj != null){
          custCode = (String) dealerObj.get('CustomerCode__c');
        } 

        if(custCode != null && keyDate != null){

          String dspKey = custCode 
                          + String.valueOf(keyDate.year()) 
                          + (keyDate.month() < 10 ? '0' + String.valueOf(keyDate.month()) : String.valueOf(keyDate.month()));
          System.debug('dspKey :: ' + dspKey );

          String dsgKey = custCode 
                          + String.valueOf(keyDate.year()) ;
          System.debug('dsgKey :: ' + dsgKey );
  
          // Order Amount 계산
          if(dspOrderAmountMap.containsKey(dspKey)){
            dspOrderAmountMap.put(dspKey, dspOrderAmountMap.get(dspKey) + order.FinalOrderAmount__c);
          }else{
            dspOrderAmountMap.put(dspKey, order.FinalOrderAmount__c);
          }


          // DNSA 에만 필요한 계산식
          if (order.RecordTypeId == dnsaOrderRT) {
            // Order Unit 계산
            if (dspOrderUnitMap.containsKey(dspKey)) {
              dspOrderUnitMap.put(dspKey, dspOrderUnitMap.get(dspKey) + 1);
            } else {
                dspOrderUnitMap.put(dspKey, 1);
            }

            // HE Order Unit 계산
            System.debug('order.Type :: ' + order.Type);
            if (order.Type == 'HE') {
              if (dspHEOrderUnitMap.containsKey(dspKey)) {
                  dspHEOrderUnitMap.put(dspKey, dspHEOrderUnitMap.get(dspKey) + 1);
              } else {
                  dspHEOrderUnitMap.put(dspKey, 1);
              }
            }

            // Avg Machine Sales Price 계산
            if (orderItemsMap.containsKey(order.Id)) {
              for (OrderItem item : orderItemsMap.get(order.Id)) {

                  // DealerSalesPlan__c - 월별 평균 가격 계산
                  if (!dspAvgMachineSalesPriceMap.containsKey(dspKey)) {
                      dspAvgMachineSalesPriceMap.put(dspKey, 0);
                      dspAvgMachineSalesPriceCount.put(dspKey, 0);
                  }
                  dspAvgMachineSalesPriceMap.put(dspKey, dspAvgMachineSalesPriceMap.get(dspKey) + item.UnitPrice);
                  dspAvgMachineSalesPriceCount.put(dspKey, dspAvgMachineSalesPriceCount.get(dspKey) + 1);

                  // DealerSalesGoal__c - 연도별 평균 가격 계산
                  if (!dsgAvgMachineSalesPriceMap.containsKey(dsgKey)) {
                      dsgAvgMachineSalesPriceMap.put(dsgKey, 0);
                      dsgAvgMachineSalesPriceCount.put(dsgKey, 0);
                  }
                  dsgAvgMachineSalesPriceMap.put(dsgKey, dsgAvgMachineSalesPriceMap.get(dsgKey) + item.UnitPrice);
                  dsgAvgMachineSalesPriceCount.put(dsgKey, dsgAvgMachineSalesPriceCount.get(dsgKey) + 1);
              }
            }
          }
      }
    }

      System.debug('dspOrderAmountMap :: ' + dspOrderAmountMap );
      System.debug('dspAvgMachineSalesPriceMap :: ' + dspAvgMachineSalesPriceMap);
      System.debug('dsgAvgMachineSalesPriceMap :: ' + dsgAvgMachineSalesPriceMap);
    }

  
    public void finish(Database.BatchableContext bc){

      List<DealerSalesPlan__c> dspList = [SELECT Id, Key__c, Actual__c, Actual_OrderUnit__c, Actual_OrderAmount__c, Actual_HEOrderUnit__c, Actual_AvgMachineSalesPrice__c, RecordTypeId, RecordType.Name
                                          FROM DealerSalesPlan__c
                                          WHERE Key__c IN: dspOrderAmountMap.keySet()];
      System.debug('dspList :: ' + dspList );

      List<DealerSalesGoal__c> dsgList = [SELECT Id, Key__c, Actual_AvgMachineSalesPrice__c, RecordTypeId, RecordType.Name
                                          FROM DealerSalesGoal__c
                                          WHERE Key__c IN: dsgAvgMachineSalesPriceMap.keySet()];
      System.debug('dsgList :: ' + dsgList );


      for (DealerSalesPlan__c dsp : dspList) {
        dspRecordMap.put(dsp.Key__c, dsp);
      }

      for (DealerSalesGoal__c dsg : dsgList) {
        dsgRecordMap.put(dsg.Key__c, dsg);
      }


      System.debug('dspOrderAmountMap ::>> ' + dspOrderAmountMap );

      // dspOrderAmountMap의 키로 dspRecordMap을 참조하여 Actual__c 값 업데이트
      for (String key : dspOrderAmountMap.keySet()) {
        System.debug('key :: ' + key );
          if (dspRecordMap.containsKey(key)) {
              DealerSalesPlan__c dspRecord = dspRecordMap.get(key);

              System.debug('Record Type :: ' + dspRecord.RecordType.Name);

              // Record Type : DNS
              if(dspRecord.RecordTypeId == dnsKRT || dspRecord.RecordTypeId == dnsGRT){
                dspRecord.Actual__c = dspOrderAmountMap.containsKey(key)  ? dspOrderAmountMap.get(key) : 0;

              // Record type : DNSA
              }else if(dspRecord.RecordTypeId == dnsaRT){
                dspRecord.Actual_OrderAmount__c = dspOrderAmountMap.containsKey(key)  ? dspOrderAmountMap.get(key) : 0;
                dspRecord.Actual_OrderUnit__c   = dspOrderUnitMap.containsKey(key)    ? dspOrderUnitMap.get(key) : 0;
                dspRecord.Actual_HEOrderUnit__c = dspHEOrderUnitMap.containsKey(key)  ? dspHEOrderUnitMap.get(key) : 0;
              
                if (dspAvgMachineSalesPriceMap.containsKey(key) && dspAvgMachineSalesPriceCount.containsKey(key) && dspAvgMachineSalesPriceCount.get(key) > 0) {
                  dspRecord.Actual_AvgMachineSalesPrice__c = dspAvgMachineSalesPriceMap.get(key) / dspAvgMachineSalesPriceCount.get(key);
                }

                System.debug('dsp.Actual_AvgMachineSalesPrice__c  :: ' + dspRecord.Actual_AvgMachineSalesPrice__c );
              
              }

              dspToUpdate.add(dspRecord);
          }
      }

      for (String key : dsgAvgMachineSalesPriceMap.keySet()){
        System.debug('key :: ' + key );
        if(dsgRecordMap.containsKey(key)){
          DealerSalesGoal__c dsgRecord = dsgRecordMap.get(key);

          System.debug('Record Type :: ' + dsgRecord.RecordType.Name);

          if(dsgRecord.RecordTypeId == dnsaGoalRT){

            if (dsgAvgMachineSalesPriceMap.containsKey(key) && dsgAvgMachineSalesPriceCount.containsKey(key) && dsgAvgMachineSalesPriceCount.get(key) > 0) {
              dsgRecord.Actual_AvgMachineSalesPrice__c = dsgAvgMachineSalesPriceMap.get(key) / dsgAvgMachineSalesPriceCount.get(key);
            }

            System.debug('dsg AvgMachineSalesPrice__c  :: ' + dsgRecord.Actual_AvgMachineSalesPrice__c );

          }

          dsgToUpdate.add(dsgRecord);
        }
      }


      if(!dspToUpdate.isEmpty()){
          update dspToUpdate;
          System.debug('dspToUpdate :: ' + dspToUpdate);
        }
        
      if(!dsgToUpdate.isEmpty()){
          update dsgToUpdate;
          System.debug('dsgToUpdate :: ' + dsgToUpdate);
        }

      System.debug('DN_DealerSalesPlanBatch completed :: ' + System.now());
    }

    
    public void execute(SchedulableContext sc) {
      // 배치 클래스 실행
      DN_DealerSalesPlanBatch batch = new DN_DealerSalesPlanBatch();
      Database.executeBatch(batch, 200);
  }
}