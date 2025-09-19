/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-02-20
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-02-17   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_ImportDealerKPIControllerTest {
    
    @TestSetup
    static void makeData(){

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Set<String> bypassSet = new Set<String>{'AccountTriggerHandler', 'ContactTriggerHandler', 'DealerKPITriggerHandler' };
        TriggerHandler.bypassedHandlers = bypassSet; // Too many SOQL queries 대응

        User dealer;
        System.runAs(thisUser) {
            Account prospectAcc = TestDataFactoryForSales.createAccount('ProspectCustomer', country, null);
            prospectAcc.CustomerCode__c = '11111';
            insert prospectAcc; 

            Account dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            dealerAcc.Name = 'test Dealer';
            dealerAcc.CustomerCode__c = '22222';
            dealerAcc.Phone = '111-222';

            insert dealerAcc;

            Contact delaerCon = TestDataFactoryForSales.createContact('Dealer', dealerAcc.Id);
            insert delaerCon;
    
            dealer = TestDataFactoryForSales.createDomesticDealer(true, dealerAcc, delaerCon);
            insert dealer;

            DealerKPI__c koreaYearKPI = new DealerKPI__c(
                Year__c = '2025',
                Dealer__c = dealerAcc.Id,
                Key__c = '22222-KoreaYear-2025',
                Sales__c = 1000,
                SalesIncrease__c = 50,
                RegularOrderRatio__c = 30,
                SpecialDCRatio__c = 20,
                CMComplianceRate__c = 95,
                Subtotal_SalesProfit__c = 200,
                TradeCustomerCount__c = 5,
                StrategicCustomersCount__c = 3,
                Subtotal_Customer__c = 8,
                FulltimeEmployeesCount__c = 10,
                ExclusiveDealersCount__c = 2,
                Subtotal_DealerResource__c = 12,
                InquiriesCount__c = 20,
                NormalOrderRate__c = 70,
                OrderHitRate__c = 65,
                Subtotal_SalesRoyalty__c = 150,
                WholesaleOverdueInterest__c = 10,
                PolicyCompliance__c = 100,
                Subtotal_Bonus__c = 300,
                Total__c = 1000
            );
            insert koreaYearKPI;

            DealerKPI__c koreaHalfKPI = new DealerKPI__c(
                Year__c = '2025',
                Dealer__c = dealerAcc.Id,
                Key__c = '22222-KoreaHalf-2025-상반기',
                Sales__c = 1000,
                SalesIncrease__c = 50,
                RegularOrderRatio__c = 30,
                SpecialDCRatio__c = 20,
                CMComplianceRate__c = 95,
                Subtotal_SalesProfit__c = 200,
                TradeCustomerCount__c = 5,
                StrategicCustomersCount__c = 3,
                Subtotal_Customer__c = 8,
                FulltimeEmployeesCount__c = 10,
                ExclusiveDealersCount__c = 2,
                Subtotal_DealerResource__c = 12,
                InquiriesCount__c = 20,
                NormalOrderRate__c = 70,
                OrderHitRate__c = 65,
                Subtotal_SalesRoyalty__c = 150,
                WholesaleOverdueInterest__c = 10,
                PolicyCompliance__c = 100,
                Subtotal_Bonus__c = 300,
                Total__c = 1000
            );
            insert koreaHalfKPI;

            DealerKPI__c globalYearKPI = new DealerKPI__c(
                Year__c = '2025',
                Dealer__c = dealerAcc.Id,
                Key__c = '22222-GlobalYear-2025',
                AnnualOrderIntakeperProduct__c = 100,
                RegularPriceOrderIntake__c = 200,
                OrderIntakeforHighendProducts__c = 300,
                NoOfNewCustomersRatio__c = 10,
                MarketSharebyterritory__c = 15,
                CustomerSatisfaction__c = 90,
                Total__c = 1000
            );
            insert globalYearKPI;

            DealerKPI__c globalQuarterKPI = new DealerKPI__c(
                Year__c = '2025',
                Dealer__c = dealerAcc.Id,
                Key__c = '22222-GlobalQuarter-2025-Q1',
                NoOfSalesPersonnel__c = 5,
                RegularPriceOrderIntake__c = 250,
                NoOfExhibitionParticipation__c = 3,
                ShowroomSize__c = 120,
                NoOfNewCustomers__c = 7,
                NoOfKeyAccounts__c = 2,
                AEPersonnelToRevenueRatio__c = 0.5,
                CSPersonnelToRevenueRatio__c = 0.6,
                NoOfViolations__c = 1,
                OrderIntakeProportionAutomation__c = 30,
                OrderIntakeforAutomation__c = 40,
                OrderIntakeProportionHighend__c = 20,
                OrderIntakeHighendProducts__c = 50,
                OrderIntakeProportionPartsCS__c = 15,
                OrderIntakeforPartsCS__c = 35,
                OrderIntakeVersusTarget__c = 80,
                DealerCreditAssessment__c = 90,
                DelinquentPayments__c = 10,
                Total__c = 1000
            );
            insert globalQuarterKPI;
        }
    }


    @isTest
    static void testGetUserInfo(){
        Test.startTest();
        User u = DN_ImportDealerKPIController.getUserInfo();
        Test.stopTest();
    }


    @isTest
    static void testGetKPIMetadata() {
        Test.startTest();
        List<String> headersKoreaYear = DN_ImportDealerKPIController.getKPIMetadata('KoreaYear');
        Test.stopTest();
    }


    @isTest
    static void testKoreaYearInsert() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "KoreaYear", ' +
                '"Year": "2025", ' +
                '"Sales__c": 100, ' +
                '"SalesIncrease__c": 10, ' +
                '"RegularOrderRatio__c": 20, ' +
                '"SpecialDCRatio__c": 30, ' +
                '"CMComplianceRate__c": 40, ' +
                '"Subtotal_SalesProfit__c": 50, ' +
                '"TradeCustomerCount__c": 60, ' +
                '"StrategicCustomersCount__c": 70, ' +
                '"Subtotal_Customer__c": 80, ' +
                '"FulltimeEmployeesCount__c": 90, ' +
                '"ExclusiveDealersCount__c": 100, ' +
                '"Subtotal_DealerResource__c": 110, ' +
                '"InquiriesCount__c": 120, ' +
                '"NormalOrderRate__c": 130, ' +
                '"OrderHitRate__c": 140, ' +
                '"Subtotal_SalesRoyalty__c": 150, ' +
                '"WholesaleOverdueInterest__c": 160, ' +
                '"PolicyCompliance__c": 170, ' +
                '"Subtotal_Bonus__c": 180' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'KoreaYear');
        Test.stopTest();
    }


    @isTest
    static void testKoreaHalfInsert() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "KoreaHalf", ' +
                '"Year": "2025", ' +
                '"Sales__c": 150, ' +
                '"SalesIncrease__c": 15, ' +
                '"RegularOrderRatio__c": 25, ' +
                '"SpecialDCRatio__c": 35, ' +
                '"CMComplianceRate__c": 85, ' +
                '"Subtotal_SalesProfit__c": 55, ' +
                '"TradeCustomerCount__c": 65, ' +
                '"StrategicCustomersCount__c": 75, ' +
                '"Subtotal_Customer__c": 85, ' +
                '"FulltimeEmployeesCount__c": 95, ' +
                '"ExclusiveDealersCount__c": 105, ' +
                '"Subtotal_DealerResource__c": 115, ' +
                '"InquiriesCount__c": 125, ' +
                '"NormalOrderRate__c": 135, ' +
                '"OrderHitRate__c": 145, ' +
                '"Subtotal_SalesRoyalty__c": 155, ' +
                '"WholesaleOverdueInterest__c": 165, ' +
                '"PolicyCompliance__c": 175, ' +
                '"Subtotal_Bonus__c": 185, ' +
                '"Period": "상반기"' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'KoreaHalf');
        Test.stopTest();
    }
    
    @isTest
    static void testGlobalYearInsert() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "GlobalYear", ' +
                '"AnnualOrderIntakeperProduct__c": 110, ' +
                '"RegularPriceOrderIntake__c": 220, ' +
                '"OrderIntakeforHighendProducts__c": 330, ' +
                '"NoOfNewCustomersRatio__c": 12, ' +
                '"MarketSharebyterritory__c": 18, ' +
                '"CustomerSatisfaction__c": 88, ' +
                '"Total__c": 1010, ' +
                '"Year": "2025"' +

            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'GlobalYear');
        Test.stopTest();
    }
    
    @isTest
    static void testGlobalQuarterInsert() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "GlobalQuarter", ' +
                '"NoOfSalesPersonnel__c": 6, ' +
                '"RegularPriceOrderIntake__c": 260, ' +
                '"NoOfExhibitionParticipation__c": 4, ' +
                '"ShowroomSize__c": 130, ' +
                '"NoOfNewCustomers__c": 8, ' +
                '"NoOfKeyAccounts__c": 3, ' +
                '"AEPersonnelToRevenueRatio__c": 0.55, ' +
                '"CSPersonnelToRevenueRatio__c": 0.65, ' +
                '"NoOfViolations__c": 2, ' +
                '"OrderIntakeProportionAutomation__c": 35, ' +
                '"OrderIntakeforAutomation__c": 45, ' +
                '"OrderIntakeProportionHighend__c": 25, ' +
                '"OrderIntakeHighendProducts__c": 55, ' +
                '"OrderIntakeProportionPartsCS__c": 18, ' +
                '"OrderIntakeforPartsCS__c": 38, ' +
                '"OrderIntakeVersusTarget__c": 85, ' +
                '"DealerCreditAssessment__c": 95, ' +
                '"DelinquentPayments__c": 5, ' +
                '"Total__c": 1020, ' +
                '"Year": "2025", ' +
                '"Period": "Q1"' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'GlobalQuarter');
        Test.stopTest();
    }


    @isTest
    static void testKoreaYearUpdate() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "KoreaYear", ' +
                '"Year": "2024", ' +
                '"Sales__c": 100, ' +
                '"SalesIncrease__c": 10, ' +
                '"RegularOrderRatio__c": 20, ' +
                '"SpecialDCRatio__c": 30, ' +
                '"CMComplianceRate__c": 40, ' +
                '"Subtotal_SalesProfit__c": 50, ' +
                '"TradeCustomerCount__c": 60, ' +
                '"StrategicCustomersCount__c": 70, ' +
                '"Subtotal_Customer__c": 80, ' +
                '"FulltimeEmployeesCount__c": 90, ' +
                '"ExclusiveDealersCount__c": 100, ' +
                '"Subtotal_DealerResource__c": 110, ' +
                '"InquiriesCount__c": 120, ' +
                '"NormalOrderRate__c": 130, ' +
                '"OrderHitRate__c": 140, ' +
                '"Subtotal_SalesRoyalty__c": 150, ' +
                '"WholesaleOverdueInterest__c": 160, ' +
                '"PolicyCompliance__c": 170, ' +
                '"Subtotal_Bonus__c": 180' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'KoreaYear');
        Test.stopTest();
    }


    @isTest
    static void testKoreaHalfUpdate() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "KoreaHalf", ' +
                '"Year": "2024", ' +
                '"Sales__c": 150, ' +
                '"SalesIncrease__c": 15, ' +
                '"RegularOrderRatio__c": 25, ' +
                '"SpecialDCRatio__c": 35, ' +
                '"CMComplianceRate__c": 85, ' +
                '"Subtotal_SalesProfit__c": 55, ' +
                '"TradeCustomerCount__c": 65, ' +
                '"StrategicCustomersCount__c": 75, ' +
                '"Subtotal_Customer__c": 85, ' +
                '"FulltimeEmployeesCount__c": 95, ' +
                '"ExclusiveDealersCount__c": 105, ' +
                '"Subtotal_DealerResource__c": 115, ' +
                '"InquiriesCount__c": 125, ' +
                '"NormalOrderRate__c": 135, ' +
                '"OrderHitRate__c": 145, ' +
                '"Subtotal_SalesRoyalty__c": 155, ' +
                '"WholesaleOverdueInterest__c": 165, ' +
                '"PolicyCompliance__c": 175, ' +
                '"Subtotal_Bonus__c": 185, ' +
                '"Period": "상반기"' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'KoreaHalf');
        Test.stopTest();
    }
    
    @isTest
    static void testGlobalYearUpdate() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "GlobalYear", ' +
                '"AnnualOrderIntakeperProduct__c": 110, ' +
                '"RegularPriceOrderIntake__c": 220, ' +
                '"OrderIntakeforHighendProducts__c": 330, ' +
                '"NoOfNewCustomersRatio__c": 12, ' +
                '"MarketSharebyterritory__c": 18, ' +
                '"CustomerSatisfaction__c": 88, ' +
                '"Total__c": 1010, ' +
                '"Year": "2024"' +

            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'GlobalYear');
        Test.stopTest();
    }
    
    @isTest
    static void testGlobalQuarterUpdate() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "22222", ' +
                '"TemplateType": "GlobalQuarter", ' +
                '"NoOfSalesPersonnel__c": 6, ' +
                '"RegularPriceOrderIntake__c": 260, ' +
                '"NoOfExhibitionParticipation__c": 4, ' +
                '"ShowroomSize__c": 130, ' +
                '"NoOfNewCustomers__c": 8, ' +
                '"NoOfKeyAccounts__c": 3, ' +
                '"AEPersonnelToRevenueRatio__c": 0.55, ' +
                '"CSPersonnelToRevenueRatio__c": 0.65, ' +
                '"NoOfViolations__c": 2, ' +
                '"OrderIntakeProportionAutomation__c": 35, ' +
                '"OrderIntakeforAutomation__c": 45, ' +
                '"OrderIntakeProportionHighend__c": 25, ' +
                '"OrderIntakeHighendProducts__c": 55, ' +
                '"OrderIntakeProportionPartsCS__c": 18, ' +
                '"OrderIntakeforPartsCS__c": 38, ' +
                '"OrderIntakeVersusTarget__c": 85, ' +
                '"DealerCreditAssessment__c": 95, ' +
                '"DelinquentPayments__c": 5, ' +
                '"Total__c": 1020, ' +
                '"Year": "2024", ' +
                '"Period": "Q1"' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'GlobalQuarter');
        Test.stopTest();
    }


    @isTest
    static void testUpsertRecordsMissingDealerCode() {
        String jsonInput = '[' +
            '{' +
                '"Column_0": "", ' +
                '"TemplateType": "KoreaYear", ' +
                '"Year": "2025", ' +
                '"Period": "Annual"' +
            '}' +
        ']';
        
        Test.startTest();
        String result = DN_ImportDealerKPIController.upsertRecords(jsonInput, 'KoreaYear');
        Test.stopTest();
    }



}