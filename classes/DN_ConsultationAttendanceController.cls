/**
* @Class : DN_ConsultationAttendanceController
* @Description : 상담배정 근태관리 Report 화면
* @Author : Jiyeong, Park
* @Date : 2025-02-13
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-02-13 | Jiyeong, Park   | 최초작성
*
*/
public with sharing class DN_ConsultationAttendanceController {
    
    //조건에 부합하는 상담원별 근태 DATA 반환
    @AuraEnabled
    public static List<ConsultationAttendanceWrapper> getData(DateTime dateTo, DateTime dateFrom, String constructortype, String constructorId, String constructorName){
        System.debug('form: '+ dateFrom.format('yyyy-MM-dd'));
        System.debug('to: '+ dateTo.format('yyyy-MM-dd'));
        
        List<ConsultationAttendanceWrapper> result = new List<ConsultationAttendanceWrapper>();
        String query = 'SELECT Id, Consultant__c, Consultant__r.Name, Consultant__r.Profile.Name, Consultant__r.EmployeeNumber,'
                        +' AttendanceDate__c, AttendanceType__c, OffStartTime__c, OffEndTime__c'
                        +' FROM ConsultationAttendance__c'
                        +' WHERE AttendanceDate__c >='+dateFrom.format('yyyy-MM-dd')
                        +' AND AttendanceDate__c <='+dateTo.format('yyyy-MM-dd')
                        +' AND Consultant__r.Name LIKE \'%'+constructorName+'%\''
                        +' AND Consultant__r.IsActive = TRUE';
                       
        String whereQuery = '';
        if(constructortype != ''){
            whereQuery = ' AND Consultant__r.ProfileId = \''+constructortype+'\'';
        }
        if(constructorId != ''){
            whereQuery = whereQuery+' AND Consultant__r.EmployeeNumber LIKE \'%'+constructorName+'%\'';
        }
        String sortQuery = ' ORDER BY Consultant__r.Name, AttendanceDate__c Asc';
        System.debug('query::'+query+whereQuery+sortQuery);
        List<SObject> sObj = Database.query(query+whereQuery+sortQuery);
        for(SObject obj:sObj){
            result.add(new ConsultationAttendanceWrapper((ConsultationAttendance__c)obj));
        }
        return result;
    } 

    //Type에 따른 ConsultationAttendance DATA 저장
    @AuraEnabled
    public static String setData(String type, List<ConsultationAttendance__c> dataList, String attendanceType, String offStartTime, String offEndTime){
        Set<Id> ids = new Set<Id>();
        system.debug('dataList>>'+dataList);
        for(ConsultationAttendance__c obj : dataList){
            ids.add(obj.Id);
        }
        List<ConsultationAttendance__c> caList = [SELECT Id, AttendanceType__c, OffStartTime__c, OffEndTime__c
                                                  FROM ConsultationAttendance__c
                                                  WHERE Id IN: ids];

        if(type == 'RESET'){
            for(ConsultationAttendance__c ca : caList){
                ca.AttendanceType__c = '';
                ca.OffStartTime__c = '';
                ca.OffEndTime__c = '';
            }
        } else {
            for(ConsultationAttendance__c ca : caList){
                ca.AttendanceType__c = attendanceType;
                ca.OffStartTime__c = offStartTime;
                ca.OffEndTime__c = offEndTime;
            }
        }

        Database.SaveResult[] res = Database.update(caList, false);
        System.debug('저장 결과::'+res);
        for(Database.SaveResult r: res) {
            if(!r.isSuccess()) {
                System.debug('Upsert error: ' + r.getErrors());
                return '오류 발생: ' + r.getErrors()[0].getMessage();
            }
        }

        return 'S';
    } 
    

    // 상담유형 콤보박스 Setting
    @AuraEnabled
    public static List<inquiryTypeOption> setInquiryType(){
        List<inquiryTypeOption> res = new List<inquiryTypeOption>();
        List<Profile> pro = [SELECT Id, Name FROM Profile WHERE (Name ='DNS CS Receptionist' OR Name ='DNS CS Technical Consultant')];

        for(Profile p:pro){
            inquiryTypeOption gr = new inquiryTypeOption();
            gr.label = p.Name=='DNS CS Receptionist'?'접수 상담사':'기술 상담사';
            gr.value = p.Id;
            res.add(gr);
        }

        return res;
    }
    
    //상담유형 Picklist 형태로 Mapping
    public class inquiryTypeOption{
        @AuraEnabled public String label { get;set; } 
        @AuraEnabled public String value { get;set; } 

        public inquiryTypeOption(){
            this.label = '';
            this.value = '';
        }
    }

    //상담배정 근태관리 반환 DATA Mapping
    public class ConsultationAttendanceWrapper {
        @AuraEnabled public String Id               { get;set; }
        @AuraEnabled public String ConsultantType   { get;set; }
        @AuraEnabled public String ConsultantId     { get;set; }
        @AuraEnabled public String ConsultantName   { get;set; }
        @AuraEnabled public Date AttendanceDate     { get;set; }
        @AuraEnabled public String AttendanceType   { get;set; }
        @AuraEnabled public String OffStartTime       { get;set; }
        @AuraEnabled public String OffEndTime         { get;set; }

        public ConsultationAttendanceWrapper() {
            Id = '';
            ConsultantType = '';
            ConsultantId = '';
            ConsultantName = '';
            AttendanceDate = null;
            AttendanceType = '';
            OffStartTime = '';
            OffEndTime = '';
        }

        public ConsultationAttendanceWrapper(ConsultationAttendance__c obj) {
            Id = obj.Id;
            ConsultantType = obj.Consultant__r.Profile.Name == 'DNS CS Receptionist'?'접수 상담사':'기술 상담사';
            ConsultantId = obj.Consultant__r.EmployeeNumber;
            ConsultantName = obj.Consultant__r.Name;
            AttendanceDate = obj.AttendanceDate__c;
            AttendanceType = obj.AttendanceType__c==null?'':obj.AttendanceType__c;
            OffStartTime = obj.OffStartTime__c==null?'':obj.OffStartTime__c.substring(0, 2) + ':' + obj.OffStartTime__c.substring(2, 4);
            OffEndTime = obj.OffEndTime__c==null?'':obj.OffEndTime__c.substring(0, 2) + ':' + obj.OffEndTime__c.substring(2, 4);
        }

        
    }
}