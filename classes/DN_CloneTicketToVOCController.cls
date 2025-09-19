/**
 * @description       : 
 * @author            : Hayeong Min
 * @group             : 
 * @last modified on  : 2025-02-26
 * @last modified by  : Hayeong Min
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   2024-10-29   Hayeong Min   Initial Version
 * 1.0   2024-10-30   Hayeong Min       VOC Save 
 * 1.0   2025-02-26   Hayeong Min    RecordType 추가 
**/
public with sharing class DN_CloneTicketToVOCController {
    /**
     * @Description
     * 	- Ticket 정보 가져오기
     * 
     * @author Hayeong Min | 10-30-2024
     * @Parameter
     *  - recordId      : Ticket ID
    **/ 
    @AuraEnabled
    public static CommonWrapper getTicketInfo(String recordId){
        CommonWrapper cw = new CommonWrapper();
        try {

            User u = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()];
            String so = u.SalesOrganization__c;
            String voc_dns = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VOC_Domestic').getRecordTypeId();

            Case ticket = [SELECT AccountId, AssetId, Requester__c, FM_Country__c, ReceptionDetails__c FROM Case WHERE Id = :recordId];
            ticket.OriginTicket__c = ticket.Id;
            ticket.RecordTypeId = voc_dns;
            cw.returnCase = ticket;

        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     * 	- VOC 정보 가져오기
     * 
     * @author Hayeong Min | 01-19-2025
     * @Parameter
     *  - recordId      : Ticket ID
    **/
    @AuraEnabled
    public static CommonWrapper getVOCInfo(String recordId){
        CommonWrapper cw = new CommonWrapper();
        try {

            User u = [SELECT SalesOrganization__c FROM User WHERE Id = :UserInfo.getUserId()];
            String so = u.SalesOrganization__c;
            String recordType = '';
            if(so == '4140' || so == '4146'){ //DNSA
                String ticket_dnsa = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_DNSA').getRecordTypeId();
                recordType = ticket_dnsa;
            }else{ //국내
                String ticket_dns = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Ticket_Domestic').getRecordTypeId();
                recordType = ticket_dns;
            }

            Case ticket = [SELECT AccountId, AssetId, Requester__c FROM Case WHERE Id = :recordId];
            ticket.OriginTicket__c = ticket.Id;
            ticket.RecordTypeId = recordType;
            cw.returnCase = ticket;

            if(String.isNotEmpty(ticket.AssetId)){
                Asset asset =  [SELECT Id, ObjectType__c FROM Asset WHERE Id = :ticket.AssetId];
                //고장부위 정보 가져오기
                DN_FailureAreaController.CustomSelectOption co = new DN_FailureAreaController.CustomSelectOption('--None--', '');
    
                FailureWapper fw = new FailureWapper();
                //고장부위
                List<DN_FailureAreaController.CustomSelectOption> fArea = new List<DN_FailureAreaController.CustomSelectOption>();
                fArea = DN_FailureAreaController.getFailureAreaMajor(asset.ObjectType__c);
                fArea.add(co);
                fw.failureArea = fArea;
                cw.fw = fw;
            }
            
        } catch (Exception e) {
            cw.isSuccess = false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /**
     * @Description
     * 	- 장비의 고장부위 정보 가져오기 
     * 
     * @author Hayeong Min | 01-19-2025
     * @Parameter
     *  - assetId      : ticket의 장비ID
    **/
    @AuraEnabled
    public static CommonWrapper getMajorFailureArea(String assetId){
        CommonWrapper cw = new CommonWrapper();
        try {
            Asset asset = [SELECT Id, ObjectType__c, AccountId FROM Asset WHERE Id = :assetId];
            String objType = asset.ObjectType__c;
            
            if(String.isNotEmpty(asset.AccountId)){
                cw.returnValue = asset.AccountId;
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
     * 	- 장비의 고장부위 상세 정보 가져오기 
     * 
     * @author Hayeong Min | 01-19-2025
     * @Parameter
     *  - major      : 고장부위(대)
    **/
    @AuraEnabled
    public static CommonWrapper getMiddleFailureArea(String major){
        CommonWrapper cw = new CommonWrapper();
        List<DN_FailureAreaController.CustomSelectOption> options = new List<DN_FailureAreaController.CustomSelectOption>();
        options = DN_FailureAreaController.getFailureAreaMiddle(major);
        DN_FailureAreaController.CustomSelectOption co = new DN_FailureAreaController.CustomSelectOption('--None--', '');
        options.add(co);
        cw.failurePick = options;
        return cw;
    }

    /**
     * @Description
     * 	- 장비의 고장현상 정보 가져오기 
     * 
     * @author Hayeong Min | 01-19-2025
     * @Parameter
     *  - major      : 고장부위(대)
     *  - middle     : 고장부위(대)
    **/
    @AuraEnabled
    public static CommonWrapper getPhenomenonFailure(String major, String middle){
        CommonWrapper cw = new CommonWrapper();
        List<DN_FailureAreaController.CustomSelectOption> options = new List<DN_FailureAreaController.CustomSelectOption>();
        options = DN_FailureAreaController.getFailurePhenomenon(major+middle);
        DN_FailureAreaController.CustomSelectOption co = new DN_FailureAreaController.CustomSelectOption('--None--', '');
        options.add(co);
        cw.failurePick = options;
        return cw;
    }

    /**
     * @Description
     * 	- 해당 Account가 보유한 장비 목록 추출
     * 
     * @author Hayeong Min | 2025-02-10
     * @Parameter
     *  - accountId      : Account RecordId
    **/
    @AuraEnabled
    public static List<Asset> getEquipmentOfAccount(String accountId){
        List<Asset> assetList = new List<Asset>();
        assetList = [SELECT Id, Name FROM Asset WHERE AccountId = :accountId];
        return assetList;
    }

    /**
     * @Description
     * 	- 해당 Account에 소속된 Contact 목록 추출
     * 
     * @author Hayeong Min | 2025-02-10
     * @Parameter
     *  - accountId      : Account RecordId
    **/
    @AuraEnabled
    public static List<Contact> getContactOfAccount(String accountId){
        List<Contact> contactList = new List<Contact>();
        contactList = [SELECT Id, Name, MobilePhone FROM Contact WHERE AccountId = :accountId];
        return contactList;
    }

    /**
     * @Description
     * 	- Ticket 생성
     * 
     * @author Hayeong Min | 10-30-2024
     * @Parameter
     *  - ticketData      : Ticket 정보
    **/ 
    @AuraEnabled
    public static CommonWrapper saveRecord(String ticketData){
        CommonWrapper cw = new CommonWrapper();
        Savepoint sp = Database.setSavepoint();
        System.debug('ticketData :: '+ticketData);
        try {
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(ticketData);

            String acc = fieldMap.get('AccountId') == null ? '' : (String)fieldMap.get('AccountId');
            String equip = fieldMap.get('AssetId') == null ? '' : (String)fieldMap.get('AssetId');
            String ticketType = fieldMap.get('InternalTicketType__c') == null ? '' : (String)fieldMap.get('InternalTicketType__c');
                        
            Asset asset = [SELECT AccountId FROM Asset WHERE Id = :equip];
            String accAsset = String.isEmpty(asset.AccountId) ? '' : asset.AccountId;
            System.debug('acc : ' + acc);
            System.debug('accAsset : ' + accAsset);
            
            if(accAsset != acc){
                if((ticketType != 'Installation request') && (ticketType == 'Post-delivery training')){
                    cw.isSuccess = false;
                    cw.errMessage = '장비에 등록된 고객사와 다릅니다. 확인 부탁드립니다.';
                }
            }

            Case newRecord = new Case();       
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

                            if (datetimeValue.endsWith('Z')) {
                                datetimeValue = datetimeValue.substring(0, datetimeValue.length() - 1);
                            }
                            newRecord.put(fieldName, Datetime.valueOf(datetimeValue.replace('T', ' ')));
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
            insert newRecord;
            System.debug(newRecord);
            cw.returnValue = newRecord.Id;
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
     * 	- 신규 Contact 생성
     * @author Hayeong Min | 2025-03-12
     * @Parameter
     *  - accountId     : Contact을 엮을 AccountId 
     *  - data          : 신규 생성 Contact 정보
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

    /*
     * @Description
     * 		- 공용Wrapper
     * 
     * @Variable
     *  	- isSuccess 			: 성공여부
     *  	- errMessage 			: 실패시 에러메세지
     * 		- returnValue 			: 성공시 Return 값 
     */
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess 		{get; set;}
        @AuraEnabled
        public String errMessage		{get; set;} 
        @AuraEnabled
        public Case returnCase		    {get; set;}
        @AuraEnabled
        public String returnValue		{get; set;}
        @AuraEnabled
        public List<Object> returnList		{get; set;}
        @AuraEnabled
        public List<DN_FailureAreaController.CustomSelectOption> failurePick {get; set;}
        @AuraEnabled
        public FailureWapper fw {get; set;}
        
        
        public CommonWrapper(){
            this.isSuccess 		= true;
            this.errMessage 	= '';
            this.returnCase 	= new Case();
            this.returnValue 	= '';
            this.returnList 	= new List<Object>();
            this.failurePick 	= new List<DN_FailureAreaController.CustomSelectOption>();
            this.fw 	= new FailureWapper();
        }
    }

    /*
     * @Description
     * 		- 고장부위 Wrapper
     * 
     * @Variable
     *  	- failureArea 			: 고장부위
     *  	- failureAreaDeail 		: 고장부위 상세 
     * 		- failurePhenomenon 	: 고장현상  
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