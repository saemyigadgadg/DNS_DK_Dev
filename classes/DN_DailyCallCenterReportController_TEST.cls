/**
 * @author            : Yeong-Deok Seo
 * @description       : 
 * @last modified on  : 2025-03-30
 * @last modified by  : yeongdeok.seo@sbtglobal.com
**/
@isTest
public with sharing class DN_DailyCallCenterReportController_TEST {
    @TestSetup
    static void makeData(){

    }

    @isTest
    static void testCoverageTest() {
        Date startDate = Date.newInstance(2025, 6, 20);
        Date endDate = Date.newInstance(2025, 6, 25);

        Test.startTest();
        DN_DailyCallCenterReportController.getCallCenterData(startDate, endDate);
        // DN_DailyCallCenterReportController.getCallCenterData(null, null);
        Test.stopTest();
    }
}