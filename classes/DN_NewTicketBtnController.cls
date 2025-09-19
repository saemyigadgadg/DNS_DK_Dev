/**
 * @description       : 
 * @author            : Hayeong Min
 * @group             : 
 * @last modified on  : 2025-04-10
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   07-25-2024   Hayeong Min   Initial Version
**/
public with sharing class DN_NewTicketBtnController {

    /**
     * @Description
     * 	- Ticket 생성
     * 
     * @author Hayeong Min | 07-25-2024
     * @Parameter
     *  - recordType      : RecordType 이름
     *  - ticketData      : Ticket 정보
    **/ 
    @AuraEnabled
    public static CommonWrapper saveTicket(String recordTypeId, String ticketData){
        CommonWrapper cw = new CommonWrapper();
        Savepoint sp = Database.setSavepoint();
        System.debug('ticketData :: '+ticketData);
        try {
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(ticketData);
            String acc = fieldMap.get('AccountId') == null ? '' : (String)fieldMap.get('AccountId');
            String equip = fieldMap.get('AssetId') == null ? '' : (String)fieldMap.get('AssetId');
            String ticketType = fieldMap.get('InternalTicketType__c') == null ? '' : (String)fieldMap.get('InternalTicketType__c');

            if(String.isNotEmpty(equip)){
                Asset asset = [SELECT AccountId FROM Asset WHERE Id = :equip];
                String accAsset = String.isEmpty(asset.AccountId) ? '' : asset.AccountId;
                System.debug('acc : ' + acc);
                System.debug('accAsset : ' + accAsset);
                
                if(accAsset != acc){
                    System.debug('ticketType ::: '+ticketType);
                    if((ticketType != 'Installation request') && (ticketType != 'Post-delivery training')){
                        cw.isSuccess = false;
                        cw.errMessage = System.Label.DNS_E_CheckAssetAccount;
                        System.debug('cw :: '+cw);
                        return cw;
                    }
                }
            }
            
           
            if(cw.isSuccess){
                Case newRecord = new Case();       
                newRecord.put('RecordTypeId', recordTypeId);
                for (String fieldName : fieldMap.keySet()) {
                    String fieldType = getFieldType(fieldName);
                    System.debug('fieldType   '+fieldType);
                    if(fieldType != 'formula' && fieldMap.get(fieldName) != null) {
                        switch on fieldType {
                            when 'LONG', 'INTEGER'{
                                String IntegerValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Integer.valueOf(IntegerValue));
                            }
                            when 'DOUBLE', 'CURRENCY', 'PERCENT'{
                                String decimalValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Double.valueOf(decimalValue));
                            }
                            when 'DATE' {
                                String dateValue = (String) fieldMap.get(fieldName);
                                newRecord.put(fieldName, Date.valueOf(dateValue));
                            }
                            when 'DATETIME'  {
                                String datetimeValue = (String) fieldMap.get(fieldName);
                                DateTime localDatetime = changeDatetime(datetimeValue);
                                newRecord.put(fieldName, localDatetime);
                            }
                            when 'BOOLEAN' {
                                newRecord.put(fieldName, fieldMap.get(fieldName));
                            }
                            when else {
                                newRecord.put(fieldName, fieldMap.get(fieldName));
                            }
                        }
                        
                    }
                }


                //휴넥트에서 접수할 때는 기술상담사한테 배정 그 외의 사람들은 본인한테 배정
                Id techId = [SELECT Id FROM Profile WHERE Name = 'DNS CS Technical Consultant'].Id;
                Id generalId = [SELECT Id FROM Profile WHERE Name = 'DNS CS Receptionist'].Id;
                if(newRecord.ReceptionPath__c == 'Indirect application'){
                    if(newRecord.TicketType__c == 'Technical inquiry' && UserInfo.getProfileId() == generalId){
                        newRecord.isSelf__c = FALSE;
                    }else{
                        newRecord.isSelf__c = TRUE;
                    }
                }


                insert newRecord;
                System.debug(newRecord);
                cw.returnValue = newRecord.Id;
            }

            
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber() + '_' +e.getMessage();
            System.debug(e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            Database.rollback(sp);
        }
        return cw;
    }

    /**
     * @Description
     * 	- Case의 Field Type
     * @Parameter
     *  - fieldName     : 타입을 조회할 Field Name
    **/ 
    private static String getFieldType(String fieldName){
        Schema.DescribeFieldResult  fieldDescribe   = Schema.SObjectType.Case.fields.getMap().get(fieldName).getDescribe();
        Schema.DisplayType          fieldType       = fieldDescribe.getType();   
        if (fieldDescribe.isCalculated()) {
            return 'formula';
        } else {
            return fieldType.name();
        }
    }

    /**
     * @Description
     * 	- Case의 RecordTypeId
     * @Parameter
     *  - recordTypeName    : 선택한 Case의 RecordType Name
    **/ 
    @AuraEnabled
    public static String getRecordTypeId(String radioValue) {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE DeveloperName = :radioValue
            AND SobjectType = 'Case'
            LIMIT 1
        ];

        return rt.Id;
    }

    /**
     * @Description
     * 	- Case의 ListView 정보
    **/ 
    @AuraEnabled
    public static CommonWrapper getRecordInfo() {
        CommonWrapper cw = new CommonWrapper();
        try{
            ListView lv =  [SELECT Id FROM ListView WHERE SobjectType = 'Case' AND DeveloperName = 'RecentlyViewedCases' LIMIT 1];
            User u = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()];
            String so = u.SalesOrganization__c;
            String query = 'SELECT Id, Name FROM RecordType WHERE SObjectType = \'Case\' AND DeveloperName ';
            if(so == '4140' || so == '4146'){ //DNSA
                query += '= \'Ticket_DNSA\'';
                cw.country = 'DNSA';
            }else{ //국내
                query += 'LIKE \'%Domestic%\'';
                cw.country = 'DNS';
            }
            query +=' ORDER BY Name';
    
            List<RecordType> recTypeList = Database.query(query);
            List<Map<String, String>> recordTypeList = new List<Map<String, String>>();
            for (RecordType rt : recTypeList) {
                Map<String, String> recordTypeMap = new Map<String, String>();
                recordTypeMap.put('label', rt.Name);
                recordTypeMap.put('value', rt.Id);
                recordTypeList.add(recordTypeMap);
            }

            cw.picklist = recordTypeList;
            cw.returnValue = lv.Id;      
                
        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     * 	- 해당장비의 Account 조회
    **/ 
    @AuraEnabled
    public static CommonWrapper getAccount(String assetId) {
        CommonWrapper cw = new CommonWrapper();
        try {
            Asset equipment = [SELECT Id, AccountId FROM Asset WHERE Id = :assetId];
            if(String.isNotEmpty(equipment.AccountId)){
                cw.returnValue = equipment.AccountId;
            }
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
            System.debug(e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
        }
        return cw;
    }
    

    

    /**
     * @Description
     *  - 기존 Ticket 정보 가져오기
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getTicketInfo(String recordId){
        CommonWrapper cw = new CommonWrapper();
        try{
            List<Case> caseList = [SELECT Id, AccountId, AssetId, Requester__c, RecordTypeId, Status, ReceptionDetails__c, ApplicationDateTime__c, 
            FailureArea__c, FailureAreaDetail__c, FailurePhenomenon__c, FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c, Phone__c, ReplyTo__c
            FROM Case 
            WHERE Id = :recordId];

            caseList[0].ReplyTo__c = caseList[0].Phone__c;
            cw.returnList = caseList;
    
            if(String.isNotEmpty(caseList[0].AssetId)){
                Asset asset =  [SELECT Id, ObjectType__c FROM Asset WHERE Id = :caseList[0].AssetId];
                //고장부위 정보 가져오기
                DN_FailureAreaController.CustomSelectOption co = new DN_FailureAreaController.CustomSelectOption('--None--', '');
    
                FailureWapper fw = new FailureWapper();
                //고장부위
                List<DN_FailureAreaController.CustomSelectOption> fArea = new List<DN_FailureAreaController.CustomSelectOption>();
                fArea = DN_FailureAreaController.getFailureAreaMajor(asset.ObjectType__c);
                fArea.add(co);
                fw.failureArea = fArea;
    
                //고장부위상세
                if(String.isNotEmpty(caseList[0].FailureAreaValue__c)){
                    List<DN_FailureAreaController.CustomSelectOption> fAreaDetail = new List<DN_FailureAreaController.CustomSelectOption>();
                    fAreaDetail = DN_FailureAreaController.getFailureAreaMiddle(caseList[0].FailureAreaValue__c);
                    fAreaDetail.add(co);
                    fw.failureAreaDeail = fAreaDetail;
                }
    
                //고장현상
                if(String.isNotEmpty(caseList[0].FailureAreaDetailValue__c)){
                    List<DN_FailureAreaController.CustomSelectOption> fPhenomenon = new List<DN_FailureAreaController.CustomSelectOption>();
                    fPhenomenon = DN_FailureAreaController.getFailurePhenomenon(caseList[0].FailureAreaValue__c+caseList[0].FailureAreaDetailValue__c);
                    fPhenomenon.add(co);
                    fw.failurePhenomenon = fPhenomenon;
                }
                cw.fw = fw;
            }
        }catch(Exception e){
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - 사용자에 따른 Ticket의 Record Type 추출
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getAvailableRecordType(String recordId){
        CommonWrapper cw = new CommonWrapper();

        String recordType = [SELECT RecordTypeId FROM Case WHERE Id = :recordId].RecordTypeId;
        User u = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()];
        String so = u.SalesOrganization__c;
        String query = 'SELECT Id, Name FROM RecordType WHERE SObjectType = \'Case\' AND DeveloperName ';
        if(so == '4140' || so == '4146'){ //DNSA
            query += 'LIKE \'%DNSA%\'';
        }else{ //국내
            query += 'LIKE \'%Domestic%\'';
        }
        query +=' ORDER BY Name';

        List<RecordType> recTypeList = Database.query(query);
        System.debug('recTypeList :: '+recTypeList);
        List<Map<String, String>> recordTypeList = new List<Map<String, String>>();
        for (RecordType rt : recTypeList) {
            Map<String, String> recordTypeMap = new Map<String, String>();
            recordTypeMap.put('label', rt.Name);
            recordTypeMap.put('value', rt.Id);
            recordTypeList.add(recordTypeMap);

            if(rt.Id != recordType){
                cw.returnValue = rt.Id;
                cw.returnLabel = rt.Name;
            }
        }

        cw.picklist = recordTypeList;
        return cw;
    }

    /**
     * @Description
     *  - 기존의 Ticket의 Record Type을 변경하여 저장
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper changeRecordType(String recordId, String recordTypeId, String ticketData){
        CommonWrapper cw = new CommonWrapper();
        Savepoint sp = Database.setSavepoint();
        System.debug('ticketData :: '+ticketData);
        try {
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(ticketData);
            Case updateRecord =[SELECT AccountId, ApplicationDateTime__c, ApplicationRoute__c, ApplicationRoute2__c, AssetId, AssignHoldingReason__c, BreakdownDateTime__c, Campaign__c, ClosedReasonDetails__c, Description, DesiredConsultationTime__c, EducationType__c, EndOfReason__c, EscLev__c, ExtractCompleted__c, FileCount__c, InstallationDefect__c, InternalRequester__c, InternalTicketType__c, isAlarmToCustomer__c, IsReGenerate__c, Issue__c, IsUrgency__c, Manager__c, ModelCode__c, NotiNO__c, Occurrence__c, Occurrence_Classification__c, OriginTicket__c, PartManager__c, FailureArea__c, FailureAreaDetail__c, FailurePhenomenon__c, PreparationChecklist__c, Priority, ProcessingDeadline__c, ProcessingDelay__c, Producer__c, Progress__c, ReceptionDetails__c, Receptionist__c, ReceptionPath__c, RecordTypeId, RepairRequestDateTime__c, ReplyMethod__c, ReplyTo__c, Requester__c, ResultOfMeasure__c, SalesDealer__c, SalesOrder__c, ServiceResource__c, SkillCheck__c, Status, SVOrdNo__c, TicketType__c, TraineeLevel__c, TrainingCount__c, TrainingDateTime1__c, TrainingDateTime2__c, TrainingDateTime3__c, TrainingSort__c, TrainingType__c, Urgency__c, VOCcategory3__c, VOCType__c, VOCTypeDetail__c, WorkingTime__c
            FROM Case WHERE Id = :recordId];    
            updateRecord.put('RecordTypeId', Id.valueOf(recordTypeId));
            for (String fieldName : fieldMap.keySet()) {
                String fieldType = getFieldType(fieldName);
                System.debug('fieldType   '+fieldType);
                if(fieldType != 'formula' && fieldMap.get(fieldName) != null) {
                    switch on fieldType {
                        when 'LONG', 'INTEGER'{
                            String IntegerValue = (String) fieldMap.get(fieldName);
                            updateRecord.put(fieldName, Integer.valueOf(IntegerValue));
                        }
                        when 'DOUBLE', 'CURRENCY', 'PERCENT'{
                            String decimalValue = (String) fieldMap.get(fieldName);
                            updateRecord.put(fieldName, Double.valueOf(decimalValue));
                        }
                        when 'DATE' {
                            String dateValue = (String) fieldMap.get(fieldName);
                            updateRecord.put(fieldName, Date.valueOf(dateValue));
                        }
                        when 'DATETIME'  {
                            String datetimeValue = (String) fieldMap.get(fieldName);
                            DateTime localDatetime = changeDatetime(datetimeValue);
                            updateRecord.put(fieldName, localDatetime);
                        }
                        when 'BOOLEAN' {
                            updateRecord.put(fieldName, fieldMap.get(fieldName));
                        }
                        when else {
                            updateRecord.put(fieldName, fieldMap.get(fieldName));
                        }
                    }
                    
                }
            }
            update updateRecord;
            System.debug(updateRecord);
            cw.returnValue = updateRecord.Id;

            //변경된 Ticket 유형 Email&Noti 알림
            


        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
            System.debug(e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            Database.rollback(sp);
        }
        return cw;
    }

    /**
     * @Description
     *  - 입력한 장비의 정보를 기반으로 고장부위(대) 정보 가져오기
     *  - 250226) DNSA의 Ticket인 경우 Dealer 정보 가져오기(장비의 SoldTo 정보)
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getMajorFailureArea(String assetId, String country){
        CommonWrapper cw = new CommonWrapper();
        try {
            Asset asset = [SELECT Id, ObjectType__c, AccountId, SoldTo__c FROM Asset WHERE Id = :assetId];
            String objType = asset.ObjectType__c;
            
            if(String.isNotEmpty(asset.AccountId)){
                cw.returnValue = asset.AccountId;
                if(country == 'DNSA'){ cw.SoldTo = (asset.SoldTo__c!= null) ? asset.SoldTo__c : '';}
            }

            if(String.isNotEmpty(asset.ObjectType__c)){
                List<DN_FailureAreaController.CustomSelectOption> options = new List<DN_FailureAreaController.CustomSelectOption>();
                options = DN_FailureAreaController.getFailureAreaMajor(asset.ObjectType__c);
                DN_FailureAreaController.CustomSelectOption co = new DN_FailureAreaController.CustomSelectOption('--None--', '');
                options.add(co);
                cw.failurePick = options;
            }
            
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - 고장부위(대)정보를 기반으로 고장부위(중) 정보 가져오기
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getMiddleFailureArea(String major){
        CommonWrapper cw = new CommonWrapper();
        try {
            List<DN_FailureAreaController.CustomSelectOption> options = new List<DN_FailureAreaController.CustomSelectOption>();
            options = DN_FailureAreaController.getFailureAreaMiddle(major);
            DN_FailureAreaController.CustomSelectOption co = new DN_FailureAreaController.CustomSelectOption('--None--', '');
            options.add(co);
            cw.failurePick = options;
            
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - 고장부위(중)정보를 기반으로 고장현상 정보 가져오기
     * @author Hayeong Min 
    **/
    @AuraEnabled
    public static CommonWrapper getPhenomenonFailure(String major, String middle){
        CommonWrapper cw = new CommonWrapper();
        try {
            List<DN_FailureAreaController.CustomSelectOption> options = new List<DN_FailureAreaController.CustomSelectOption>();
            options = DN_FailureAreaController.getFailurePhenomenon(major+middle);
            DN_FailureAreaController.CustomSelectOption co = new DN_FailureAreaController.CustomSelectOption('--None--', '');
            options.add(co);
            cw.failurePick = options;
            
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - 해당 Account의 보유 장비(Asset) 목록 추출
     * @author Hayeong Min | 2025-01-20
    **/
    @AuraEnabled
    public static List<Asset> getEquipmentOfAccount(String accountId){
        List<Asset> assetList = new List<Asset>();
        try {
            assetList = [SELECT Id, Name, MachineName__c FROM Asset WHERE AccountId = :accountId];
            
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }
        return assetList;
    }

    /**
     * @Description
     *  - 해당 Account에 등록된 Contact 목록 추출
     * @author Hayeong Min | 2025-01-20
    **/
    @AuraEnabled
    public static List<Contact> getContactOfAccount(String accountId){
        List<Contact> contactList = new List<Contact>();
        try {
            contactList = [SELECT Id, Name, MobilePhone FROM Contact WHERE AccountId = :accountId];
            
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
        }
        return contactList;
    }

    /**
     * @Description
     *  - Contact 신규 생성
     * @author Hayeong Min | 2025-03-12
    **/
    @AuraEnabled
    public static CommonWrapper contactSave(String accountId, String data){
        CommonWrapper cw = new CommonWrapper();
        try {

            Map<String, Object> newRecord = (Map<String, Object>) JSON.deserializeUntyped(data);
            Contact con = new Contact();
            con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSCustomer').getRecordTypeId();
            con.Lastname = (String) newRecord.get('Name');
            con.MobilePhone = (String) newRecord.get('MobilePhone');
            con.AccountId = accountId;
            insert con;

            List<Contact> contactList = [SELECT Id, Name, MobilePhone FROM Contact WHERE AccountId = :accountId ORDER BY CreatedDate DESC];
            cw.returnList = contactList;
            cw.returnValue = con.Id;

        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getLineNumber() +'__'+ e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     *  - String인 DateTime 값 DateTime 형태로 변경해서 
     * @author Hayeong Min 
    **/
    private static DateTime changeDatetime(String datetimeValue){
        datetimeValue = datetimeValue.replace('T', ' ').substring(0, 19);
        Datetime utcDatetime = Datetime.valueOf(datetimeValue);
        TimeZone tz = UserInfo.getTimeZone();
        Datetime localDatetime = utcDatetime.addSeconds(tz.getOffset(utcDatetime) / 1000);
        return localDatetime;
    }


    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		          {get; set;}
        @AuraEnabled
        public String errMessage		          {get; set;} 
        @AuraEnabled
        public String country		          {get; set;}
        @AuraEnabled
        public String returnValue		          {get; set;}
        @AuraEnabled
        public String returnLabel		          {get; set;}
        @AuraEnabled
        public String SoldTo		          {get; set;}
        @AuraEnabled
        public List<Map<String, String>> picklist {get; set;}
        @AuraEnabled
        public List<DN_FailureAreaController.CustomSelectOption> failurePick {get; set;}
        @AuraEnabled
        public List<Object> returnList {get; set;}
        @AuraEnabled
        public FailureWapper fw {get; set;}
        
        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.country 	= '';
            this.returnValue 	= '';
            this.returnLabel 	= '';
            this.SoldTo 	= '';
            this.picklist 	= new List<Map<String, String>>();
            this.failurePick 	= new List<DN_FailureAreaController.CustomSelectOption>();
            this.returnList 	= new List<Object>();
            this.fw 	= new FailureWapper();
        }
    }

    /*
     * @Description
     * 		- 고장부위 (대), (중), 고장현상 Wrapper
     * 
     * @Variable
     *  	- failureArea 			: 고장부위(대)
     *  	- failureAreaDeail 		: 고장부위(중)
     *  	- failurePhenomenon 	: 고장현상
     */
    public class FailureWapper {
        @AuraEnabled
        public List<DN_FailureAreaController.CustomSelectOption> failureArea {get; set;}
        @AuraEnabled
        public List<DN_FailureAreaController.CustomSelectOption> failureAreaDeail {get; set;}
        @AuraEnabled
        public List<DN_FailureAreaController.CustomSelectOption> failurePhenomenon {get; set;}

        public FailureWapper(){
            this.failureArea 	= new List<DN_FailureAreaController.CustomSelectOption>();
            this.failureAreaDeail 	= new List<DN_FailureAreaController.CustomSelectOption>();
            this.failurePhenomenon 	= new List<DN_FailureAreaController.CustomSelectOption>();
        }
    }
}