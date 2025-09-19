/**
 * @author            : Yu-Hyun Park
 * @description       : Test class for DealerBonusTriggerHandler
 * @last modified on  : 2025-02-17
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-13   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
private class DealerBonusTriggerHandlerTest {

    @testSetup
    static void makeData() {
        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];

        Country__c country = TestDataFactoryForSales.createKRCountry();
        insert country;

        Account dealerAcc;

        System.runAs(thisUser) {
            dealerAcc = TestDataFactoryForSales.createAccount('Dealer', country, null);
            insert dealerAcc;
    
            // Create test DealerBonus__c records
            DealerBonus__c dbRecord = new DealerBonus__c(
                Name        = 'Test Dealer Bonus',
                Year__c     = '2024',
                Dealer__c   = dealerAcc.Id,
                OwnerId     = UserInfo.getUserId()
            );
            
            insert dbRecord;
        }
    }

    @isTest
    static void testValidationCheck() {
        // Retrieve test DealerBonus__c record
        DealerBonus__c dbRecord = [SELECT Id, Name, Year__c, OwnerId FROM DealerBonus__c LIMIT 1];

        // Test invalid Year__c format
        Test.startTest();
        try {
            dbRecord.Year__c = 'abc';
            update dbRecord;
            System.assert(false, 'Expected validation error for Year__c but none occurred.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('This field must be a 4-digit number and cannot start with 0.'),
                'Validation error for Year__c did not occur as expected.');
        }
        Test.stopTest();
    }

    @isTest
    static void testOwnerIdUpdateDisallowed() {
        // Retrieve test DealerBonus__c record
        DealerBonus__c dbRecord = [SELECT Id, Name, Year__c, OwnerId FROM DealerBonus__c LIMIT 1];

        // Create a new User
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User newOwner = new User(
            FirstName           = 'New',
            LastName            = 'Owner',
            Email               = 'newowner@test.com',
            Username            = 'newowner@test.com',
            Alias               = 'nowner',
            TimeZoneSidKey      = 'America/Los_Angeles',
            LocaleSidKey        = 'en_US',
            EmailEncodingKey    = 'UTF-8',
            ProfileId           = standardProfile.Id,
            LanguageLocaleKey   = 'en_US'
        );
        insert newOwner;

        // Attempt to change OwnerId
        Test.startTest();
        try {
            dbRecord.OwnerId = newOwner.Id;
            update dbRecord;
            System.assert(false, 'Expected validation error for OwnerId update but none occurred.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Can only be changed through the Sharing modal.'),
                'Validation error for OwnerId update did not occur as expected.');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidUpdate() {
        // Retrieve test DealerBonus__c record
        DealerBonus__c dbRecord = [SELECT Id, Name, Year__c FROM DealerBonus__c LIMIT 1];

        // Update with valid data
        Test.startTest();
        dbRecord.Year__c = '2025';
        update dbRecord;
        Test.stopTest();

        // Verify update
        DealerBonus__c updatedRecord = [SELECT Id, Year__c FROM DealerBonus__c WHERE Id = :dbRecord.Id];
        System.assertEquals('2025', updatedRecord.Year__c, 'Year__c should be updated to 2025.');
    }
}