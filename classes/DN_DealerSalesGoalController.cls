/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-09-2024   Hanyeong Choi   Initial Version
**/
public with sharing class DN_DealerSalesGoalController {
    public static Boolean allowOwnerIdUpdate = false;

    
    /**
     * @Description
     * 	- DealerSalesGoal__c 레코드의 Share버튼 모달 Init 
     * @author Hanyeong Choi | 07-09-2024
     * @Parameter
     *  - recordId	    : DealerSalesGoal__c Record Id
    **/ 
    @AuraEnabled
    public static Map<String, Object> getInitSharingModal(String recordId) {
        Map<String, Object> result = new Map<String, Object>();
        try {

            AccContactInfoWrapper accConInfo = getAccContactInfo(recordId);
            result.put('getAccContactInfo', accConInfo);

        } catch (AuraHandledException e) {
            // 예외 메시지를 클라이언트에 전달
            result.put('error', e.getMessage());
            System.debug('Error: ' + e.getMessage());

        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }


    /**
     * @Description
     * 	- 모달 '확인' 누르면 DealerSalesGoal__c 레코드 Owner 변경
     * @author Hanyeong Choi | 08-05-2024
     * @Parameter
     *  - shareRecordId	: DealerSalesGoal__c 또는 DealerBonus__c Record Id
     *  - ownerId       : Contact record ownerId
    **/ 
    @AuraEnabled
    public static string changeOwner(String shareRecordId, String userId){
        try {

            List<DealerSalesGoal__c>    dsgToUpdate = new List<DealerSalesGoal__c>();
            List<DealerBonus__c>        dbToUpdate  = new List<DealerBonus__c>();

            Boolean isSalesGoal = false;

            // DealerSalesGoal__c에서 Sharing
            List<DealerSalesGoal__c> dsgList = [
                SELECT Id
                        , OwnerId
                        , Year__c
                FROM DealerSalesGoal__c
                WHERE Id = :shareRecordId
                LIMIT 1
            ];

            DealerSalesGoal__c dsg = null;
            if(!dsgList.isEmpty()){
                dsg = dsgList[0];
                isSalesGoal = true;
                if (dsg.OwnerId != userId) {
                    allowOwnerIdUpdate = true;
                    dsg.OwnerId = userId;
                    dsgToUpdate.add(dsg);
                }
            }
           
            // DealerBonus__c에서 Sharing
            if (!isSalesGoal) {
                List<DealerBonus__c> dbList = [
                    SELECT Id
                            , OwnerId
                            , Year__c
                            , Month__c
                    FROM DealerBonus__c
                    WHERE Id = :shareRecordId
                    LIMIT 1
                ];

                DealerBonus__c db = null;

                if(!dbList.isEmpty()){
                    db = dbList[0];
                    if (db != null && db.OwnerId != userId) {
                        allowOwnerIdUpdate = true;
                        db.OwnerId = userId;
                        dbToUpdate.add(db);
                    }
                }

            }

            // DealerSalesGoal__c에서 Sharing
            if (!dsgToUpdate.isEmpty()) {
                update dsgToUpdate;
                alertOwnerUpdateforSalesGoal(dsgToUpdate, userId);
                return 'Success';

            // DealerBonus__c에서 Sharing
            } else if (!dbToUpdate.isEmpty()) {
                update dbToUpdate;
                alertOwnerUpdateforBonus(dbToUpdate, userId);
                return 'Success';
            } else {
                return 'Already';
            }
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            return 'Fail';
        }
    }


    /**
     * @Description
     * 	- DealerSalesGoal__c와 연관된 Account와 Contact의 정보
     * @author Hanyeong Choi | 07-09-2024
     * @Parameter
     *  - recordId      : DealerSalesGoal__c Record Id
    **/ 
    private static AccContactInfoWrapper getAccContactInfo(String recordId) {
        AccContactInfoWrapper       accConInfo      = new AccContactInfoWrapper();
        List<User>                  isRUserList     = new List<User>();
        Set<Id>                     accIds          = new Set<Id>();
        List<DealerSalesGoal__c>    dsgList         = new List<DealerSalesGoal__c>();
        List<DealerBonus__c>        dbList          = new List<DealerBonus__c>();

        // DealerSalesGoal__c에서 Sharing
        dsgList = [
            SELECT Id
                    , Dealer__c
                    , Dealer__r.Name
            FROM DealerSalesGoal__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        if(!dsgList.isEmpty()) {
            accIds.add(dsgList[0].Dealer__c);

        // DealaerBonus__c에서 Sharing
        }else{
            dbList = [
                SELECT Id
                        , Dealer__c
                        , Dealer__r.Name
                FROM DealerBonus__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            if(!dbList.isEmpty()){
                accIds.add(dbList[0].Dealer__c);
            }
        }


        List<User> userList = DN_WithoutSharingClass.getDealerInfo(accIds);

        if(!userList.isEmpty()) {
            accConInfo.contactCheck = true;

            // DealerSalesGoal__c에서 Sharing
            if(!dsgList.isEmpty()) {
            accConInfo.shareRecordId    = dsgList[0].Id;
            accConInfo.accountName      = dsgList[0].Dealer__r.Name;

            // DealaerBonus__c에서 Sharing
            } else if(!dbList.isEmpty()){
                accConInfo.shareRecordId    = dbList[0].Id;
                accConInfo.accountName      = dbList[0].Dealer__r.Name;
            }

            for(User u : userList) {
                if(u.UserRole.PortalRole == 'Manager' ) {
                    isRUserList.add(u);
                } else{
                    System.debug('Not Representative');
                    accConInfo.contactCheck = false;
                    return accConInfo; // 변경된 부분

                }
            }

            if(!isRUserList.isEmpty()) {
                for(User u : isRUserList) {
                    accConInfo.name             = u.Contact.Name;
                    accConInfo.email            = u.Contact.Email;
                    accConInfo.mobile           = u.Contact.MobilePhone;
                    accConInfo.userId           = u.Id;
                    accConInfo.isRepresentative = u.UserRole.PortalRole == 'Manager' ? 'Y' : 'N';
                    accConInfo.position         = u.Contact.Position__c;
                    accConInfo.role             = u.Contact.Role__c;
                    break;
                }

            }

        } else {
            accConInfo.contactCheck = false;
        }
        return accConInfo;
    }


    public class AccContactInfoWrapper {
        @AuraEnabled public Boolean contactCheck        {get;set;} // Account의 Contact 존재 유무
        @AuraEnabled public String  shareRecordId       {get;set;} // DealerSalesGoal__c 또는 DealerBonus__c record Id
        @AuraEnabled public String  accountName         {get;set;} // Account의 Name
        @AuraEnabled public String  name                {get;set;} // Contact의 Name
        @AuraEnabled public String  email               {get;set;} // Contact의 Email
        @AuraEnabled public String  mobile              {get;set;} // Contact의 MobilePhone
        @AuraEnabled public String  userId              {get;set;} // Contact의 Partner User Id
        @AuraEnabled public String  isRepresentative    {get;set;} // Contact의 IsRepresentative__c
        @AuraEnabled public String  position            {get;set;} // Contact의 Position__c
        @AuraEnabled public String  role                {get;set;} // Contact의 Role__c

        public AccContactInfoWrapper() {}
    }


    /**
     * @Description
     * 	- DealerSalesGoal__c의 Share이 성공적으로 완료되면 해당 대상자에게 Alert
     * @author Yuhyun Park | 10-28-2024
     * @Parameter
     *  - target           : DealerSalesGoal__c Record List
     *  - userId           : Owner Id(Alert 대상자 : Portal)
    **/ 
    private static void alertOwnerUpdateforSalesGoal(List<DealerSalesGoal__c> target, String userId){

        //orderService 기생
        DN_OrderService ordSvc = new DN_OrderService();

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        for(DealerSalesGoal__c goal : target) {
            targetUserMap.put(goal.Id, new Set<Id>{userId});
        }

        if(!target.isEmpty()){
            // bell 
            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'DealerSalesGoalOwnerUpdateAlert'
                , 'bell'
                , target
                , targetUserMap
                , null
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(bellAlertResult.errMessage); }

            // email 
            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'DealerSalesGoalOwnerUpdateAlert'
                , 'email'
                , target
                , targetUserMap
                , null
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(emailAlertResult.errMessage); }
        }
    }


    /**
     * @Description
     * 	- DealerBonus__c의 Share이 성공적으로 완료되면 해당 대상자에게 Alert
     * @author Yuhyun Park | 10-28-2024
     * @Parameter
     *  - target           : DealerBonus__c Record List
     *  - userId           : Owner Id(Alert 대상자 : Portal)
    **/ 
    private static void alertOwnerUpdateforBonus(List<DealerBonus__c> target, String userId){

        //orderService 기생
        DN_OrderService ordSvc = new DN_OrderService();

        Map<String, Set<Id>> targetUserMap = new Map<String, Set<Id>>();
        for(DealerBonus__c goal : target) {
            targetUserMap.put(goal.Id, new Set<Id>{userId});
        }

        if(!target.isEmpty()){
            // bell 
            UTIL_Alert.ResultWrapper bellAlertResult = ordSvc.sendAlert(
                'DealerBonusOwnerUpdateAlert'
                , 'bell'
                , target
                , targetUserMap
                , null
            );
            if(!Test.isRunningTest() && !bellAlertResult.isSuccess && bellAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(bellAlertResult.errMessage); }

            // email 
            UTIL_Alert.ResultWrapper emailAlertResult = ordSvc.sendAlert(
                'DealerBonusOwnerUpdateAlert'
                , 'email'
                , target
                , targetUserMap
                , null
            );
            if(!Test.isRunningTest() && !emailAlertResult.isSuccess && emailAlertResult.errMessage != System.Label.DNS_M_NotiDeliveryFail) { target[0].addError(emailAlertResult.errMessage); }
        }
    }
}