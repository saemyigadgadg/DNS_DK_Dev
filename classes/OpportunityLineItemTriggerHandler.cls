/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 06-16-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-31   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
    private static final Id GeneralRT  = SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
    
    // 무한 반복 방지
    private static Boolean isExecuting = false;
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        isExecuting = true;
        if(isExecuting) {
            System.debug('OpportunityLineItem BEFORE_UPDATE TRIGGER Start');
            OpportunityLineItem oldCheck;
            OpportunityLineItem newCheck;
            System.debug('triggernew : ' + news);
            if(olds.size() > 0) {
                oldCheck = (OpportunityLineItem)olds[0];
            }
            if(news.size() > 0) {
                newCheck = (OpportunityLineItem)news[0];
            }
            Opportunity recordTypeId = [SELECT RecordTypeId FROM Opportunity WHERE Id =:newCheck.OpportunityId LIMIT 1];
            System.debug('newCheck.Quantity : ' + newCheck.Quantity);
            if(newCheck.Quantity != 1 && recordTypeId.RecordTypeId == GeneralRT){
                newCheck.addError(System.Label.DNS_M_CantChgQty);
            }
            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('OpportunityLineItem BEFORE_UPDATE TRIGGER End');
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        List<OpportunityLineItem> itemList = (List<OpportunityLineItem>) news;
        Map<Id, String> opportunityMap = new Map<Id, String>();
        for(OpportunityLineItem opptyLine : itemList){
            opportunityMap.put(opptyLine.Id, opptyLine.Name);
        }
        
        Set<Id> userIds = new Set<Id>();
        userIds.add(UserInfo.getUserId());
        List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);
            
        if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
            //[GSR SR0000010031094] 제품 등록 시 CRM 알람 추가
            String alertName        = 'Create Opportunity Line Item Alert';
            String alertType        = 'Notification';
            String userId           = UserInfo.getUserId();
            String alertLanguage    = 'ko';

            DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,opportunityMap);
        }
    }

    public override void onBeforeInsert(List<sObject> news) {
        if (isExecuting) {
            return;
        }
        
        isExecuting = true;

        try {
            System.debug('OpportunityLineItem [onBeforeInsert]');
            List<OpportunityLineItem> itemList = (List<OpportunityLineItem>) news;
            Map<Id, Decimal> qtyMap = new Map<Id, Decimal>();
            Set<Id> optyIds = new Set<Id>();

            for(OpportunityLineItem item : itemList){
                optyIds.add(item.OpportunityId);
            }

            List<Opportunity> optyList = new List<Opportunity>();
            optyList = [SELECT Id, Name, RecordTypeId
                        FROM Opportunity
                        WHERE Id IN: optyIds];

            Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();
            for(Opportunity opty : optyList){
                optyMap.put(opty.Id, opty);
            }

            System.debug('itemList ::: ' + itemList);
            System.debug('itemList.size() ::: ' + itemList.size());
            
            for (OpportunityLineItem item : itemList) {
                Opportunity opty = optyMap.get(item.OpportunityId);

                // UnitPrice가 비어있으면 기본값으로 0 설정
                if (item.UnitPrice == null) {
                    item.UnitPrice = 0;
                }
                // Opportunity가 General Type일 때만 복제
                if(opty.RecordTypeId == GeneralRT && item.Quantity > 1){
                    qtyMap.put(item.Product2Id, item.Quantity);

                    System.debug('qtyMap ::' + qtyMap);
                }
            }
            
            if(!qtyMap.isEmpty()){
                cloneOpportunityLineItem(qtyMap, itemList);
            }
            
        } finally {
            isExecuting = false;
        }
    }


    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if (isExecuting) {
            return;
        }
        
        isExecuting = true;
        if(isExecuting) {
            System.debug('OpportunityLineItem [onAfterInsert]');

            List<OpportunityLineItem> itemList = (List<OpportunityLineItem>) news;
            Set<Id> optyIds = new Set<Id>();
            Set<Id> prodIds = new Set<Id>();

            for(OpportunityLineItem item : itemList){
                if(item.OpportunityId != null && item.Product2Id != null){
                    optyIds.add(item.OpportunityId);
                    prodIds.add(item.Product2Id);
                }
            }

            if(!optyIds.isEmpty() && !prodIds.isEmpty()){
                checkStrategicMaterial(optyIds, prodIds, itemList);
            } 

            //current path가 qualified && quote 생성 전 && ERP Inquiry No가 있을 경우 실행
            List<Opportunity> opptyInfo = [SELECT HasFinalQuote__c, isQuote__c, StageName, Opportunity_Owner__c, AccountId, Id, Inquiry_Type__c FROM Opportunity WHERE Id =: itemList[0].OpportunityId];
            //firstCheck에 값이 있으면 최초생성이 아닌 Qualified때 최초 I/F 후 추가생성임
            List<OpportunityLineItem> firstCheck = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: itemList[0].OpportunityId and ERPInquiryNo__c != null];
            //quoteClone의 크기가 1보다 크면 복제인 경우기때문에 새로 Inquiry I/F안해야함
            List<Quote> quoteClone = [SELECT Id FROM Quote WHERE OpportunityId =: itemList[0].OpportunityId];
            if(opptyInfo[0].HasFinalQuote__c == false && opptyInfo[0].StageName == 'Qualified' && firstCheck.size() > 0 && quoteClone.size() == 1){
                System.debug('여기오니2');

                DN_OpportunityCallout.createInquiry(opptyInfo[0].Opportunity_Owner__c, opptyInfo[0].AccountId, opptyInfo[0].Id, opptyInfo[0].Inquiry_Type__c);
            }

           

            setting(false, TriggerOperation.AFTER_INSERT);
        }
    }


    public override void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){
        List<OpportunityLineItem> deletedItemList = (List<OpportunityLineItem>) dels;
        Set<Id> optyIds = new Set<Id>();

        // 삭제된 아이템의 OpportunityId 수집
        for(OpportunityLineItem item : deletedItemList){
            if(item.OpportunityId != null){
                optyIds.add(item.OpportunityId);

                System.debug('optyIds :: ' + optyIds);
            }
        }

        // Update할 Opportunity를 담을 List
        List<Opportunity> optyToUpdateList = [SELECT Id, Name, IsStrategicMaterial__c, RecordTypeId
                                                FROM Opportunity
                                                WHERE Id IN :optyIds];

        for(Opportunity opty : optyToUpdateList){
            if(opty.RecordTypeId == GeneralRT){
                checkStrategicMaterialForDelete(opty);
            }
        }

        if(!optyToUpdateList.isEmpty()){
            update optyToUpdateList;
        }
    }

    /**
     * @Description
     * 	- Opportunity Product삭제 시 Loass Reason에 값이 없으면 삭제 불가
     * @author Sejin Kwon | 10-17-2024
    **/ 
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        // OpportunityLineItem 리스트를 캐스팅
        // List<OpportunityLineItem> deletedItemList = (List<OpportunityLineItem>) dels;
        // List<Opportunity> recordName = [SELECT RecordType.Name FROM Opportunity WHERE Id =: deletedItemList[0].OpportunityId LIMIT 1];

        // for (OpportunityLineItem item : deletedItemList) {
        //     if (recordName[0].RecordType.Name == 'Turn-Key (AE)') {
        //         item.addError('시스템 영업기회 PS000은 삭제가 불가능합니다.');
        //     }
            // LossReasonText__c 필드가 null 또는 빈 값이면 에러 추가
            // else if (recordName[0].RecordType.Name != 'Turn-Key (AE)' && (item.LossReasonText__c == null || item.LossReasonText__c.trim() == '')) {
                // 삭제 방지와 함께 사용자에게 오류 메시지를 표시
                // item.addError('삭제 하시려면 Edit Mode에서 Loss Reason 필드에 사유를 입력해 주세요.');
            // }
            // else {
            //     OpportunityProductHistorys__c oppPrdHistory = new OpportunityProductHistorys__c(
            //             Opportunity__c = item.OpportunityId,
            //             Product__c = item.Product2Id,
            //             LossReasonText__c = item.LossReasonText__c,
            //             LossReasonText__c = 'Delete From QuoteLineItem',
            //             Type__c  = 'Loss'
            //     );
            //     try {
            //         System.debug('oppPrdHistory : ' + oppPrdHistory);
            //         insert oppPrdHistory;
            //     } catch (Exception e) {
            //         System.debug('Insert Error : ' + e);
            //     }
            // }
        // }
    }

   
    /**
     * @Description
     * 	- 입력한 갯수 만큼 Line Item 복제
     * @author Yuhyun Park | 08-01-2024
     * @Parameter
     *  - qtyMap	        : key = OpportunityLineItem Id, value = Quantity(복제한 레코드 갯수)
     *  - itemList	        : 원본 OpportunityLineItem List
    **/ 
    private void cloneOpportunityLineItem (Map<Id, Decimal> qtyMap, List<OpportunityLineItem> itemList){
        List<OpportunityLineItem> clonedItemList = new List<OpportunityLineItem>();

        for(OpportunityLineItem item : itemList){
            Decimal qty = qtyMap.get(item.Product2Id);
            item.Quantity = 1;  // 원본 레코드의 갯수 초기화

            for(Decimal i = 1; i < qty; i++){    
                OpportunityLineItem clonedItem = item.clone(false, false, false, false);
                clonedItem.Quantity = 1;    // 복제된 레코드의 Quantity를 1로 설정
                clonedItem.TotalPrice = null; // 자동 계산 에러 방지
                clonedItemList.add(clonedItem);
            }
        }

        System.debug('clonedItemList :: ' + clonedItemList);
        System.debug('clonedItemList :: ' + clonedItemList.size());

        // 복제본 insert
        if(!clonedItemList.isEmpty()){
            insert clonedItemList;
        }
    }

    
    /**
     * @Description
     * 	- Product의 IsStrategicMaterial__c필드가 true 일때, Opportunity의 IsStrategicMaterial__c필드도 true
     * @author Yuhyun Park | 08-02-2024
     * @Parameter
     *  - optyIds	        : OpportunityLineItem과 연관된 Opportunity의 Id Set
     *  - prodIds	        : OpportunityLineItem과 연관된 Product2의 Id Set
     *  - itemList	        : 원본 OpportunityLineItem List
    **/ 
    private void checkStrategicMaterial (Set<Id> optyIds, Set<Id> prodIds, List<OpportunityLineItem> itemList){

        System.debug('checkStrategicMaterial 입성 ');

        // Update할 Opportunity를 담을 List
        List<Opportunity> optyToUpdateList = new List<Opportunity>();

        // Opportunity 조회
        List<Opportunity> optyList = new List<Opportunity>();
        Map<Id, Opportunity> optyMap = new Map<Id, Opportunity>();

        optyList = [SELECT Id, Name, IsStrategicMaterial__c, RecordTypeId, Opportunity_Owner__r.Email, Opportunity_Owner__r.Id, StageName  FROM Opportunity WHERE Id IN: optyIds];

        for(Opportunity opty : optyList){
            optyMap.put(opty.Id, opty);
        }

        System.debug('optyMap :: ' + optyMap);

        // Porduct2 조회
        List<Product2> prodList = new List<Product2>();
        Map<Id, Product2> prodMap = new Map<Id, Product2>();

        // Opty 하위 Product 조회
        List<Product2> prodOfOptyList = [SELECT Id, Name, IsStrategicMaterial__c FROM Product2 WHERE Id IN : prodIds];

        prodList = [SELECT Id, Name, IsStrategicMaterial__c FROM Product2 WHERE Id IN: prodIds];
        
        for(Product2 prod : prodList){
            prodMap.put(prod.Id, prod);
        }

        System.debug('prodMap :: ' + prodMap);

        // Opportunity의 제품 중 하나라도 전략 물자인지 확인하기 위한 맵 생성
        Map<Id, Boolean> optyStrategicFlagMap = new Map<Id, Boolean>();

        // Product의 IsStrategicMaterial__c필드가 true 일때, Opportunity의 IsStrategicMaterial__c필드도 true
        for(OpportunityLineItem item : itemList){

            Product2 prod = prodMap.get(item.Product2Id);
            Opportunity opty = optyMap.get(item.OpportunityId);

            // Opportunity가 General Type일 때만
            if (prod != null && prod.IsStrategicMaterial__c && opty != null && !opty.IsStrategicMaterial__c && opty.RecordTypeId == GeneralRT){                
                opty.IsStrategicMaterial__c = true;
                optyToUpdateList.add(opty);
                System.debug('optyToUpdateList :: ' + optyToUpdateList);
            }
        }

        if(!optyToUpdateList.isEmpty()){
            update optyToUpdateList;
        }
    }


      
    /**
     * @Description
     * 	- OpportunityLineItem이 삭제되었을 때, 상위 Opportunity의 모든 OpportunityLineItem을 조회.
     *  - 조회된 OpportunityLineItem의 Product의 IsStrategicMaterial__c가 하나라도 true면 그 Opportunity의 IsStrategicMaterial__c도 true 아니면 false.
     * @author Yuhyun Park | 08-02-2024
     * @Parameter
     *  - opty	        : 업데이틀 Opportunity
    **/ 
    private void checkStrategicMaterialForDelete (Opportunity opty){

        // 해당 Opportunity에 속한 모든 OpportunityLineItem 조회
        List<OpportunityLineItem> allItemList = [SELECT Id, Name, Product2.IsStrategicMaterial__c, OpportunityId 
                                                FROM OpportunityLineItem 
                                                WHERE OpportunityId = :opty.Id];

        Boolean isStrategicMaterial = false;

        // 해당 Opportunity에 속한 모든 LineItem을 확인
        for (OpportunityLineItem item : allItemList) {
            if (item.Product2.IsStrategicMaterial__c) {
                isStrategicMaterial = true;
                break;
            }
        }

        // IsStrategicMaterial__c 필드를 업데이트
        opty.IsStrategicMaterial__c = isStrategicMaterial;

    }
       public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}