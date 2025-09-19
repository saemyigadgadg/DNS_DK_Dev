/** 
 * @Class :  DN_DMLBatchProcessing
 * 
 * @Test: DN_DMLBatchProcessing_TEST
 * @Author : Hyunwook Jin 
 * @Date : 2025. 02. 03. 
 * @Version : 1.0 
 * @Modified :  
 *  ---------------------------------------------- 
 *  NO | Date       | Modifier       | Description  
 *  ----------------------------------------------  
 *  1. | 2025-02-03 | Hyunwook Jin   | 최초작성 
 */ 
public with sharing class DN_DMLBatchProcessing implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
    
    public enum DmlType {
        ADD, MODIFY, ADDORMODIFY
        //, HARDDELETE
    } //생성, 수정, 생성 및 수정

    private String externalField {get; set;}
    private List<SObject> dmlList {get; set;}
    private DmlType type {get; set;}

    private DN_AsyncApexErrorLogger logger {
        get {
            if(logger == null) logger = new DN_AsyncApexErrorLogger();
            return logger;
        }
        set;
    }
    
    /*
    * @ 생성자 : DN_DMLBatchProcessing
    * @ Description : Type,dmlList 설정
    */
    public DN_DMLBatchProcessing(DmlType type, List<SObject> dmlList) {
        this.type = type;
        this.dmlList = dmlList;
    }
    
    /*
    * @ 생성자 : DN_DMLBatchProcessing
    * @ Description : Type,dmlList,externalField 설정
    */
    public DN_DMLBatchProcessing(DmlType type, List<SObject> dmlList, String externalField) {
        this.type = type;
        this.dmlList = dmlList;
        this.externalField = externalField;
    }

    /*
    * @ Method : start
    * @ Description : 배치 시작
    */
    public Iterable<sObject> start(Database.BatchableContext context){
        System.debug(' =============== DN_DMLBatchProcessing Batch start ================');
        return dmlList;
    }

    /*
    * @ Method : start
    * @ Description : 배치 실행
    */
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        System.debug(' =============== DN_DMLBatchProcessing Batch Execute ================');
        System.debug(type);
        System.debug(scope.size());
        try {
            Schema.SObjectType objectType = scope.getSObjectType();
            String objectApi = objectType.getDescribe().getName();
            switch on type {
                when  ADD {
                    List<Database.SaveResult> saveResult = Database.insert(scope, false);
                    Integer idx = 0;
                    for (Database.SaveResult sr : saveResult) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully inserted ' + objectApi + ' ID: ' + sr.getId());
                        }
                        else {
                            for(Database.Error err : sr.getErrors()) {
                                String log = 'The following error has occurred. insert IDX ['+idx +'] \n'
                                        + err.getStatusCode() + ': ' + err.getMessage() + ' \n '
                                        + objectApi+ ' fields that affected this error: ' + err.getFields();
                                System.debug(log);                    
                                
                                logger.addLog(context.getJobId() , 'DN_DMLBatchProcessing', 'execute', 'BatchApex', log);
                            }
                        }
                        idx++;
                    }
                }
                when  MODIFY {
                    List<Database.SaveResult> saveResult = Database.update(scope, false);
                    Integer idx = 0;
                    for (Database.SaveResult sr : saveResult) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully update ' + objectApi + ' ID: ' + sr.getId());
                        }
                        else {
                            for(Database.Error err : sr.getErrors()) {
                                String log = 'The following error has occurred. update IDX ['+idx +'] \n'
                                        + err.getStatusCode() + ': ' + err.getMessage() + ' \n '
                                        + objectApi+ ' fields that affected this error: ' + err.getFields();
                                System.debug(log);                    
                                
                                logger.addLog(context.getJobId() , 'DN_DMLBatchProcessing', 'execute', 'BatchApex', log);
                            }
                        }
                        idx++;
                    }
                    
                }
                when  ADDORMODIFY {
                    Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                    Schema.SObjectField fieldToken = fieldMap.get(externalField.toLowerCase());

                    if(fieldToken == null) fieldToken = fieldMap.get('id');
                    Integer idx = 0;
                    List<Database.UpsertResult> upsertResultList = Database.upsert(scope, fieldToken, false);
                    for (Database.UpsertResult ur : upsertResultList) {
                        if (ur.isSuccess()) {
                            System.debug('Successfully upsert ' + objectApi + ' ID: ' + ur.getId());
                        }
                        else {
                            for(Database.Error err : ur.getErrors()) {
                                String log = 'The following error has occurred. upsert IDX ['+idx +'] \n'
                                        + err.getStatusCode() + ': ' + err.getMessage() + ' \n '
                                        + objectApi+ ' fields that affected this error: ' + err.getFields();
                                System.debug(log);                    
                                
                                logger.addLog(context.getJobId() , 'DN_DMLBatchProcessing', 'execute', 'BatchApex', log);
                            }
                        }
                        idx++;
                    }
                }
            }
        } catch (Exception e) {
            String log = ' '
                       + ' Exception : ' + e.getStackTraceString() + '\n'
                       + ' Message : ' + e.getMessage();
            System.debug(log);
            logger.addLog(context.getJobId() , 'DN_DMLBatchProcessing', 'execute', 'BatchApex', log);

            if(logger.size() > 0)
                logger.insertLog();
        }
        
    }

    /*
    * @ Method : finish
    * @ Description : 배치 종료
    */
    public void finish(Database.BatchableContext context){
        System.debug(' =============== DN_DMLBatchProcessing Batch finish ================');
        System.debug('배치 실행 완료');

        
    }
}