/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-01-13
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-13   yuhyun.park@sbtglobal.com   Initial Version
**/
@isTest
private class DealerKPITriggerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create test data setup
        DealerKPI__c validKPI = new DealerKPI__c(
            Name = 'Valid KPI',
            Year__c = '2024'
        );
        insert validKPI;
    }

    @isTest
    static void testValidationCheckForValidYear() {
        // Test valid Year__c
        DealerKPI__c validKPI = new DealerKPI__c(
            Name = 'Test KPI',
            Year__c = '2023'
        );

        Test.startTest();
        insert validKPI;
        Test.stopTest();

        DealerKPI__c insertedKPI = [SELECT Id, Year__c FROM DealerKPI__c WHERE Id = :validKPI.Id];
        System.assertEquals('2023', insertedKPI.Year__c, 'Year__c should be valid and saved.');
    }

    @isTest
    static void testValidationCheckForInvalidYear() {
        // Test invalid Year__c
        DealerKPI__c invalidKPI = new DealerKPI__c(
            Name = 'Invalid KPI',
            Year__c = 'abcd'
        );

        Test.startTest();
        try {
            insert invalidKPI;
            System.assert(false, 'Expected validation error for invalid Year__c but none occurred.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('This field must be a 4-digit number and cannot start with 0.'),
                'Validation error for Year__c did not occur as expected.');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidationCheckOnUpdate() {
        // Retrieve existing DealerKPI__c record
        DealerKPI__c existingKPI = [SELECT Id, Year__c FROM DealerKPI__c LIMIT 1];

        // Update with valid Year__c
        existingKPI.Year__c = '2025';

        Test.startTest();
        update existingKPI;
        Test.stopTest();

        DealerKPI__c updatedKPI = [SELECT Id, Year__c FROM DealerKPI__c WHERE Id = :existingKPI.Id];
        System.assertEquals('2025', updatedKPI.Year__c, 'Year__c should be updated to 2025.');
    }

    @isTest
    static void testValidationCheckOnInvalidUpdate() {
        // Retrieve existing DealerKPI__c record
        DealerKPI__c existingKPI = [SELECT Id, Year__c FROM DealerKPI__c LIMIT 1];

        // Attempt to update with invalid Year__c
        existingKPI.Year__c = 'abcd';

        Test.startTest();
        try {
            update existingKPI;
            System.assert(false, 'Expected validation error for invalid Year__c update but none occurred.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('This field must be a 4-digit number and cannot start with 0.'),
                'Validation error for Year__c update did not occur as expected.');
        }
        Test.stopTest();
    }
}