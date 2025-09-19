/** 
 * @Class :  DN_AsyncApexErrorLogger_TEST
 * 
 * @Author : Hyunwook Jin 
 * @Date : 2025. 03. 21. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-03-21 | Hyunwook Jin   | 최초작성 
 */ 
@isTest
public with sharing class DN_AsyncApexErrorLogger_TEST {
    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void inserFailLog() {
        DN_AsyncApexErrorLogger logger = new DN_AsyncApexErrorLogger();
        logger.addLog('비동기Id', 'DN_AsyncApexErrorLogger_TEST', 'inserFailLog', '비동기타입', 'log 사유');
        logger.insertLog();
    }
}