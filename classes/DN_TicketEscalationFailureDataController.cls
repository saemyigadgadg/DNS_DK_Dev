/**
 * @description       : Ticket Escalation 고장부위 등록 모달
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2024-12-23
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-23-2024   junyeong.choi@sbtglobal   Initial Version
**/
public with sharing class DN_TicketEscalationFailureDataController {

    @AuraEnabled
    public static List<FailureAreaWrapper> initFailureData(String recordId){
        List<FailureAreaWrapper> wrappers = new List<FailureAreaWrapper>();
        try {
            List<TicketEscalationFailureArea__c> faList = 
            [
                SELECT Id, ObjectType__c, FailureAreaMain__c, FailureAreaMiddle__c, FailurePhenomenon__c, TicketEscalationRule__c
                FROM TicketEscalationFailureArea__c
                WHERE TicketEscalationRule__c =: recordId
            ];

            for(TicketEscalationFailureArea__c fa : faList) {
                FailureAreaWrapper wrapper = new FailureAreaWrapper();
                wrapper.Id                  = fa.Id;
                wrapper.objectType          = fa.ObjectType__c;
                wrapper.failureAreaMajor    = fa.FailureAreaMain__c;
                wrapper.failureAreaMiddle   = fa.FailureAreaMiddle__c;
                wrapper.failurePhenomenon   = fa.FailurePhenomenon__c;
                wrappers.add(wrapper);
            }
            System.debug('wrappers' + wrappers);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrappers;
    }

    /**
    @description       : 등록된 Ticket Escalation 고장부위 삭제
    **/
    @AuraEnabled
    public static ResultWrapper deletefailureArea(Id faId){
        ResultWrapper rw = new ResultWrapper();
        try {
            delete [SELECT Id FROM TicketEscalationFailureArea__c WHERE Id = :faId];
        } catch (Exception e) {
            rw.isSuccess = false;
        }
        return rw;
    }

    /*
     * @Description
     * 	- Object Type Get Method
     * 
     * @Author
     *  - Junyeong, Choi, 2024-12-23
    */ 
    @AuraEnabled
    public static List<getObjectTypeWrapper> getObjectType(){
        List<getObjectTypeWrapper> wrappers = new List<getObjectTypeWrapper>();
        try {
            List<String> objectTypeList = getObjectTypeList();
            for(String objectType : objectTypeList) {
                getObjectTypeWrapper wrapper = new getObjectTypeWrapper();
                wrapper.label   = objectType;
                wrapper.value   = objectType;
                wrappers.add(wrapper);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return wrappers;
    }

    /*
     * @Description
     * 	- 고장부위(대) Get Method
     * 
     * @Parameter
     *  - selectedObjectType : 선택한 Object Type
     * 
     * @Author
     *  - Junyeong, Choi, 2024-12-23
    */ 
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureMain(String selectedObjectType){
        return DN_FailureAreaController.getFailureAreaMajor(selectedObjectType);
    }

    /*
     * @Description
     * 	- 고장부위(중) Get Method
     * 
     * @Parameter
     *  - selectedFailureMain : 선택한 고장부위(대)
     * 
     * @Author
     *  - Junyeong, Choi, 2024-12-23
    */ 
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getFailureMiddle(String selectedFailureMain){
        return DN_FailureAreaController.getFailureAreaMiddle(selectedFailureMain);
    }

    /*
     * @Description
     * 	- 고장현상 Get Method
     * 
     * @Parameter
     *  - selectedFailureMiddle : 선택한 고장부위(중)
     * 
     * @Author
     *  - Junyeong, Choi, 2024-12-23
    */ 
    @AuraEnabled
    public static List<DN_FailureAreaController.CustomSelectOption> getPhenomenon(String selectedFailureMain, String selectedFailureMiddle){
        String mergeValue = selectedFailureMain + selectedFailureMiddle;
        return DN_FailureAreaController.getFailurePhenomenon(mergeValue);
    }

    @AuraEnabled
    public static ResultWrapper failureSave(String data, String recordId){
        System.debug('recordId' + recordId);
        System.debug('data' + data);
        ResultWrapper rw = new ResultWrapper();
        try {
            String selectedObjectType               = '';
            String selectedFailureMain              = '';
            String selectedFailureMiddle            = '';
            String selectedFailurePhenomenon        = '';
            String selectedFailureMainLabel         = '';
            String selectedFailureMiddleLabel       = '';
            String selectedFailurePhenomenonLabel   = '';
            // 이미 등록된 조건 확인 여부 Key
            String existKey = '';

            Map<String, Object> dataJSON = (Map<String, Object>) JSON.deserializeUntyped(data);
            if(String.isNotEmpty((String)dataJSON.get('selectedObjectType'))){
                selectedObjectType = (String) dataJSON.get('selectedObjectType');
                existKey += selectedObjectType;
            }
            if(String.isNotEmpty((String)dataJSON.get('selectedFailureMain'))){
                selectedFailureMain = (String) dataJSON.get('selectedFailureMain');
            }
            if(String.isNotEmpty((String)dataJSON.get('selectedFailureMiddle'))){
                selectedFailureMiddle = (String) dataJSON.get('selectedFailureMiddle');
            }
            if(String.isNotEmpty((String)dataJSON.get('selectedFailurePhenomenon'))){
                selectedFailurePhenomenon = (String) dataJSON.get('selectedFailurePhenomenon');
            }
            if(String.isNotEmpty((String)dataJSON.get('selectedFailureMainLabel'))){
                selectedFailureMainLabel = (String) dataJSON.get('selectedFailureMainLabel');
                existKey += selectedFailureMainLabel;
            }
            if(String.isNotEmpty((String)dataJSON.get('selectedFailureMiddleLabel'))){
                selectedFailureMiddleLabel = (String) dataJSON.get('selectedFailureMiddleLabel');
                existKey += selectedFailureMiddleLabel;
            }
            if(String.isNotEmpty((String)dataJSON.get('selectedFailurePhenomenonLabel'))){
                selectedFailurePhenomenonLabel = (String) dataJSON.get('selectedFailurePhenomenonLabel');
                existKey += selectedFailurePhenomenonLabel;
            }

            System.debug('등록할 existKey ->'+existKey);
            // 중복 등록 확인
            List<TicketEscalationFailureArea__c> failureList = getFailureList(recordId);
            for(TicketEscalationFailureArea__c failure : failureList) {
                System.debug('등록된 key'+failure.ObjectType__c+failure.FailureAreaMain__c+failure.FailureAreaMiddle__c+failure.FailurePhenomenon__c);
                String objectType = failure.ObjectType__c  != null ? failure.ObjectType__c        : '';
                objectType += failure.FailureAreaMain__c   != null ? failure.FailureAreaMain__c   : '';
                objectType += failure.FailureAreaMiddle__c != null ? failure.FailureAreaMiddle__c : '';
                objectType += failure.FailurePhenomenon__c != null ? failure.FailurePhenomenon__c : '';
                if(existKey.equals(objectType)) {
                    System.debug('existKey'+existKey);
                    rw.isExist     = true;
                    rw.isSuccess   = false;
                    return rw;
                }
            }

            TicketEscalationFailureArea__c insertFA = new TicketEscalationFailureArea__c();
            insertFA.ObjectType__c          = selectedObjectType;
            if(String.isNotEmpty(selectedFailureMainLabel)) {
            insertFA.FailureAreaMain__c     = selectedFailureMainLabel;
            }
            if(String.isNotEmpty(selectedFailureMiddleLabel)) {
                insertFA.FailureAreaMiddle__c   = selectedFailureMiddleLabel;
            }
            if(String.isNotEmpty(selectedFailurePhenomenonLabel)) {
                insertFA.FailurePhenomenon__c   = selectedFailurePhenomenonLabel;
            }
            insertFA.TicketEscalationRule__c   = recordId;
            System.debug('insertFA :::' + insertFA);
            insert insertFA;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return rw;
    }

    @AuraEnabled
    public static List<String> getObjectTypeList(){
        try {
            List<String> objectTypeList = new List<String>();
            List<AggregateResult> famajList = [SELECT ModelCategory__c FROM FailureArea_Major__c GROUP BY ModelCategory__c];
            for (AggregateResult famaj : famajList) {
                objectTypeList.add((String)famaj.get('ModelCategory__c'));
            }
            System.debug('objectTypeList : '+ objectTypeList);
            return objectTypeList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<TicketEscalationFailureArea__c> getFailureList(String recordId){
        try {
            return [SELECT Id, ObjectType__c, FailureAreaMain__c, FailureAreaMiddle__c, FailurePhenomenon__c FROM TicketEscalationFailureArea__c WHERE TicketEscalationRule__c =: recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * @Description
     * 	- Init 시 Get Queue List
     *  
     * @Author
     *  - Junyeong, Choi, 2025-02-04
    */ 
    @AuraEnabled
    public static List<QueueWrapper> initQueueList(String recordId){
        List<QueueWrapper> qwList = new List<QueueWrapper>();
        List<TicketEscalationQueue__c> teqList = [SELECT Id, Name, TicketEscalationRule__c FROM TicketEscalationQueue__c WHERE TicketEscalationRule__c =: recordId];
        for(TicketEscalationQueue__c eq : teqList) {
            QueueWrapper qw = new QueueWrapper();
            qw.Name = eq.Name;
            qw.Id   = eq.Id;
            qwList.add(qw);
        }
        return qwList;
    }

    /*
     * @Description
     * 	- 등록된 Queue Delete
     *  
     * @Author
     *  - Junyeong, Choi, 2025-02-04
    */ 
    @AuraEnabled
    public static void deleteQueue(String queueId){
        delete [SELECT Id FROM TicketEscalationQueue__c WHERE Id = :queueId];
    }

    /**
    @description       : Queue 목록 조회
    **/
    @AuraEnabled
    public static List<PicklistWrapper> getQueueList(){
        List<PicklistWrapper> wrappers = new List<PicklistWrapper>();
        try {
            List<Group> queueList = 
            [
                SELECT Id, Name, Type
                FROM Group
                WHERE Type = 'Queue'
            ];
            if(queueList.size() > 0) {
                for(Group queue : queueList) {
                    PicklistWrapper pw = new PicklistWrapper();
                    pw.label = queue.Name;
                    pw.value = queue.Id;
                    wrappers.add(pw);
                }
            }

            return wrappers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    @description       : 선택한 Queue 등록
    **/
    @AuraEnabled
    public static ResultWrapper submitQueue(String recordId, String selectedValue, String selectedLabel){
        System.debug('selectedValue'+selectedValue);
        System.debug('selectedLabel'+selectedLabel);
        ResultWrapper rw = new ResultWrapper();
        List<TicketEscalationQueue__c> existEQList = [SELECT Id, Name FROM TicketEscalationQueue__c WHERE TicketEscalationRule__c =: recordId];
        if(existEQList.size() > 0) {
            rw.isSuccess = false;
        } else {
            TicketEscalationQueue__c eq = new TicketEscalationQueue__c();
            eq.Name                     = selectedLabel;
            eq.TicketEscalationRule__c  = recordId;
            insert eq;
        }
        return rw;
    }

    /* Role */
    @AuraEnabled
    public static List<RoleWrapper> initRoleList(String recordId){
        List<RoleWrapper> rwList = new List<RoleWrapper>();
        List<TicketEscalationRole__c> terList = [SELECT Id, Name, TicketEscalationRule__c FROM TicketEscalationRole__c WHERE TicketEscalationRule__c =: recordId];
        for(TicketEscalationRole__c er : terList) {
            RoleWrapper rw = new RoleWrapper();
            rw.Name = er.Name;
            rw.Id = er.Id;
            rwList.add(rw);
        }
        return rwList;
    }

    /**
    @description       : Role 목록 조회
    **/
    @AuraEnabled
    public static List<PicklistWrapper> getRoleList(){
        List<PicklistWrapper> wrappers = new List<PicklistWrapper>();
        try {
            // List<UserRole> roleList = 
            // [
            //     SELECT Id, Name, ParentRoleId
            //     FROM UserRole
            //     WHERE PortalType IN ('None')
            // ];

            List<UserRole> subRoles = getSubRoleList('CS본부');

            if(subRoles.size() > 0) {
                for(UserRole role : subRoles) {
                    PicklistWrapper rw = new PicklistWrapper();
                    rw.value           = role.Id;
                    rw.label           = role.Name;
                    wrappers.add(rw);
                }
            }
            return wrappers;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    @description       : Role 목록 조회
    **/
    @AuraEnabled
    public static List<UserRole> getSubRoleList(String roleName) {
        List<UserRole> roleList = new List<UserRole>();
        UserRole csRole;
        try {
            csRole = [SELECT Id, Name FROM UserRole WHERE Name = :roleName LIMIT 1];
        } catch (Exception e) {
            System.debug('해당 Role을 찾을 수 없음: ' + roleName);
            return roleList;
        }
        getChildRoles(csRole.Id, roleList, new Set<Id>());
        return roleList;
    }

    /**
    @description       : Role 목록 조회
    **/
    private static void getChildRoles(Id parentRoleId, List<UserRole> roleList, Set<Id> roleIdSet) {
        List<UserRole> childRoles = [SELECT Id, Name, ParentRoleId FROM UserRole WHERE ParentRoleId = :parentRoleId AND PortalType IN ('None') ORDER BY Name ASC];

        for (UserRole role : childRoles) {
            if (!roleIdSet.contains(role.Id)) {
                roleList.add(role);
                roleIdSet.add(role.Id); // 중복 방지
                getChildRoles(role.Id, roleList, roleIdSet);
            }
        }
    }
    
    /**
    @description       : 선택한 Role 저장
    **/
    @AuraEnabled
    public static ResultWrapper submitRole(String recordId, String selectedValue, String selectedLabel){
        System.debug('selectedValue'+selectedValue);
        System.debug('selectedLabel'+selectedLabel);
        ResultWrapper rw = new ResultWrapper();
        List<TicketEscalationRole__c> existERList = [SELECT Id, Name FROM TicketEscalationRole__c WHERE TicketEscalationRule__c =: recordId];
        if(existERList.size() > 0) {
            rw.isSuccess = false;
        } else {
            TicketEscalationRole__c er = new TicketEscalationRole__c();
            er.Name                     = selectedLabel;
            er.TicketEscalationRule__c  = recordId;
            insert er;
        }
        return rw;   
    }

    /**
    @description       : 등록된 Role 삭제
    **/
    @AuraEnabled
    public static void deleteRole(String roleId){
        System.debug('roleId'+roleId);
        delete [SELECT Id FROM TicketEscalationRole__c WHERE Id = :roleId];
    }

    /*
     * @Description 
     *  - Apex Callout 실행 결과용 Wrapper
     * 
     * @Variable 
     *  - isSuccess 	: 성공 여부
     *  - errMessage 	: 실패 시 에러메세지 
     */ 
    public class ResultWrapper{
        @AuraEnabled public Boolean isSuccess  { get; set;}
        @AuraEnabled public String  errMessage { get; set;}
        @AuraEnabled public Boolean isExist    { get; set;}
        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }

    public class getObjectTypeWrapper{
        @AuraEnabled public String label { get; set;}
        @AuraEnabled public String value { get; set;}

        public getObjectTypeWrapper(){
            this.label = '';
            this.value = '';
        }
    }

    /*
     * @Description 
     *  - Return FailureArea Wrapper
     * 
     */ 
    public class FailureAreaWrapper{
        @AuraEnabled public String Id                  { get; set;}
        @AuraEnabled public String objectType          { get; set;}
        @AuraEnabled public String failureAreaMajor    { get; set;}
        @AuraEnabled public String failureAreaMiddle   { get; set;}
        @AuraEnabled public String failurePhenomenon   { get; set;}

        public FailureAreaWrapper(){
            this.Id                  = '';
            this.objectType          = '';
            this.failureAreaMajor    = '';
            this.failureAreaMiddle   = '';
            this.failurePhenomenon   = '';
        }
    }

    /*
     * @Description 
     *  - Return Picklist Wrapper
     */ 
    public class PicklistWrapper{
        @AuraEnabled public String label   { get; set;}
        @AuraEnabled public String value   { get; set;}

        public PicklistWrapper(){
            this.label   = '';
            this.value   = '';
        }
    }

    /*
     * @Description 
     *  - Return Queue Name
     * 
     */ 
    public class QueueWrapper{
        @AuraEnabled public String Name { get; set;}
        @AuraEnabled public String Id   { get; set;}
        
        public QueueWrapper(){
            this.Name   = '';
            this.Id     = '';
        }
    }

    /*
     * @Description 
     *  - Return Role Name
     * 
     */ 
    public class RoleWrapper{
        @AuraEnabled public String Name       { get; set;}
        @AuraEnabled public String Id         { get; set;}
        @AuraEnabled public String ParentId   { get; set;}
        
        public RoleWrapper(){
            this.Name       = '';
            this.Id         = '';
            this.ParentId   = '';
        }
    }
}