/**
 * @description       : 
 * @author            : geonsang.park@sobetec.com
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : geonsang.park@sobetec.com
**/
@isTest
private class SignatureContainerController_TEST {
    
    @testSetup
    static void setupData() {
        
        WorkOrder wo = new WorkOrder(
            Subject = 'Test WorkOrder',
            Status = 'New',
            hasCustomerSign__c = false,
            hasEngineerSign__c = false
        );
        insert wo;
        
    }

    @isTest
    static void testSaveSignatureNew() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        String dummyBody = EncodingUtil.base64Encode(Blob.valueOf('Dummy Signature'));

        Test.startTest();
        Boolean result = SignatureContainerController.saveSignatureNew(dummyBody, wo.Id, 'engineer');
        Test.stopTest();   
    }

    @isTest
    static void testDeleteSignFile() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        String dummyBody = EncodingUtil.base64Encode(Blob.valueOf('Dummy Signature'));
        SignatureContainerController.saveSignatureNew(dummyBody, wo.Id, 'customer');

        Test.startTest();
        String deleteResult = SignatureContainerController.deleteSignFile(wo.Id, 'customer');
        Test.stopTest();

    }

    @isTest
    static void testGetSignature() {
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        String dummyBody = EncodingUtil.base64Encode(Blob.valueOf('Dummy Signature'));

        SignatureContainerController.saveSignatureNew(dummyBody, wo.Id, 'customer');

        Test.startTest();
        String url = SignatureContainerController.getSignature(wo.Id, 'customer');
        Test.stopTest();

        
    }
}