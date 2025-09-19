/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-07
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-05   yuhyun.park@sbtglobal.com   Initial Version
**/
public without sharing class DN_AssignManagerButtonController {

    /**
     * @Description
     * 	- junction object에 매니저가 등록되어 있는지 확인
     * @author Yuhyun Park | 02-06-2025
     * @Parameter
     *  - recordId       : recordId (MessageGroup__c)
    **/ 
    @AuraEnabled
    public static Map<String, Object> checkManagerInfo(String recordId){

        Map<String, Object> resultMap = new Map<String, Object>();

        try {

            // Message Group Record Query 
            List<MessageGroup__c> groupList = [
                SELECT  Id, SalesDistrict__c, Country__c, SalesOffice__c
                FROM    MessageGroup__c
                WHERE   Id =: recordId
                LIMIT   1
            ];

            if (groupList.isEmpty()) {
                resultMap.put('status'  , 'NoRecord');
                return resultMap;
            }

            MessageGroup__c groupInfo = groupList[0];

            // Junction Record Query
            List<Message_Group_Junction__c> juncList = [
                SELECT  Id, Message_Group__c, User__c
                FROM    Message_Group_Junction__c
                WHERE   Message_Group__c = :groupInfo.Id
            ];

            // juncList가 없는 경우
            if (juncList.isEmpty()) {
                resultMap.put('status', 'NoUser');
                return resultMap;

            // juncList가 2개 이상인 경우
            } else if (juncList.size() > 1) {
                resultMap.put('status'  , 'NotOneUser');
                return resultMap;
            }

            Message_Group_Junction__c juncRecord = juncList[0];

            // 할당된 User 정보 조회
            List<User> userList = [
                SELECT  Id, Name, SmallPhotoUrl, Email
                FROM    User
                WHERE   Id = :juncRecord.User__c
                LIMIT   1
            ];
            
            if (userList.isEmpty()) {
                resultMap.put('status', 'NoUser');
                return resultMap;
            }

            User managerUser = userList[0];
            resultMap.put('status', 'Success');
            resultMap.put('manager', managerUser);
            resultMap.put('groupInfo', groupInfo);
            System.debug('resultMap :: ' + resultMap);
            return resultMap;
            
        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            resultMap.put('status', 'Fail');
            return resultMap;
        }    
    
    }



    /**
     * @Description
     * 	- 모달 '확인' 누르면 해당 User들의 Manager, Internal Approval 변경
     *  - Korea     : Sales Office 기준
     *  - Global    : Country 기준
     * @author Yuhyun Park | 02-05-2025
     * @Parameter
     *  - groupInfo      : groupInfo
     *  - managerInfo    : DNS Internal Manager Info
    **/ 
    @AuraEnabled
    public static string assignManagertoUser(Object groupInfo, Object managerInfo){
        try {

            List<User> dealerList                   = new List<User>();
            List<User> dealerToUpdate               = new List<User>();
            Map<String, String> dealerManagerMap    = new Map<String, String>();

            // groupInfo
            String jsonStrGorup = JSON.serialize(groupInfo);
            Map<String, Object> groupInfoMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStrGorup);

            // managerInfo
            String jsonStrManager = JSON.serialize(managerInfo);
            Map<String, Object> managerInfoMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStrManager);

            String salesDistrict    = (String) groupInfoMap.get('SalesDistrict__c');
            String country          = (String) groupInfoMap.get('Country__c');
            String salesOffice      = (String) groupInfoMap.get('SalesOffice__c');
            String managerId        = (String) managerInfoMap.get('Id');

            // Korea
            if(salesDistrict == 'Korea'){
                System.debug('Korea :: ' );

                dealerList = [
                    SELECT  Id, IsActive, Username, ManagerId, internal_approver__c, UserRole.PortalRole, AccountId, Account.SalesOffice__c 
                    FROM    User
                    WHERE   Account.SalesOffice__c  =: salesOffice
                    AND     UserRole.PortalRole != null
                    AND     IsActive = true
                ];

                if(!dealerList.isEmpty()){
                    for(User user : dealerList){
                        if(user.UserRole.PortalRole == 'Manager'){
                            dealerManagerMap.put(user.AccountId, user.Id);
                        }
                    }

                    for(User user : dealerList){

                        Boolean isChanged = false;

                        if (user.ManagerId != managerId) {
                            user.ManagerId = managerId;
                            isChanged = true;
                        }

                        if (user.UserRole.PortalRole == 'Worker' && dealerManagerMap.containsKey(user.AccountId)) {
                            String newApprover = dealerManagerMap.get(user.AccountId);
                            if (user.internal_approver__c != newApprover) {
                                user.internal_approver__c = newApprover;
                                isChanged = true;
                            }
                        }

                        if (isChanged) {
                            System.debug('User updated: ' + user.Username);
                            dealerToUpdate.add(user);
                        }
                    }
                }

            
            // Global
            } else if(salesDistrict == 'Global'){
                System.debug('Global :: ' );

                dealerList = [
                    SELECT  Id, IsActive, Username, ManagerId, internal_approver__c, UserRole.PortalRole, AccountId, Account.CountryLookup__c
                    FROM    User
                    WHERE   Account.CountryLookup__c =: country
                    AND     UserRole.PortalRole != null
                    AND     IsActive = true
                ];

                if(!dealerList.isEmpty()){
                    for(User user : dealerList){
                        if(user.UserRole.PortalRole == 'Manager'){
                            dealerManagerMap.put(user.AccountId, user.Id);
                        }
                    }

                    for(User user : dealerList){

                        Boolean isChanged = false;

                        if (user.ManagerId != managerId) {
                            user.ManagerId = managerId;
                            isChanged = true;
                        }

                        if (user.UserRole.PortalRole == 'Worker' && dealerManagerMap.containsKey(user.AccountId)) {
                            String newApprover = dealerManagerMap.get(user.AccountId);
                            if (user.internal_approver__c != newApprover) {
                                user.internal_approver__c = newApprover;
                                isChanged = true;
                            }
                        }

                        if (isChanged) {
                            System.debug('User updated: ' + user.Username);
                            dealerToUpdate.add(user);
                        }
                    }
                }
            }

            if(!dealerToUpdate.isEmpty()){
                update dealerToUpdate;
            }

            return 'Success';

        } catch (Exception e) {
            System.debug('Error : ' + e.getMessage());
            System.debug('Line Number : ' + e.getLineNumber());
            return 'Fail';
        }
    }



}