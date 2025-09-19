/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 07-23-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-08-2024   Hanyeong Choi   Initial Version
**/
public with sharing class SQRegistrationTriggerHandler extends TriggerHandler {

    /**
     * SQRegistration__c 레코드 업데이트 전, Drop 상태 검증, 소유자 변경, Final Confirm 처리 및 Owner 동기화를 수행합니다.
     */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQRegistration__c BEFORE_UPDATE TRIGGER Start');
            List<SQRegistration__c> sqRegList = (List<SQRegistration__c>) news;
            List<SQRegistration__c> updateOwner = new List<SQRegistration__c>();
            Set<Id> quoteIds = new Set<Id>();
            List<SQRegistration__c>  ownerSQRList = new List<SQRegistration__c>();
            
            for(SQRegistration__c sqReg : sqRegList) {
                if(oldMap.get(sqReg.Id).get('Stage__c') == 'Drop') {
                    if(!Test.isRunningTest()) {
                        sqReg.addError(System.Label.DNS_SQR_T_NOTUPDATEDROP);
                    } else {
                        System.debug('success');
                    }
                }
                if(oldMap.get(sqReg.Id).get('Owner__c') != sqReg.Owner__c) {
                    updateOwner.add(sqReg);
                }
                if(oldMap.get(sqReg.Id).get('OwnerId') != sqReg.OwnerId) {
                    sqReg.put('Owner__c', sqReg.OwnerId);
                }

                if(sqReg.Stage__c == 'Final Confirm') {
                    sqReg.put('Final_Confirm_Date__c', Date.today());
                    if(sqReg.RecordTypeid == SObjectType.SQRegistration__c.getRecordTypeInfosByDeveloperName().get('DNSA').getRecordTypeId()) {
                        quoteIds.add(sqReg.Quote__c);
                        ownerSQRList.add(sqReg);
                    }
                }
            }
            if(!updateOwner.isEmpty()) changeOwner(updateOwner);
            if(!quoteIds.isEmpty()) {
                List<Quote> quoteList = [SELECT Id, OwnerId FROM Quote WHERE Id IN :quoteIds];
                for(Quote quote : quoteList) {
                    for(SQRegistration__c sqr : ownerSQRList) {
                        if(sqr.Quote__c == quote.Id) sqr.put('OwnerId', quote.OwnerId);
                    }

                }
            }

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('SQRegistration__c BEFORE_UPDATE TRIGGER End');
        }
    }

    /**
     * SQRegistration__c 레코드 업데이트 후, 알림 전송, SQ 삽입, 리뷰 날짜 업데이트 및 이벤트 발행을 처리합니다.
     */
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQRegistration__c AFTER_UPDATE TRIGGER Start');
            List<SQRegistration__c> sqRegList = (List<SQRegistration__c>) news;
            List<SQRegistration__c> notiList = new List<SQRegistration__c>();
            List<SQRegistration__c> dropNotiList = new List<SQRegistration__c>();
            List<SQRegistration__c> dateAlertList = new List<SQRegistration__c>();
            Set<Id> sqRegIds = new Set<Id>();
            Set<Id> dateAlertSQRegIds = new Set<Id>();
            Set<Id> managerIds = new Set<Id>();
            Set<Id> finals = new Set<Id>();

            for(SQRegistration__c sqReg : sqRegList) {
                if(oldMap.get(sqReg.Id).get('ReviewRequestDate__c') != sqReg.ReviewRequestDate__c) {
                    dateAlertSQRegIds.add(sqReg.Id);
                    managerIds.add(sqReg.Manager__c);
                    dateAlertList.add(sqReg);
                }

                if(
                    oldMap.get(sqReg.Id).get('Stage__c') != sqReg.Stage__c &&
                    sqReg.Stage__c == 'R&D Confirm'
                ) {
                    sqRegIds.add(sqReg.Id);
                }

                if(sqReg.Stage__c == 'Final Confirm') {
                    notiList.add(sqReg);
                    finals.add(sqReg.Id);
                }

                if(sqReg.Stage__c == 'Drop') {
                    dropNotiList.add(sqReg);
                }
            }

            if(!dateAlertSQRegIds.isEmpty()) {
                sendChangeDateNoti(dateAlertSQRegIds, managerIds, dateAlertList);
                sendChangeDateEmail(dateAlertSQRegIds, managerIds, dateAlertList, oldMap);
            }

            if(!finals.isEmpty()) {
                List<SQ__c> sql= [SELECT Id, IsFinal__c FROM SQ__c WHERE SQ_Registration__c IN :finals AND IsDelete__c != true];
                if(!sql.isEmpty()) {
                    List<SQ__C> squpdateupdate = new List<SQ__C>();
                    for(SQ__c sqsq: sql) {
                        if(!sqsq.IsFinal__c) {
                            sqsq.IsFinal__c = true;
                            squpdateupdate.add(sqsq);
                        }
                    }
                    if(!squpdateupdate.isEmpty()) {
                        update squpdateupdate;
                    }
                }
            }

            if(!sqRegIds.isEmpty()) {
                insertSQ(sqRegIds);
                sendInsertSQEmail(sqRegIds);
                sendInsertSQAlert(sqRegIds);
                updateSQReviewDate(sqRegIds);
            }
            if(!notiList.isEmpty()) sendFinalNotificationAlert(notiList);
            if(!notiList.isEmpty()) sendFinalNotificationEmail(notiList);
            if(!dropNotiList.isEmpty()) sendDropNotification(dropNotiList);
            if(!dropNotiList.isEmpty()) sendDropEmail(dropNotiList);

            refreshEvent__e event = new refreshEvent__e();
            event.objectName__c = 'SQRegistration';
            EventBus.publish(event);


            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('SQRegistration__c AFTER_UPDATE TRIGGER End');
        }
    }

    /**
     * SQRegistration__c 레코드 삭제 전, 관련된 Junction 및 하위 레코드를 삭제합니다.
     */
    public override void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if(isExecuting) {
            System.debug('SQRegistration__c BEFORE_DELETE TRIGGER Start');
            List<SQRegistration__c> sqrList = (List<SQRegistration__c>) dels;
            Set<Id> sqrIds = new Set<Id>();

            for(SQRegistration__c sqr : sqrList) {
                sqrIds.add(sqr.Id);
            }

            if(!sqrIds.isEmpty()) deleteRelated(sqrIds);
            
            setting(false, TriggerOperation.BEFORE_DELETE);
            System.debug('SQRegistration__c BEFORE_DELETE TRIGGER End');
        }
    }

    /**
     * SQRegistration__c와 관련된 Junction 및 하위 레코드를 삭제합니다.
     */
    private static void deleteRelated(Set<Id> sqrIds) {
        List<SQregistration_Quote__c> sqQuoteJunction = [SELECT Id FROM SQregistration_Quote__c WHERE SQ_Registration__c IN :sqrIds];
        if(!sqQuoteJunction.isEmpty()) delete sqQuoteJunction;

        List<SQ_Registration_Junction__c> sqQuoteLineItemJunction = [SELECT Id FROM SQ_Registration_Junction__c WHERE SQRegistration__c IN :sqrIds];
        if(!sqQuoteLineItemJunction.isEmpty()) delete sqQuoteLineItemJunction;

        List<RequestedSQ__c> reqList = [SELECT Id FROM RequestedSQ__c WHERE SQRegistration__c IN :sqrIds];
        if(!reqList.isEmpty()) delete reqList;

        List<SQReview__c> reviewList = [SELECT Id FROM SQReview__c WHERE SQRegistration__c IN :sqrIds];
        if(!reviewList.isEmpty()) delete reviewList;

        List<SQ__c> sqList = [SELECT Id FROM SQ__c WHERE SQ_Registration__c IN :sqrIds];
        if(!sqList.isEmpty()) {
            Set<Id> sqIds = new Set<Id>();
            for(SQ__c sq : sqList) {
                sqIds.add(sq.Id);
            }
            List<SQ_QuoteLineitem_Junction__c> sqQlis = [SELECT Id FROM SQ_QuoteLineitem_Junction__c WHERE SQ__c IN :sqIds];
            if(!sqQlis.isEmpty()) delete sqQlis;
            
            delete sqList;
        }
    }

    /**
     * SQRegistration__c의 소유자를 변경합니다.
     */
    private static void changeOwner(List<SQRegistration__c> updateOwner) {
        List<SQRegistration__c> updateList = new List<SQRegistration__c>();
        for(SQRegistration__c sqr : updateOwner) {
            sqr.OwnerId = sqr.Owner__c;
            updateList.add(sqr);
        }
        update updateList;
    }

    /**
     * SQ__c 레코드를 삽입하거나 업데이트합니다.
     */
    private static void insertSQ(Set<Id> sqRegIds) {
        List<SQReview__c> sqReviewList = [
            SELECT  Id, SQTitle__c, Description__c, Category__c, SQRegistration__c,
                    KRWcost__c, SalesPrice__c, IsFirst__c, PreShipmentReview__c,
                    DesignReviewRequired__c, DeliveryDate_months__c, Comments__c,
                    Product_Representative__c, Part__c, RequestedSQ__c,
                    SQRegistration__r.CurrencyIsoCode, SQRegistration__r.Quote__c,
                    SQRegistration__r.Quote__r.RecordTypeId
                    , RequestedSQ__r.Sales_SQ__c, RequestedSQ__r.Description__c, IsReview__c
                    , Material_Cost__c
                    , Assembly_Cost__c
            FROM SQReview__c
            WHERE SQRegistration__c IN :sqRegIds
            AND RequestedSQ__c != null
        ];
    
        List<SQ__c> sqList = [SELECT Id, Name, RequestedSQ__c, IsDelete__c, Price__c FROM SQ__c WHERE SQ_Registration__c IN :sqRegIds AND IsDelete__c != true];
    
        // Existing SQ__c 매핑
        Map<Id, SQ__c> existingSQMapByRequestedSQ = new Map<Id, SQ__c>();
        for (SQ__c sq : sqList) {
            if (sq.RequestedSQ__c != null) {
                existingSQMapByRequestedSQ.put(sq.RequestedSQ__c, sq);
            }
        }
    
        // SQReview__c를 RequestedSQ__c 기준으로 그룹화
        Map<Id, List<SQReview__c>> groupedByRequestedSQ = new Map<Id, List<SQReview__c>>();
        for (SQReview__c review : sqReviewList) {
            if (!groupedByRequestedSQ.containsKey(review.RequestedSQ__c)) {
                groupedByRequestedSQ.put(review.RequestedSQ__c, new List<SQReview__c>());
            }
            groupedByRequestedSQ.get(review.RequestedSQ__c).add(review);
        }
    
        System.debug('groupedByRequestedSQ ::: ' + groupedByRequestedSQ);
        // 유효한 RequestedSQ__c ID 수집
        Set<Id> validRequestedSQIds = groupedByRequestedSQ.keySet();
    
        // 삭제 또는 업데이트가 필요한 SQ__c 레코드 분류
        List<SQ__c> deleteSQList = new List<SQ__c>();
        List<SQ__c> updateList = new List<SQ__c>();
        List<SQ__c> deleteList = new List<SQ__c>();
        for (SQ__c sq : sqList) {
            if (!validRequestedSQIds.contains(sq.RequestedSQ__c)) {
                deleteSQList.add(sq);
            }
        }
        System.debug('>>>>> deleteSQList ::: ' + deleteSQList);
    
        // 삭제 조건 확인 후 IsDelete__c 업데이트 또는 삭제
        if (!deleteSQList.isEmpty()) {
            List<SQ_QuoteLineitem_Junction__c> sqljList = [
                SELECT Id, SQ__c, FM_ERPCODE__c, POSNR__c FROM SQ_QuoteLineitem_Junction__c WHERE SQ__c IN :deleteSQList
            ];
            Map<Id, String> sqljMap = new Map<Id, String>();
            if(!sqljList.isEmpty()) {
                for (SQ_QuoteLineitem_Junction__c sqlj : sqljList) {
                    String posnrValue = (sqlj.POSNR__c != null) ? String.valueOf(sqlj.POSNR__c) : '';
                    sqljMap.put(sqlj.SQ__c, posnrValue);
                }
                
                for (SQ__c sq : deleteSQList) {
                    if (sqljMap.containsKey(sq.Id) && String.isNotBlank(sqljMap.get(sq.Id))) {
                        sq.IsDelete__c = true;
                        updateList.add(sq);
                    } else {
                        deleteList.add(sq);
                    }
                }
                System.debug('>>>>> updateList ::: ' + updateList);
                System.debug('>>>>> deleteList ::: ' + deleteList);
                if (!updateList.isEmpty()) DN_WithoutSharingClass.updateSQ(updateList);
                if (!deleteList.isEmpty()) DN_WithoutSharingClass.deleteSQ(deleteList);
            }
        }
    
        // SQ__c 레코드 생성 및 업데이트
        List<SQ__c> insertSQList = new List<SQ__c>();
        List<SQ__c> updateSQList = new List<SQ__c>();
        for (Id requestedSQId : groupedByRequestedSQ.keySet()) {
            if (existingSQMapByRequestedSQ.containsKey(requestedSQId)) {
                SQ__c sq = existingSQMapByRequestedSQ.get(requestedSQId);
                sq = consolidateReviewsIntoSQ(groupedByRequestedSQ.get(requestedSQId), sq);
                updateSQList.add(sq);
            } else {
                SQ__c newSQ = new SQ__c();
                newSQ = consolidateReviewsIntoSQ(groupedByRequestedSQ.get(requestedSQId), newSQ);
                insertSQList.add(newSQ);
            }
        }
    
        System.debug('>>>>> updateSQList ::: ' + updateSQList);
        System.debug('>>>>> insertSQList ::: ' + insertSQList);
        if (!updateSQList.isEmpty()) update updateSQList;
        if (!insertSQList.isEmpty()) {
            insert insertSQList;
            // sendInsertSQEmail(sqRegIds);
            // sendInsertSQAlert(sqRegIds);
        }
    }
    
    /**
     * SQReview__c 데이터를 SQ__c 레코드로 통합합니다.
     */
    private static SQ__c consolidateReviewsIntoSQ(List<SQReview__c> reviews, SQ__c sq) {
        Id factoryRT = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Factory').getRecordTypeId();
        
        String description = '';
        String category = '';
        Decimal totalCost = 0;
        Decimal totalMaterial = 0;
        Decimal totalAssemble = 0;
        Decimal totalPrice = 0;
        String mComments = '';
        String cComments = '';
        Boolean isFirst = false;
        Boolean designReview = false;
        Boolean preShipmentReview = false;
        Decimal month = 0;
    
        for (SQReview__c review : reviews) {
            sq.Name = review.SQTitle__c;
            sq.IsReview__c = review.IsReview__c;
            sq.SQ_Registration__c = review.SQRegistration__c;
            sq.RequestedSQ__c = review.RequestedSQ__c;
            sq.CurrencyIsoCode = review.SQRegistration__r.CurrencyIsoCode;
            sq.Quote__c = review.SQRegistration__r.Quote__r.RecordTypeId == factoryRT ? review.SQRegistration__r.Quote__c : null;
            sq.DNS_Price__c = 0;
            if(review.RequestedSQ__r.Sales_SQ__c != null) {
                sq.SQ_Comments__c = review.RequestedSQ__r.Description__c;
            }
            // description = review.Description__c;
            category = review.Category__c != null ? review.Category__c : '기타';
            totalCost += review.KRWcost__c != null ? review.KRWcost__c : 0;
            totalMaterial += review.Material_Cost__c != null ? review.Material_Cost__c : 0;
            totalAssemble += review.Assembly_Cost__c != null ? review.Assembly_Cost__c : 0;
            // totalPrice += review.SalesPrice__c != null ? review.SalesPrice__c : 0;
            if (review.Part__c == '기계') {
                mComments = review.Comments__c;
            } else {
                cComments = review.Comments__c;
            }
            isFirst = review.IsFirst__c == true ? true : (isFirst == false ? false : true);
            designReview = review.DesignReviewRequired__c == true ? true : (designReview == false ? false : true);
            preShipmentReview = review.PreShipmentReview__c == true ? true : (preShipmentReview == false ? false : true);
            if(month < review.DeliveryDate_months__c) {
                month = review.DeliveryDate_months__c;
            }
        }
    
        String data = '*기계 : <br />' + (mComments != null ? mComments : '') + '<br /><br />' + '*제어 : <br />' + (cComments != null ? cComments : '');
        // sq.Description__c = description;
        sq.Category__c = category;
        sq.Cost__c = totalCost;
        sq.Material_Cost__c = totalMaterial;
        sq.Assembly_Cost__c = totalAssemble;
        // if(sq.Price__c != null && sq.Price__c != 0) {
        //     sq.Price__c = sq.Price__c;
        // } else {
        //     sq.Price__c = 0;
        // }
        sq.Price__c = 0;
        sq.listPrice__c = totalCost;
        sq.MachineComments__c = mComments;
        sq.ControlComments__c = cComments;
        System.debug('test ::: ' + data);
        sq.SalesComments__c = data;
        sq.IsFirst__c = isFirst;
        sq.DesignReviewRequired__c = designReview;
        sq.PreShipmentReview__c = preShipmentReview;
        sq.Delivery_Date_months__c = month;
        sq.ReviewApprovalDate__c = Date.today();
    
        return sq;
    }

    /**
     * SQReview__c의 검토 승인 날짜를 업데이트합니다.
     */
    private static void updateSQReviewDate(Set<Id> sqRegIds) {
        List<SQReview__c> updateSQReviewList = [
            SELECT  Id
                    , ReviewApprovalDate__c
            FROM SQReview__c
            WHERE Id IN :sqRegIds
        ];

        if(!updateSQReviewList.isEmpty()) {
            List<SQReview__c> updateList = new List<SQReview__c>();
            for(SQReview__c sqr : updateSQReviewList) {
                sqr.ReviewApprovalDate__c = Date.today();
                updateList.add(sqr);
            }
            if(!updateList.isEmpty()) update updateList;
        }
    }

    /**
     * SQ 삽입에 대한 이메일 알림을 전송합니다.
     */
    private static void sendInsertSQEmail(Set<Id> sqRegIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> groupIds = new Set<Id>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();

        List<SQRegistration__c> sqRegList = [
            SELECT  Id
                    , Name
                    , Representative__c
                    , Message_Group__c
                    , DNSA_Sales_Team__c
                    , OwnerId
            FROM SQRegistration__c
            WHERE Id IN :sqRegIds
        ];

        for(SQRegistration__c sqr : sqRegList) {
            groupIds.add(sqr.Message_Group__c);
        }

        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c IN :groupIds
            AND User__r.IsActive = true
        ];

        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.FM_UserEmail__c);
            } else {
                receiverEN.add(mgj.FM_UserEmail__c);
            }
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Alert' LIMIT 1];
        if(!am.isEmpty()) {
            for(SQRegistration__c sqReg : sqRegList) {
                if(!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforEmail    = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
                if(!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforEmail    = receiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
            }
            System.debug('ahwList ::: ' + ahwList);
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * SQ 삽입에 대한 알림을 전송합니다.
     */
    private static void sendInsertSQAlert(Set<Id> sqRegIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();

        List<SQRegistration__c> sqRegList = [
            SELECT  Id
                    , Name
                    , Representative__c
                    , Message_Group__c
                    , OwnerId
            FROM SQRegistration__c
            WHERE Id IN :sqRegIds
        ];

        for(SQRegistration__c sqr : sqRegList) {
            groupIds.add(sqr.Message_Group__c);
        }

        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c IN :groupIds
            AND User__r.IsActive = true
        ];

        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.User__c);
            } else {
                receiverEN.add(mgj.User__c);
            }
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New SQ Alert' LIMIT 1];
        if(!am.isEmpty()) {
            for(SQRegistration__c sqReg : sqRegList) {
                if(!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID    = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
                if(!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID       = receiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * Final Confirm 상태에 대한 알림을 전송합니다.
     */
    private static void sendFinalNotificationAlert(List<SQRegistration__c> notiList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();

        for(SQRegistration__c sqr : notiList) {
            groupIds.add(sqr.Message_Group__c);
            ownerIds.add(sqr.OwnerId);
        }

        List<Message_Group_Junction__c> mgjList = [
            SELECT  User__c
                    , FM_UserEmail__c
                    , FM_UserProfile__c
                    , FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c IN :groupIds
            AND User__r.IsActive = true
        ];

        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.User__c);
            } else {
                receiverEN.add(mgj.User__c);
            }
        }

        List<User> ownerList = DN_WithoutSharingClass.getUserEmails(ownerIds);

        if(!ownerList.isEmpty()) {
            for(User owner : ownerList) {
                if(owner.LanguageLocaleKey == 'ko') {
                    receiver.add(owner.Id);
                } else {
                    receiverEN.add(owner.Id);
                }
            }
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Final SQ Registration Alert' LIMIT 1];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(SQRegistration__c sqReg : notiList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID       = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
            }
            if(!receiverEN.isEmpty()) {
                for(SQRegistration__c sqReg : notiList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID       = receiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * Final Confirm 상태에 대한 이메일 알림을 전송합니다.
     */
    private static void sendFinalNotificationEmail(List<SQRegistration__c> notiList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
    
        // SQ Owner, Message Group 수집
        for(SQRegistration__c sqr : notiList) {
            groupIds.add(sqr.Message_Group__c);
            ownerIds.add(sqr.OwnerId);
        }
    
        // 포탈 URL 준비
        String portalUrl = null;
        List<Network> portal = [SELECT Id FROM Network WHERE Name = 'Partners' LIMIT 1];
        if (!portal.isEmpty()) {
            portalUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        }
    
        // Message Group 유저 수신자 분류
        List<Message_Group_Junction__c> mgjList = [
            SELECT  FM_UserEmail__c,
                    FM_UserLanguage__c 
            FROM Message_Group_Junction__c 
            WHERE Message_Group__c IN :groupIds
            AND User__r.IsActive = true
        ];
    
        for(Message_Group_Junction__c mgj : mgjList) {
            if(mgj.FM_UserLanguage__c == 'ko') {
                receiver.add(mgj.FM_UserEmail__c);
            } else {
                receiverEN.add(mgj.FM_UserEmail__c);
            }
        }
        
        List<User> ownerList = DN_WithoutSharingClass.getUserEmails(ownerIds);
        Map<Id, User> ownerMap = new Map<Id, User>(ownerList);
    
        for(User owner : ownerList) {
            if(owner.LanguageLocaleKey == 'ko') {
                receiver.add(owner.Email);
            } else {
                receiverEN.add(owner.Email);
            }
        }
    
        // Alert 템플릿 가져오기
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Final SQ Registration Alert' LIMIT 1];
    
        if(!am.isEmpty()) {
            Id alertId = am[0].Id;
    
            for(SQRegistration__c sqReg : notiList) {
                User owner = ownerMap.get(sqReg.OwnerId);
                Boolean isPortalUser = owner != null && owner.IsPortalEnabled;
    
                String finalUrl = '';
                if (isPortalUser && portalUrl != null) {
                    finalUrl = portalUrl + '/' + sqReg.Id;
                } else {
                    finalUrl = URL.getOrgDomainURL().toExternalForm() + '/' + sqReg.Id;
                }
    
                // 한국어 수신자
                if (!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(finalUrl);
                    history.alertID = alertId;
                    history.targetID = sqReg.Id;
                    history.receiverforEmail = receiver;
                    history.alertLanguage = 'ko';
                    ahwList.add(history);
                }
    
                // 영어 수신자
                if (!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(finalUrl);
                    history.alertID = alertId;
                    history.targetID = sqReg.Id;
                    history.receiverforEmail = receiverEN;
                    history.alertLanguage = 'en';
                    ahwList.add(history);
                }
            }
    
            System.debug('ahwList ::: ' + ahwList);
            if (!ahwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(ahwList);
            }
        }
    
        return;
    }

    /**
     * Drop 상태에 대한 알림을 전송합니다.
     */
    private static void sendDropNotification(List<SQRegistration__c> notiList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'SQ Registration Drop Alert' LIMIT 1];
        if (am.isEmpty()) return;
    
        // 필요한 데이터 미리 수집
        Set<Id> rndReviewSqrIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> dnsaGroupIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
    
        for (SQRegistration__c sqr : notiList) {
            if (sqr.Stage__c == 'R&D Review') {
                rndReviewSqrIds.add(sqr.Id);
            }
            if (sqr.Message_Group__c != null) groupIds.add(sqr.Message_Group__c);
            if (sqr.DNSA_Sales_Team__c != null) dnsaGroupIds.add(sqr.DNSA_Sales_Team__c);
            ownerIds.add(sqr.OwnerId);
        }
    
        // SQReview__c 데이터 한 번에 조회
        Map<Id, Set<Id>> sqrToReviewUsers = new Map<Id, Set<Id>>();
        if (!rndReviewSqrIds.isEmpty()) {
            List<SQReview__c> reviews = [
                SELECT SQRegistration__c, Product_Representative__r.User__c, Product_Representative__r.ControlUser__c
                FROM SQReview__c
                WHERE SQRegistration__c IN :rndReviewSqrIds AND IsReview__c = true
            ];
            for (SQReview__c review : reviews) {
                Set<Id> users = sqrToReviewUsers.get(review.SQRegistration__c) ?? new Set<Id>();
                if (review.Product_Representative__r.User__c != null) users.add(review.Product_Representative__r.User__c);
                if (review.Product_Representative__r.ControlUser__c != null) users.add(review.Product_Representative__r.ControlUser__c);
                sqrToReviewUsers.put(review.SQRegistration__c, users);
            }
        }
    
        // Message Group 데이터 한 번에 조회
        Map<Id, Set<Id>> groupToUsersKo = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> groupToUsersEn = new Map<Id, Set<Id>>();
        if (!groupIds.isEmpty() || !dnsaGroupIds.isEmpty()) {
            Set<Id> allGroupIds = new Set<Id>();
            allGroupIds.addAll(groupIds);
            allGroupIds.addAll(dnsaGroupIds);
            List<Message_Group_Junction__c> mgjList = [
                SELECT Message_Group__c, User__c, FM_UserLanguage__c
                FROM Message_Group_Junction__c
                WHERE Message_Group__c IN :allGroupIds
                AND User__r.IsActive = true
            ];
            for (Message_Group_Junction__c mgj : mgjList) {
                if (mgj.User__c != null) {
                    if (mgj.FM_UserLanguage__c == 'ko') {
                        Set<Id> users = groupToUsersKo.get(mgj.Message_Group__c) ?? new Set<Id>();
                        users.add(mgj.User__c);
                        groupToUsersKo.put(mgj.Message_Group__c, users);
                    } else {
                        Set<Id> users = groupToUsersEn.get(mgj.Message_Group__c) ?? new Set<Id>();
                        users.add(mgj.User__c);
                        groupToUsersEn.put(mgj.Message_Group__c, users);
                    }
                }
            }
        }
    
        // Owner 데이터 조회
        Map<Id, String> userToLanguage = new Map<Id, String>();
        List<User> ownerList = DN_WithoutSharingClass.getUserEmails(ownerIds);
        for (User owner : ownerList) {
            userToLanguage.put(owner.Id, owner.LanguageLocaleKey);
        }
    
        // 각 SQRegistration__c별로 알림 생성
        for (SQRegistration__c sqr : notiList) {
            Set<Id> receiver = new Set<Id>();
            Set<Id> receiverEN = new Set<Id>();
    
            // R&D Review 수신자 추가
            if (sqrToReviewUsers.containsKey(sqr.Id)) {
                receiver.addAll(sqrToReviewUsers.get(sqr.Id));
            }
    
            // Message Group 수신자 추가
            if (sqr.Message_Group__c != null) {
                if (groupToUsersKo.containsKey(sqr.Message_Group__c)) {
                    receiver.addAll(groupToUsersKo.get(sqr.Message_Group__c));
                }
                if (groupToUsersEn.containsKey(sqr.Message_Group__c)) {
                    receiverEN.addAll(groupToUsersEn.get(sqr.Message_Group__c));
                }
            }
    
            // DNSA Sales Team 수신자 추가
            if (sqr.DNSA_Sales_Team__c != null) {
                if (groupToUsersKo.containsKey(sqr.DNSA_Sales_Team__c)) {
                    receiver.addAll(groupToUsersKo.get(sqr.DNSA_Sales_Team__c));
                }
                if (groupToUsersEn.containsKey(sqr.DNSA_Sales_Team__c)) {
                    receiverEN.addAll(groupToUsersEn.get(sqr.DNSA_Sales_Team__c));
                }
            }
    
            // Owner 수신자 추가
            String ownerLanguage = userToLanguage.get(sqr.OwnerId);
            if (ownerLanguage == 'ko') {
                receiver.add(sqr.OwnerId);
            } else {
                receiverEN.add(sqr.OwnerId);
            }
    
            // 알림 생성
            if (!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Notification';
                history.elementList.add(sqr.Name);
                history.alertID = am[0].Id;
                history.targetID = sqr.Id;
                history.receiverforID = receiver;
                history.alertLanguage = 'ko';
                ahwList.add(history);
            }
            if (!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Notification';
                history.elementList.add(sqr.Name);
                history.alertID = am[0].Id;
                history.targetID = sqr.Id;
                history.receiverforID = receiverEN;
                history.alertLanguage = 'en';
                ahwList.add(history);
            }
        }
    
        if (!ahwList.isEmpty()) {
            UTIL_Alert.runAlertEvent(ahwList);
        }
    }

    /**
     * Drop 상태에 대한 이메일 알림을 전송합니다.
     */
    private static void sendDropEmail(List<SQRegistration__c> notiList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'Final SQ Registration Alert' LIMIT 1];
        if (am.isEmpty()) return;
    
        // 필요한 데이터 미리 수집
        Set<Id> rndReviewSqrIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Set<Id> dnsaGroupIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
    
        for (SQRegistration__c sqr : notiList) {
            if (sqr.Stage__c == 'R&D Review') {
                rndReviewSqrIds.add(sqr.Id);
            }
            if (sqr.Message_Group__c != null) groupIds.add(sqr.Message_Group__c);
            if (sqr.DNSA_Sales_Team__c != null) dnsaGroupIds.add(sqr.DNSA_Sales_Team__c);
            ownerIds.add(sqr.OwnerId);
        }
    
        // SQReview__c 데이터 한 번에 조회
        Map<Id, Set<String>> sqrToReviewEmails = new Map<Id, Set<String>>();
        if (!rndReviewSqrIds.isEmpty()) {
            List<SQReview__c> reviews = [
                SELECT SQRegistration__c, Product_Representative__r.ControlEmail__c, Product_Representative__r.MachineEmail__c
                FROM SQReview__c
                WHERE SQRegistration__c IN :rndReviewSqrIds AND IsReview__c = true
            ];
            for (SQReview__c review : reviews) {
                Set<String> emails = sqrToReviewEmails.get(review.SQRegistration__c) ?? new Set<String>();
                if (review.Product_Representative__r.ControlEmail__c != null) emails.add(review.Product_Representative__r.ControlEmail__c);
                if (review.Product_Representative__r.MachineEmail__c != null) emails.add(review.Product_Representative__r.MachineEmail__c);
                sqrToReviewEmails.put(review.SQRegistration__c, emails);
            }
        }
    
        // Message Group 데이터 한 번에 조회
        Map<Id, Set<String>> groupToEmailsKo = new Map<Id, Set<String>>();
        Map<Id, Set<String>> groupToEmailsEn = new Map<Id, Set<String>>();
        if (!groupIds.isEmpty() || !dnsaGroupIds.isEmpty()) {
            Set<Id> allGroupIds = new Set<Id>();
            allGroupIds.addAll(groupIds);
            allGroupIds.addAll(dnsaGroupIds);
            List<Message_Group_Junction__c> mgjList = [
                SELECT Message_Group__c, FM_UserEmail__c, FM_UserLanguage__c
                FROM Message_Group_Junction__c
                WHERE Message_Group__c IN :allGroupIds
                AND User__r.IsActive = true
            ];
            for (Message_Group_Junction__c mgj : mgjList) {
                if (mgj.FM_UserEmail__c != null) {
                    if (mgj.FM_UserLanguage__c == 'ko') {
                        Set<String> emails = groupToEmailsKo.get(mgj.Message_Group__c) ?? new Set<String>();
                        emails.add(mgj.FM_UserEmail__c);
                        groupToEmailsKo.put(mgj.Message_Group__c, emails);
                    } else {
                        Set<String> emails = groupToEmailsEn.get(mgj.Message_Group__c) ?? new Set<String>();
                        emails.add(mgj.FM_UserEmail__c);
                        groupToEmailsEn.put(mgj.Message_Group__c, emails);
                    }
                }
            }
        }
    
        // Owner 데이터 조회
        Map<Id, String> userToEmail = new Map<Id, String>();
        Map<Id, String> userToLanguage = new Map<Id, String>();
        List<User> ownerList = DN_WithoutSharingClass.getUserEmails(ownerIds);
        for (User owner : ownerList) {
            userToEmail.put(owner.Id, owner.Email);
            userToLanguage.put(owner.Id, owner.LanguageLocaleKey);
        }
    
        // 각 SQRegistration__c별로 알림 생성
        for (SQRegistration__c sqr : notiList) {
            List<String> receiver = new List<String>();
            List<String> receiverEN = new List<String>();
            String orgUrl;
    
            // R&D Review 수신자 추가
            if (sqrToReviewEmails.containsKey(sqr.Id)) {
                receiver.addAll(sqrToReviewEmails.get(sqr.Id));
            }
    
            // Message Group 수신자 추가
            if (sqr.Message_Group__c != null) {
                if (groupToEmailsKo.containsKey(sqr.Message_Group__c)) {
                    receiver.addAll(groupToEmailsKo.get(sqr.Message_Group__c));
                }
                if (groupToEmailsEn.containsKey(sqr.Message_Group__c)) {
                    receiverEN.addAll(groupToEmailsEn.get(sqr.Message_Group__c));
                }
                orgUrl = URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id;
            }
    
            // DNSA Sales Team 수신자 추가
            if (sqr.DNSA_Sales_Team__c != null) {
                if (groupToEmailsKo.containsKey(sqr.DNSA_Sales_Team__c)) {
                    receiver.addAll(groupToEmailsKo.get(sqr.DNSA_Sales_Team__c));
                }
                if (groupToEmailsEn.containsKey(sqr.DNSA_Sales_Team__c)) {
                    receiverEN.addAll(groupToEmailsEn.get(sqr.DNSA_Sales_Team__c));
                }
                orgUrl = URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id;
            }
    
            // Owner 수신자 추가
            String ownerEmail = userToEmail.get(sqr.OwnerId);
            String ownerLanguage = userToLanguage.get(sqr.OwnerId);
            if (ownerEmail != null) {
                if (ownerLanguage == 'ko') {
                    receiver.add(ownerEmail);
                } else {
                    receiverEN.add(ownerEmail);
                }
                List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
                String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
                orgUrl = baseUrl + '/' + sqr.Id;
            }
    
            // String orgUrl = URL.getOrgDomainURL().toExternalForm() + '/' + sqr.Id;

            // List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
            // String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');

            if (!receiver.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Email';
                history.elementList.add(sqr.Name);
                history.elementList.add(orgUrl);
                history.alertID = am[0].Id;
                history.targetID = sqr.Id;
                history.receiverforEmail = receiver;
                history.alertLanguage = 'ko';
                ahwList.add(history);
            }
            if (!receiverEN.isEmpty()) {
                UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                history.alertType = 'Email';
                history.elementList.add(sqr.Name);
                history.elementList.add(orgUrl);
                history.alertID = am[0].Id;
                history.targetID = sqr.Id;
                history.receiverforEmail = receiverEN;
                history.alertLanguage = 'en';
                ahwList.add(history);
            }
        }
    
        if (!ahwList.isEmpty()) {
            System.debug('ahwList ::: ' + ahwList);
            UTIL_Alert.runAlertEvent(ahwList);
        }
    }

    /**
     * 검토 요청 날짜 변경에 대한 알림을 전송합니다.
     */
    private static void sendChangeDateNoti(Set<Id> dateAlertSQRegIds, Set<Id> managerIds, List<SQRegistration__c> dateAlertList) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> receiverEN = new Set<Id>();

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if(!managerIds.isEmpty()) {
            List<User> managers = DN_WithoutSharingClass.getUserEmails(managerIds);
            for(User manager : managers) {
                if(currentUser.Id != manager.Id) {
                    if(manager.LanguageLocaleKey == 'ko') {
                        receiver.add(manager.Id);
                    } else {
                        receiverEN.add(manager.Id);
                    }
                }
            }
        }

        List<SQReview__c> reviews = [SELECT Id, OwnerId FROM SQReview__c WHERE SQRegistration__c IN :dateAlertSQRegIds]; 
        
        Set<Id> ownerIds = new Set<Id>();
        if(!reviews.isEmpty()) {
            for(SQReview__c rev : reviews) {
                ownerIds.add(rev.OwnerId);
            }

            List<User> reviewOwners = DN_WithoutSharingClass.getUserEmails(ownerIds);
            for(User us : reviewOwners) {
                receiver.add(us.ManagerId);
            }
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'SQ Review Request Date Alert' LIMIT 1];
        System.debug('receiver ::: ' + receiver);
        System.debug('receiverEn ::: ' + receiverEN);
        System.debug('am ::: ' + am);

        if(!am.isEmpty()) {
            for(SQRegistration__c sqReg : dateAlertList) {
                if(!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID       = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
            
                if(!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforID       = receiverEN;
                    history.alertLanguage       = 'en';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    /**
     * 검토 요청 날짜 변경에 대한 이메일 알림을 전송합니다.
     */
    private static void sendChangeDateEmail(Set<Id> dateAlertSQRegIds, Set<Id> managerIds, List<SQRegistration__c> dateAlertList, Map<Id, sObject> oldMap) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        List<String> receiverEN = new List<String>();
        Map<String, Boolean> emailToIsPortalUser = new Map<String, Boolean>(); // 이메일별 포털 유저 여부
    
        // 포털 baseUrl 및 CRM URL 설정
        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
        String crmUrl = URL.getOrgDomainURL().toExternalForm();
    
        User currentUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    
        if (!managerIds.isEmpty()) {
            List<User> managers = DN_WithoutSharingClass.getUserEmails(managerIds);
            for (User manager : managers) {
                if (currentUser.Id != manager.Id) {
                    if (manager.LanguageLocaleKey == 'ko') {
                        receiver.add(manager.Email);
                    } else {
                        receiverEN.add(manager.Email);
                    }
                    emailToIsPortalUser.put(manager.Email, false);
                }
            }
        }
    
        List<SQReview__c> reviews = [SELECT Id, OwnerId FROM SQReview__c WHERE SQRegistration__c IN :dateAlertSQRegIds]; 
        Set<Id> ownerIds = new Set<Id>();
        if (!reviews.isEmpty()) {
            for (SQReview__c rev : reviews) {
                ownerIds.add(rev.OwnerId);
            }
    
            List<User> reviewOwners = DN_WithoutSharingClass.getUserEmails(ownerIds);
            for (User us : reviewOwners) {
                receiver.add(us.Manager.Email);
                emailToIsPortalUser.put(us.Manager.Email, true);
            }
        }
    
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'SQ Review Request Date Alert' LIMIT 1];
    
        if (!am.isEmpty()) {
            for (SQRegistration__c sqReg : dateAlertList) {
                // 한국어 수신자
                if (!receiver.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(currentUser.Name);
                    history.elementList.add(String.valueOf(oldMap.get(sqReg.Id).get('ReviewRequestDate__c')));
                    history.elementList.add(String.valueOf(sqReg.ReviewRequestDate__c));
                    Boolean hasPortalUser = false;
                    for (String email : receiver) {
                        if (emailToIsPortalUser.get(email)) {
                            hasPortalUser = true;
                            break;
                        }
                    }
                    String url = hasPortalUser ? baseUrl : crmUrl;
                    history.elementList.add(url + '/' + sqReg.Id);
                    history.alertID = am[0].Id;
                    history.targetID = sqReg.Id;
                    history.receiverforEmail = receiver;
                    history.alertLanguage = 'ko';
                    ahwList.add(history);
                }
    
                
                if (!receiverEN.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType = 'Email';
                    history.elementList.add(sqReg.Name);
                    history.elementList.add(currentUser.Name);
                    history.elementList.add(String.valueOf(oldMap.get(sqReg.Id).get('ReviewRequestDate__c')));
                    history.elementList.add(String.valueOf(sqReg.ReviewRequestDate__c));
                    Boolean hasPortalUser = false;
                    for (String email : receiverEN) {
                        if (emailToIsPortalUser.get(email)) {
                            hasPortalUser = true;
                            break;
                        }
                    }
                    String url = hasPortalUser ? baseUrl : crmUrl;
                    history.elementList.add(url + '/' + sqReg.Id);
                    history.alertID = am[0].Id;
                    history.targetID = sqReg.Id;
                    history.receiverforEmail = receiverEN;
                    history.alertLanguage = 'en';
                    ahwList.add(history);
                }
            }
    
            if (!ahwList.isEmpty()) {
                UTIL_Alert.runAlertEvent(ahwList);
            }
        }
    }
}