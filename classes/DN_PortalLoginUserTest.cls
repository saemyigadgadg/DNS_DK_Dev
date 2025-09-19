/**
 * @description       : 
 * @author            : daewook.kim@sbtglobal.com
 * @last modified on  : 04-22-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-24-2025   daewook.kim@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_PortalLoginUserTest {
    static String partnerUserName ='partACOCC@test.test.com';
    static String partnerUserName2 ='part2ACOCC@test.test.com';

    static String accId;

    @TestSetup
    static void makeData(){
        List<User> userList = new List<User>();
        User adminTestUser = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser.SalesOrganization__c = '1800';
        adminTestUser.DistributionChannel__c = '10';
        adminTestUser.Division__c = '40';
        adminTestUser.SalesOffice__c = '1146';
        // adminTestUser.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser);

        insert userList;

        Contact con;
        System.runAs(adminTestUser) {
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            System.debug('dealer.CustomerCode__c: ' + dealer.CustomerCode__c);
            insert dealer;
    
            accId = dealer.Id;
            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;
    
            List<Sequence__c> sequenceList = new List<Sequence__c>();
            Sequence__c seq0 = new Sequence__c(
                Name ='DealerCustomer_Dealer',
                Type__c = 'Dealer', 
                Pattern__c = 'C1{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq0);

            Sequence__c seq1 = new Sequence__c(
                Name ='DealerCustomer_Customer',
                Type__c = 'Customer', 
                Pattern__c = 'C5{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq1);

            insert sequenceList;

            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            insert dealerCustomer;
            System.debug(dealerCustomer + ' ::: dealerCustomer');
            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(dealerCustomer.Id);
            System.debug(shipTo +' :: shipTo');
            insert shipTo;
        }
    
        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.SalesOrganization__c = '1846';
        partnerTestUser.DistributionChannel__c = '10';
        partnerTestUser.Division__c = '40';
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;

        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(accId);
            customer.Name = 'dealerCustomer';
            customer.RoadAddr__c = '부산광역시 강서구 유통단지1로 41';
            customer.DetailInfo__c = '대저2동 부산티플렉스131동 117,217,118,218호';
            
            insert customer;

            DealerCustomerShipTo__c shipTo = TestDataFactoryForDealerPortal.getCustomerShipTO(customer.Id);
            shipTo.IsDealer__c = true;
            insert shipTo;
        }
    }

    @isTest
    static void testGetUserInfo_Success() {
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        String userId = partPortalUser.Id;
        System.runAs(partPortalUser) {        
            DN_PortalLoginUser.GetUserInfo(userId);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetUserInfo_Fail() {
        Test.startTest();
        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];
        String userId = '005xxxxxxxxxxxxx';
        System.runAs(partPortalUser) {
            try {
                DN_PortalLoginUser.GetUserInfo(userId);
            }catch(AuraHandledException e){
                system.debug(e);
            }
        }
        Test.stopTest();
    }
}