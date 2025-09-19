/** 
 * @Class :  DN_AsyncApexErrorLogger
 * 
 * @Test: DN_AsyncApexErrorLogger_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 02. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-02 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_AsyncApexErrorLogger {
    private List<AsyncApexJobExceptionLog__c> logList {
        get {
            if(logList == null) logList = new List<AsyncApexJobExceptionLog__c>();
            return logList;
        }
        set;
    }
    
    public DN_AsyncApexErrorLogger() {}
    /*
    * @ Method : addLog
    * @ Description : logList에 로그 정보 담기
    */
    public void addLog(String jobId,String apexClass, String methodName, String jobType, String log) {
        logList.add(new AsyncApexJobExceptionLog__c(
            JobId__c = jobId,
            ApexClass__c = apexClass,
            methodName__c = methodName,
            JobType__c = jobType,
            Log__c = log
        ));
    }

    /*
    * @ Method : insertLog
    * @ Description : 로그 생성
    */
    public void insertLog() {
        if(logList.size() > 0) {
            insert logList;
            logList.clear();
        }
    }

    /*
    * @ Method : size
    * @ Description : 로그 사이즈 반환
    */
    public Integer size() {
        return logList.size();
    }
}