@IsTest
public with sharing class IF_ERP_DeliveryOrderBatch_Test {
    public IF_ERP_DeliveryOrderBatch_Test() {}

    @IsTest
    static void DeliveryOrderBatchTest(){
        InterfaceCommonUtil.setInterface('IF-DELIV-002', 'IF_ERP_DELIV');
        Test.startTest();
        IF_ERP_DELIV_Classes.IF_DELIV_002_Req_I_USERINFO i_userInfo = 
        new IF_ERP_DELIV_Classes.IF_DELIV_002_Req_I_USERINFO();
        i_userInfo.BNAME = 'MPUFS002';
        i_userInfo.HIER = 'A';
        i_userInfo.KUNNR = '1169833';
        i_userInfo.VKORG = '1800';
        i_userInfo.VTWEG = '10';
        i_userInfo.SPART = '40';
        
        IF_ERP_DELIV_Classes.IF_DELIV_002_Req req = new IF_ERP_DELIV_Classes.IF_DELIV_002_Req();
        req.I_AEDAT_FR = '20250201';
        req.I_AEDAT_TO = '20250217';
        req.I_USERINFO = i_userInfo;
        
        
        List<String> tableNameList = new List<String>{
            'T_MATERIAL',  
            'T_PARTNER',
            'T_DOC',
            'T_ZCRMS0062',
            'T_HEADER',
            'T_CREDIT',
            'T_COND',
            'T_NOTE',
            'T_CHANGE',
            'T_DELINFO'
        };
        
        for(String tableNm : tableNameList){
            IF_ERP_DeliveryOrderBatch batch = new IF_ERP_DeliveryOrderBatch(req,tableNm);
            Database.executeBatch(batch, 50); 
        }
        Test.stopTest();        
    }
}