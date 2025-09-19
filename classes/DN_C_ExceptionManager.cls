/**
 * @description       : 
 * @author            : sunwoong.han@dkbmc.com
 * @group             : 
 * @last modified on  : 2025-09-19
 * @last modified by  : sunwoong.han@dkbmc.com
**/
public with sharing class DN_C_ExceptionManager implements Queueable, Database.AllowsCallouts {
    private static String DATETIME_FORMAT_STRING = 'yyyy-MM-dd HH:mm:ssZ';
    private static List<ExceptionInfo> EXCEPTION_LIST;

    class ExceptionInfo {
        public String className;
        public String methodName;
        public String message;
        public String stackTrace;
        public String eventDatetime;
        public String eventDatetimeGmt;
        public String userId;
        public String params;
        public Datetime currentDatetime;

        public ExceptionInfo(String className, String methodName, String message, String stackTrace, Object inputParams) {
            this.className = className;
            this.methodName = methodName;
            this.message = message;
            this.stackTrace = stackTrace;
            this.currentDatetime = Datetime.now();
            this.eventDatetime = this.currentDatetime.format(DATETIME_FORMAT_STRING);
            this.eventDatetimeGmt = this.currentDatetime.formatGmt(DATETIME_FORMAT_STRING);
            this.userId = UserInfo.getUserId();
            if(inputParams != null) this.params = JSON.serializePretty(inputParams);
        }
    }

    /**
    * @description Exception Log 데이터 생성
    * @author sunwoong.han@dkbmc.com | 2025-09-02 
    * @param Exception e
    **/
    public static void doCatch(Exception e, Object inputParams) {
        String stackTrace = e.getStackTraceString();
        List<String> stackTraceLines = stackTrace.split('\n');
        String className;
        String methodName;

        if (stackTraceLines.size() > 0) {
            String errorLocationLine = stackTraceLines[0];
            Integer colonIndex = errorLocationLine.indexOf(':');

            if (colonIndex != -1) {
                String classAndMethod = errorLocationLine.substring(0, colonIndex);
                List<String> parts = classAndMethod.split('\\.');

                if (parts.size() >= 2) {
                    className = parts[parts.size() - 2];
                    methodName = parts[parts.size() - 1];
                }
            }
        }

        if(EXCEPTION_LIST == null) EXCEPTION_LIST = new List<ExceptionInfo>();
        EXCEPTION_LIST.add(
            new ExceptionInfo(
                className,
                methodName,
                e.getMessage(),
                stackTrace,
                inputParams
            )
        );
    }

    /**
    * @description Exception Log 저장 Queue 실행
    * @author sunwoong.han@dkbmc.com | 2025-09-02 
    **/
    public static void finishCatch() {
        if(EXCEPTION_LIST != null && EXCEPTION_LIST.size() > 0) {
            System.enqueueJob(new DN_C_ExceptionManager(EXCEPTION_LIST));
        }
    }

    /**
     * Queueable
     */
    private List<ExceptionInfo> QUEUEABLE_EXCEPTION_LIST;
    private List<String> EXCEPTION_RECIVERS;
    private String ORGWIDEEMAILADDRESS_ID;
    private String ORG_URL;

    public DN_C_ExceptionManager(List<ExceptionInfo> exceptionList) {
        QUEUEABLE_EXCEPTION_LIST     = exceptionList;
        EXCEPTION_RECIVERS           = getExceptionRecivers();
        ORGWIDEEMAILADDRESS_ID       = getOrgWideEmailAddress();
        ORG_URL                      = DN_C_Utils.getLexOrigin();
    }

    public void execute(QueueableContext context) {
        if(QUEUEABLE_EXCEPTION_LIST != null && QUEUEABLE_EXCEPTION_LIST.size() > 0) {
            List<ExceptionLog__c> logs = new List<ExceptionLog__c>();
            for(ExceptionInfo ei : QUEUEABLE_EXCEPTION_LIST) {
                logs.add(new ExceptionLog__c(
                    ApexClassName__c         = ei.className,
                    MethodName__c            = ei.methodName,
                    Message__c               = ei.message,
                    StackTrace__c            = ei.stackTrace,
                    ExceptionDatetime__c     = ei.currentDatetime,
                    DatetimeString__c        = ei.eventDatetime,
                    DatetimeGMTString__c     = ei.eventDatetimeGmt,
                    Arguments__c             = ei.params,
                    User__c                  = ei.userId
                ));
            }
            if(logs != null && logs.size() > 0) {
                insert logs;

                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                for(ExceptionLog__c log : logs) {
                    String body = 'Exception Log\n'
                                + 'Apex Class Name : '  + log.ApexClassName__c   + '\n'
                                + 'Method Name : '      + log.MethodName__c      + '\n'
                                + 'Arguments : '        + log.Arguments__c       + '\n'
                                + 'Error Message : '    + log.Message__c         + '\n'
                                + 'Stack Trace : '      + log.StackTrace__c      + '\n'
                                + 'log record url : '   + ORG_URL                + '/' + log.Id;

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(EXCEPTION_RECIVERS);
                    mail.setSubject('Exception Alert');
                    mail.setPlainTextBody(body);
                    
                    if(ORGWIDEEMAILADDRESS_ID != null) mail.setOrgWideEmailAddressId(ORGWIDEEMAILADDRESS_ID);

                    emails.add(mail);
                }
                if(!Test.isRunningTest()) Messaging.sendEmail(emails);
            }
        }
    }

    /**
    * @description Exception Email Notification Reciver List
    * @author sunwoong.han@dkbmc.com | 2025-09-02 
    * @return List<String> 
    **/
    private List<String> getExceptionRecivers() {
        List<String> receivers = new List<String>();
        for(ExceptionManager__c em : ExceptionManager__c.getAll().values()) {
            if(em.Email__c != null && em.IsActive__c) receivers.add(em.Email__c);
        }
        return receivers;
    }

    /**
    * @description Get OrgWideEmaillAddress first record Id
    * @author sunwoong.han@dkbmc.com | 2025-09-02 
    * @return Id 
    **/
    private Id getOrgWideEmailAddress() {
        List<OrgWideEmailAddress> owe = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        if(owe != null && owe.size() > 0) return owe[0].Id;
        return null;
    }
}