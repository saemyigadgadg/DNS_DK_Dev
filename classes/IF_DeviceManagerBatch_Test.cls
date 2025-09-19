@IsTest
public with sharing class IF_DeviceManagerBatch_Test {
    public IF_DeviceManagerBatch_Test() {}

    @IsTest 
    static void deviceManagerBatch(){
        InterfaceCommonUtil.setInterface('IF-OPTY-001', 'IF_ERP_Opty_DeviceManager');
        Test.startTest();
        List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR> satnr_list =
        new List<IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR>();

        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR item =
        new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req_I_T_SATNR();
        item.LOW = 'MH0004'; 

        satnr_list.add(item);


        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req wrapper =
            new IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req(); 
            wrapper.I_CA_RNDD = 'X';
            wrapper.I_T_SATNR = satnr_list;     


        IF_DeviceManagerBatch batchJob = new IF_DeviceManagerBatch(wrapper,'T_ZCRMS0002');
        Database.executeBatch(batchJob, 50);

        Test.stopTest();            
    }
}