/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-28
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-28   yeongdeok.seo@sbtglobal.com   Initial Version
**/
@isTest
public with sharing class DN_AlarmTalkReportBatch_TEST {
    public DN_AlarmTalkReportBatch_TEST() {}

    @isTest(SeeAllData=true)
    static void testExecuteBatch() {
        DN_AlarmTalkReportBatch batch = new DN_AlarmTalkReportBatch();
        Database.executeBatch(batch);
    }
}