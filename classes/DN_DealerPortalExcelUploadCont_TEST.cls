@IsTest
public with sharing class DN_DealerPortalExcelUploadCont_TEST {
    @IsTest
    static void test1(){
        Test.startTest();
        DN_DealerPortalExcelUploadController.ExcelTemplate template = new DN_DealerPortalExcelUploadController.ExcelTemplate();
        DN_DealerPortalExcelUploadController.ExcelTemplateColumn column = new DN_DealerPortalExcelUploadController.ExcelTemplateColumn();
        DN_DealerPortalExcelUploadController.getTemplate('StorageBinTemplate');
        Test.stopTest();
        
    }
}