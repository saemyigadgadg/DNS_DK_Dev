/**
 * @description       : User Trigger Handler
 * @author            : Joohyun Lee
 * @group             : 
 * @last modified on  : 2025-07-22
 * @last modified by  : yuhyun.park@sbtglobal.com
**/
public with sharing class UserTriggerHandler extends TriggerHandler {
    public static Boolean isUpdateContact = false;

    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {
                System.debug('User BEFORE_INSERT TRIGGER Start');
                Decimal lastNumber = getLastNumber();

                for(User updateUser : (List<User>) news){
                    lastNumber ++;
                    updateUser.ERP_Key__c = lastNumber;
                }

                setting(false, TriggerOperation.BEFORE_INSERT);
                System.debug('User BEFORE_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        try {
            if(isExecuting) {
                System.debug('User BEFORE_UPDATE TRIGGER Start');
                List<User>  userList        = (List<User>) news;
                Set<Id>     userContactIds  = new Set<Id>();
    
                for(User user : userList) {
                    User oldUser = (User) oldMap.get(user.Id);
                    if(
                        !ContactTriggerHandler.isUpdateUser &&
                        (
                            oldUser.Phone           != user.Phone
                            || oldUser.Fax          != user.Fax
                            || oldUser.MobilePhone  != user.MobilePhone
                            || oldUser.Email        != user.Email
                            // 2024-10-24 추가 : Yu-Hyun Park
                            || oldUser.IsActive     != user.IsActive
                        )
                    ) {
                        userContactIds.add(user.ContactId);
                    } 
                }
    
                if(!userContactIds.isEmpty()) updateContactInfo(userContactIds, userList);
    
                setting(false, TriggerOperation.BEFORE_UPDATE);
                System.debug('User BEFORE_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
 

    /**
     * @Description
     * 	- User필드 update 되면, 연관된 Contact의 같은 필드 update
     * @author Hanyeong Choi | 07-24-2024
     * @Parameter
     *  - userIds           : User record Id Set
     *  - userList          : User List
    **/
    private static void updateContactInfo(Set<Id> userContactIds, List<User> userList) {
        Map<String, Contact>    contactForIdMap     = new Map<String, Contact>();
        List<Contact>           updateContactList   = new List<Contact>();

        List<Contact> contactList = [
            SELECT Id
                    , Phone
                    , Fax
                    , MobilePhone
                    , Email
                    , Inactive__c
            FROM Contact
            WHERE Id IN :userContactIds
        ];

        if(!contactList.isEmpty()) {
            for(Contact contact : contactList) {
                contactForIdMap.put(contact.Id, contact);
            }
    
            for(User user : userList) {
                if(contactForIdMap.keySet().contains(user.ContactId)) {
                    Contact updateContact = contactForIdMap.get(user.ContactId);
                    if(user.Phone        != contactForIdMap.get(user.ContactId).Phone)          updateContact.Phone         = user.Phone;
                    if(user.Fax          != contactForIdMap.get(user.ContactId).Fax)            updateContact.Fax           = user.Fax;
                    if(user.MobilePhone  != contactForIdMap.get(user.ContactId).MobilePhone)    updateContact.MobilePhone   = user.MobilePhone;
                    if(user.Email        != contactForIdMap.get(user.ContactId).Email)          updateContact.Email         = user.Email;
                    // 2024-10-24 추가 : Yu-Hyun Park
                    if(user.IsActive     == contactForIdMap.get(user.ContactId).Inactive__c)    updateContact.Inactive__c   = !user.IsActive;
    
                    updateContactList.add(updateContact);
                }
            }
    
            if(!updateContactList.isEmpty()) {
                isUpdateContact = true;
                // 비동기 처리 : User의 IsActive는 Setup 객체로 인식
                System.enqueueJob(new UpdateContactQueueable(updateContactList));
            }
        }
        return;
    }


    /**
     * @Description
     * 	- Contact Update : Queueable로 비동기 처리
     * @author Yu-Hyun Park | 10-24-2024
     * @Parameter
     *  - 
    **/
    public class UpdateContactQueueable implements Queueable {
        private List<Contact> conToUpdate;

        public UpdateContactQueueable(List<Contact> conToUpdate) {
            this.conToUpdate = conToUpdate;
        }

        public void execute(QueueableContext context) {
            update conToUpdate;
            System.debug('User Trigger : UpdateContactQueueable Executed');
        }
    }


    // User의 ERP_Key__c 필드에 마지막 번호를 넣어주는 메소드
    private Decimal getLastNumber(){
        Decimal lastNumber = 0;

        List<User> lastNumberUserList = [
            SELECT      ERP_Key__c
            FROM        User
            WHERE       ERP_Key__c != null
            ORDER BY    ERP_Key__c DESC
            LIMIT       1
        ];

        if (lastNumberUserList.size() > 0) lastNumber = lastNumberUserList[0].ERP_Key__c;

        return lastNumber;
    }
}