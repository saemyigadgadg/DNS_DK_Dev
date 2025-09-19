/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-27
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-03-27   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public with sharing class TriggerManager {
    
    @TestVisible private static TriggerManager instance = null;
    private final List<TriggerHandler> handlers;
    @TestVisible private Boolean isExecuting;
    @TestVisible private TriggerOperation operationType;
    private Integer currIndex = -1;
    @TestVisible private List<sObject> news;
    @TestVisible private List<sObject> olds;
    @TestVisible private Map<Id, sObject> newMap; 
    @TestVisible private Map<Id, sObject> oldMap;
    
    // 동일 Transaction 상황에서 한번만 동작하도록  함
    @TestVisible private static Boolean onceRun = true;
    @TestVisible private static boolean avoidRecursion(){
        if(onceRun){
            onceRun=false;
            return true;
        }else{
            return onceRun;
        }
    }
    
    @TestVisible
    private TriggerManager(){
        handlers = new List<TriggerHandler>();
    }
    
    public static TriggerManager prepare(){
        instance = new TriggerManager();
        instance.setting();
        return instance;
    } 

    private void setting(){
        this.isExecuting = trigger.isExecuting;
        this.operationType = trigger.operationType;
        this.news = trigger.new;
        this.olds = trigger.old;
        this.newMap = trigger.newMap;
        this.oldMap = trigger.oldMap;
    }

    public TriggerManager bind(TriggerHandler handler){
        handler.setting(isExecuting, operationType);
        handlers.add(handler);
        return instance;
    }
    
    public TriggerManager bind(TriggerHandler handler, Boolean doFieldTracking){
        handler.setting(isExecuting, operationType, doFieldTracking);
        handlers.add(handler);
        return instance;
    }

    private void reset() {
        this.currIndex = -1;
    }

    private Boolean hasNext() {
        return this.currIndex < this.handlers.size() - 1;
    }

    private void next() {
        
        while (hasNext()) {
            runNext().execute(news, olds, newMap, oldMap);
        }
    }

    public void execute() {
        reset();
        while (hasNext()) {
            runNext().execute(news, olds, newMap, oldMap);
        }
    }
    
    public TriggerHandler runNext(){
        this.currIndex++;
        TriggerHandler handler = this.handlers[this.currIndex];
        return handler;
    }
}