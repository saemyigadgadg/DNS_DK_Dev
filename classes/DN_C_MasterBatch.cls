/**
 * @description       : 
 * @author            : sunwoong.han@dkbmc.com
 * @group             : 
 * @last modified on  : 2025-09-19
 * @last modified by  : sunwoong.han@dkbmc.com
**/
public abstract without sharing class DN_C_MasterBatch implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
    // [S]
    /**
     * Batch Logger Class
     */
    public virtual class BatchLog {
        public String log {get;set;}
        public String methodName {get;set;}
        public Datetime startDatetime {get;set;}
        public Datetime endDatetime {get;set;}
        private String loggingFirstComments = '--------------------{0}--------------------';

        public BatchLog(){
            this.startDatetime = Datetime.now();
        }

        public void loggingStart() {
            this.log = String.format(loggingFirstComments, new List<String>{this.methodName});
        }

        public void setEndDatetime(){
            this.endDatetime = Datetime.now();
        }

        public void addLog(String log){
            this.log += '\n'+log;
        }
    }

    /**
     * Batch Start Funtion Log Class
     */
    public class StartLog extends BatchLog {
        public String startStatement {get;set;}
        public String batchClassName {get;set;}
        public Integer totalCount {get;set;}
        
        public StartLog() {
            this.methodName = 'start';
            loggingStart();
        }

        public void setClassName(String className) {
            this.batchClassName = className;
        }

        public void setStartStatement(List<Object> startStatement) {
            this.totalCount         = startStatement.size();
            this.startStatement     = JSON.serializePretty(startStatement);
            this.log                += '\n' + '**** total scope size : [' + this.totalCount + ']';
            setEndDatetime();
        }
    }

    /**
     * Batch Execute Funtion Log Class
     */
    public class ExecuteLog extends BatchLog {
        public Integer successCount {get;set;}
        public Integer failCount {get;set;}

        public ExecuteLog() {
            this.methodName     = 'execute';
            this.successCount   = 0;
            this.failCount      = 0;
            loggingStart();
        }

        public void setExecuteResult(Integer successCount, Integer failCount) {
            this.successCount    = (this.successCount == null ? 0 : this.successCount) + successCount;
            this.failCount       = (this.failCount == null ? 0 : this.failCount) + failCount;
            this.log             += '\n' + '- successCount : [' + this.successCount + ']';
            this.log             += '\n' + '- failCount : [' + this.failCount + ']';
            setEndDatetime();
        }
    }

    /**
     * Batch Finish Funtion Log Class
     */
    public class FinishLog extends BatchLog {
        public FinishLog() {
            this.methodName = 'finish';
            loggingStart();
        }
    }
    // [E]
    
    protected List<Object> START_STATEMENT;
    protected StartLog S_LOG;
    protected String STATUS;
    protected ExecuteLog E_LOG;
    protected FinishLog F_LOG;
    protected private Integer EXECUTE_COUNT = 0;

    public Iterable<Object> start(Database.BatchableContext BC) {
        S_LOG = new StartLog();
        S_LOG.setClassName(String.valueOf(this).substring(0, String.valueOf(this).indexOf(':')));

        try {
            START_STATEMENT = startF();
            S_LOG.setStartStatement(START_STATEMENT);
        } catch (Exception e) {
            STATUS = DN_C_Utils.StatusCode.ERROR.name();
            S_LOG.addLog(e.getMessage() + ' Stack Trace:: ' + e.getStackTraceString());
            S_LOG.setEndDatetime();
        }

        return START_STATEMENT;
    }

    public void execute(Database.BatchableContext BC, List<Object> scope){
        Integer scopeSize = scope.size();

        E_LOG = E_LOG == null ? new ExecuteLog() : E_LOG;
        E_LOG.addLog('======================================================');
        E_LOG.addLog('**** execute count :: [' + ++EXECUTE_COUNT + ']');
        E_LOG.addLog('- scope size :: [' + scopeSize + ']');

        try {
            executeF(scope);
            E_LOG.setExecuteResult(scopeSize, 0);
        } catch (Exception e) {
            STATUS = DN_C_Utils.StatusCode.ERROR.name();
            E_LOG.addLog(e.getMessage() + ' Stack Trace:: ' + e.getStackTraceString());
            E_LOG.setExecuteResult(0, scopeSize);
        }
    }

    public void finish(Database.BatchableContext bc){
        F_LOG = new FinishLog();

        try {
            finishF();
        } catch (Exception e) {
            STATUS = DN_C_Utils.StatusCode.ERROR.name();
            F_LOG.addLog(e.getMessage() + ' Stack Trace:: ' + e.getStackTraceString());
        } finally {
            F_LOG.setEndDatetime();

            BatchLog__c bLog = createBatchLog();
            insert bLog;
        }
    }

    private BatchLog__c createBatchLog() {
        BatchLog__c bLog = new BatchLog__c();

        bLog.ExecuteCount__c     = EXECUTE_COUNT;
        bLog.BatchClass__c       = S_LOG.batchClassName;
        bLog.StartStatement__c   = substringMax(S_LOG.startStatement);
        bLog.SStartDatetime__c   = S_LOG.startDatetime;
        bLog.SEndDatetime__c     = S_LOG.endDatetime;
        bLog.StartLog__c         = substringMax(S_LOG.log);
        bLog.TotalCount__c       = S_LOG.totalCount;
        bLog.Status__c           = STATUS == null ? DN_C_Utils.StatusCode.SUCCESS.name() : STATUS;

        if(E_LOG != null) {
            bLog.EStartDatetime__c   = E_LOG.startDatetime;
            bLog.EEndDatetime__c     = E_LOG.endDatetime;
            bLog.ExecuteLog__c       = substringMax(E_LOG.log);
            bLog.SuccessCount__c     = E_LOG.successCount;
            bLog.FailCount__c        = E_LOG.failCount;
        }

        if(F_LOG != null) {
            bLog.FStartDatetime__c   = F_LOG.startDatetime;
            bLog.FEndDatetime__c     = F_LOG.endDatetime;
            bLog.FinishLog__c        = substringMax(F_LOG.log);
        }

        return bLog;
    }

    private String substringMax(String text) {
        return text.length() > 131072 ? text.substring(0, 131072) : text;
    }

    @TestVisible
    protected virtual List<Object> startF(){
        return START_STATEMENT;
    }
    
    @TestVisible
    protected virtual void executeF(List<Object> scope){}
    
    @TestVisible
    protected virtual void finishF(){}
}