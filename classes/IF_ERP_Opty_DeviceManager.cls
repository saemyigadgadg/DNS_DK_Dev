/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-18-2024   deokjun.kim@sbtglobal.com   Initial Version
**/
public with sharing class IF_ERP_Opty_DeviceManager {
    public InterfaceCommonUtil interfaceUtil = InterfaceCommonUtil.getInterfaceUtil();
    private String  apexClassName = 'IF_ERP_Opty_DeviceManager';
    private Boolean isResponseXml = true;  
    private String  interfaceId;
    public IF_ERP_Opty_DeviceManager() {}


/** IF_OPTY_001
    */  
    /**
         * Apex Class           : IF_ERP_Opty_DeviceManager
         * Wrapper Class        : IF_ERP_Opty_DeviceManager_Classes
         * Wrapper Name         : IF_OPTY_001
         * SFDC interface Id    : IF-OPTY-001
         * AS-IS RFC            : 	
         * New I/F              : ZCRM_SD_RESPONSIBLE_4_MODEL
         * Description          : 기종별 담당자 정보 연동
         * KeyValue             : X
         * NOT NULL             : X
     */               
    public IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res IF_OPTY_001(
        IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Req parameters){
            // interfaceUtil.isInsertLog = false;
            interfaceId = 'IF-OPTY-001';
            String parametersString = 'InputParam=' 
                                        + '{"Input":' 
                                        + JSON.serialize(parameters) 
                                        + '}'; 
    
            String responseString = interfaceUtil.sendHttp(parametersString, interfaceId, apexClassName, isResponseXml);
    
            try {
                System.debug('responseString :: '+responseString);
    
                IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res response = 
                (IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res) JSON.deserialize(
                    responseString, 
                    IF_ERP_Opty_DeviceManager_Classes.IF_OPTY_001_Res.class);
        
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');            
                    System.debug(':::::::::::::  RESPONSE =>');
                    System.debug(':::::::::::::    {');
                    System.debug(':::::::::::::    '+JSON.serialize(response));
                    System.debug(':::::::::::::    } ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    ');
                    System.debug(':::::::::::::    INTERFACE ID : '+interfaceId);
                    System.debug(':::::::::::::    RFC NAME     : ZCRM_SD_RESPONSIBLE_4_MODEL');
                    return response;        
    
            } catch (Exception e) {
                System.debug('ERROR MESSAGE : '+e.getMessage());
                System.debug('ERROR LINE NUMBER : '+e.getLineNumber());
                return null;        
            }                        
    }
}