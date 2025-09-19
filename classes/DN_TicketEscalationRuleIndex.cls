/**
 * @description       : Ticket Escalation Rule 적용 순서를 위한 Rule Index 설정 Class
 * @author            : Hanyeong Choi
 * @last modified on  : 04-29-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class DN_TicketEscalationRuleIndex {
    
    /**
    @description       : Level 별 Ticket Escalation Rule 조회
    **/
    @AuraEnabled
    public static List<LevelWrapper> getLevelData(String selectedLevel){
        List<LevelWrapper> LevelWrappers = new List<LevelWrapper>();
        try {
            if(String.isNotEmpty(selectedLevel)) {
                switch on selectedLevel {
                    when 'Esc.Lev 1' {
                        List<TicketEscalationRule__c> ruleList = getRuleList(selectedLevel);
                        for(TicketEscalationRule__c rule : ruleList) {
                            LevelWrapper wrapper = new LevelWrapper();
                            wrapper.Id              = rule.Id;
                            wrapper.Name            = rule.Name;
                            wrapper.EscalationLevel = rule.EscalationLv__c;
                            LevelWrappers.add(wrapper);
                        }
                    }
                    when 'Esc.Lev 2' {
                        List<TicketEscalationRule__c> ruleList = getRuleList(selectedLevel);
                        for(TicketEscalationRule__c rule : ruleList) {
                            LevelWrapper wrapper = new LevelWrapper();
                            wrapper.Id              = rule.Id;
                            wrapper.Name            = rule.Name;
                            wrapper.EscalationLevel = rule.EscalationLv__c;
                            LevelWrappers.add(wrapper);
                        }
                    }
                    when 'Esc.Lev 3' {
                        List<TicketEscalationRule__c> ruleList = getRuleList(selectedLevel);
                        for(TicketEscalationRule__c rule : ruleList) {
                            LevelWrapper wrapper = new LevelWrapper();
                            wrapper.Id              = rule.Id;
                            wrapper.Name            = rule.Name;
                            wrapper.EscalationLevel = rule.EscalationLv__c;
                            LevelWrappers.add(wrapper);
                        }
                    }
                    when 'Esc.Lev 4' {
                        List<TicketEscalationRule__c> ruleList = getRuleList(selectedLevel);
                        for(TicketEscalationRule__c rule : ruleList) {
                            LevelWrapper wrapper = new LevelWrapper();
                            wrapper.Id              = rule.Id;
                            wrapper.Name            = rule.Name;
                            wrapper.EscalationLevel = rule.EscalationLv__c;
                            LevelWrappers.add(wrapper);
                        }
                    }
                    when else {
                        System.debug('getLevelData :::');
                    }
                }
            }
            return LevelWrappers;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    @description       : Rule Index 저장
    **/
    @AuraEnabled
    public static void saveEscIndex(String jsonRuleList){
        List<TicketEscalationRule__c> ruleList = new List<TicketEscalationRule__c>();
        if(!String.isEmpty(jsonRuleList)) {
            ruleList = (List<TicketEscalationRule__c>) JSON.deserialize(jsonRuleList, List<TicketEscalationRule__c>.class);
            for(Integer i = 0; i < ruleList.size(); i++) {
                ruleList[i].IndexNumber__c = i;
            }
            update ruleList;
        }
    }

    /**
    @description       : Rule List 조회
    **/
    @AuraEnabled
    public static List<TicketEscalationRule__c> getRuleList(String selectedLevel){
        List<TicketEscalationRule__c> ruleList = 
        [
            SELECT Id, Name, EscalationLv__c, IndexNumber__c, IsActive__c
            FROM TicketEscalationRule__c
            WHERE EscalationLv__c = : selectedLevel
            AND IsActive__c = true
            ORDER BY IndexNumber__c ASC
        ];
        return ruleList;
    }


    /*
     * @Description 
     *  - LV1 Data
     */ 
    public class LevelWrapper{
        @AuraEnabled public String Id                { get; set;}
        @AuraEnabled public String Name              { get; set;}
        @AuraEnabled public String EscalationLevel   { get; set;}

        public LevelWrapper(){
            this.Id                = '';
            this.Name              = '';
            this.EscalationLevel   = '';
        }
    }
}