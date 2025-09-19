global class MatrixCallController {


    public class CallInfoClass {
        public String Agent_ID; 
        public Datetime Answered_At;  
        public String Call_ID; 
        public String  Call_State; 
        public String  Call_Type;  
        public String  CallerID;  
        public Datetime  Created_At;  
        public String  DNIS;  
        public String  DNIS_Memo;  
        public String Extension; 
        public String Phone_Number;
        public Boolean Is_Ans;   
        public String IVR_Tag;  
        public String  IVR_Tag_Memo;  
        public String  Queue_Name;  
        public Datetime Queued_At;  
        public Datetime Ring_At;  
        public Integer TM_Connect;   
        public Integer TM_Queue;  
        public Integer TM_Ring;  
        public Datetime Updated_At; 
        public String focusObjectTabId ;

    }


    webService static String CheckAndCreateContactAndTask(String phone,String subject, String callInfo) {
        List<Contact> contactList = new List<Contact>();
        Map<String,ID> returnValue = new Map<String,ID>();
        ID selectedContactId = null;
        CallInfoClass callInfoJSON = new CallInfoClass();
        callInfoJSON = (CallInfoClass)System.JSON.deserialize(callInfo, CallInfoClass.class);

        // for (Contact contact: [SELECT Id, Phone, Name, Title, AccountId FROM Contact WHERE (phone = :phone Or MobilePhone =:phone) order by LastModifiedDate desc LIMIT 1]){
        //     contactList.add(contact);
        // }
        contactList = findContactsByPhone(phone);

        if(contactList.size() == 0){
            String lastName = 'Caller:'+ phone;
            Contact a = new Contact();
            a.phone = phone;
            a.MobilePhone = phone;
            RecordType recordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'CSCustomer' LIMIT 1];
            Account acc = [SELECT ID FROM Account WHERE Name = '미확인 고객사' Limit 1];
            if(acc != null){
                a.AccountId = acc.ID;
            }
            a.RecordTypeId = recordType.ID ;
            a.LastName = lastName;
            insert a;
            selectedContactId = a.ID;

        }else {
            selectedContactId = contactList[0].ID;

        }
        returnValue.put('contactId',selectedContactId); 

        Task newTask = new Task();

        String callType = 'Inbound Call';
        if(callInfoJSON.Call_Type == 'Outbound'){
            callType = 'Outbound Call';
        }

        System.debug(callInfoJSON.Call_Type + ' ' + callType);


        newTask.whoId = selectedContactId;

        newTask.Subject = subject;
        newTask.TaskSubtype = 'Call';
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.today();

        newTask.Matrix_Agent_ID__c = callInfoJSON.Agent_ID;
        newTask.Matrix_Answered_At__c = callInfoJSON.Answered_At;
        newTask.Matrix_Call_ID__c = callInfoJSON.Call_ID;
        newTask.Matrix_Call_Type__c = callInfoJSON.Call_Type;
        newTask.CallType__c = callType;
        newTask.Matrix_CallerID__c = callInfoJSON.CallerID;
        newTask.Matrix_Created_At__c = callInfoJSON.Created_At;
        newTask.Matrix_DNIS__c = callInfoJSON.DNIS;
        newTask.Matrix_DNIS_Memo__c = callInfoJSON.DNIS_Memo;
        newTask.Matrix_Extension__c = callInfoJSON.Extension;
        newTask.Matrix_Phone_Number__c = callInfoJSON.Phone_Number;
        newTask.Matrix_Is_Ans__c = callInfoJSON.Is_Ans;
        newTask.Matrix_IVR_Tag__c = callInfoJSON.IVR_Tag;
        newTask.Matrix_IVR_Tag_Memo__c = callInfoJSON.IVR_Tag_Memo;
        newTask.Matrix_Queue_Name__c = callInfoJSON.Queue_Name;
        newTask.Matrix_Queued_At__c = callInfoJSON.Queued_At;
        newTask.Matrix_Ring_At__c = callInfoJSON.Ring_At;
        newTask.Matrix_TM_Connect__c = callInfoJSON.TM_Connect;
        newTask.Matrix_TM_Queue__c = callInfoJSON.TM_Queue;
        newTask.Matrix_TM_Ring__c = callInfoJSON.TM_Ring;
        newTask.Matrix_Updated_At__c = callInfoJSON.Updated_At;
        newTask.Matrix_Call_State__c = callInfoJSON.Call_State;
 
        insert newTask;
        returnValue.put('newTaskId',newTask.ID);

        return JSON.serialize(returnValue);
        
    }   

    webService static String CheckTicketAndCreateTask(String phone,String subject, String callInfo) {
        List<Contact> contactList = new List<Contact>();
        Map<String,ID> returnValue = new Map<String,ID>();
        ID selectedContactId = null;
        CallInfoClass callInfoJSON = new CallInfoClass();
        callInfoJSON = (CallInfoClass)System.JSON.deserialize(callInfo, CallInfoClass.class);


        Task newTask = new Task();

        // for (Contact contact: [SELECT Id, Phone, Name, Title, AccountId FROM Contact WHERE (phone = :phone Or MobilePhone =:phone) order by LastModifiedDate desc LIMIT 1]){
        //     contactList.add(contact);
        // }
        contactList = findContactsByPhone(phone);

        if(contactList.size() == 0){
            String lastName = 'Caller:'+ phone;

            Contact a = new Contact();
            a.phone = phone;
            a.MobilePhone = phone;
            RecordType recordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'CSCustomer' LIMIT 1];
            Account acc = [SELECT ID FROM Account WHERE Name = '미확인 고객사' Limit 1];
            if(acc != null){
                a.AccountId = acc.ID;
            }
            a.RecordTypeId = recordType.ID ;
            a.LastName = lastName;
            insert a;
            selectedContactId = a.ID;


        }else {
            selectedContactId = contactList[0].ID;

        }
        
        if (!String.isEmpty(callInfoJSON.focusObjectTabId)){
            Id recordId = (Id)callInfoJSON.focusObjectTabId;
            String objectType = recordId.getSObjectType().getDescribe().getName();
            System.debug('objectType' + objectType + recordId);


            if (objectType == 'Case'){
                newTask.whatId = recordId;
                newTask.whoId = selectedContactId;
                returnValue.put('callCaseId',recordId);
            } else if(objectType == 'Lead'){
                newTask.whoId = recordId;
                returnValue.put('callCaseId',recordId);
            } else if(objectType == 'Contact'){
                newTask.whoId = recordId;
                returnValue.put('callCaseId',recordId);
            } else if(objectType == 'Opportunity'){
                newTask.whatId = recordId;
                newTask.whoId = selectedContactId;
                returnValue.put('callCaseId',recordId);
            } else if(objectType == 'WorkOrder'){
                WorkOrder findedWorkOrder = [SELECT CaseId FROM WorkOrder WHERE ID = :recordId   LIMIT 1];
                System.debug('findedWorkOrder: ' + findedWorkOrder);
                newTask.whatId = findedWorkOrder.CaseId;
                newTask.whoId = selectedContactId;
                returnValue.put('callCaseId',recordId);
            }

            
        } else {
            newTask.whoId = selectedContactId;
            returnValue.put('callCaseId',selectedContactId);           
        }
        String callType = 'Inbound Call';
        if(callInfoJSON.Call_Type == 'Outbound'){
            callType = 'Outbound Call';
        }

        newTask.Subject = subject;
        newTask.TaskSubtype = 'Call';
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.today();

        newTask.Matrix_Agent_ID__c = callInfoJSON.Agent_ID;
        newTask.Matrix_Answered_At__c = callInfoJSON.Answered_At;
        newTask.Matrix_Call_ID__c = callInfoJSON.Call_ID;
        newTask.Matrix_Call_Type__c = callInfoJSON.Call_Type;
        newTask.CallType__c = callType;
        newTask.Matrix_CallerID__c = callInfoJSON.CallerID;
        newTask.Matrix_Created_At__c = callInfoJSON.Created_At;
        newTask.Matrix_DNIS__c = callInfoJSON.DNIS;
        newTask.Matrix_DNIS_Memo__c = callInfoJSON.DNIS_Memo;
        newTask.Matrix_Extension__c = callInfoJSON.Extension;
        newTask.Matrix_Phone_Number__c = callInfoJSON.Phone_Number;
        newTask.Matrix_Is_Ans__c = callInfoJSON.Is_Ans;
        newTask.Matrix_IVR_Tag__c = callInfoJSON.IVR_Tag;
        newTask.Matrix_IVR_Tag_Memo__c = callInfoJSON.IVR_Tag_Memo;
        newTask.Matrix_Queue_Name__c = callInfoJSON.Queue_Name;
        newTask.Matrix_Queued_At__c = callInfoJSON.Queued_At;
        newTask.Matrix_Ring_At__c = callInfoJSON.Ring_At;
        newTask.Matrix_TM_Connect__c = callInfoJSON.TM_Connect;
        newTask.Matrix_TM_Queue__c = callInfoJSON.TM_Queue;
        newTask.Matrix_TM_Ring__c = callInfoJSON.TM_Ring;
        newTask.Matrix_Updated_At__c = callInfoJSON.Updated_At;
        newTask.Matrix_Call_State__c = callInfoJSON.Call_State;
 
        insert newTask;
        returnValue.put('newTaskId',newTask.ID);

        return JSON.serialize(returnValue);
        
    }  


    webService static Id findCase(String uid) {
      System.debug('Case 검색 : ' + uid);

      String key = uid;
      List<Task> findedCase =[
        SELECT Id, WhatId
        FROM Task
        WHERE Matrix_Call_ID__c = :key
        LIMIT 1
      ];
      if(findedCase.size() > 0){
        return findedCase[0].WhatId;
      } else {
        return null;
      }

    }

    webService static String createCase(String phone, 
        String subject,  String call_tag , String callInfo) {
        List<Contact> contactList = new List<Contact>();
        Map<String,ID> returnValue = new Map<String,ID>();
        ID selectedContactId = null;

        CallInfoClass callInfoJSON = new CallInfoClass();
        callInfoJSON = (CallInfoClass)System.JSON.deserialize(callInfo, CallInfoClass.class);
        



        // for (Contact contact: [SELECT Id, Phone, Name, Title, AccountId FROM Contact WHERE (phone = :phone Or MobilePhone =:phone) order by LastModifiedDate desc LIMIT 1]){
        //     contactList.add(contact);
        // }
        contactList = findContactsByPhone(phone);

        DateTime nowTime = DateTime.now();
        if(contactList.size() == 0){
            String lastName = 'Caller:'+ phone;

            Contact a = new Contact(LastName = lastName, Phone = phone );
            insert a;
            selectedContactId = a.ID;


        }else {
            selectedContactId = contactList[0].ID;

        }
        returnValue.put('contactId',selectedContactId);            
            
        Case newCase = new Case(ContactId= selectedContactId, 
        Subject = subject, Matrix_Call_Tag__c = call_tag, Matrix_Call_ID__c = callInfoJSON.Call_ID );
        insert newCase;
        ID caseId = newCase.ID;
        // returnValue.put('newCase',(ID)'1');
        returnValue.put('caseId',caseId);
        Task newTask = new Task();

        newTask.Matrix_Agent_ID__c = callInfoJSON.Agent_ID;
        newTask.Matrix_Answered_At__c = callInfoJSON.Answered_At;
        newTask.Matrix_Call_ID__c = callInfoJSON.Call_ID;
        newTask.Matrix_Call_Type__c = callInfoJSON.Call_Type;
        newTask.Matrix_CallerID__c = callInfoJSON.CallerID;
        newTask.Matrix_Created_At__c = callInfoJSON.Created_At;
        newTask.Matrix_DNIS__c = callInfoJSON.DNIS;
        newTask.Matrix_DNIS_Memo__c = callInfoJSON.DNIS_Memo;
        newTask.Matrix_Extension__c = callInfoJSON.Extension;
        newTask.Matrix_Phone_Number__c = callInfoJSON.Phone_Number;
        newTask.Matrix_Is_Ans__c = callInfoJSON.Is_Ans;
        newTask.Matrix_IVR_Tag__c = callInfoJSON.IVR_Tag;
        newTask.Matrix_IVR_Tag_Memo__c = callInfoJSON.IVR_Tag_Memo;
        newTask.Matrix_Queue_Name__c = callInfoJSON.Queue_Name;
        newTask.Matrix_Queued_At__c = callInfoJSON.Queued_At;
        newTask.Matrix_Ring_At__c = callInfoJSON.Ring_At;
        newTask.Matrix_TM_Connect__c = callInfoJSON.TM_Connect;
        newTask.Matrix_TM_Queue__c = callInfoJSON.TM_Queue;
        newTask.Matrix_TM_Ring__c = callInfoJSON.TM_Ring;
        newTask.Matrix_Updated_At__c = callInfoJSON.Updated_At;
        newTask.Matrix_Call_State__c = callInfoJSON.Call_State;
 
        insert newTask;
        returnValue.put('newTaskId',newTask.ID);
        return JSON.serialize(returnValue);
   
    }	
	

    webService static String createCaseAndTaskForNoAnswer(String phone, 
        String subject,  String call_tag,  String callInfo) {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        Map<String,ID> returnValue = new Map<String,ID>();
        Date myDate = date.today();

        Id selectedContactId = null;
        Id selectedCaseId = null;

        CallInfoClass callInfoJSON = new CallInfoClass();
        callInfoJSON = (CallInfoClass)System.JSON.deserialize(callInfo, CallInfoClass.class);

        System.debug(callInfoJSON);


        // for (Contact contact: [SELECT Id, Phone, Name, Title, AccountId FROM Contact WHERE (phone = :phone Or MobilePhone =:phone) order by LastModifiedDate desc LIMIT 1]){
        //     contactList.add(contact);
        // }
        contactList = findContactsByPhone(phone);

        if(contactList.size() == 0){
            String lastName = 'Caller:'+ phone;

            Contact a = new Contact();
            a.phone = phone;
            a.MobilePhone = phone;
            RecordType recordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'CSCustomer' LIMIT 1];
            Account acc = [SELECT ID FROM Account WHERE Name = '미확인 고객사' Limit 1];
            if(acc != null){
                a.AccountId = acc.ID;
            }
            a.RecordTypeId = recordType.ID ;
            a.LastName = lastName;
            insert a;
            selectedContactId = a.ID;


        }else {
            selectedContactId = contactList[0].ID;

        }

        returnValue.put('contactId',selectedContactId);   

        // for (Case casedata: [SELECT Id  FROM Case where (ContactPhone = :phone Or ContactMobile = :phone) and isclosed = false  order by CreatedDate desc limit  1]){
        //     caseList.add(casedata);
        // }

        // if(caseList.size() == 0){
        //     Case newCase = new Case(ContactId= selectedContactId, Subject = subject, Matrix_Call_Tag__c = call_tag, Matrix_Call_ID__c = callInfoJSON.Call_ID ,Origin ='Phone');

        //     insert newCase;
        //     selectedCaseId = newCase.ID;
        //     // returnValue.put('newCase',(ID)'1');

        // }else{

        //     selectedCaseId = caseList[0].Id;
        // }

        Task newTask = new Task();
        
        if(!String.isEmpty(callInfoJSON.focusObjectTabId) ){
            Id recordId = (Id)callInfoJSON.focusObjectTabId;
            String objectType = recordId.getSobjectType().getDescribe().getName();
            if (objectType == 'Case'){
                newTask.whatId = recordId;
            } else if(objectType == 'Lead'){
                newTask.whoId = recordId;
            } else if(objectType == 'Contact'){
                newTask.whoId = recordId;
            } else if(objectType == 'Opportunity'){
                newTask.whatId = recordId;
            } 
            returnValue.put('callCaseId',recordId);
        } else {
            newTask.whoId = selectedContactId;
            returnValue.put('callCaseId',selectedContactId);
        }
 



        newTask.Subject = subject;
        newTask.TaskSubtype = 'Call';
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.today();

        newTask.Matrix_Agent_ID__c = callInfoJSON.Agent_ID;
        newTask.Matrix_Answered_At__c = callInfoJSON.Answered_At;
        newTask.Matrix_Call_ID__c = callInfoJSON.Call_ID;
        newTask.Matrix_Call_Type__c = callInfoJSON.Call_Type;
        newTask.Matrix_CallerID__c = callInfoJSON.CallerID;
        newTask.Matrix_Created_At__c = callInfoJSON.Created_At;
        newTask.Matrix_DNIS__c = callInfoJSON.DNIS;
        newTask.Matrix_DNIS_Memo__c = callInfoJSON.DNIS_Memo;
        newTask.Matrix_Extension__c = callInfoJSON.Extension;
        newTask.Matrix_Phone_Number__c = callInfoJSON.Phone_Number;
        newTask.Matrix_Is_Ans__c = callInfoJSON.Is_Ans;
        newTask.Matrix_IVR_Tag__c = callInfoJSON.IVR_Tag;
        newTask.Matrix_IVR_Tag_Memo__c = callInfoJSON.IVR_Tag_Memo;
        newTask.Matrix_Queue_Name__c = callInfoJSON.Queue_Name;
        newTask.Matrix_Queued_At__c = callInfoJSON.Queued_At;
        newTask.Matrix_Ring_At__c = callInfoJSON.Ring_At;
        newTask.Matrix_TM_Connect__c = callInfoJSON.TM_Connect;
        newTask.Matrix_TM_Queue__c = callInfoJSON.TM_Queue;
        newTask.Matrix_TM_Ring__c = callInfoJSON.TM_Ring;
        newTask.Matrix_Updated_At__c = callInfoJSON.Updated_At;
        newTask.Matrix_Call_State__c = callInfoJSON.Call_State;
 
        insert newTask;
        returnValue.put('newTaskId',newTask.ID);

        return JSON.serialize(returnValue);
    
    }  
   
    webService static String createTaskOnContactForNoAnswer(String phone, 
        String subject,  String call_tag,  String callInfo) {
        List<Contact> contactList = new List<Contact>();
        List<Case> caseList = new List<Case>();
        Map<String,ID> returnValue = new Map<String,ID>();
        Date myDate = date.today();

        Id selectedContactId = null;
        Id selectedCaseId = null;

        CallInfoClass callInfoJSON = new CallInfoClass();
        callInfoJSON = (CallInfoClass)System.JSON.deserialize(callInfo, CallInfoClass.class);

        System.debug(callInfoJSON);


        // for (Contact contact: [SELECT Id, Phone, MobilePhone FROM Contact WHERE (phone =:phone Or MobilePhone =: phone) and Active__c = true order by LastModifiedDate desc LIMIT 1]){
        //     contactList.add(contact);
        // }
        contactList = findContactsByPhone(phone);

        if(contactList.size() == 0){
            String lastName = 'Caller:'+ phone;

            Contact a = new Contact();
            a.phone = phone;
            a.MobilePhone = phone;
            RecordType recordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'CSCustomer' LIMIT 1];
            Account acc = [SELECT ID FROM Account WHERE Name = '미확인 고객사' Limit 1];
            if(acc != null){
                a.AccountId = acc.ID;
            }
            a.RecordTypeId = recordType.ID ;
            a.LastName = lastName;
            insert a;
            selectedContactId = a.ID;

        }else {
            selectedContactId = contactList[0].ID;

        }
        returnValue.put('contactId',selectedContactId);  
        returnValue.put('callCaseId',selectedContactId);
        
        Task newTask = new Task();

        newTask.Subject = subject;
        newTask.TaskSubtype = 'Call';
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.today();

        newTask.Matrix_Agent_ID__c = callInfoJSON.Agent_ID;
        newTask.Matrix_Answered_At__c = callInfoJSON.Answered_At;
        newTask.Matrix_Call_ID__c = callInfoJSON.Call_ID;
        newTask.Matrix_Call_Type__c = callInfoJSON.Call_Type;
        newTask.Matrix_CallerID__c = callInfoJSON.CallerID;
        newTask.Matrix_Created_At__c = callInfoJSON.Created_At;
        newTask.Matrix_DNIS__c = callInfoJSON.DNIS;
        newTask.Matrix_DNIS_Memo__c = callInfoJSON.DNIS_Memo;
        newTask.Matrix_Extension__c = callInfoJSON.Extension;
        newTask.Matrix_Phone_Number__c = callInfoJSON.Phone_Number;
        newTask.Matrix_Is_Ans__c = callInfoJSON.Is_Ans;
        newTask.Matrix_IVR_Tag__c = callInfoJSON.IVR_Tag;
        newTask.Matrix_IVR_Tag_Memo__c = callInfoJSON.IVR_Tag_Memo;
        newTask.Matrix_Queue_Name__c = callInfoJSON.Queue_Name;
        newTask.Matrix_Queued_At__c = callInfoJSON.Queued_At;
        newTask.Matrix_Ring_At__c = callInfoJSON.Ring_At;
        newTask.Matrix_TM_Connect__c = callInfoJSON.TM_Connect;
        newTask.Matrix_TM_Queue__c = callInfoJSON.TM_Queue;
        newTask.Matrix_TM_Ring__c = callInfoJSON.TM_Ring;
        newTask.Matrix_Updated_At__c = callInfoJSON.Updated_At;
        newTask.Matrix_Call_State__c = callInfoJSON.Call_State;
 
        insert newTask;
        returnValue.put('newTaskId',newTask.ID);

        return JSON.serialize(returnValue);
    
    }    

    webService static String createTaskOnContactForOutBoundCall(String phone, 
        String subject,  String call_tag,  String callInfo) {
        List<Contact> contactList = new List<Contact>();

        Map<String,ID> returnValue = new Map<String,ID>();
        Date myDate = date.today();

        Id selectedContactId = null;
        Id selectedCaseId = null;

        CallInfoClass callInfoJSON = new CallInfoClass();
        callInfoJSON = (CallInfoClass)System.JSON.deserialize(callInfo, CallInfoClass.class);

        System.debug(callInfoJSON);


        // for (Contact contact: [SELECT Id, Phone, MobilePhone FROM Contact WHERE (phone =:phone Or MobilePhone =: phone) and Active__c = true order by LastModifiedDate desc LIMIT 1]){
        //     contactList.add(contact);
        // }
        contactList = findContactsByPhone(phone);

        if(contactList.size() == 0){
            String lastName = 'Caller:'+ phone;

            Contact a = new Contact();
            a.phone = phone;
            a.MobilePhone = phone;
            RecordType recordType = [SELECT ID FROM RecordType WHERE DeveloperName = 'CSCustomer' LIMIT 1];
            Account acc = [SELECT ID FROM Account WHERE Name = '미확인 고객사' Limit 1];
            if(acc != null){
                a.AccountId = acc.ID;
            }
            a.RecordTypeId = recordType.ID ;
            a.LastName = lastName;
            insert a;
            selectedContactId = a.ID;


        }else {
            selectedContactId = contactList[0].ID;

        }

        returnValue.put('callCaseId',selectedContactId);

        Task newTask = new Task();
        newTask.whoId = selectedContactId;

        String callType = 'Inbound Call';
        if(callInfoJSON.Call_Type == 'Outbound'){
            callType = 'Outbound Call';
        }

        newTask.Subject = subject;
        newTask.TaskSubtype = 'Call';
        newTask.Status = 'Completed';
        newTask.ActivityDate = Date.today();

        newTask.Matrix_Agent_ID__c = callInfoJSON.Agent_ID;
        newTask.Matrix_Answered_At__c = callInfoJSON.Answered_At;
        newTask.Matrix_Call_ID__c = callInfoJSON.Call_ID;
        newTask.Matrix_Call_Type__c = callInfoJSON.Call_Type;
        newTask.CallType__c = callType;
        newTask.Matrix_CallerID__c = callInfoJSON.CallerID;
        newTask.Matrix_Created_At__c = callInfoJSON.Created_At;
        newTask.Matrix_DNIS__c = callInfoJSON.DNIS;
        newTask.Matrix_DNIS_Memo__c = callInfoJSON.DNIS_Memo;
        newTask.Matrix_Extension__c = callInfoJSON.Extension;
        newTask.Matrix_Phone_Number__c = callInfoJSON.Phone_Number;
        newTask.Matrix_Is_Ans__c = callInfoJSON.Is_Ans;
        newTask.Matrix_IVR_Tag__c = callInfoJSON.IVR_Tag;
        newTask.Matrix_IVR_Tag_Memo__c = callInfoJSON.IVR_Tag_Memo;
        newTask.Matrix_Queue_Name__c = callInfoJSON.Queue_Name;
        newTask.Matrix_Queued_At__c = callInfoJSON.Queued_At;
        newTask.Matrix_Ring_At__c = callInfoJSON.Ring_At;
        newTask.Matrix_TM_Connect__c = callInfoJSON.TM_Connect;
        newTask.Matrix_TM_Queue__c = callInfoJSON.TM_Queue;
        newTask.Matrix_TM_Ring__c = callInfoJSON.TM_Ring;
        newTask.Matrix_Updated_At__c = callInfoJSON.Updated_At;
        newTask.Matrix_Call_State__c = callInfoJSON.Call_State;
 
        insert newTask;
        returnValue.put('newTaskId',newTask.ID);

        return JSON.serialize(returnValue);

    }


    public static List<Contact> findContactsByPhone(String inputPhone) {
        // 입력된 전화번호가 10자리인지 확인
        String formattedPhone;
        if (inputPhone.length() == 10) {
            if (inputPhone.startsWith('02')) {
                // 서울 국번인 경우 (02) - 3자리 국번 - 4자리
                formattedPhone = inputPhone.substring(0, 2) + '-' + inputPhone.substring(2, 7) + '-' + inputPhone.substring(7);
            } else {
                // 다른 국번인 경우 (3자리 국번) - 4자리 - 4자리
                formattedPhone = inputPhone.substring(0, 3) + '-' + inputPhone.substring(3, 6) + '-' + inputPhone.substring(6);
            }
            System.debug('formattedPhone: '+formattedPhone);
            List<Contact> matchedContacts = [
                SELECT Id, Name, Phone
                FROM Contact
                WHERE (Phone = :formattedPhone OR Phone = :inputPhone ) AND Inactive__c  = False
                order by LastModifiedDate desc
            ];
            System.debug('The number of contact records matched: ' + matchedContacts.size());
            System.debug('matchedContacts'+ matchedContacts);
            return matchedContacts;
        } else if(inputPhone.length() == 11) {
            formattedPhone = inputPhone.substring(0, 3) + '-' + inputPhone.substring(3, 7) + '-' + inputPhone.substring(7);
            System.debug('formattedPhone: '+formattedPhone);
            List<Contact> matchedContacts = [
                SELECT Id, Name, Phone
                FROM Contact
                WHERE (MobilePhone = :formattedPhone OR MobilePhone = :inputPhone OR Phone = :formattedPhone OR Phone = :inputPhone) AND Inactive__c  = False
                order by LastModifiedDate desc
            ];
            System.debug('The number of contact records matched: ' + matchedContacts.size());
            System.debug('matchedContacts'+ matchedContacts);
            return matchedContacts;
        } else if(inputPhone.length() == 8) {
            formattedPhone = inputPhone.substring(0, 4) + '-' + inputPhone.substring(4) ;
            System.debug('formattedPhone: '+formattedPhone);
            List<Contact> matchedContacts = [
                SELECT Id, Name, Phone
                FROM Contact
                WHERE (MobilePhone = :formattedPhone OR MobilePhone = :inputPhone OR Phone = :formattedPhone OR Phone = :inputPhone) AND Inactive__c  = False
                order by LastModifiedDate desc
            ];
            System.debug('The number of contact records matched: ' + matchedContacts.size());
            System.debug('matchedContacts'+ matchedContacts);
            return matchedContacts;
        }

        List<Contact> matchedContacts = [
            SELECT Id, Name, Phone
            FROM Contact
            WHERE (MobilePhone = :inputPhone OR Phone = :inputPhone ) AND Inactive__c  = False
            order by LastModifiedDate desc
        ];
        System.debug('The number of contact records matched: ' + matchedContacts.size());
        System.debug('matchedContacts'+ matchedContacts);
        return matchedContacts;

    } 

    public static String maskPhoneNumber(String phoneNumber) {
        // 전화번호 길이 확인 (정상적인 11자리일 경우)
        if (phoneNumber != null && phoneNumber.length() > 7) {
            // 첫 4자리와 마지막 4자리를 유지하고 가운데 3자리를 '*'로 변환
            String maskedPhoneNumber = phoneNumber.substring(0, 3) + '****' + phoneNumber.substring(7);
            return maskedPhoneNumber;
        } else {
            // 전화번호가 11자리가 아닌 경우 그대로 반환하거나 예외 처리 가능
            return phoneNumber;
        }
    }


        
    // UUID 생성 메서드
    private static String generateUUID() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String uuid = h.substring(0,8) + '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + 
                        h.substring(16,20) + '-' + h.substring(20);
        return uuid;
    }

    @AuraEnabled
    public static String getCurrentUserEmail() {
        return UserInfo.getUserEmail();
    }    
    
    webService static String getPicklistLabels(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        try {
            // 객체의 SObject 메타데이터 가져오기

            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType != null) {
                Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
                
                // 픽리스트 필드의 메타데이터 가져오기
                Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();
                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    picklistValues.add(entry.getLabel());
                    System.debug('label: ' + entry.getLabel() + ' value: ' + entry.getValue());
                }
                return JSON.serialize(picklistValues);

            } else {
                System.debug(objectName + ' not found.');
                return JSON.serialize(picklistValues);
            }
        } catch (Exception e) {
            System.debug('Error fetching picklist values: ' + e.getMessage());
            return JSON.serialize(picklistValues);
        }
       
    }

    webService static String getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        try {
            // 객체의 SObject 메타데이터 가져오기
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType != null) {
                Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
                
                // 픽리스트 필드의 메타데이터 가져오기
                Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();
                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    picklistValues.add(entry.getValue());
                    System.debug('label: ' + entry.getLabel() + ' value: ' + entry.getValue());
                }
                return JSON.serialize(picklistValues);
            } else {
                System.debug(objectName + ' not found.');
                return JSON.serialize(picklistValues);
            }
        } catch (Exception e) {
            System.debug('Error fetching picklist values: ' + e.getMessage());
            return JSON.serialize(picklistValues);
        }
       
    }

    public class MyPickListInfo
    {
         public String validFor;
    }
 
   
    
    static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField)
    {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
    
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
    
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
    
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            System.debug('ControllingField: Label:' + currControllingValue.getValue());
            controllingInfo.put(currControllingValue.getValue(), new List<String>());
        }
    

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
    
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
    
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
    
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
    
            Integer baseCount = 0;
    
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
    
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                if((val & 1) == 1)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getValue());
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getValue());                    
                }
                


                if((val & 2) == 2)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getValue());
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getValue());                    
                }


                if((val & 4) == 4)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getValue());
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getValue());                    
                }
                if((val & 8) == 8)

                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getValue());
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getValue());
                }
    

                baseCount += 4;
            }            
        } 
    
        System.debug('ControllingInfo: ' + controllingInfo);
    
        return controllingInfo;
    }

    @AuraEnabled
    webService static String getFieldDependenciesForExt(String objectName, String controllingField, String dependentField)

    {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        Map<String, List<String>> controllingInfoApiName = new Map<String, List<String>>();
        Map<String, Map<String, List<String>>> result = new Map<String, Map<String, List<String>>>();
        Map<String, List<String>> controllingInfoLabels = new Map<String, List<String>>();

    

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
    
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
    
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
            controllingInfoApiName.put(currControllingValue.getValue(), new List<String>());
            controllingInfoLabels.put(currControllingValue.getValue(), new List<String>());
            controllingInfoLabels.get(currControllingValue.getValue()).add(currControllingValue.getLabel());
        }
    

        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
    
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
    
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
    
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
    
            Integer baseCount = 0;
    
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
    
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                if((val & 1) == 1)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                    controllingInfoApiName.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getValue());
                   
                }
                


                if((val & 2) == 2)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                    controllingInfoApiName.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getValue());
                }


                if((val & 4) == 4)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                    controllingInfoApiName.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getValue());
                }
                if((val & 8) == 8)

                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                    controllingInfoApiName.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getValue());
                }
    

                baseCount += 4;
            }            
        } 
    
        System.debug('ControllingInfo: ' + controllingInfo);
        System.debug('ControllingInfoApiName: ' + controllingInfoApiName);
        result.put('mapping', controllingInfoLabels);
        result.put('Labels', controllingInfo);
        result.put('ApiNames', controllingInfoApiName);
        return JSON.serialize(result);

    }


    webService static String saveConsultCategory(String category, String detail) {
        // 주어진 유형이 Map에 있는지 확인
        Map<String, List<String>> controllingInfo = getFieldDependencies('Task', 'ConsultationTypeMajor__c', 'ConsultationTypeMiddle__c');
        System.debug('ControllingInfo: ' + controllingInfo);
        if (controllingInfo.containsKey(category)) {
            List<String> details = controllingInfo.get(category);
            // 상세 항목이 해당 유형의 목록에 있는지 확인
            if (details.contains(detail)) {
                return JSON.serialize(new String[]{category, detail});
            }
        }
        // 일치하는 항목이 없으면 "기타"로 반환
        return JSON.serialize(controllingInfo);
    }

    @future(callout=true)
    public static void callApiWithCallBacks(Map<Id, String>  caseCallbackMap) {
        // API 엔드포인트 기본 URL과 토큰 가져오기
        String endPoint = 'https://desk.matrixcloud.kr/matrixIpcc/G002/api/ext/callbacks/state'; // '/matrixIpcc/{0}/api/ext/callbacks/state' 형식
        String apiToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NDUyLCJjZW50ZXJJZCI6NDUyLCJjZW50ZXJpZCI6ImRucyIsImNlbnRlck5hbWUiOiLrlJTsl5TshpTro6jshZjspogiLCJpYXQiOjE3MzMxMjE1ODIsImV4cCI6MjA0ODQ4MTU4Mn0.SE0o4fc9_KTfl-Wa1ySiRHrRZ1Kc8NlhH_SNPZjlZ74';
        
        String userEmail = getCurrentUserEmail();
        for (Id caseId : caseCallbackMap.keySet()) {
            try {
                // HTTP 요청 준비
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endPoint);
                req.setMethod('PUT');
                req.setHeader('Content-Type', 'application/json');
                
                // trace-id 생성 (UUID)
                String traceId = generateUUID();
                req.setHeader('trace-id', traceId);
                
                // mt-api-token 설정
                req.setHeader('mt-api-token', apiToken);
                
                String ani = caseCallbackMap.get(caseId);

                // 요청 바디 생성
                Map<String, Object> body = new Map<String, Object>();
                body.put('state', 'Done');
                body.put('ani', ani);

                body.put('email', userEmail);
                // Map을 JSON 문자열로 변환
                String jsonBody = JSON.serialize(body);
                req.setBody(jsonBody);
                
                // API 호출 실행
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                // 응답 처리
                if (res.getStatusCode() != 200) {
                    System.debug('API 호출 실패 - Trace ID: ' + traceId + ', 응답: ' + res.getBody());
                }
                
            } catch(Exception e) {
                System.debug('API 호출 중 에러 발생: ' + e.getMessage());
            }
        }
    }

    

}