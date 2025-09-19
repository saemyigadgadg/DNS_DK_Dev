/**
 * @description       : 
 * @author            : JangJunHee
 * @group             : 
 * @last modified on  : 06-26-2025
 * @last modified by  : JangJunHee
**/
global with sharing class DN_UpdatePSBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private static Schema.SObjectField PSEField  = Schema.getGlobalDescribe().get('PS__c').getDescribe().fields.getMap().get('ERPInquiryNo__c');

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('DN_UpdatePSBatch Start ------------');
        try {
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('IF_AEPortal__c').getDescribe().fields.getMap();
            List<String> fieldsToQuery = new List<String>(objectFields.keySet());

            String  query = 'SELECT ' + String.join(fieldsToQuery, ', ') + ' FROM IF_AEPortal__c';
                    query += ' WHERE IsComplete__c = false AND IsConvertError__c = false';
                    query += ' AND Interface_ID__c = \'IF-OPTY-017\'';
                    query += ' ORDER BY CreatedDate ASC';

            return Database.getQueryLocator(query);
        } catch (Exception e) {
            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw e;
        }
    }
    // inquiryNo가 key값이 아닌경우 
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('DN_UpdatePSBatch Execute ------------');

        Savepoint sp = Database.setSavepoint(); 

        TriggerHandler.bypass('PSTriggerHandler');
        System.debug('<< TriggerHandler.bypass On >>');

        Map<String, IF_AEPortal__c> ifAEPortalForERPInquiryNo           = new Map<String, IF_AEPortal__c>();
        Map<String, List<IF_AEPortal__c>> ifAEPortalListForERPInquiryNo = new Map<String, List<IF_AEPortal__c>>();
        // Map<String, Message_Group_Junction__c>  MGJForPSId                 = new Map<String, Message_Group_Junction__c>();
        Map<String, List<Message_Group_Junction__c>> MGJListForPSId     = new Map<String, List<Message_Group_Junction__c>>();
        Map<String, String> ERPInquiryNoForPSId                         = new Map<String, String>();
        
        List<IF_AEPortal__c>           updateIFAEPortalList  = new List<IF_AEPortal__c>();
        List<IF_AEPortal__c>           executeIFAEPortalList = new List<IF_AEPortal__c>();
        Set<Id> executeIFAEPortalSet = new Set<Id>(); // ✅ [수정] 중복 방지용 Set 추가
        // 기존 Message Group Junction Delete 후 Insert
        List<Message_Group_Junction__c> insertMGJList        = new List<Message_Group_Junction__c>();
        List<Message_Group_Junction__c> deleteMGJList        = new List<Message_Group_Junction__c>();
 
        List<String> ERPInquiryNoList             = new List<String>();
        List<String> SEPersonNOList               = new List<String>();
        List<String> PSIdList                     = new List<String>();

        String formattedDate = getYesterdayFormatted();

        try {
            for (IF_AEPortal__c ifAEPortal : (List<IF_AEPortal__c>) scope) {
                System.debug('ERPInquiryNoList : ' + ERPInquiryNoList);
                
                if(ifAEPortal.I_INQUIRY_NO__c != null)   {
                    ERPInquiryNoList.add(ifAEPortal.I_INQUIRY_NO__c);
                    System.debug('ERPInquiryNoList : ' + ERPInquiryNoList);

                    if(ifAEPortalListForERPInquiryNo.get(ifAEPortal.I_INQUIRY_NO__c) == null){
                        ifAEPortalListForERPInquiryNo.put(ifAEPortal.I_INQUIRY_NO__c, new List<IF_AEPortal__c>{ifAEPortal});
                    }else{
                        ifAEPortalListForERPInquiryNo.get(ifAEPortal.I_INQUIRY_NO__c).add(ifAEPortal);
                    }
                }       
                if(ifAEPortal.I_SE_PERSON_NO__c != null) {
                    for(String SEPersonNO : ifAEPortal.I_SE_PERSON_NO__c.split(',')) SEPersonNOList.add(SEPersonNO);
                }
                ifAEPortalForERPInquiryNo.put(ifAEPortal.I_INQUIRY_NO__c, ifAEPortal);
            }

            System.debug('ERPInquiryNoList : ' + ERPInquiryNoList);
            // 추후에 I_ADDRESS 추가
            List<PS__c> psList = [
                SELECT Id, ERPInquiryNo__c, Version__c, RequiredDelivryDate__c, ResponsibleBranch__c,
                    CustomerName__c, PartsforMachining__c, ProductionVolumeYearly__c, WorkingHoursDaily__c, 
                    WorkingDaysMonthly__c, OperationRate__c, CycleTimeRequired__c, CustomerDesc__c, 
                    CustomerEmail__c, CustomerMobileNo__c, InquirySeq__c,Inquiry_Seq2__c, Opportunity__c, 
                    AEApprove__c, RFQ_Specification__c
                FROM PS__c
                WHERE ERPInquiryNo__c IN :ERPInquiryNoList
                    AND ERPInquiryNo__c != null
            ];

            List<User> userList = [
                SELECT Id, Portal_EmployeeNumber__c
                FROM User
                WHERE Portal_EmployeeNumber__c IN : SEPersonNOList
            ];

            Map<String, String> userIdForEmployeeNo = new Map<String, String>();
            for (User user : userList) userIdForEmployeeNo.put(user.Portal_EmployeeNumber__c, user.Id);
            for (PS__c ps: psList)     PSIdList.add(ps.Id);  

            List<Message_Group_Junction__c> MGJList = [
                SELECT Id, User__c, RFQ_Specification__c
                FROM Message_Group_Junction__c
                WHERE RFQ_Specification__c IN : PSIdList
            ];
            for(Message_Group_Junction__c MGJ : MGJList) {
                if(MGJListForPSId.get(MGJ.RFQ_Specification__c) == null) 
                    MGJListForPSId.put(MGJ.RFQ_Specification__c, new List<Message_Group_Junction__c> {MGJ});
                else MGJListForPSId.get(MGJ.RFQ_Specification__c).add(MGJ); 
            }
                
            for (PS__c ps: psList) {
                IF_AEPortal__c ifAEPortal = ifAEPortalForERPInquiryNo.get(ps.ERPInquiryNo__c);

                if(ifAEPortal.I_VERSION__c != null)              ps.Version__c                   = Decimal.valueOf(ifAEPortal.I_VERSION__c);
                if(ifAEPortal.I_REVIEW_REQUEST_DATE__c != null)  ps.RequiredDelivryDate__c       = convertStringToDate(ifAEPortal.I_REVIEW_REQUEST_DATE__c);
                // if(ifAEPortal.I_BRANCH_NAME__c != null)          ps.ResponsibleBranch__c         = ifAEPortal.I_BRANCH_NAME__c;
                // ps.Owner.Name                   = ifAEPortal.I_SALES_PERSON__c; x
                // ps.AEUser__r.Name               = ifAEPortal.I_SE_PERSON__c; x
                
                // if(ifAEPortal.I_CUSTOMER_COMPANY__c != null)     ps.CustomerName__c              = ifAEPortal.I_CUSTOMER_COMPANY__c;
                // ps.Opportunity__r.Owner.Account.CustomerCode__c = ifAEPortal.I_DEALER_CODE__c; x
                if(ifAEPortal.I_PRODUCT_NAME__c != null)         ps.PartsforMachining__c         = ifAEPortal.I_PRODUCT_NAME__c;
                if(ifAEPortal.I_OUTPUT__c != null)               ps.ProductionVolumeYearly__c    = Decimal.valueOf(ifAEPortal.I_OUTPUT__c);
                if(ifAEPortal.I_WORKING_HOURS__c != null)        ps.WorkingHoursDaily__c         = Decimal.valueOf(ifAEPortal.I_WORKING_HOURS__c);
                
                if(ifAEPortal.I_DUTY_DAY__c != null)             ps.WorkingDaysMonthly__c        = Decimal.valueOf(ifAEPortal.I_DUTY_DAY__c);
                if(ifAEPortal.I_OPERATION_RATE__c != null)       ps.OperationRate__c             = Decimal.valueOf(ifAEPortal.I_OPERATION_RATE__c);
                if(ifAEPortal.I_CYCLE_IME_REQUEST__c != null)    ps.CycleTimeRequired__c         = Decimal.valueOf(ifAEPortal.I_CYCLE_IME_REQUEST__c);
                if(ifAEPortal.I_REMARK__c != null)               ps.CustomerDesc__c       = ifAEPortal.I_REMARK__c;
                if(ifAEPortal.I_EMAIL__c != null)                ps.CustomerEmail__c             = ifAEPortal.I_EMAIL__c;

                if(ifAEPortal.I_TEL__c != null)                  ps.CustomerMobileNo__c          = ifAEPortal.I_TEL__c;
                if(ifAEPortal.I_ORDER_STATUS__c != null)         ps.Status__c                    = ifAEPortal.I_ORDER_STATUS__c;
                if(ifAEPortal.I_CONTENTS__c != null)             ps.AEApprove__c                 = ifAEPortal.I_CONTENTS__c;
                // ps.Owner.Name                   = ifAEPortal.I_WRITER__c; x
                // ps.InquirySeq__c                = ifAEPortal.I_INQUIRY_SEQ__c; mapping이 아니라 key 값
                // ps.AEUser__r.CustomerCode__c    = ifAEPortal.I_SE_PERSON_NO__c; x

                if(ifAEPortal.I_STATUS__c == '-8' || ifAEPortal.I_STATUS__c == '-99'){
                    // 상태가 반려일 경우
                    ps.Status__c        = 'RequestToReview';
                    ps.RejecType__c     = 'Reject';
                    ps.RejectReason__c  = ifAEPortal.I_CONTENTS__c;
                }else if(ifAEPortal.I_STATUS__c == '-7'){
                    // 상태가 기각일 경우
                    ps.RejecType__c = 'Discard';
                    ps.Status__c    = 'Rejected';
                }else if(ifAEPortal.I_STATUS__c == '-77'){
                    // 상태가 삭제일 경우
                }else if(ifAEPortal.I_STATUS__c == '9'){
                    ps.Status__c    = 'AE Confirm';
                    ps.AE_Confirmed_Date__c = Date.valueOf(formattedDate);
                }

                // 모든 조건이 만족할 때 MGJ 교체
                if(ifAEPortal.I_SE_PERSON_NO__c != null 
                    && MGJListForPSId.get(ps.Id) != null) {
                    
                    List<String> userSENoList = ifAEPortal.I_SE_PERSON_NO__c.split(',');

                    Boolean breakFlag = true;

                    for(String userSENo : userSENoList){
                        userSENo = userSENo.toUpperCase();
                        Message_Group_Junction__c MGJ = new Message_Group_Junction__c();
                        system.debug('userSENo ::: ' + userSENo);
                        system.debug('userIdForEmployeeNo ::: ' + JSON.serialize(userIdForEmployeeNo));

                        if(userIdForEmployeeNo.get(userSENo) != null){
                            MGJ.User__c              = userIdForEmployeeNo.get(userSENo);
                            MGJ.RFQ_Specification__c = ps.Id;
    
                            insertMGJList.add(MGJ);
                            breakFlag = false;
                        }
                    }
                    // !breakFlag 보다 직관적임
                    if(breakFlag == false) deleteMGJList.addAll(MGJListForPSId.get(ps.Id));
                }

                System.debug('ps.Id : ' + ps.Id);
                System.debug('ps.ERPInquiryNo__c : ' + ps.ERPInquiryNo__c);
                ERPInquiryNoForPSId.put(ps.Id, ps.ERPInquiryNo__c);

                updateIFAEPortalList.addAll(ifAEPortalListForERPInquiryNo.get(ps.ERPInquiryNo__c));
            }

            if(psList.size() > 0) {
                List<Database.SaveResult> srList = Database.update(psList, false);

                for (Database.SaveResult sr : srList) {
                    System.debug('sr.getId() : ' + sr.getId());
                    System.debug('ERPInquiryNoForPSId.get(sr.getId()) : ' + ERPInquiryNoForPSId.get(sr.getId()));
                    IF_AEPortal__c ifAEPortal   = ifAEPortalForERPInquiryNo.get(ERPInquiryNoForPSId.get(sr.getId()));
                    System.debug('ifAEPortal : ' + ifAEPortal);
                    
                    if(!sr.isSuccess()) {
                        ifAEPortal.IsComplete__c         = false;
                        ifAEPortal.IsConvertError__c     = true;

                        List<String> convertErrorMessageList  = new List<String>();
                        for (Database.Error err : sr.getErrors()) convertErrorMessageList.add(err.getStatusCode() + ' : ' + err.getMessage());
                        ifAEPortal.ConvertErrorMessage__c = ifAEPortal.ConvertErrorMessage__c + '\r\n' + String.join(convertErrorMessageList, ',');
                        //executeIFAEPortalList.add(ifAEPortal);//중복제외하기위해 제외 20250625
                        if (!executeIFAEPortalSet.contains(ifAEPortal.Id)) {// 중복제외하기 위해 수정 20250625
                            executeIFAEPortalList.add(ifAEPortal);
                            executeIFAEPortalSet.add(ifAEPortal.Id);
                        }
                    }
                }
            }

            System.debug('deleteMGJList ::: ' + JSON.serialize(deleteMGJList));
            if(deleteMGJList.size() > 0) Database.Delete(deleteMGJList, true);
            System.debug('insertMGJList ::: ' + JSON.serialize(insertMGJList));
            if(insertMGJList.size() > 0) Database.Insert(insertMGJList, true);

            if(updateIFAEPortalList.size() > 0)  Database.Update(updateIFAEPortalList, false);
            if(executeIFAEPortalList.size() > 0) Database.Update(executeIFAEPortalList, false);

        } catch (Exception e) {
            Database.rollback(sp);

            System.debug('Error : '         + e.getMessage());
            System.debug('Line Number : '   + e.getLineNumber());
            throw e;
        }
        TriggerHandler.clearBypass('PSTriggerHandler');
        System.debug('<< TriggerHandler.bypass Off >>');
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('DN_UpdatePSBatch Finish ------------');
    }

    // schedule 실행 (적재하는곳 finish에 연결 시켜야 할 것으로 보임)
    // global void execute(SchedulableContext sc) {
    //     DN_UpdatePSBatch batch = new DN_UpdatePSBatch();
    //     Database.executeBatch(batch, 200);
    // }

    private Date convertStringToDate(String dateString){

        Integer year   = Integer.valueOf(dateString.substring(0, 4));
        Integer month  = Integer.valueOf(dateString.substring(4, 6));
        Integer day    = Integer.valueOf(dateString.substring(6, 8));

        return Date.newInstance(year, month, day);
    }

        
    public static String getYesterdayFormatted() {
        Date yesterday = Date.today().addDays(-1);
        String year = String.valueOf(yesterday.year());
        String month = leftPad(String.valueOf(yesterday.month()), 2, '0');
        String day = leftPad(String.valueOf(yesterday.day()), 2, '0');
        return year + '-' + month + '-' + day;
    }

    public static String leftPad(String value, Integer size, String padChar) {
        while (value.length() < size) {
            value = padChar + value;
        }
        return value;
    }
   
}