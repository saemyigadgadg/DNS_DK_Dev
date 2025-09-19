/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-17-2025
 * @last modified by  : deokjun.kim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-17-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
global with sharing class IF_ERP_DeliveryOrderConvertBatch 
                    implements Database.Batchable<IF_DeliveryOrder__c> , 
                               Database.AllowsCallouts, 
                               Database.Stateful  {

/**
 * """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" START
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * */         

    public Iterable<IF_DeliveryOrder__c> start(Database.BatchableContext BC){

        String objectName = 'IF_DeliveryOrder__c'; 
        List<IF_DeliveryOrder__c> records;

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields.getMap();

        // IsConverted -> 아직 변환되지 않는 것들만 조회회
        String queryFields = String.join(new List<String>(fieldMap.keySet()), ', ');
        String query       = 'SELECT ' + queryFields + ' FROM ' + objectName + ' WHERE IsConverted__c = false';

        records = Database.query(query);

        return records;
    }

/**
 * """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" EXECUTE
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * */         
    public void execute(Database.BatchableContext BC, List<IF_DeliveryOrder__c> scope){

        if(scope.size()<1){
            return;
        }

        // # 0 RESULTS MAP
        Map<String,DeliveryOrder__c>                resultDeliveryMap     = new Map<String,DeliveryOrder__c>(); 
        Map<String,Order>                           resultOrderMap        = new Map<String,Order>();
    

        // # 1. IF Object 로 변환 후 테이블별로 MAP 을 생성 
        Map<String,Map<String,IF_DeliveryOrder__c>> tableMap      = getTableMapByScope(scope)   ; 

        if (tableMap == null) {
            System.debug('Error: tableMap is null');
            return;
        }

        Map<String,IF_DeliveryOrder__c>             resultIfMap   = tableMap.containsKey('IFOBJ')       ? tableMap.get('IFOBJ')         : new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             condMap       = tableMap.containsKey('T_COND')      ? tableMap.get('T_COND')        : new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             headerMap     = tableMap.containsKey('T_HEADER')    ? tableMap.get('T_HEADER')      : new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             noteMap       = tableMap.containsKey('T_NOTE')      ? tableMap.get('T_NOTE')        : new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             zcrms0062Map  = tableMap.containsKey('T_ZCRMS0062') ? tableMap.get('T_ZCRMS0062')   : new Map<String,IF_DeliveryOrder__c>();
        
        System.debug('TOTAL SIZE : '+scope.size());

        // # 2. COND 의 VBELN 으로 01 번, 02 번대  ORDER MAP을 반환 
        Map<String,Map<String,Order>>   orderMaps  = orderMapsByCondList(condMap.values());
        Map<String,Order>               order01Map = new Map<String,Order>();
        Map<String,Order>               order02Map = new Map<String,Order>();
        if( orderMaps.containsKey('orderN01') ){ order01Map = orderMaps.get('orderN01');}
        if( orderMaps.containsKey('orderN02') ){ order02Map = orderMaps.get('orderN02');}

        
        // # 3.  Order Id들을 추출하여 SELECT * FROM DeliveryOrder__c WHERE Order__c IN ORDERIDS
        Set<String>                     orderIdSet       = new Set<String>();
        for(Order order : order01Map.values()) { orderIdSet.add(order.Id); } // 1번대 오더 Id 
        for(Order order : order02Map.values()) { orderIdSet.add(order.Id); } // 2번대 오더 Id
        Set<String>                     condKeys         = condMap.keySet();
        Map<String,DeliveryOrder__c>    deliveryMap      = findDoByOrderIds(orderIdSet);

        // # 5. DO 할당
        for(String doNum : condKeys){
            try{
                // 1.  ( DO 번호 == AUBEL, ORDER 번호 == VBELN_VA )
                String vbelnVa = condMap.get(doNum).VBELN_VA__c;

                // 2. order 조회 
                Order headOrder;

                     if( order01Map.containsKey(vbelnVa) ) { headOrder = order01Map.get(vbelnVa);                              }
                else if( order02Map.containsKey(vbelnVa) ) { headOrder = order02Map.get(vbelnVa);                              }
                else                                       { throw new NotFoundOrderException(); }

                // 3. Order 조회 이후 Order 상태 변경 
                if(!headOrder.Owner.IsActive)              { headOrder.OwnerId = UserInfo.getUserId();}
                headOrder.IF_DO__c = doNum;
                
                // 4. DO 존재 여부 
                DeliveryOrder__c delivery;

                if( deliveryMap.containsKey(headOrder.Id) ){   // DO가 이미 존재함  
                    delivery = deliveryMap.get(headOrder.Id);
                } 
                else{                                          // DO가 존재 하지 않음 -> 새로 생성 
                    delivery = new DeliveryOrder__c();       
                    delivery.DistributionChannel__c =  headOrder.DistributionChannel__c;
                    delivery.Status__c              = 'DOInternalApproved';
                    delivery.Order__c               =  headOrder.Id;
                    delivery.OwnerId                =  headOrder.OwnerId;
                } 

                // 5. 데이터 할당
                delivery.ERPDONo__c = doNum;

                fromCOND(delivery,condMap.get(doNum));

                if(    headerMap.containsKey(doNum) ) {    fromHEADER(delivery,   headerMap.get(doNum)); }
                if( zcrms0062Map.containsKey(doNum) ) { fromZCRMS0062(delivery,zcrms0062Map.get(doNum)); }
                if(      noteMap.containsKey(doNum) ) {      fromNOTE(delivery,     noteMap.get(doNum)); }
                
                resultDeliveryMap.put(doNum,delivery)        ;
                   resultOrderMap.put(headOrder.Id,headOrder);
            }
            catch(NotFoundOrderException e){
                String message = 'DO :'+doNum+' not exit order';
                System.debug(message);
                assignException(resultIfMap, doNum, message);
            }            
            catch(Exception e){
                String message = 'DO :'+doNum+' - LINE :'+e.getLineNumber()+' - message : '+e.getMessage();
                System.debug(message);
                assignException(resultIfMap, doNum, message);                
            }
        }

        // Delivery Order UPSERT
        if(resultDeliveryMap.size() > 0){
            List<Database.UpsertResult> upsertIfObj = Database.upsert(resultDeliveryMap.values(),  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('Delivery Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
            }
        }
        
        // Order UPSERT
        if(resultOrderMap.size() > 0){
            List<Database.UpsertResult> upsertIfObj = Database.upsert(resultOrderMap.values(),  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('Delivery Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
            }
        }        

        // IF Delivery Order UPSERT
        if(scope.size() > 0){
            List<Database.UpsertResult> upsertIfObj = Database.upsert(scope,  false);
            for(Database.UpsertResult ur : upsertIfObj) {
                if(!ur.isSuccess()) { System.debug('IF Delivery Upsert ERROR  ::: ' + ur.getId() + ' / ' + ur.getErrors()); }
            }            
        }
    }


/**
 * """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" FINISH
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
 * */    
    public void finish(Database.BatchableContext BC){

    }

// 01, 02 번대 오더 조회하기      
    private Map<String,Map<String,Order>> orderMapsByCondList(List<IF_DeliveryOrder__c> condList ){
        Map<String,Map<String,Order>> orderMaps = new Map<String,Map<String,Order>>(); 
        Set<String>                   orderIds_01 = new Set<String>();
        Set<String>                   orderIds_02 = new Set<String>();

        // get ownerid list 
        for(IF_DeliveryOrder__c item : condList){
            String vbelnVA = item.VBELN_VA__C;

            if(vbelnVA != null){
                if(vbelnVA.startsWith('01')){
                    orderIds_01.add(vbelnVA); // VBELN__VA
                }
                else if(vbelnVA.startsWith('02')){
                    orderIds_02.add(vbelnVA); // VBELN__VA
                }
                else{
                    System.debug('WRONG VBELN VA VALUE : '+vbelnVA);
                }
            }
        }

        if(!orderIds_01.isEmpty()){
            List<Order> orders = [SELECT Id, OwnerId, Owner.IsActive, DistributionChannel__c, ERPOrderNo__c, ERPPSONo__c,IF_DO__c FROM Order where ERPOrderNo__c IN :orderIds_01];

            if(!orders.isEmpty()){
                Map<String,Order> orderMap = new Map<String,Order>();

                for(Order order : orders){
                    orderMap.put(order.ERPOrderNo__c,order);
                }        
                orderMaps.put('orderN01',orderMap);          
            }            
        }

        if(!orderIds_02.isEmpty()){
            List<Order> orders = [SELECT Id, OwnerId, Owner.IsActive, DistributionChannel__c, ERPOrderNo__c, ERPPSONo__c,IF_DO__c FROM Order where ERPPSONo__c IN :orderIds_02];

            if(!orders.isEmpty()){
                Map<String,Order> orderMap = new Map<String,Order>();

                for(Order order : orders){
                    orderMap.put(order.ERPPSONo__c,order);
                }      
                orderMaps.put('orderN02',orderMap);                            
            }            
        }        

        return orderMaps;
    }    

// Do 번호로 Order 가 존재하는 DeliveryOrder 찾기
    private Map<String,DeliveryOrder__c> findDoByOrderIds(Set<String> orderIds){
        
        Map<String,DeliveryOrder__c> doMapAssignOrder = new Map<String,DeliveryOrder__c>();
        
        for(DeliveryOrder__c delivery : [ SELECT Id, Order__c, CapitalNo__c, DestinationZone__c, CurrencyIsoCode,
                                                    PlannedGI__c, DeliveryDate__c, ActualGIDate__c,
                                                    ETD__c, ETA__c, VesselName__c, ShippingCompany__c, Status__c,
                                                    ERPDONo__c,DistributionChannel__c
                                            FROM DeliveryOrder__c 
                                            WHERE Order__c IN: orderIds]){
                doMapAssignOrder.put(delivery.Order__c,delivery);
        }

        return doMapAssignOrder;
    }

// CONVERTING 
    public DeliveryOrder__c fromCOND        ( DeliveryOrder__c deliveryOrder, IF_DeliveryOrder__c ifDeliveryOrder ){
        deliveryOrder.CapitalNo__c       =  ifDeliveryOrder.CAPITAL_NO__c;
        deliveryOrder.DestinationZone__c = 	ifDeliveryOrder.TO__c        ;
        return deliveryOrder;
    }

    public DeliveryOrder__c fromHEADER      ( DeliveryOrder__c deliveryOrder, IF_DeliveryOrder__c ifDeliveryOrder ){
        deliveryOrder.CurrencyIsoCode = ifDeliveryOrder.WAERK__c;
        return deliveryOrder;
    }

    public DeliveryOrder__c fromNOTE        ( DeliveryOrder__c deliveryOrder, IF_DeliveryOrder__c ifDeliveryOrder ){
        // deliveryOrder.Note__c = ifDeliveryOrder.TDLINE__c;
        return deliveryOrder;
    }

    public DeliveryOrder__c fromZCRMS0062   ( DeliveryOrder__c deliveryOrder, IF_DeliveryOrder__c ifDeliveryOrder ){
        deliveryOrder.PlannedGI__c       = (ifDeliveryOrder.WAUHR__c != null)? convertDateTime(ifDeliveryOrder.WADAT__c,ifDeliveryOrder.WAUHR__c) : convertDateTime(ifDeliveryOrder.WADAT__c);
        deliveryOrder.DeliveryDate__c    = (ifDeliveryOrder.LFUHR__c != null)? convertDateTime(ifDeliveryOrder.LFDAT__c,ifDeliveryOrder.LFUHR__c) : convertDateTime(ifDeliveryOrder.LFDAT__c);
        if( ifDeliveryOrder.WADAT_IST__c != '0000-00-00'){
            deliveryOrder.ActualGIDate__c    = (ifDeliveryOrder.WADAT_IST__c != null)? convertDateTime(ifDeliveryOrder.WADAT_IST__c):null;
        }
        if( ifDeliveryOrder.ZFETD__c     != '0000-00-00'){
            deliveryOrder.ETD__c             = (ifDeliveryOrder.ZFETD__c != null)? convertDate(ifDeliveryOrder.ZFETD__c) : null;
        }
        if( ifDeliveryOrder.ZFETA__c     != '0000-00-00'){
            deliveryOrder.ETA__c             = (ifDeliveryOrder.ZFETA__c != null)? convertDate(ifDeliveryOrder.ZFETA__c) : null;
        }

        deliveryOrder.VesselName__c      = (ifDeliveryOrder.ZFCARNM__c != null)? ifDeliveryOrder.ZFCARNM__c : null;
        deliveryOrder.ShippingCompany__c = (ifDeliveryOrder.ZFCSHCP__c != null)? ifDeliveryOrder.ZFCSHCP__c : null;  

        if(ifDeliveryOrder.ZZSTATUS__c == 'C'){
            deliveryOrder.Status__c = 'DOConfirmed';
        }

        return deliveryOrder; 
    }

// SOQL QUERY    
    private Map<String,Map<String,IF_DeliveryOrder__c>> getTableMapByScope(List<IF_DeliveryOrder__c> scope){
        Map<String,Map<String,IF_DeliveryOrder__c>> tableMap = new Map<String,Map<String,IF_DeliveryOrder__c>>();
        Map<String,IF_DeliveryOrder__c>             condMap       = new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             headerMap     = new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             noteMap       = new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             zcrms0062Map  = new Map<String,IF_DeliveryOrder__c>();
        Map<String,IF_DeliveryOrder__c>             totalIFDeliv  = new Map<String,IF_DeliveryOrder__c>();

        for(IF_DeliveryOrder__c item : scope ){
            
            item.IsConverted__c = true;             
                 if( item.ObjectType__c == 'T_COND'      && item.AUBEL__c != null ){
                condMap.put(item.AUBEL__c,item);   
                totalIFDeliv.put(item.ObjectType__c+'_'+item.AUBEL__c,item);
            }
            else if( item.ObjectType__c == 'T_HEADER'    && item.VBELN__c != null ){
                headerMap.put(item.VBELN__c,item);   
                totalIFDeliv.put(item.ObjectType__c+'_'+item.VBELN__c,item);

            }
            else if( item.ObjectType__c == 'T_NOTE'      && item.VBELN__c != null ){
                noteMap.put(item.VBELN__c,item);
                totalIFDeliv.put(item.ObjectType__c+'_'+item.VBELN__c,item);

            }
            else if( item.ObjectType__c == 'T_ZCRMS0062' && item.VBELN__c != null ){
                zcrms0062Map.put(item.VBELN__c,item);
                totalIFDeliv.put(item.ObjectType__c+'_'+item.VBELN__c,item);
            }           
            else{
                continue; 
            }
        }
        tableMap.put('T_COND'     ,condMap      );
        tableMap.put('T_HEADER'   ,headerMap    );   
        tableMap.put('T_NOTE'     ,noteMap      );   
        tableMap.put('T_ZCRMS0062',zcrms0062Map );   
        tableMap.put('IFOBJ'      ,totalIFDeliv );   

        return tableMap;
    }

// UTILS 
    public Date convertDate(String dateFromSAP){
        String[] dateInfoArr = dateFromSAP.split('-');
        return Date.newInstance(
            Integer.valueOf(dateInfoArr[0]),
            Integer.valueOf(dateInfoArr[1]),
            Integer.valueOf(dateInfoArr[2])
        );
    }

    public Datetime convertDateTime(String dateTimeFromSAP){
        String[] dateInfoArr = dateTimeFromSAP.split('-');
               return DateTime.newInstance(
            Integer.valueOf(dateInfoArr[0]),
            Integer.valueOf(dateInfoArr[1]),
            Integer.valueOf(dateInfoArr[2]),
            0,0,0
        );
    }

    public Datetime convertDateTime(String dateFromSAP, String timeFromSAP){
        String[] dateInfoArr =  dateFromSAP.split('-');
        String[] timeInfoArr =  timeFromSAP.split(':');

        return DateTime.newInstance(
            Integer.valueOf(dateInfoArr[0]),
            Integer.valueOf(dateInfoArr[1]),
            Integer.valueOf(dateInfoArr[2]),
            Integer.valueOf(timeInfoArr[0]),
            Integer.valueOf(timeInfoArr[1]),
            Integer.valueOf(timeInfoArr[2])
        );
    }


    private void assignException(Map<String,IF_DeliveryOrder__c> ifObjMap,String doNum, String message){
        IF_DeliveryOrder__c condObj   = ifObjMap.get('T_COND_'      +doNum) ;
        IF_DeliveryOrder__c headerObj = ifObjMap.get('T_HEADER_'    +doNum) ; 
        IF_DeliveryOrder__c noteObj   = ifObjMap.get('T_NOTE_'      +doNum) ;
        IF_DeliveryOrder__c zcrmObj   = ifObjMap.get('T_ZCRMS0062_' +doNum) ;   

        if(condObj!=null)   { condObj.ErrorTxt__c    = message;     condObj.IsConverted__c = false;}
        if(headerObj!=null) { headerObj.ErrorTxt__c  = message;   headerObj.IsConverted__c = false;}
        if(noteObj!=null)   { noteObj.ErrorTxt__c    = message;     noteObj.IsConverted__c = false;}
        if(zcrmObj!=null)   { zcrmObj.ErrorTxt__c    = message;     zcrmObj.IsConverted__c = false;}

    }

// Exception 
    public class NotFoundOrderException     extends Exception {}        
    public class NotExistTableTypeException extends Exception {}        
}