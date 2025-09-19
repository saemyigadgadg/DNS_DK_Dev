/**
 * @description       : Contact Trigger Handler
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   06-18-2024   Hanyeong Choi   Initial Version
**/
public with sharing class ContactTriggerHandler extends TriggerHandler {
    public static           Boolean isUpdateUser    = false;
    private static final    Id      contactPersonRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContactPerson').getRecordTypeId();
    private static final    Id      dealerRT        = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final    Id      csCustomerRT    = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSCustomer').getRecordTypeId();


    /**
     * Contact 레코드 삽입 전, 관련 Account 정보를 매핑하고 검증을 수행합니다.
     */
    public override void onBeforeInsert(List<sObject> news){
        try {
            if (isExecuting) {
                System.debug('Contact BEFORE_INSERT TRIGGER Start');
                List<Contact>   contactList = (List<Contact>) news;
                Set<Id>         accIds      = new Set<Id>();
    
                for(Contact contact : contactList) {
                    accIds.add(contact.AccountId);
                }
    
                Map<Id, Account> accountForId = new Map<Id, Account>([
                    SELECT Id
                            , RecordType.DeveloperName
                            , SalesOrganization__c
                            , DistributionChannel__c
                            , Division__c
                            , SalesDistrict__c
                            , SalesOffice__c
                    FROM Account 
                    WHERE Id IN :accIds
                ]);
                
                for(Contact contact : contactList) {
                    if(accountForId.containsKey(contact.AccountId)) {
                        accFieldMapping(contact, accountForId);
                    }
                }
                
                setting(false, TriggerOperation.BEFORE_INSERT);
                System.debug('Contact BEFORE_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Contact 레코드 삽입 후, 사용자 정보를 업데이트하고 고객 접근 권한을 부여합니다.
     */
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        try {
            if (isExecuting) {
                System.debug('Contact AFTER_INSERT TRIGGER Start');
                List<Contact>   contactList     = (List<Contact>) news;
                Set<Id>         contactIds      = new Set<Id>();
                Set<Id>         conDealerIds    = new Set<Id>();
                Set<Id>         accDealerIds    = new Set<Id>();
    
                for(Contact contact : contactList) {
                    if(contact.RecordTypeId == dealerRT
                    ){

                         if(
                            contact.AccountId != null
                        ){
                            conDealerIds.add(contact.Id);
                            accDealerIds.add(contact.AccountId);
                        }

                        if(
                            contact.Phone != null
                            || contact.Fax != null
                            || contact.MobilePhone != null
                            || contact.Email != null
                        ) {
                            contactIds.add(contact.Id);
                        } 
                    }
                }
                
                if(!contactIds.isEmpty()) updateUserInfo(contactIds, contactList);
                if(!accDealerIds.isEmpty()) grantAccessToCustomer(conDealerIds, accDealerIds);

                
                setting(false, TriggerOperation.AFTER_INSERT);
                System.debug('Contact AFTER_INSERT TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Contact 레코드 업데이트 전, Dealer 레코드 타입의 경우 사용자 정보를 업데이트합니다.
     */
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        try {
            if(isExecuting) {
                System.debug('Contact BEFORE_UPDATE TRIGGER Start');
                List<Contact>   contactList         = (List<Contact>) news;
                Set<Id>         contactIds          = new Set<Id>();

                for(Contact contact : contactList) {
                    Contact oldContact = (Contact) oldMap.get(contact.Id);

                    if(
                        !UserTriggerHandler.isUpdateContact && contact.RecordTypeId == dealerRT &&
                        (
                            oldContact.Phone           != contact.Phone
                            || oldContact.Fax          != contact.Fax
                            || oldContact.MobilePhone  != contact.MobilePhone
                            || oldContact.Email        != contact.Email
                            || oldContact.Inactive__c  != contact.Inactive__c
                        )
                    ) {
                        contactIds.add(contact.Id);
                    }

                }

                if(!contactIds.isEmpty()) updateUserInfo(contactIds, contactList);

                setting(false, TriggerOperation.BEFORE_UPDATE);
                System.debug('Contact BEFORE_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * Contact 레코드 업데이트 후, 전화번호 변경 시 관련 Case의 전화번호 정보를 업데이트합니다.
     */
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        try {
            if(isExecuting) {
                System.debug('Contact AFTER_UPDATE TRIGGER Start');
                List<Contact>   contactList         = (List<Contact>) news;
                Map<Id, String> phoneConIds         = new Map<Id, String>();

                for(Contact contact : contactList) {
                    Contact oldContact = (Contact) oldMap.get(contact.Id);

                    if(contact.Phone != oldContact.Phone){
                        phoneConIds.put(contact.Id, contact.MobilePhone);
                    }
                }

                if(!phoneConIds.isEmpty()) changeTickePhoneInfo(phoneConIds);

                setting(false, TriggerOperation.AFTER_UPDATE);
                System.debug('Contact AFTER_UPDATE TRIGGER End');
            }
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    /**
     * @Description
     *  - Contact Insert 시, Contact 필드에 Account 정보 Mapping
     * @author Hanyeong Choi | 07-18-2024
     * @Parameter
     *  - contact           : Contact record
     *  - accountForId      : key : Account record Id, value : Account record Map
    **/ 
    private static void accFieldMapping(Contact contact, Map<Id, Account> accountForId) {
        Account relatedAccount      = accountForId.get(contact.AccountId);
        String  accRecordTypeName   = relatedAccount.RecordType.DeveloperName;

        validationCheck(contact, relatedAccount);

        contact.SalesOrganization__c      = relatedAccount.SalesOrganization__c;
        contact.DistributionChannel__c    = relatedAccount.DistributionChannel__c;
        contact.Division__c               = relatedAccount.Division__c;
        contact.SalesDistrict__c          = relatedAccount.SalesDistrict__c;
        contact.SalesOffice__c            = relatedAccount.SalesOffice__c;

        return;
    }


    /**
     * @Description
     * 	- Contact validation Check
     * @author Hanyeong Choi | 07-18-2024
     * @Parameter
     *  - contact       : Contact record
    **/ 
    private static void validationCheck(Contact contact, Account relatedAccount) {
        if(contact.RecordTypeId != csCustomerRT) {
            if(contact.RecordTypeId != contactPersonRT) {
                if(relatedAccount.RecordType.DeveloperName == 'ProspectCustomer' || relatedAccount.RecordType.DeveloperName == 'TradeCustomer' || relatedAccount.RecordType.DeveloperName == 'ShipToParty') {
                    contact.addError('This account can only be created as a Contact Person.');
                }
            }
            if(contact.RecordTypeId == contactPersonRT) {
                if(relatedAccount.RecordType.DeveloperName == 'Dealer') {
                    contact.addError('You cannot select Dealer Account for the Contact Person type.');
                }
            }
        }
        return;
    }


    /**
     * @Description
     * 	- Contact의 필드 update 되면, 해당 User의 같은 필드 update
     * @author Hanyeong Choi | 07-22-2024
     * @Parameter
     *  - contactIds        : Contact record Id Set
     *  - contactList       : Contact List
    **/
    private static void updateUserInfo(Set<Id> contactIds, List<Contact> contactList) {
        Map<String, User>   userForContactIdMap = new Map<String, User>();
        List<User>          userList            = new List<User>();
        List<User>          updateUserList      = new List<User>();

        userList = [SELECT Id, Username, ContactId, Phone, Fax, MobilePhone, Email, IsActive
                    FROM User
                    WHERE ContactId IN: contactIds];

        if(userList != null && !userList.isEmpty()) {
            for(User user : userList) {
                userForContactIdMap.put(user.ContactId, user);
            }
    
            for(Contact contact : contactList) {
                if(userForContactIdMap.keySet().contains(contact.Id)) {
                    User updateUser = userForContactIdMap.get(contact.Id);

                    if(contact.Phone        != userForContactIdMap.get(contact.Id).Phone)          updateUser.Phone = contact.Phone;
                    if(contact.Fax          != userForContactIdMap.get(contact.Id).Fax)            updateUser.Fax = contact.Fax;
                    if(contact.MobilePhone  != userForContactIdMap.get(contact.Id).MobilePhone)    updateUser.MobilePhone = contact.MobilePhone;
                    if(contact.Email        != userForContactIdMap.get(contact.Id).Email)          updateUser.Email = contact.Email;
                    if(contact.Inactive__c  == userForContactIdMap.get(contact.Id).IsActive)        updateUser.IsActive = !contact.Inactive__c;
    
                    updateUserList.add(updateUser);
                }
            }
    
            if(!updateUserList.isEmpty()) {
                isUpdateUser = true;
                // 비동기 처리 : User의 IsActive는 Setup 객체로 인식
                System.enqueueJob(new UpdateUserQueueable(updateUserList));
            }
        }

        return;
    }


    /**
     * @Description
     * 	- User Update : Queueable로 비동기 처리
     * @author Yu-Hyun Park | 10-24-2024
     * @Parameter
     *  - 
    **/
    public class UpdateUserQueueable implements Queueable {
        private List<User> usersToUpdate;

        public UpdateUserQueueable(List<User> usersToUpdate) {
            this.usersToUpdate = usersToUpdate;
        }

        public void execute(QueueableContext context) {
            update usersToUpdate;
            System.debug('Contact Trigger : UpdateUserQueueable Executed');
        }
    }



    /**
     * @Description
     * 	- 딜러(Contact) 생성 시, 대리점(Account) 소속의 모든 딜러(Contact/User)에게 Customer(Account) Read 권한 부여 
     *  - 2025-01-03 : Read 권한에서 Edit 권한으로 변경
     *  - 2025-01-15 : AccountShare 생성에서 AccountContactRelation 생성 + Sharing Set(Portal)으로 변경
     * @author Yuhyun Park | 01-16-2025
     * 
    **/   
    private static void grantAccessToCustomer(Set<Id> conDealerIds, Set<Id> accDealerIds) {

        List<AccountContactRelation> relationToInsert = new List<AccountContactRelation>();

        List<DNS_CustomerDealerAssociation__c> existCDA = [
            SELECT  Id, Dealer__c, Customer__c
            FROM    DNS_CustomerDealerAssociation__c
            WHERE   Dealer__c IN :accDealerIds
            AND     Customer__c != ''
        ];

        System.debug('existCDA :: ' + existCDA);

        for(DNS_CustomerDealerAssociation__c cda : existCDA){
            for(Id contactId : conDealerIds){

                AccountContactRelation newRelation = new AccountContactRelation();
                newRelation.AccountId = cda.Customer__c;
                newRelation.ContactId = contactId;

                relationToInsert.add(newRelation);
            }
        }
 
        if (!relationToInsert.isEmpty()) {
        System.debug('relationToInsert :: ' + relationToInsert);

            Database.SaveResult[] results = Database.insert(relationToInsert, false);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('AccountContactRelation Insert Error: ' + err.getMessage());
                    }
                }
            }
        }
    }


    /**
     * @Description
     * 	- Contact의 Phone 정보 변경시, 연관된 Ticket의 요청자 Phone 정보 변경
     * @author Hayeong Min | 12-24-2024
     * @Parameter
     *  - phoneConIds    : Phone 정보가 변경된 Contact ID가 key, 변경된 phone정보가 value인 Map 
    **/   
    private static void changeTickePhoneInfo(Map<Id, String> phoneConIds) {
        System.debug('phoneConIds  :: ' + phoneConIds);
        
        List<Case> ticketList = [SELECT Id, Requester__c, Phone__c FROM Case WHERE Requester__c IN :phoneConIds.keySet()];
        if(!ticketList.isEmpty()){
            for(Case c : ticketList){
                c.Phone__c = phoneConIds.get(c.Requester__c);
            }
            update ticketList;
        }
        return;
    }

    

}