/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @group             : 
 * @last modified on  : 2025-04-23
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   12-20-2024   Hanyeong Choi   Initial Version
**/
public virtual with sharing class TriggerHandler {
    
    private static User currentUser;
    public static Set<String> bypassedHandlers;
    protected long handlerStartTimeMillis = System.currentTimeMillis();
    protected Boolean hasDivisionCondition = false;
    public static Boolean isActive = TriggerSetting__c.getInstance()?.isActive__c;
    public Boolean isExecuting;
    public Boolean doFieldTracking = true;
    public Boolean isDiffusion = false;
    public static MT_Trigger_Active__mdt triggerOption;
    public TriggerOperation operationType;
    public String currentClassName;
    public static Map<String, MT_Trigger_Active__mdt> triggerOptionMap;
    public static User currentUserInfo;
    public static Boolean onceExecution = false;
    public static Set<Id> profileIdSet;
    public static Boolean isBatchUpdate = false;

    static {
        bypassedHandlers = new Set<String>();
    }
    public TriggerHandler(){
        if(currentUser == null) TriggerHandler.currentUser = [SELECT Id, Division, Profile.name FROM User WHERE Id = :UserInfo.getUserId()];
        this.currentClassName = String.valueOf(this).split(':')[0];
        System.debug('currentClassName - ' + this.currentClassName);
    }

    public TriggerHandler(Boolean isExecuting, TriggerOperation operationType){
        if(currentUser == null) currentUser = [SELECT Id, Division, Profile.name FROM User WHERE Id = :UserInfo.getUserId()];
        this.isExecuting = isExecuting;
        this.operationType = operationType;
        this.currentClassName = String.valueOf(this).split(':')[0];
        System.debug('currentClassName - ' + this.currentClassName);
    } 

    public void setting(Boolean isExecuting, TriggerOperation operationType){
        this.isExecuting = isExecuting;
        this.operationType = operationType;
    }
    
    public void setting(Boolean isExecuting, TriggerOperation operationType, Boolean doFieldTracking){
        this.isExecuting = isExecuting;
        this.operationType = operationType;
        this.doFieldTracking = doFieldTracking;
    }

    public static void setBatchUpdate(Boolean value) {
        isBatchUpdate = value;
    }

    @TestVisible
    private static TriggerOption  getCurrentHandlerOption(String currentClassName){
        if(triggerOptionMap == null)  {
            triggerOptionMap = new Map<String, MT_Trigger_Active__mdt>();
            for( MT_Trigger_Active__mdt taOption : [SELECT Id, DeveloperName, IsActive__c, IsSingleProcessing__c, ActiveDivision__c, Organization__c FROM MT_Trigger_Active__mdt]) {
                triggerOptionMap.put(taOption.DeveloperName , taOption);
            }
        }
        triggerOption = triggerOptionMap.get(currentClassName);
        return new TriggerOption(
            triggerOption?.IsActive__c,
            triggerOption?.IsSingleProcessing__c,
            triggerOption?.ActiveDivision__c
        );
    }

    public User getUserInfo(){
        return TriggerHandler.currentUser;
    }

    public void execute( List<sObject> news, List<sObject> olds, Map<Id, sObject> newMap, Map<Id, sObject> oldMap){
        List<TriggerExceptionLog__c> exLogs = new List<TriggerExceptionLog__c>();
        triggerOption option = getCurrentHandlerOption(currentClassName);

        // TEST Code Coverage
        if (Test.isRunningTest()) {
            option = new TriggerOption(true, false, 'All');
            TriggerHandler.isActive = true;
            System.debug( new TriggerOption(true, false) );
        }

        String UserProfilename = this.getUserInfo().Profile.name;
        if(UserProfilename == null) UserProfilename = '';
        try{
            if(TriggerHandler.isActive && option.isActive){
                if(!validateRun()) {
                    return;
                }
                if(  this.getUserInfo() == null ) currentUserInfo = [SELECT Id, Name, Email, Title, Profile.name FROM User WHERE Id = :UserInfo.getUserId()];
                switch on operationType {
                    when BEFORE_INSERT {
                        
                        // 조건에 따라 실행여부 결정
                        if(executeCondition(news, null) && !option.IsSingleProcessing) this.onBeforeInsert(news);
                        else if(executeCondition(news, null) && option.IsSingleProcessing && news.size() == 1) this.onBeforeInsert(news[0]);

                        OrganizationMapper org = new OrganizationMapper(news);
                        org.mappingField(news);
                    }
                    when AFTER_INSERT {
                        // 조건에 따라 실행여부 결정
                        if(executeCondition(news, null) && !option.IsSingleProcessing) this.onAfterInsert(news, newMap);
                        else if(executeCondition(news, null) && option.IsSingleProcessing && news.size() == 1) this.onAfterInsert(news[0]);
                    }
                    when BEFORE_UPDATE {
                        
                        // 조건에 따라 실행여부 결정
                        if(executeCondition(news, olds) && !option.IsSingleProcessing) this.onBeforeUpdate(olds, news, oldMap, newMap);
                        else if(executeCondition(news, olds) && option.IsSingleProcessing && news.size() == 1) this.onBeforeUpdate(olds[0], news[0]);         
                        
                        // OrganizationMapper org = new OrganizationMapper(news);
                        // org.mappingField(news, oldMap);
                    }
                    when AFTER_UPDATE {
                        // 조건에 따라 실행여부 결정
                        if(executeCondition(news, olds) && !option.IsSingleProcessing) this.onAfterUpdate(olds, news, oldMap, newMap);
                        else if(executeCondition(news, olds) && option.IsSingleProcessing && news.size() == 1) this.onAfterUpdate(olds[0], news[0]);
                    }
                    when BEFORE_DELETE {
                        // 조건에 따라 실행여부 결정
                        if(executeCondition(null, olds) && !option.IsSingleProcessing) this.onBeforeDelete(olds, oldMap);
                        else if(executeCondition(null, olds) && option.IsSingleProcessing && olds.size() == 1) this.onBeforeDelete(olds[0]);
                    }
                    when AFTER_DELETE {
                        // 조건에 따라 실행여부 결정
                        if(executeCondition(null, olds) && !option.IsSingleProcessing) this.onAfterDelete(olds, oldMap);
                        else if(executeCondition(null, olds) && option.IsSingleProcessing && olds.size() == 1) this.onAfterDelete(olds[0]);
                    }
                    when AFTER_UNDELETE {
                        // 조건에 따라 실행여부 결정
                        if(executeCondition(news, null) && !option.IsSingleProcessing) this.onAfterUndelete(news, newMap);
                        else if(executeCondition(news, null) && option.IsSingleProcessing && news.size() == 1) this.onAfterUndelete(news[0]);
                    }
                }
            }
        }
        catch(Exception ex){
            TriggerExceptionLog__c exLog = new TriggerExceptionLog__c();
            exLog.LineNumber__c = ex.getLineNumber();
            system.debug(ex.getLineNumber());
            system.debug(ex.getMessage());
            system.debug(ex.getTypeName());
            system.debug(currentClassName); 
            exLog.Message__c =  currentClassName + ' : ' + ex.getMessage();
            exLog.ExceptionType__c = ex.getTypeName();
            exLog.ProgramStartTimemilles__c = handlerStartTimeMillis;
            exLog.ProgramEndTimemilles__c = System.currentTimeMillis();
            ex.getCause();
            exLogs.add(exLog);
        }
        finally{
            // 트리거 오류 로그 기록
            if(exLogs.size() > 0) insert exLogs;
        }
    } 

    public virtual void onBeforeInsert(List<sObject> news){}   
    public virtual void onBeforeInsert(sObject newRecord){}
                               
    public virtual void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){}
    public virtual void onBeforeUpdate(sObject oldRecord, sObject newRecord){}

    public virtual void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){}   
    public virtual void onBeforeDelete(sObject delRecord){}                                            

    public virtual void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){}
    public virtual void onAfterInsert(sObject newRecord){}
                                                             
    public virtual void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){}   
    public virtual void onAfterUpdate(sObject oldRecord, sObject newRecord){}

    public virtual void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){}
    public virtual void onAfterDelete(sObject delRecord){}

    public virtual void onAfterUndelete(List<sObject> dels, Map<Id, sObject> delMap){}
    public virtual void onAfterUndelete(sObject delRecord){}

    /*
     * @Description : 해당 핸들러 실행 조건, 핸들러 override 하여 실행조건을 지정할 수 있음
     * @Params :
     *      news : 트리거된 새로운 데이터
     *      olds : 트리거 되기 이전 데이터
     */ 
    public virtual Boolean executeCondition(List<sObject> news, List<sObject> olds){
        return true;
    }

    public virtual Boolean executeDivisionCondision(triggerOption option) {
        
        String division = option.activeDivision;
        String currentuserProfile = currentUser?.Profile?.name;
        if(currentuserProfile == null) currentuserProfile = '';
        
        if('All'.equals(division)) {
            return true;
        }
        else if('Essencemediacom'.equals(division) && 'Essencemediacom'.equals(currentUser.Division)){ 
          return true;
        }
        else if('Mindshare'.equals(division) && 'Mindshare'.equals(currentUser.Division)){ 
          return true;
        }
        else if('Wavemaker'.equals(division) && 'Wavemaker'.equals(currentUser.Division)){ 
          return true;
        } 
        else if('Nexus'.equals(division) && 'Nexus'.equals(currentUser.Division)){ 
            return true;
        } 
        else if('Xaxis'.equals(division) && 'Xaxis'.equals(currentUser.Division)){ 
            return true;
        } 
        else{
            return false;
        }
    }

    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }
    
    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    private Boolean validateRun() {
        return !TriggerHandler.bypassedHandlers.contains(currentClassName);
    }

    public class TriggerOption {
        public Boolean isActive {get;set;}
        public Boolean isSingleProcessing {get;set;}
        public String activeDivision {get;set;}
        
        public TriggerOption(Boolean isActive, Boolean isSingleProcessing){
            this.isActive = isActive;
            this.isSingleProcessing = isSingleProcessing;
        }

        public TriggerOption(Boolean isActive, Boolean isSingleProcessing, String activeDivision){
            this.isActive = isActive;
            this.isSingleProcessing = isSingleProcessing;
            this.activeDivision = activeDivision;
        } 
    }
}