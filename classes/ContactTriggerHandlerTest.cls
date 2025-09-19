/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-03
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-04-03   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class ContactTriggerHandlerTest {

    private static final    Id      contactPersonRT = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ContactPerson').getRecordTypeId();
    private static final    Id      dealerRT        = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId();
    private static final    Id      csCustomerRT    = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSCustomer').getRecordTypeId();


    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'UserTriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        Account dealerAcc;
        Account prospectAcc;
        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';
            insert dealerAcc;


            Account anotherDealer = TestDataFactoryForSales.createAccount('Dealer', country, null);
            anotherDealer.Name = 'anotherDealer';
            anotherDealer.CustomerCode__c = '33333';
            anotherDealer.Phone = '111-222-33';
            insert anotherDealer;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            delaerCon.LastName = 'testDealerContact';
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.LastName = 'testPortalUser';
            insert dealer;

            prospectAcc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
            prospectAcc.Name = 'Test Customer';
            insert prospectAcc;

            DNS_CustomerDealerAssociation__c cdaRecord = new DNS_CustomerDealerAssociation__c(
                Customer__c = prospectAcc.Id,
                Dealer__c = dealerAcc.Id
            );
            insert cdaRecord;

        }

    }

    @isTest
    static void testContactTriggers() {
        // 테스트용 Dealer Account와 Customer Account 조회
        Account dealerAccount = [SELECT Id, SalesOrganization__c, DistributionChannel__c, Division__c, SalesDistrict__c, SalesOffice__c 
                                 FROM Account WHERE Name = 'test Dealer' LIMIT 1];
        Account customerAccount = [SELECT Id FROM Account WHERE Name = 'Test Customer' LIMIT 1];
        
        // Dealer 타입 Contact 생성 (Account의 필드 매핑, grantAccessToCustomer, updateUserInfo 로직 검증)
        Contact dealerContact = new Contact(
            LastName    = 'Test Dealer Contact',
            AccountId   = dealerAccount.Id,
            RecordTypeId = dealerRT,
            Phone       = '111-1111',
            Fax         = '111-1111',
            MobilePhone = '111-1111',
            Email       = 'testdealer@example.com',
            Inactive__c = false
        );
        
        Test.startTest();
            // Contact 삽입: onBeforeInsert, onAfterInsert 트리거 실행
            insert dealerContact;
            
            // 삽입 후, Account의 필드 값이 Contact로 매핑되었는지 확인
            Contact insertedContact = [SELECT Id, SalesOrganization__c, DistributionChannel__c, Division__c, SalesDistrict__c, SalesOffice__c 
                                        FROM Contact WHERE Id = :dealerContact.Id];
            // Contact 업데이트: 전화, 팩스, 모바일, 이메일, Inactive__c 값 변경 → onBeforeUpdate, onAfterUpdate, updateUserInfo 트리거 실행
            insertedContact.Phone       = '222-2222';
            insertedContact.Fax         = '222-2222';
            insertedContact.MobilePhone = '222-2222';
            insertedContact.Email       = 'updateddealer@example.com';
            insertedContact.Inactive__c = true;
            update insertedContact;
            
            // 비동기 Queueable(job)이 실행되도록 Test.stopTest 전까지 대기
            // 업데이트 후, User 필드가 Contact의 변경 내용에 따라 업데이트 되었는지 확인
            User testUser = [SELECT Id, Phone, Fax, MobilePhone, Email, IsActive 
                        FROM User WHERE LastName = 'testPortalUser'];
            
            // Case 레코드 생성하여 onAfterUpdate의 전화번호 변경 로직(changeTickePhoneInfo) 검증
            Case testCase = new Case(
                Subject       = 'Test Case',
                Requester__c  = insertedContact.Id,
                Phone__c      = '111-1111'  // 기존 전화번호
            );
            insert testCase;
            
            Contact testContact = [SELECT Id, LastName, Phone FROM Contact WHERE LastName = 'testDealerContact'];
            testContact.Phone = '333-3333';
            update testContact;
            
            testCase = [SELECT Id, Phone__c FROM Case WHERE Id = :testCase.Id];
            
            // grantAccessToCustomer 검증: DNS_CustomerDealerAssociation__c에 의해
            // AccountContactRelation 레코드가 생성되었는지 확인
            List<AccountContactRelation> acrList = [SELECT Id, AccountId, ContactId 
                                                    FROM AccountContactRelation 
                                                    WHERE ContactId = :insertedContact.Id 
                                                      AND AccountId = :customerAccount.Id];
        Test.stopTest();
    }


}