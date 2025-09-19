/**
* @Class : TaskTriggerHandler
*
* @Author : Hayeong, Min
* @Date : 2024. 10. 21.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-10-21 | Hayeong, Min   | 최초작성
*
*/
public with sharing class TaskTriggerHandler extends TriggerHandler{
    
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        // 기술상담사 Outbound Call 진행시 Ticket에 일/시 매핑 - Sangil,Park 2024. 12. 18
        if (isExecuting) {

            System.debug('TaskTriggerHandler.onAfterInsert');

            List<Task> taskList = (List<Task>)news;

            Set<String> caseIds = new Set<String>();
            for (Task task : taskList) {
                if (task.WhatId != null) {
                    if (task.WhatId.getSobjectType().getDescribe().getName() == 'Case') {
                        if (task.CallType__c == 'Outbound Call') {
                            caseIds.add(task.WhatId);
                        }
                    }
                }
            }

            List<Case> caseList = [SELECT Id, TechnicalCallDatetime__c, GeneralCallDatetime__c, TicketType__c, ConsultationTime__c
                                   FROM Case 
                                   WHERE Id IN :caseIds];

            Map<String, Case> caseMap = new Map<String, Case>();

            for (Case ticket : caseList) {
                caseMap.put(ticket.Id, ticket);
            }

            List<Case> updateTicketList = new List<Case>();
            for (Task task : taskList) {
                if (caseMap.get(task.WhatId) != null) {
                    Case ticket = caseMap.get(task.WhatId);
                    //2025.02.21 박지영 추가_[관리자 모니터링] Report '상담' Column용 필드를 만들기 위해 Matrix_Ring_At__c 데이터 삽입
                    if(ticket.ConsultationTime__c == null){
                        ticket.ConsultationTime__c = task.Matrix_Ring_At__c; 
                    }

                    if (ticket.TicketType__c == 'General inquiry' && ticket.GeneralCallDatetime__c == null) {
                        ticket.GeneralCallDatetime__c = task.CreatedDate;
                        // updateTicketList.add(ticket);
                    } else if (ticket.TicketType__c == 'Technical inquiry' && ticket.TechnicalCallDatetime__c == null) {
                        ticket.TechnicalCallDatetime__c = task.CreatedDate;
                    } else {
                        continue;
                    }
                    updateTicketList.add(ticket);
                }
            }

            if (updateTicketList.size() > 0) update updateTicketList;

        }
        
    }
    
    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        System.debug('TaskTriggerHandler.onBeforeUpdate');
        List<Task> taskList = (List<Task>) news;
        for(Task t : taskList){
            Task oldObj = (Task)oldMap.get(t.Id);
            System.debug('before OLD Trigger WhatID : '+oldObj.WhatId);
            System.debug('before NEW Trigger WhatID : '+t.WhatId);
        }
    }

    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        System.debug('TaskTriggerHandler.onAfterUpdate');
        List<Task>   taskList     = (List<Task>) news;
        for(Task t : taskList){
            Task oldObj = (Task)oldMap.get(t.Id);
            System.debug('after OLD Trigger WhatID : '+oldObj.WhatId);
            System.debug('after NEW Trigger WhatID : '+t.WhatId);
        }
    }
}