/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-09
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-20   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ImportOpportunityControllerTest {

    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        // Country__c country = TestDataFactoryForSales.createCountry('USA', 'USD', 'US');
        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Region__c region = TestDataFactoryForSales.createRegion('KRRegion', 'KRW', 'KRR', country.Id);
        insert region;

        DNSAModel__c model = new DNSAModel__c(
            Name = 'ModelA',
            ModelName__c = 'ModelA'
        );
        insert model;

        Competitor__c comp = new Competitor__c(
            Name = 'CompetitorX'
        );
        insert comp;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler' ,'UserTriggerHandler'};
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account dnsaAcc = TestDataFactoryForSales.createAccount('DNSACustomer', country, null);
            dnsaAcc.CustomerCode__c = '11111';
            dnsaAcc.Name = 'DNSACustomer';
            dnsaAcc.Representative__c = 'DNSARep';
            insert dnsaAcc; 

            Contact contactPerson = TestDataFactoryForSales.createContact('ContactPerson', dnsaAcc.Id);
            insert contactPerson;

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';
            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            dealer.SalesOrganization__c = '4140';
            insert dealer;

            Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(dnsaAcc, dealer, 'DNSA');
            opty.ETOpportunityId__c = 'Id';
            insert opty;
        }
    }


    @isTest
    static void testGetOptydMetadata() {
        Test.startTest();
        List<String> headers = DN_ImportOpportunityController.getImportOpportunityMetadata();
        Test.stopTest();
    }


    @isTest
    static void testUpdateOpportunity() {
        // Map을 사용하여 JSON 입력 데이터 생성 (키 순서를 삽입 순서에 따라 유지할 가능성이 있음)
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        Map<String, Object> rec = new Map<String, Object>();
        User dealerUser = [SELECT Id, Username FROM User WHERE LastName =: 'dealer'];
        Date today = Date.today();
        
        rec.put('Column_0', '22222');                // Dealer 코드
        rec.put('Column_1', 'DealerName');           // Dealer 코드
        rec.put('Column_2', dealerUser.Username);          // Opportunity Owner Name (lead key 구성에 사용)
        rec.put('Column_3', 'Acme Customer');          // Account 이름 (lead key 구성에 사용)
        rec.put('Column_4', 'AcmeReps');          // Account 이름 (lead key 구성에 사용)
        rec.put('Column_5', 'ModelA');                 // Model Name
        rec.put('Column_6', '70');                     // Probability (Excel 값)
        rec.put('Column_7', '03/13/2025');                  // Close Date (Excel days)
        rec.put('Column_8', '');                  // Request Delivery Date (Excel days)
        rec.put('Column_9', 'KR');                     // Country 코드
        rec.put('Column_10', 'KRR');                 // Region 코드
        rec.put('Column_11', 'MA');               // MainCategory
        rec.put('Column_12', 'MA6');                // SubCategory
        rec.put('Column_13', 'MY');                     // IsTooling
        rec.put('Column_14', 'PO123');                 // PO
        rec.put('Column_15', '123 Main St');           // ShippingStreet
        rec.put('Column_16', 'Metropolis');            // ShippingCity
        rec.put('Column_17', 'NY');                    // ShippingState
        rec.put('Column_18', '10001');                 // ShippingPostalCode
        rec.put('Column_19', '555-0000');              // Phone
        rec.put('Column_20', 'customer@example.com');  // Email
        rec.put('Column_21', 'ContactLastName');       // Contact Person LastName
        rec.put('Column_22', 'CompetitorX');           // Competitor
        rec.put('Column_23', 'Visit');       // LeadSourceDNSA__c
        rec.put('Column_26', 'Id');       // ETOpportunityId__c
        
        records.add(rec);
        String jsonInput = JSON.serialize(records);
        
        Test.startTest();
        String result = DN_ImportOpportunityController.upsertRecords(jsonInput);
        Test.stopTest();

    }

    @isTest
    static void testInsertOpportunity() {
        // Map을 사용하여 JSON 입력 데이터 생성 (키 순서를 삽입 순서에 따라 유지할 가능성이 있음)
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        Map<String, Object> rec = new Map<String, Object>();
        User dealerUser = [SELECT Id, Username FROM User WHERE LastName =: 'dealer'];
        Date today = Date.today();
        
        rec.put('Column_0', '22222');                // Dealer 코드
        rec.put('Column_1', 'DealerName');           // Dealer 코드
        rec.put('Column_2', dealerUser.Username);          // Opportunity Owner Name (lead key 구성에 사용)
        rec.put('Column_3', 'Acme Customer');          // Account 이름 (lead key 구성에 사용)
        rec.put('Column_4', 'AcmeReps');          // Account 이름 (lead key 구성에 사용)
        rec.put('Column_5', 'ModelA');                 // Model Name
        rec.put('Column_6', '70');                     // Probability (Excel 값)
        rec.put('Column_7', '03/13/2025');                  // Close Date (Excel days)
        rec.put('Column_8', '');                  // Request Delivery Date (Excel days)
        rec.put('Column_9', 'KR');                     // Country 코드
        rec.put('Column_10', 'KRR');                 // Region 코드
        rec.put('Column_11', 'MA');               // MainCategory
        rec.put('Column_12', 'MA6');                // SubCategory
        rec.put('Column_13', 'MY');                     // IsTooling
        rec.put('Column_14', 'PO123');                 // PO
        rec.put('Column_15', '123 Main St');           // ShippingStreet
        rec.put('Column_16', 'Metropolis');            // ShippingCity
        rec.put('Column_17', 'NY');                    // ShippingState
        rec.put('Column_18', '10001');                 // ShippingPostalCode
        rec.put('Column_19', '555-0000');              // Phone
        rec.put('Column_20', 'customer@example.com');  // Email
        rec.put('Column_21', 'ContactLastName');       // Contact Person LastName
        rec.put('Column_22', 'CompetitorX');           // Competitor
        rec.put('Column_23', 'Visit');       // LeadSourceDNSA__c
        
        records.add(rec);
        String jsonInput = JSON.serialize(records);
        
        Test.startTest();
        String result = DN_ImportOpportunityController.upsertRecords(jsonInput);
        Test.stopTest();

    }


    @isTest
    static void testUpsertAccount() {
        // Map을 사용하여 JSON 입력 데이터 생성 (키 순서를 삽입 순서에 따라 유지할 가능성이 있음)
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        Map<String, Object> rec = new Map<String, Object>();
        User dealerUser = [SELECT Id, Username FROM User WHERE LastName =: 'dealer'];

        rec.put('Column_0', '22222');                // Dealer 코드
        rec.put('Column_1', 'DealerName');           // Dealer 코드
        rec.put('Column_2', dealerUser.Username);          // Opportunity Owner Name (lead key 구성에 사용)
        rec.put('Column_3', 'DNSACustomer');          // Account 이름 (lead key 구성에 사용)
        rec.put('Column_4', 'DNSARep');          // Account 이름 (lead key 구성에 사용)
        rec.put('Column_5', 'ModelA');                 // Model Name
        rec.put('Column_6', '70');                     // Probability (Excel 값)
        rec.put('Column_7', '03/13/2025');                  // Close Date (Excel days)
        rec.put('Column_8', '');                  // Request Delivery Date (Excel days)
        rec.put('Column_9', 'KR');                     // Country 코드
        rec.put('Column_10', 'KRR');                 // Region 코드
        rec.put('Column_11', 'MA');               // MainCategory
        rec.put('Column_12', 'MA6');                // SubCategory
        rec.put('Column_13', 'MY');                     // IsTooling
        rec.put('Column_14', 'PO123');                 // PO
        rec.put('Column_15', '123 Main St');           // ShippingStreet
        rec.put('Column_16', 'Metropolis');            // ShippingCity
        rec.put('Column_17', 'NY');                    // ShippingState
        rec.put('Column_18', '10001');                 // ShippingPostalCode
        rec.put('Column_19', '555-0000');              // Phone
        rec.put('Column_20', 'customer@example.com');  // Email
        rec.put('Column_21', 'ContactLastName');       // Contact Person LastName
        rec.put('Column_22', 'CompetitorX');           // Competitor
        rec.put('Column_23', 'Visit');       // LeadSourceDNSA__c
        
        records.add(rec);
        String jsonInput = JSON.serialize(records);
        
        Test.startTest();
        String result = DN_ImportOpportunityController.upsertRecords(jsonInput);
        Test.stopTest();

    }

   
}