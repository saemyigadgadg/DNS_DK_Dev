@isTest
public with sharing class DN_BoardController_TEST {
    static User adminTestUser;
    static User adminTestUser2;
    static User adminTestUser3;
    static User partnerTestUser;
    @TestSetup
    static void makeData(){
        List<User> userList = new List<User>();
        adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesOffice__c = '414A';
        adminTestUser.SalesDistrict__c = 'A1KR';
        adminTestUser.IsActive = true;
        userList.add(adminTestUser);

        adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1846';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesOffice__c = '414A';
        adminTestUser2.SalesDistrict__c = 'A1KR';
        adminTestUser2.IsActive = true;
        //adminTestUser2.ProfileId = profile.Id;
        userList.add(adminTestUser2);
        
        adminTestUser3 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser3.UserName='adminTEst1111@test.com1111';
        adminTestUser3.SalesOrganization__c = '1800';
        adminTestUser3.DistributionChannel__c = '10';
        adminTestUser3.Division__c = '40';
        adminTestUser3.SalesOffice__c = '414A';
        adminTestUser3.SalesDistrict__c = 'A1KR';
        adminTestUser3.IsActive = true;
        userList.add(adminTestUser3);
        insert userList;
        System.runAs(adminTestUser2) {
            Account acc = TestDataFactoryForDealerPortal.dealer;
            acc.OwnerId = adminTestUser3.Id;
            insert acc; 
            Contact contact = TestDataFactoryForDealerPortal.createContact(acc.Id);
            insert contact;  
        }
        System.runAs(adminTestUser) {
            Contact contact = [SELECT Id FROM Contact LIMIT 1];
            Profile profile = [SELECT Id FROM Profile WHERE Name ='DNS CS Service_Partner' LIMIT 1];
            partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(contact.Id);
            partnerTestUser.Username = 'boardPoPUPTEST11111@test.com';
            partnerTestUser.ProfileId = profile.Id;
            partnerTestUser.SalesOrganization__c = '1846';
            partnerTestUser.DistributionChannel__c = '10';
            partnerTestUser.Division__c = '40';
            partnerTestUser.SalesOffice__c = '414A';
            partnerTestUser.SalesDistrict__c = 'A1KR';
            partnerTestUser.IsActive = true;
            insert partnerTestUser;
        }
        

        System.runAs(adminTestUser3) {
            Board__c salesborad = new Board__c(
                Name ='Salestest',
                Contents__c = 'test',
                IsScroll__c = false,
                IsPopUp__c = true,
                RecordTypeId = TestDataFactoryForDealerPortal.getRecordType('Announcement','Board__c').Id,
                BoardStartDate__c = System.now(),
                BoardEndDate__c = System.now(),
                SalesOffice__c = '414A',
                SalesOrganization__c = '1800',
                Category__c = 'General'
            );
            insert salesborad;
            User user = [SELECT Id, Profile.Name FROM User WHERE Id =:partnerTestUser.Id];

            Board__c csborad = new Board__c(
                Name ='CStest',
                Contents__c = 'test',
                IsScroll__c = false,
                IsPopUp__c = true,
                RecordTypeId = TestDataFactoryForDealerPortal.getRecordType('Announcement','Board__c').Id,
                BoardStartDate__c = System.now(),
                BoardEndDate__c = System.now(),
                SalesOffice__c = '414A',
                SalesOrganization__c = '1846',
                NoticeTarget__c = 'DNS CS Service_Partner',
                Category__c = 'General'
            );
            insert csborad;
            Board__c csBoard = [SELECT Id FROM Board__c WHERE Name LIKE '%CStest%' LIMIT 1];
            ContentVersion con = TestDataFactoryForDealerPortal.getContentVersion(adminTestUser3.Id);
            insert con;
            ContentVersion contentVersion = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id=:con.Id];

            ContentDocumentLink docLink = TestDataFactoryForDealerPortal.getDocumentLink(contentVersion.ContentDocumentId,csBoard.Id);
            insert docLink;
        }
    }

    @IsTest 
    static void test1(){
        User partnerTestUsers = [SELECT Id, Name,IsActive FROM User WHERE Profile.Name='DNS CS Service_Partner' AND UserName='boardPoPUPTEST11111@test.com' LIMIT 1];
        Date todays = Date.today();
        RecordType recordTypes = [select Id, Name, DeveloperName, SobjectType from RecordType where SobjectType ='Board__c' order by Name asc limit 1];
        
        Test.startTest();
            System.runAs(partnerTestUsers){
                DN_PopManagerController.getBoardIds();          
                DN_BoardController.getBoardListwithCs('General','test','keyword',String.valueOf(todays),recordTypes.Id);
                DN_BoardController.getHomeBoardList('General',String.valueOf(todays),recordTypes.Id);
            }
            User adminUser = [SELECT Id,Name,IsActive,SalesOrganization__c FROM User WHERE UserName='adminTEst1111@test.com1111' AND SalesOrganization__c='1800' LIMIT 1];
            System.runAs(adminUser){
                System.debug(adminUser  +' ::: adminUser');
                DN_BoardController.getBoardList('General','test','keyword',String.valueOf(todays),recordTypes.Id);
                DN_BoardController.getHomeBoardList('General',String.valueOf(todays),recordTypes.Id);
                DN_BoardController.homeBoardListwithSales('General',String.valueOf(todays),recordTypes.Id);
                DN_BoardController.saveQnA('title','Content');
                DN_BoardController.PicklistWrapper wrapper = new DN_BoardController.PicklistWrapper();
                DN_BoardController.PicklistWrapper wrapper2 = new DN_BoardController.PicklistWrapper('test','test');
            }
        Test.stopTest();
    }

 
    
}