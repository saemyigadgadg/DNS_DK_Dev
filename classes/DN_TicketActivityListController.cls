/**
* @Class : DN_TicketActivityListController
*
* @Author : Hayeong, Min
* @Date : 2024. 05. 30.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-05-30 | Hayeong, Min   | 최초작성
*
*/
public with sharing class DN_TicketActivityListController {

    /*
     * @Description
     * 	- 상담이력 
     * 
     * @Parameter
     *  - recordId	    : ticket Id
     */
    @AuraEnabled
    public static CommonWrapper getActivityList(Id recordId){
        CommonWrapper cw = new CommonWrapper();
        try{
            List<ActivityWrapper> result = new List<ActivityWrapper>();
            Case ticket = [SELECT Id, AccountId, AssetId, Requester__c, Requester__r.Phone FROM Case WHERE Id = :recordId];
            if((String.isNotEmpty(String.valueOf(ticket.AccountId))) && (String.isNotEmpty(String.valueOf(ticket.AssetId)))){
                //해당 Ticket의 고객사, 장비가 동일한 Ticket 목록
                List<Case> ticketList = [SELECT Id FROM Case WHERE AccountId = :ticket.AccountId AND AssetId = :ticket.AssetId];
                Set<Id> ticketIds = new Set<Id>();
                if(ticketList.size()>0){
                    for(Case t : ticketList){
                        ticketIds.add(t.Id);
                    }
                }

                List<Task> taskList = [SELECT ActivityDate, Matrix_Answered_At__c, Matrix_Updated_At__c, CreatedBy.Name, Matrix_Call_Type__c, Matrix_Is_Ans__c, Matrix_IVR_Tag__c, Matrix_IVR_Tag_Memo__c, Matrix_Phone_Number__c, Matrix_Queued_At__c, Matrix_Ring_At__c, TaskSubtype, WhatId, STT__c, STT__r.STTDescription__c  
                                        FROM Task 
                                        WHERE WhatId IN :ticketIds
                                        AND TaskSubtype = 'Call' 
                                        AND Matrix_Is_Ans__c = TRUE 
                                        ORDER BY CreatedDate DESC];
                if(taskList.size()>0){
                    Set<String> conSet = new Set<String>();
                    for(Task t : taskList){
                        conSet.add(t.Matrix_Phone_Number__c);
                    }

                    Map<String, Contact> conMap = contactMap(conSet);
                    for(Task t : taskList){
                        ActivityWrapper aw = new ActivityWrapper();
                        aw.ConsultDate = t.ActivityDate;//상담일자
                        aw.Consultant = t.CreatedBy.Name;//상담원
                        aw.Phone = t.Matrix_Phone_Number__c;//연락처
                        if(conMap.containsKey(t.Matrix_Phone_Number__c)){
                            aw.Contact = conMap.get(t.Matrix_Phone_Number__c).Name;//고객명
                            aw.ContactURL = URL.getOrgDomainUrl().toExternalForm() + '/' + conMap.get(t.Matrix_Phone_Number__c).Id;//고객명
                        }
                        //IN/OUT
                        if(String.isNotEmpty(t.Matrix_Call_Type__c)){
                            aw.InOutBound = t.Matrix_Call_Type__c;
                        }
                        if(t.Matrix_Answered_At__c==null){
                            aw.StartTime = Time.newInstance(0, 0, 0, 0);
                        }else{
                            aw.StartTime = t.Matrix_Answered_At__c.timeGmt();
                        } 
                        if(t.Matrix_Updated_At__c==null){
                            aw.EndTime = Time.newInstance(0, 0, 0, 0);
                        }else{
                            aw.EndTime = t.Matrix_Updated_At__c.timeGmt();
                        }                       
                        aw.Description = t.STT__r.STTDescription__c; //상담내용
                        result.add(aw);
                    }
                }
            }
            cw.activityWrapper = result;
        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage =  e.getMessage();
            System.debug('Exception : ' + e.getMessage());
        }
        return cw;
    }


    /*
     * @Description
     * 	- 전체상담이력 List Getter
     * 
     * @Parameter
     *  - recordID	    : Ticket의 recordID
     */ 
    @AuraEnabled
    public static CommonWrapper getAllActivityList(ID recordId){
        CommonWrapper cw = new CommonWrapper();
        try{
            List<ActivityWrapper> result = new List<ActivityWrapper>();
            Case ticket = [SELECT Id, AccountId, AssetId, Requester__c, Requester__r.Phone FROM Case WHERE Id = :recordId];
            if(String.isNotEmpty(String.valueOf(ticket.AccountId))){
                //해당 Ticket의 고객사가 동일한 Ticket 목록
                List<Case> ticketList = [SELECT Id, CaseNumber, AccountId, Account.Name, AssetId, Asset.Name, Asset.MachineName__c FROM Case WHERE AccountId = :ticket.AccountId];
                Map<Id, Case> ticketMap = new Map<Id, Case>();
                if(ticketList.size()>0){
                    for(Case t : ticketList){
                        ticketMap.put(t.Id, t);
                    }
                }

                List<Task> taskList = [SELECT CallType__c, ActivityDate, Matrix_Answered_At__c, Matrix_Updated_At__c, CreatedBy.Name, Matrix_Call_Type__c, Matrix_Is_Ans__c, Matrix_IVR_Tag__c, Matrix_IVR_Tag_Memo__c, Matrix_Phone_Number__c, Matrix_Queued_At__c, Matrix_Ring_At__c, TaskSubtype, WhatId, STT__r.STTDescription__c 
                                        FROM Task 
                                        WHERE WhatId IN :ticketMap.keySet()
                                        AND TaskSubtype = 'Call' 
                                        AND Matrix_Is_Ans__c = TRUE 
                                        ORDER BY CreatedDate DESC];
                if(taskList.size()>0){
                    Set<String> conSet = new Set<String>();
                    for(Task t : taskList){
                        conSet.add(t.Matrix_Phone_Number__c);
                    }

                    Map<String, Contact> conMap = contactMap(conSet);

                    for(Task t : taskList){
                        ActivityWrapper aw = new ActivityWrapper();
                        aw.ConsultDate = t.ActivityDate;//상담일자
                        aw.Consultant = t.CreatedBy.Name;//상담원
                        aw.Phone = t.Matrix_Phone_Number__c;//연락처
                        if(conMap.containsKey(t.Matrix_Phone_Number__c)){
                            aw.Contact = conMap.get(t.Matrix_Phone_Number__c).Name;//고객명
                            aw.ContactURL = URL.getOrgDomainUrl().toExternalForm() + '/' + conMap.get(t.Matrix_Phone_Number__c).Id;//고객명
                        }
                        //IN/OUT
                        if(String.isNotEmpty(t.Matrix_Call_Type__c)){
                            aw.InOutBound = t.Matrix_Call_Type__c;
                        }
                        if(t.Matrix_Answered_At__c==null){
                            aw.StartTime = Time.newInstance(0, 0, 0, 0);
                        }else{
                            aw.StartTime = t.Matrix_Answered_At__c.timeGmt();
                        } 
                        if(t.Matrix_Updated_At__c==null){
                            aw.EndTime = Time.newInstance(0, 0, 0, 0);
                        }else{
                            aw.EndTime = t.Matrix_Updated_At__c.timeGmt();
                        }  
                        aw.Description = t.STT__r.STTDescription__c; //상담내용
                        aw.Channel= t.CallType__c;    

                        Case tik = ticketMap.get(t.WhatId);
                        aw.Ticket		           = tik.CaseNumber; //티켓번호  
                        aw.TicketURL		       = URL.getOrgDomainUrl().toExternalForm() + '/' + tik.Id;//티켓번호  
                        aw.Asset		           = tik.Asset.Name;    
                        aw.AssetURL		           = String.isNotEmpty(String.valueOf(tik.AssetId)) ? URL.getOrgDomainUrl().toExternalForm() + '/' + tik.AssetId : ''; 
                        aw.Model		           = tik.Asset.MachineName__c; 
                        result.add(aw);
                    }
                }
            }
            cw.activityWrapper = result;
        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage =  e.getMessage();
            System.debug('Exception : ' + e.getMessage());
        }
        return cw;
    }

    /*
     * @Description 
     *  - Activity Wrapper
     * 
     * @Variable 
     *  - ConsultDate		: 상담일자
     *  - Consultant 	    : 상담원
     *  - Contact 		    : 고객명
     *  - ContactURL		: 고객URL
     *  - Phone		        : 연락처
     *  - InOutBound 		: In/Out 구분
     *  - StartTime 	    : 상담시작시간
     *  - EndTime           : 상담종료시간
     *  - Description       : 상담내용
     * 
     */ 
    public class ActivityWrapper{
        @AuraEnabled public DateTime ConsultDate 		    { get;set; }
        @AuraEnabled public String Consultant 	            { get;set; }
        @AuraEnabled public String Contact 		            { get;set; }
        @AuraEnabled public String ContactURL 		        { get;set; }
        @AuraEnabled public String Phone 			        { get;set; }
        @AuraEnabled public String InOutBound			    { get;set; }
        @AuraEnabled public Time StartTime 	                { get;set; }
        @AuraEnabled public Time EndTime                    { get;set; }
        @AuraEnabled public String Description		        { get;set; }
        @AuraEnabled public String Ticket 		            { get;set; }
        @AuraEnabled public String TicketURL 		        { get;set; }
        @AuraEnabled public String Channel 		            { get;set; }
        @AuraEnabled public String Asset 		            { get;set; }
        @AuraEnabled public String AssetURL 		        { get;set; }
        @AuraEnabled public String Model 		            { get;set; }

        public ActivityWrapper(){
            this.ConsultDate 	       = System.now(); 	    
            this.Consultant 	       = '';     
            this.Contact 		       = '';  
            this.ContactURL 		   = '';     
            this.Phone 			       = '';     
            this.InOutBound		       = '';	    
            this.StartTime 	           = Time.newInstance(0, 0, 0, 0);
            this.EndTime               = Time.newInstance(0, 0, 0, 0);
            this.Description		   = '';    
            this.Ticket		           = '';    
            this.TicketURL		       = '';    
            this.Channel		       = '';    
            this.Asset		           = '';    
            this.AssetURL		       = '';    
            this.Model		           = '';    
        }
    }

    /*
     * @Description 
     *  - CommonWrapper
     * 
     * @Variable 
     *  - isSuccess 		: 성공여부
     *  - errMessage 	    : 에러메시지
     *  - activityWrapper 	: Task 정보
     * 
     */ 
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess		                {get; set;}
        @AuraEnabled
        public String errMessage		                {get; set;}
        @AuraEnabled
        public List<ActivityWrapper> activityWrapper	{get; set;}
    
    
        public CommonWrapper(){
            this.isSuccess 		    = true;
            this.errMessage 	    = '';
            this.ActivityWrapper 	= new List<ActivityWrapper>();
        }
    }

     /*
     * @Description
     * 	- MobilePhone을 Key로 Contact 정보 Mapping
     * 
     * @Parameter
     *  - phoneSet	    : MobilePhone 정보를 담은 Set
     */ 
    public static Map<String, Contact> contactMap(Set<String> phoneSet){
        List<Contact> conList = [SELECT Id, Phone, Name, MobilePhone, AccountId FROM Contact 
        WHERE Inactive__c = FALSE AND (Phone != NULL OR MobilePhone != NULL) AND AccountId != NULL AND MobilePhone IN :phoneSet];
        Map<String, Contact> conMap = new Map<String, Contact>();
        for(Contact con : conList){
            conMap.put(con.MobilePhone, con);
        }

        return conMap;
    }






    
}