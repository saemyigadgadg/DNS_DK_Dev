/**
 * @description       : DN_AccountController 초안
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 05-29-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   11-20-2024   Hanyeong Choi   Initial Version
**/
@isTEST
public with sharing class DN_AccountController_TEST {
    @TestSetup
    static void setUp() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        AlertManager__c am1 = TestDataFactoryForSales.createAlertManager('GlobalDealerConvertTradeAlert');
        AlertManager__c am2 = TestDataFactoryForSales.createAlertManager('Request Convert Account Alert');
        AlertManager__c am3 = TestDataFactoryForSales.createAlertManager('Convert Trade Customer Request Alert');
        insert new List<AlertManager__c>{am1, am2, am3};
        
        // Country 생성
        Country__c krCountry = TestDataFactoryForSales.createKRCountry();
        Country__c usCountry = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        insert new List<Country__c>{krCountry, usCountry};
        
        // Region 생성
        Region__c krRegion = TestDataFactoryForSales.createRegion('제주도', 'KRW', '01', krCountry.Id);
        Region__c usRegion = TestDataFactoryForSales.createRegion('California', 'USD', 'CA', usCountry.Id);
        insert new List<Region__c>{krRegion, usRegion};

        List<Account> prospect = new List<Account>{
            createProspectAccount(krCountry, 'MVC', '2025-01-01', '2025-02-01', 'wddww', 'dwdwadaq', true, krRegion.Id, 9),
            createProspectAccount(krCountry, null, null, null, 'TEST2TEST2123', 'TESTT21', true, krRegion.Id, 7),
            createProspectAccount(usCountry, null, null, null, 'TEST4TEST4352', 'TESTT24', true, usRegion.Id, 8)
        };
        insert prospect;
        
        User dealer;
        User dealer2;
        System.runAs(thisUser) {
            // Dealer Account 생성
            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', krCountry, null);
            Account dealerAcc2 = TestDataFactoryForSales.createAccount('Dealer', usCountry, null);
            dealerAcc2.Name = 'ExclusiveDealer';
            dealerAcc2.Representative__c = 'Exclusive';
            dealerAcc2.BusinessNumber__c = '151235341';
            dealerAcc2.IsExclusiveDealer__c = true;
            dealerAcc2.SalesOrganization__c = '4140';
            dealerAcc2.SalesOffice__c = '414A';
            dealerAcc2.SalesDistrict__c = 'M3US';
            dealerAcc2.DistributionChannel__c = '10';
            dealerAcc2.Division__c = '40';
            insert new List<Account>{dealerAcc, dealerAcc2};
            
            // Dealer Contact 생성
            Contact dealerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            Contact dealerCon2 = TestDataFactoryForSales.createContact('Dealer', dealerAcc2.Id);
            dealerCon2.LastName = 'asdas';
            dealerCon2.Email = 'qregrgdf@gmail.com';
            dealerCon2.SalesOrganization__c = '4140';
            dealerCon2.SalesOffice__c = '414A';
            dealerCon2.SalesDistrict__c = 'MP04';
            dealerCon2.DistributionChannel__c = '10';
            dealerCon2.Division__c = '40';
            insert new List<Contact>{dealerCon, dealerCon2};
            
            // Dealer 생성
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, dealerCon);
            dealer2 = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc2, dealerCon2);
            dealer2.Email = 'qregrgdf@gmail.com';
            dealer2.LastName = 'asdas';
            dealer2.Alias = 'fwefwefw';
            dealer2.SalesDistrict__c = 'MP04';
            insert new List<User>{dealer, dealer2};
            
            // User 생성
            insert TestDataFactoryForSales.createDNSUser('영업 KA', 'KA');
        }
        
        // Too many SOQL queries 방지
        TriggerHandler.bypassedHandlers = new Set<String>{'AccountTriggerHandler'};
        
        System.runAs(dealer) {
            // Prospect Account 생성
            List<Account> prospectAccounts = new List<Account>{
                createProspectAccount(krCountry, 'MVC', '2025-01-01', '2025-02-01', null, null, false, null, 1),
                createProspectAccount(krCountry, null, null, null, 'TEST2TEST2', 'TESTT', true, krRegion.Id, 2),
                createProspectAccount(usCountry, null, null, null, 'TEST3TEST3', 'TESTT3', true, null, 3),
                createProspectAccount(usCountry, null, null, null, 'TEST4TEST4', 'TESTT4', true, usRegion.Id, 4)
            };
            insert prospectAccounts;
            
            // Parent Account 생성
            Account parentAcc = TestDataFactoryForSales.createParentAccount(krCountry);
            insert parentAcc;
            
            // Trade Account 생성
            Account tradeAcc = TestDataFactoryForSales.createAccount('TradeCustomer', krCountry, parentAcc);
            tradeAcc.CustomerCode__c    = '123456';
            tradeAcc.BusinessNumber__c  = '5148171773';
            tradeAcc.Representative__c  = 'realAcc';
            insert tradeAcc;
            
            // SalesAreaData 생성
            List<SalesAreaData__c> salesAreas = new List<SalesAreaData__c>();
            for (Account acc : prospectAccounts) {
                salesAreas.add(TestDataFactoryForSales.createAreaData(acc));
            }
            salesAreas.add(TestDataFactoryForSales.createAreaData(tradeAcc));
            insert salesAreas;
            
            // Contact 생성
            insert TestDataFactoryForSales.createContact('ContactPerson', tradeAcc.Id);

            DNS_RequestToUseCustomer__c asd = new DNS_RequestToUseCustomer__c();
            asd.TargetAccount__c = prospectAccounts[0].Id;
            asd.RequestReason__c = 'TEST';
            insert asd;
        }

        // System.runAs(dealer2) {
        //     List<Account> prospectAccounts = new List<Account>{
        //         // createProspectAccount(krCountry, 'MVC', '2025-01-01', '2025-02-01', null, null, false, null, 1),
        //         createProspectAccount(krCountry, null, null, null, 'TEST2TEST2', 'TESTT', true, krRegion.Id, 2),
        //         createProspectAccount(usCountry, null, null, null, 'TEST3TEST3', 'TESTT3', true, null, 3)
        //         // createProspectAccount(usCountry, null, null, null, 'TEST4TEST4', 'TESTT4', true, usRegion.Id, 4)
        //     };
        //     insert prospectAccounts;
        // }
    }

    @isTest
    static void portalHeaderInit_Test() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        DN_AccountController.portalHeaderInit(acc.Id);
        Test.stopTest();
    }

    @isTest
    static void checkConvertRequired_TestCase1() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-006', 'IF_ERP_Account');
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'test company' LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'TEST2TEST2' LIMIT 1];
        Account acc3 = [SELECT Id FROM Account WHERE Name = 'TEST3TEST3' LIMIT 1];
        Account acc4 = [SELECT Id FROM Account WHERE Name = 'TEST4TEST4' LIMIT 1];
        Account acc5 = [SELECT Id FROM Account WHERE Name = 'TEST2TEST2123' LIMIT 1];
        Account acc6 = [SELECT Id FROM Account WHERE Name = 'TEST4TEST4352' LIMIT 1];

        Test.startTest();
        DN_AccountController.checkConvertRequired(acc1.Id);
        DN_AccountController.checkConvertRequired(acc2.Id);
        DN_AccountController.checkConvertRequired(acc3.Id);
        DN_AccountController.checkConvertRequired(acc4.Id);
        DN_AccountController.checkConvertRequired(acc5.Id);
        DN_AccountController.checkConvertRequired(acc6.Id);
        Test.stopTest();
    }

    @isTest
    static void checkConvertRequired_TestCasetest() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-006', 'IF_ERP_Account');
        Account acc6 = [SELECT Id FROM Account WHERE Name = 'TEST4TEST4' LIMIT 1];
        User dealer = [SELECT Id, SalesDistrict__c FROM User WHERE LastName = 'dealer' LIMIT 1];
        dealer.SalesDistrict__c = 'M3UL';
        
        Test.startTest();
        DN_AccountController.checkConvertRequired(acc6.Id);
        Test.stopTest();
    }
    @isTest
    static void checkConvertRequired_TestCasetest2() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-006', 'IF_ERP_Account');
        Account acc6 = [SELECT Id FROM Account WHERE Name = 'TEST4TEST4' LIMIT 1];
        User dealer = [SELECT Id, SalesDistrict__c FROM User WHERE LastName = 'asdas' LIMIT 1];

        Test.startTest();
        System.runAs(dealer) {
            DN_AccountController.checkConvertRequired(acc6.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void checkConvertRequired_TestCase2() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-006', 'IF_ERP_Account');
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'test company' LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'TEST2TEST2' LIMIT 1];
        Account acc3 = [SELECT Id FROM Account WHERE Name = 'TEST3TEST3' LIMIT 1];
        Account acc4 = [SELECT Id FROM Account WHERE Name = 'TEST4TEST4' LIMIT 1];

        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();
        System.runAs(dealer) {
            DN_AccountController.checkConvertRequired(acc1.Id);
            DN_AccountController.checkConvertRequired(acc2.Id);
            DN_AccountController.checkConvertRequired(acc3.Id);
            DN_AccountController.checkConvertRequired(acc4.Id);
        }
        Test.stopTest();
    }
    
    @isTest
    static void checkConvertRequired_TestCase3() {
        InterfaceCommonUtil.setInterface('IF-ACCOUNT-006', 'IF_ERP_Account');
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'test company' LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'TEST2TEST2' LIMIT 1];
        Account acc3 = [SELECT Id FROM Account WHERE Name = 'TEST3TEST3' LIMIT 1];
        Account acc4 = [SELECT Id FROM Account WHERE Name = 'TEST4TEST4' LIMIT 1];

        User dealer2 = [SELECT Id FROM User WHERE Alias = 'fwefwefw' LIMIT 1];

        Test.startTest();
        System.runAs(dealer2) {
            DN_AccountController.checkConvertRequired(acc1.Id);
            DN_AccountController.checkConvertRequired(acc2.Id);
            DN_AccountController.checkConvertRequired(acc3.Id);
            DN_AccountController.checkConvertRequired(acc4.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void getAddress_Test() {
        InterfaceCommonUtil.setInterface('MOIS_ADDRESS', 'IF_MOIS_ADDRESS', 'SUCCESS');

        Test.startTest();
        DN_AccountController.getAddress('대왕판교로', 1);
        Test.stopTest();
    }

    @isTest
    static void setShippingAddress_Test() {
        Account krAcc = [SELECT Id FROM Account WHERE Name = 'TEST2TEST2' LIMIT 1];
        Map<String, Object> addressMap = new Map<String, Object>{
            'roadAddr'  => 'New Road Address',
            'zipNo'     => '67890',
            'siNm'      => 'New City',
            'sggNm'     => 'New District'
        };
        String detailInfo = 'Apt 101';

        Test.startTest();
        DN_AccountController.setShippingAddress(krAcc.Id, addressMap, detailInfo);
        Test.stopTest();
    }

    @isTest
    static void checkBusinessNumber_Test() {
        InterfaceCommonUtil.setInterface('NTS_BusinessNumber', 'IF_NTS_BusinessNumber');
        Account acc = [SELECT Id FROM Account WHERE Name = 'test company' LIMIT 1];

        Test.startTest();
        DN_AccountController.checkBusinessNumber(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    static void checkBusinessNumber_ListView_Test() {
        InterfaceCommonUtil.setInterface('NTS_BusinessNumber', 'IF_NTS_BusinessNumber');

        Test.startTest();
        DN_AccountController.checkBusinessNumber_ListView('123123112233');
        Test.stopTest();
    }

    @isTest
    static void updateIsBusinessLicense_Test() {
        Account krAcc = [SELECT Id FROM Account WHERE Name = 'test company' LIMIT 1];

        Test.startTest();
        DN_AccountController.updateIsBusinessLicense(krAcc.Id);
        Test.stopTest();
    }

    // @isTest
    // static void getSalesAreaData_Test() {
    //     Account krAcc = [SELECT Id FROM Account WHERE Name = 'TEST2TEST2123' LIMIT 1];
    //     SalesAreaData__c asd = TestDataFactoryForSales.createAreaData(krAcc);
    //     insert asd;

    //     Test.startTest();
    //     DN_AccountController.getSalesAreaData(krAcc.Id);
    //     Test.stopTest();
    // }

    @isTest
    static void getSalesAreaData_Test() {
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'test company' LIMIT 1];
        User dealer = [SELECT Id FROM User WHERE LastName = 'dealer' LIMIT 1];

        Test.startTest();
        System.runAs(dealer) {
            DN_AccountController.getSalesAreaData(acc1.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void getSiteUrlList_Test() {
        Test.startTest();
        DN_AccountController.getSiteUrlList();
        Test.stopTest();
    }

    @isTest
    static void setDealerCustomerAddress_Test() {
        DealerCustomer__c dc = new DealerCustomer__c(
            Name = 'dcTest'
        );
        TriggerHandler.bypass('DealerCustomerTriggerHandler');
        insert dc;
        TriggerHandler.clearBypass('DealerCustomerTriggerHandler');

        Map<String, Object> addressMap = new Map<String, Object>{
            'roadAddr'  => 'New Road Address',
            'zipNo'     => '67890',
            'siNm'      => 'New City',
            'sggNm'     => 'New District'
        };
        String detailInfo = 'Apt 101';

        Test.startTest();
        DN_AccountController.setDealerCustomerAddress(dc.Id, addressMap, detailInfo);
        Test.stopTest();
    }

    @isTest
    static void OrderInfoWrapper_Test() {
        Test.startTest();
        new DN_AccountController.OrderInfoWrapper(
            'Test Owner', 
            'ORD-12345', 
            '2024-02-06T10:30:00Z', 
            Date.today(), 
            'Processing', 
            'Test Item'
        );
        Test.stopTest();
    }

    @isTest
    static void FieldCheckWrapper_Test() {
        Test.startTest();
        DN_AccountController.FieldCheckWrapper fieldCheck = new DN_AccountController.FieldCheckWrapper();
        fieldCheck.isKorea                      = true;
        fieldCheck.checkResult                  = true;
        fieldCheck.businessNumber               = true;
        fieldCheck.production                   = false;
        fieldCheck.isBusinessLicense            = true;
        fieldCheck.residentRegistrationNumber   = false;
        fieldCheck.isTotalBusinessNumber        = true;
        fieldCheck.isBVC                        = false;
        fieldCheck.shippingAddress              = true;
        fieldCheck.typeOfBusiness               = true;
        fieldCheck.typeOfIndustry               = false;
        fieldCheck.country                      = true;
        fieldCheck.region                       = false;
        Test.stopTest();
    }

    @isTest
    static void SalesAreaFieldCheckWrapper_Test() {
        Test.startTest();
        DN_AccountController.SalesAreaFieldCheckWrapper salesAreaCheck = new DN_AccountController.SalesAreaFieldCheckWrapper();
        salesAreaCheck.checkResult          = true;
        salesAreaCheck.name                 = 'Test Sales Area';
        salesAreaCheck.currencyField        = true;
        salesAreaCheck.shippingConditions   = false;
        salesAreaCheck.incoterms            = true;
        salesAreaCheck.termsOfPayment       = false;
        salesAreaCheck.district             = true;
        salesAreaCheck.office               = false;
        Test.stopTest();
    }

    @isTest
    static void getConfirmInfo_Test() {
        Account krAcc = [SELECT Id FROM Account WHERE Name = 'test company' LIMIT 1];
        DNS_RequestToUseCustomer__c asd = [SELECT Id FROM DNS_RequestToUseCustomer__c LIMIT 1];

        Test.startTest();
        DN_AccountController.getConfirmInfo(krAcc.Id, 'Account');
        DN_AccountController.getConfirmInfo(asd.Id, 'DNS_RequestToUseCustomer__c');
        Test.stopTest();
    }

    private static Account createProspectAccount(Country__c country, String customerSystem, String startDate, String endDate,
                                                String name, String production, Boolean isBusinessLicense, String regionId, Integer i) {
        Account acc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
        Integer j = 51481135;
        Integer bNumber = i + j;
        
        acc.Name                        = (name != null)                ? name                      : acc.Name;
        acc.Production__c               = (production != null)          ? production                : null;
        acc.CustomerSystem__c           = (customerSystem != null)      ? customerSystem            : null;
        acc.CustomerSystemStartDate__c  = (startDate != null)           ? Date.valueOf(startDate)   : null;
        acc.CustomerSystemEndDate__c    = (endDate != null)             ? Date.valueOf(endDate)     : null;
        acc.IsBusinessLicense__c        = (isBusinessLicense != null)   ? isBusinessLicense         : false;
        acc.RegionLookup__c             = (regionId != null)            ? regionId                  : null;
        acc.BusinessNumber__c           = String.valueOf(bNumber);
        acc.CustomerCode__c           = '111111' + String.valueOf(i);
        return acc;
    }

}