/**
 * @description       : 
 * @author            : suheon.ha@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-02-2025
 * @last modified by  : suheon.ha@UserSettingsUnder.SFDoc
**/
@isTest
private class DN_FailureAreaControllerTest {

    @testSetup
    static void setupTestData() {
        
        // FailureArea_Major__c
        insert new FailureArea_Major__c(
            ModelCategory__c = 'TEST_MODEL',
            FailureAreaMajor_Label__c = 'MajorLabel1',
            FailureAreaMajor_Value__c = 'MajorValue1',
            // FM_FailureAreaMajor_Label__c = 'FM_MajorLabel1',
            Branch__c = 'DNSA'
        );

        // FailureAreaMiddle__c
        insert new FailureAreaMiddle__c(
            CodeGroup__c = 'MajorValue1',
            FailureAreaMiddle_Label__c = 'MiddleLabel1',
            FailureAreaMiddle_Value__c = 'MiddleValue1',
            ERPCodeGroup__c = 'ERP1'
            // FM_FailureAreaMiddle_Label__c = 'FM_MiddleLabel1'
        );

        // FailurePhenomenon__c
        insert new FailurePhenomenon__c(
            CodeGroup__c = 'MiddleValue1',
            FailurePhenomenon_Label__c = 'PhenomenonLabel1',
            FailurePhenomenon_Value__c = 'PhenomenonValue1'
            // FM_FailurePhenomenon_Label__c = 'FM_PhenomenonLabel1'
        );

        // FailureCause__c
        insert new FailureCause__c(
            CodeGroup__c = 'PhenomenonValue1',
            FailureCause_Label__c = 'CauseLabel1',
            FailureCause_Code__c = 'CauseCode1'
            // FM_FailureCause_Label__c = 'FM_CauseLabel1'
        );

        // RepairAction__c
        insert new RepairAction__c(
            ModelCategory__c = 'TEST_MODEL',
            RepairAction_Label__c = 'RepairLabel1',
            RepairAction_Value__c = 'RepairValue1'
            // FM_Repaire_Action_Label__c = 'FM_RepairLabel1'
        );
    }

    @isTest
    static void testGetFailureAreaMajor() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> results =
            DN_FailureAreaController.getFailureAreaMajor('TEST_MODEL');
        Test.stopTest();
    }

    @isTest
    static void testGetFailureAreaMiddle() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> results =
            DN_FailureAreaController.getFailureAreaMiddle('MajorValue1');
        Test.stopTest();
    }

    @isTest
    static void testGetFailurePhenomenon() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> results =
            DN_FailureAreaController.getFailurePhenomenon('MiddleValue1');
        Test.stopTest();
    }

    @isTest
    static void testGetFailureCause() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> results =
            DN_FailureAreaController.getFailureCause('PhenomenonValue1');
        Test.stopTest();
    }

    @isTest
    static void testGetRepairAction() {
        Test.startTest();
        List<DN_FailureAreaController.CustomSelectOption> results =
            DN_FailureAreaController.getRepairAction('TEST_MODEL');
        Test.stopTest();
    }


}