/** 
 * @Class :  DN_DealerPortalQuoteCreateCon_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 18. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-18 | Hyunwook Jin   | 최초작성 
 */
@isTest
public with sharing class DN_DealerPortalQuoteCreateCon_TEST {
    static String partnerUserName ='partPoIt@test.test.com';
    static String partnerUserName2 ='part2PoIt@test.test.com';

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

        User adminTestUser2 = TestDataFactoryForDealerPortal.createTestAdminUser('CEO');
        adminTestUser2.SalesOrganization__c = '1800';
        adminTestUser2.DistributionChannel__c = '10';
        adminTestUser2.Division__c = '40';
        adminTestUser2.SalesOffice__c = '1146';
        // adminTestUser2.SalesDistrict__c = 'A1KR';
        userList.add(adminTestUser2);

        insert userList;

        
        Contact con;
        System.runAs(adminTestUser) {
            // Test.startTest();
            Account dealer = TestDataFactoryForDealerPortal.dealer;
            // dealer.isPa
            insert dealer;

            con = TestDataFactoryForDealerPortal.createContact(dealer.Id);
            insert con;

            DealerCustomer__c dealerCustomer = TestDataFactoryForDealerPortal.getCustomer(dealer.Id);
            insert dealerCustomer;

            List<Sequence__c> sequenceList = new List<Sequence__c>();
            Sequence__c seq1 = new Sequence__c(
                Name ='DealerCustomer_Dealer',
                Type__c = 'Dealer', 
                Pattern__c = '1{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq1);

            Sequence__c seq2 = new Sequence__c(
                Name ='DealerCustomer_Customer',
                Type__c = 'Customer', 
                Pattern__c = '5{000000}',
                SObjectAPI__c = 'DealerCustomer__c',
                StartNumber__c = 1
            );
            sequenceList.add(seq2);
            insert sequenceList;

            List<Product2> partList = new List<Product2>();
            partList.add(
                TestDataFactoryForDealerPortal.getPart('R18181', 'R18181영문', 'R18181국문')
            );
            insert partList;
            // test.stopTest();
        }
    
        User partnerTestUser = TestDataFactoryForDealerPortal.createTestPartPortalUser(con.Id);
        partnerTestUser.Username = partnerUserName;
        insert partnerTestUser;
        System.runAs(partnerTestUser) {
            DealerCustomer__c customer = TestDataFactoryForDealerPortal.getCustomer(null);
            customer.Name = 'test';
            insert customer;
        }
        
    }

    @isTest 
    static void doSimulation_TEST() {
        test.startTest();
        List<String> partCodeList = new List<String> {
            'R18181'
        };
        DN_DealerPortalQuoteCreateController.doSimulation(partCodeList);
        test.stopTest();
    }

    @isTest
    static void doSaveAndDownload_TEST() {
        test.startTest();

        User partPortalUser = [SELECT Id FROM User WHERE UserName = :partnerUserName LIMIT 1];

        System.runAs(partPortalUser) {
            
            DN_UserDetails currentUser = new DN_UserDetails();
            
            List<DealerCustomer__c> customers = [ SELECT Id, Name FROM DealerCustomer__c WHERE IsDealer__c = false ];

            List<Product2> partList = [ SELECT Id, ProductCode, FM_MaterialDetails__c FROM Product2 WHERE ProductCode = 'R18181'];

            DN_DealerPortalQuoteCreateController.Quote quote = new DN_DealerPortalQuoteCreateController.Quote();
            quote.salesOrganization = currentUser.getSalesOranization();
            quote.distributionChannel = currentUser.getDistributionChannel();
            quote.division    = currentUser.getDivision();
            quote.dealer      = currentUser.getAgencyId();
            quote.dealerName  = currentUser.getAgencyName();
            quote.customer    = customers[0].id;
            quote.customerName = customers[0].Name;
            quote.machineName = '기종';
            quote.equipment   = '장비번호';
            quote.description = '견적서 설명';
            quote.address     = ''; 
            quote.phone       = '';
            quote.fax         = '';
            quote.postalCode  = '';

            DN_DealerPortalQuoteCreateController.QuoteItem quoteItem = new DN_DealerPortalQuoteCreateController.QuoteItem();
            quoteItem.part          = partList[0].id;      
            quoteItem.partName      = partList[0].ProductCode;            
            quoteItem.partDetails   = partList[0].FM_MaterialDetails__c;      
            quoteItem.replacingPart = partList[0].id;      
            quoteItem.replacingPartName  = partList[0].ProductCode;
            quoteItem.replacingPartDetails = partList[0].FM_MaterialDetails__c;
            quoteItem.unit = '';
            quoteItem.quantity = 1;    
            quoteItem.customerPrice = 1000; 
            quoteItem.discountRate = 10.0;  
            quoteItem.discountPrice = quoteItem.customerPrice * (1 - quoteItem.discountRate/ 100);
            quoteItem.discountAmount = quoteItem.quantity * quoteItem.discountPrice;
            quote.itemList.add(quoteItem);
            
            Map<String,Object> saveResult = DN_DealerPortalQuoteCreateController.doSave(quote);
            DN_DealerPortalQuoteCreateController.doDownloadQuote((String)saveResult.get('quoteId'));
        }

        test.stopTest();

    }
}