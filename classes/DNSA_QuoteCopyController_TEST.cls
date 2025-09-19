/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   04-02-2025   Hanyeong Choi   Initial Version
**/
@isTest
public with sharing class DNSA_QuoteCopyController_TEST {
    @isTest
    static void cloneCommodityQuote_Test() {

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account acc = TestDataFactoryForSales.createAccount('TradeCustomer', country, null);
        acc.CustomerCode__c   = 'CUST001';
        acc.BusinessNumber__c = '5148171773';
        acc.Representative__c = 'realAcc';
        insert acc;

        Opportunity opty = TestDataFactoryForSales.createDNSDomesticOpty(acc, currentUser, 'General');
        insert opty;

        Id recordTypeIdCommo = SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('DNSA_Commodity').getRecordTypeId();
        Quote quote1 = new Quote (
            Name = 'testQuote (v1)',
            RecordTypeId = recordTypeIdCommo,
            OpportunityId = opty.Id
        );
        Quote quote2 = new Quote (
            Name = 'testQuote (v2)',
            RecordTypeId = recordTypeIdCommo,
            OpportunityId = opty.Id
        );
        TriggerHandler.bypass('QuoteTriggerHandler');
        insert quote1;
        insert quote2;
        TriggerHandler.clearBypass('QuoteTriggerHandler');

        Test.startTest();
        DNSA_QuoteCopyController.cloneCommodityQuote(quote2.Id);
        Test.stopTest();
    }
}