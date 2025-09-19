/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-08-2024   Hanyeong Choi   Initial Version
**/
public with sharing class SQReviewTriggerHandler extends TriggerHandler {
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQReview__c AFTER_INSERT TRIGGER Start');
            List<SQReview__c> sqReviewList = (List<SQReview__c>) news;
            Set<Id> sendList = new Set<Id>();
            
            for(SQReview__c sqr : sqReviewList) {
                if(sqr.Product_Representative__c != null) {
                    sendList.add(sqr.Id);
                }
            }
            if(!sendList.isEmpty()) sendEmailNotification(sendList);
            if(!sendList.isEmpty()) sendNotification(sendList);

            setting(false, TriggerOperation.AFTER_INSERT);
            System.debug('SQReview__c AFTER_INSERT TRIGGER End');
        }
    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQRegistration__c BEFORE_UPDATE TRIGGER Start');
            List<SQReview__c> sqrList = (List<SQReview__c>) news;
            Set<Id> revIds = new Set<Id>();
            Map<String, String> reviewMap = new Map<String, String>();

            for(SQReview__c sqr : sqrList) {
                Decimal Material_Cost = 0;
                Decimal Assembly_Cost = 0;
                if(oldMap.get(sqr.Id).get('SQTitle__c') != sqr.SQTitle__c) {
                    revIds.add(sqr.Id);
                    reviewMap.put(sqr.RequestedSQ__c, sqr.SQTitle__c);
                }

                // if(sqr.KRWcost__c == null) {
                //     sqr.KRWcost__c = 0;
                // }
                //원가에 재료비 + 조립비 _20250724
                if(sqr.Material_Cost__c == null){
                    Material_Cost = 0;
                }else{
                    Material_Cost = sqr.Material_Cost__c;
                }
                if(sqr.Assembly_Cost__c == null){
                    Assembly_Cost = 0;
                }else{
                    Assembly_Cost = sqr.Assembly_Cost__c;
                }
                sqr.KRWcost__c = Material_Cost + Assembly_Cost;
            }

            if(!revIds.isEmpty()) {
                List<SQReview__c> updateList = new List<SQReview__c>();
                List<RequestedSQ__c> updateRequestedList = new List<RequestedSQ__c>();
                List<SQReview__c> revies = [SELECT Id, SQTitle__c, RequestedSQ__c FROM SQReview__c WHERE (RequestedSQ__c IN :reviewMap.keySet()) AND (Id NOT IN :revIds)];
                List<RequestedSQ__c> reqList = [SELECT Id, Name FROM RequestedSQ__c WHERE Id IN :reviewMap.keySet()];

                if(!reqList.isEmpty()) {
                    for(RequestedSQ__c req : reqList) {
                        req.Name = reviewMap.get(req.Id);
                        updateRequestedList.add(req);
                    }
                }

                for(SQReview__c review : revies) {
                    review.SQTitle__c = reviewMap.get(review.RequestedSQ__c);
                    updateList.add(review);
                }
                if(!updateList.isEmpty()) update updateList;
                if(!updateRequestedList.isEmpty()) update updateRequestedList;
            }

            setting(false, TriggerOperation.BEFORE_UPDATE);
            System.debug('SQReview__c BEFORE_UPDATE TRIGGER End');
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            System.debug('SQReview__c AFTER_UPDATE TRIGGER Start');
            List<SQReview__c> sqrList = (List<SQReview__c>) news;
            Set<Id> sqRegistrationIds = new Set<Id>();
            List<refreshEvent__e> events = new List<refreshEvent__e>();

            for(SQReview__c sqr : sqrList) {
                if(
                    // sqr.Comments__c != null &&
                    // sqr.KRWcost__c != null
                    sqr.IsComplete__c
                ) {
                    sqRegistrationIds.add(sqr.SQRegistration__c);
                }
            }

            if(!sqRegistrationIds.isEmpty()) updateStageConfirm(sqRegistrationIds);

            setting(false, TriggerOperation.AFTER_UPDATE);
            System.debug('SQReview__c AFTER_UPDATE TRIGGER End');
        }
    }

    public override void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap) {
        if(isExecuting) {
            System.debug('SQReview__c AFTER_DELETE TRIGGER Start');
            List<SQReview__c>   sqrList             = (List<SQReview__c>) dels;
            Set<Id>             sqRegistrationIds   = new Set<Id>();
            Set<Id>             requestedSQIds      = new Set<Id>();

            for(SQReview__c sqr : sqrList) {
                sqRegistrationIds.add(sqr.SQRegistration__c);
                if(sqr.RequestedSQ__c != null) requestedSQIds.add(sqr.RequestedSQ__c);
            }

            if(!sqRegistrationIds.isEmpty()) updateStageConfirm(sqRegistrationIds);

            setting(false, TriggerOperation.AFTER_DELETE);
            System.debug('SQReview__c AFTER_DELETE TRIGGER End');
        }
    }

    // private static void sendNotification(Set<Id> RepresentativeIds, Set<Id> sqRegIds) {
    private static void sendNotification(Set<Id> reviewIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> receiver = new Set<Id>();
        Set<Id> sqrIds = new Set<Id>();
        
        List<SQReview__c> reviews = [
            SELECT  Id
                    , Part__c
                    , Product_Representative__c
                    , Product_Representative__r.User__c
                    , Product_Representative__r.ControlUser__c
                    , SQRegistration__c
                    , OwnerId
            FROM SQReview__c
            WHERE Id IN :reviewIds
        ];

        for(SQReview__c review : reviews) {
            receiver.add(review.OwnerId);
            // if(review.Part__c == '제어') {
            //     if(review.Product_Representative__r.ControlUser__c != UserInfo.getUserId()) {
            //         receiver.add(review.Product_Representative__r.ControlUser__c);
            //     }
            // } else {
            //     if(review.Product_Representative__r.User__c != UserInfo.getUserId()) {
            //         receiver.add(review.Product_Representative__r.User__c);
            //     }
            // }
            sqrIds.add(review.SQRegistration__c);
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New Review SQ Alert' LIMIT 1];

        List<SQRegistration__c> sqRegList = [
            SELECT  Id
                    , Name
            FROM SQRegistration__c
            WHERE Id IN :sqrIds
        ];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(SQRegistration__c sqReg : sqRegList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType       = 'Notification';
                    history.elementList.add(sqReg.Name);
                    history.alertID         = am[0].Id;
                    history.targetID        = sqReg.Id;
                    history.receiverforID   = receiver;
                    history.alertLanguage   = 'ko';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    // private static void sendEmailNotification(Set<Id> RepresentativeIds, Set<Id> sqRegIds) {
    private static void sendEmailNotification(Set<Id> reviewIds) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        List<String> receiver = new List<String>();
        Set<Id> sqrIds = new Set<Id>();
        Set<Id> ownerids = new Set<Id>();

        List<SQReview__c> reviews = [
            SELECT  Id
                    , Part__c
                    , Product_Representative__c
                    , Product_Representative__r.ControlUser__c
                    , Product_Representative__r.User__c
                    , Product_Representative__r.ControlEmail__c
                    , Product_Representative__r.MachineEmail__c
                    , SQRegistration__c
                    , OwnerId
            FROM SQReview__c
            WHERE Id IN :reviewIds
        ];

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');

        for(SQReview__c review : reviews) {
            ownerids.add(review.OwnerId);
            // if(review.Part__c == '제어') {
            //     if(review.Product_Representative__r.ControlUser__c != UserInfo.getUserId()) {
            //         receiver.add(review.Product_Representative__r.ControlEmail__c);
            //     }
            // } else {
            //     if(review.Product_Representative__r.User__c != UserInfo.getUserId()) {
            //         receiver.add(review.Product_Representative__r.MachineEmail__c);
            //     }
            // }
            sqrIds.add(review.SQRegistration__c);
        }

        List<User> userList = DN_WithoutSharingClass.getUserEmails(ownerids);

        for(User u : userList) {
            receiver.add(u.Email);
        }

        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'New Review SQ Alert' LIMIT 1];

        List<SQRegistration__c> sqRegList = [
            SELECT  Id
                    , Name
                    , (
                        SELECT Id, Quote__r.Name, Name, Quote__r.Opportunity.Name
                        FROM SQregistration_Quote_Junction__r
                    )
            FROM SQRegistration__c
            WHERE Id IN :sqrIds
        ];

        if(!am.isEmpty()) {
            if(!receiver.isEmpty()) {
                for(SQRegistration__c sqReg : sqRegList) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType           = 'Email';
                    history.elementList.add
                    (sqReg.Name);
                    history.elementList.add(sqReg.SQregistration_Quote_Junction__r[0].Quote__r.Opportunity.Name);
                    history.elementList.add(sqReg.SQregistration_Quote_Junction__r[0].Quote__r.Name);
                    history.elementList.add(baseUrl + '/' + sqReg.Id);
                    history.alertID             = am[0].Id;
                    history.targetID            = sqReg.Id;
                    history.receiverforEmail    = receiver;
                    history.alertLanguage       = 'ko';
                    ahwList.add(history);
                }
            }
            if(!ahwList.isEmpty()) UTIL_Alert.runAlertEvent(ahwList);
        }
        return;
    }

    private static void updateStageConfirm(Set<Id> sqRegistrationIds) {
        List<SQReview__c> sqrList = [
            SELECT  Id
                    , Comments__c
                    , KRWcost__c
                    , Color__c
                    , IsReview__c
                    , Product_Representative__c
                    , Product_Representative__r.MachineUserLeader__c
                    , Product_Representative__r.MachineLeaderEmail__c
                    , Product_Representative__r.ControlUserLeader__c
                    , Product_Representative__r.ControlLeaderEmail__c
                    , Part__c
                    , SQRegistration__c
                    , IsComplete__c
            FROM SQReview__c
            WHERE SQRegistration__c IN :sqRegistrationIds
            AND Category__c != '입회검사'
            AND IsReview__c = true
            AND Type__c = 'SQ'
        ];

        Boolean nullCheck = false;
        if(!sqrList.isEmpty()) {
            for(SQReview__c sqr : sqrList) {
                // if(sqr.Comments__c == null || sqr.KRWcost__c == null || sqr.Color__c) {
                //     nullCheck = true;
                // }
                if(!sqr.IsComplete__c) nullCheck = true;
            }

            if(!nullCheck) {
                List<SQRegistration__c> sqRegList = [
                    SELECT  Id
                            , Stage__c
                    FROM SQRegistration__c
                    WHERE Id IN :sqRegistrationIds
                ];
    
                if(!sqRegList.isEmpty()) {
                    List<SQRegistration__c> updateList = new List<SQRegistration__c>();
                    for(SQRegistration__c sqReg : sqRegList) {
                        sqReg.Stage__c = 'R&D Confirm';
                        updateList.add(sqReg);
                    }
                    if(!updateList.isEmpty()) {
                        update updateList;

                        sendReviewConfirmAlertAndEmail(sqrList);
                    }
                }
            }
        }

        return;
    }

    private static void sendReviewConfirmAlertAndEmail(List<SQReview__c> reviews) {
        List<UTIL_Alert.HistoryWrapper> ahwList = new List<UTIL_Alert.HistoryWrapper>();
        Set<Id> sqrIds = new Set<Id>();
        
        for(SQReview__c review : reviews) {
            sqrIds.add(review.SQRegistration__c);
        }
    
        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'RND Confirm Alert' LIMIT 1];
        if(am.isEmpty()) return;
    
        List<SQRegistration__c> sqRegList = [
            SELECT Id, Name
            FROM SQRegistration__c
            WHERE Id IN :sqrIds
        ];

        List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
        String baseUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login');
    
        for(SQReview__c review : reviews) {
            Set<Id> receiverIds = new Set<Id>();
            List<String> receiverEmails = new List<String>();
            
            if(review.Part__c == '제어') {
                if(review.Product_Representative__r.ControlUserLeader__c != UserInfo.getUserId()) {
                    if(review.Product_Representative__r.ControlUserLeader__c != null) receiverIds.add(review.Product_Representative__r.ControlUserLeader__c);
                    if(review.Product_Representative__r.ControlLeaderEmail__c != null) receiverEmails.add(review.Product_Representative__r.ControlLeaderEmail__c);
                }
            } else if(review.Part__c == '기계') {
                if(review.Product_Representative__r.MachineUserLeader__c != UserInfo.getUserId()) {
                    if(review.Product_Representative__r.MachineUserLeader__c != null) receiverIds.add(review.Product_Representative__r.MachineUserLeader__c);
                    if(review.Product_Representative__r.MachineLeaderEmail__c != null) receiverEmails.add(review.Product_Representative__r.MachineLeaderEmail__c);
                }
            }
            System.debug('receiverIds ::: ' + receiverIds);
            System.debug('receiverEmails ::: ' + receiverEmails);
    
            SQRegistration__c relatedSqReg;
            for(SQRegistration__c sqReg : sqRegList) {
                if(sqReg.Id == review.SQRegistration__c) {
                    relatedSqReg = sqReg;
                    break;
                }
            }
    
            if(relatedSqReg != null) {
                if(!receiverIds.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType = 'Notification';
                    history.elementList.add(relatedSqReg.Name);
                    history.alertID = am[0].Id;
                    history.targetID = relatedSqReg.Id;
                    history.receiverforID = receiverIds;
                    history.alertLanguage = 'ko';
                    ahwList.add(history);
                }
    
                if(!receiverEmails.isEmpty()) {
                    UTIL_Alert.HistoryWrapper history = new UTIL_Alert.HistoryWrapper();
                    history.alertType = 'Email';
                    history.elementList.add(relatedSqReg.Name);
                    history.elementList.add(baseUrl + '/' + relatedSqReg.Id);
                    history.alertID = am[0].Id;
                    history.targetID = relatedSqReg.Id;
                    history.receiverforEmail = receiverEmails;
                    history.alertLanguage = 'ko';
                    ahwList.add(history);
                }
            }
        }
    
        if(!ahwList.isEmpty()) {
            UTIL_Alert.runAlertEvent(ahwList);
        }
    }
}