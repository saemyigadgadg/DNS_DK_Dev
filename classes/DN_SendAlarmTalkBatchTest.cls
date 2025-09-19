@isTest
public with sharing class DN_SendAlarmTalkBatchTest {
    @isTest
    static void testGetRecordInfo(){        

        List<UTIL_Alert.historyWrapper> wrappers = new List<UTIL_Alert.historyWrapper>();
        List<DN_HappyCallBatch.CampaignTargetWrapper> hWrappers = new List<DN_HappyCallBatch.CampaignTargetWrapper>();

        Test.startTest();
        DN_SendAlarmTalkBatch stb = new DN_SendAlarmTalkBatch();
        stb.wrappers = wrappers;
        stb.ctwrappers = hWrappers;
        Database.executeBatch(stb, 10);
        Test.stopTest();
    }
}