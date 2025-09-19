/**
 * @author            : Se-Jin Kwon
 * @description       : 
 *  - RFQ의 RDD가 -1일이 되면 Noti
 *  - Status Sales Reviewe -> 담당 지사장에게 알림
 *  - Status Sales Confirm, SE Recipt -> 검토담당자에게Noti
 *  - Opportunity Stage가 Closed가 아닌것만 추출
 *  - -> 검토 담당자가 없으면 AE 팀장에게 Noti 
 * @last modified on  : 2025-07-17
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-07-17   SEJIN KWON                 Initial Version
**/
public with sharing class DN_RFQActivityAlertBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    private static final String SalesReview = 'SalesReview';
    private static final String SalesConfirm   = 'SalesConfirm';
    private static final String SEReceipt   = 'SEReceipt';
    List<UTIL_Alert.HistoryWrapper> historyWrappers = new List<UTIL_Alert.HistoryWrapper>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT
                Id,
                ERPInquiryNo__c,
                Status__c,
                Opportunity__r.Owner.SalesOffice__c
            FROM
                PS__c
            WHERE
                DiffRequiredDelivryDate__c = -1
            AND Opportunity__r.Opportunity_Owner__r.SalesDistrict__c = 'A1KR'
            AND Status__c IN ('SalesReview','SalesConfirm','SEReceipt')
            AND Opportunity__r.StageName IN ('Identified','Validated','Qualified','Conditional Agreement')
        ]);
    }
    public void execute(Database.BatchableContext bc, List<PS__c> scope){
            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'RFQ RDD Over Email Alert'];
            Id alertId;
        try{
            List<PS__c> statusSaleReview    = new List<PS__c>();
            List<PS__c> statusOthers        = new List<PS__c>();

            if(!am.isEmpty()){
                alertId = am[0].Id;
            }else{
                alertId = 'a0xJO000000JLQXYA4';
            }

            //지사장 메일
            List<User> jisaEmailList = new List<User>();
            if(System.Test.isRunningTest()){
                jisaEmailList = [SELECT Id, Name, Profile.Name, UserRole.Name, SalesOffice__c FROM User WHERE IsActive = true LIMIT 1];
            }else{
                jisaEmailList = [SELECT Id, Name, Profile.Name, UserRole.Name, SalesOffice__c FROM User WHERE Profile.Name like '%지사장%' AND IsActive = true];
            }
            Map<String, String> jisaEmailMap = new Map<String, String>();

            if(!jisaEmailList.isEmpty() || System.Test.isRunningTest()){
                for(User u : jisaEmailList){
                    //지사장 메일 주소 찾아서 적재
                    jisaEmailMap.put(u.SalesOffice__c, DN_WithoutSharingClass.getUserEmail(u.Id).Email);
                }
            }

            //AE정보 등록된 RFQ
            List<Message_Group_Junction__c> aeInfoRFQ = 
            [
                SELECT
                    User__c, 
                    User__r.Name, 
                    FM_UserEmail__c,
                    RFQ_Specification__c,
                    RFQ_Specification__r.ERPInquiryNo__c
                FROM
                    Message_Group_Junction__c 
                WHERE 
                    RFQ_Specification__r.DiffRequiredDelivryDate__c = -1 
                AND RFQ_Specification__r.Opportunity__r.Opportunity_Owner__r.SalesDistrict__c = 'A1KR' 
                AND RFQ_Specification__r.Status__c IN ('SalesConfirm','SEReceipt')
            ];
            
            Map<String, String> aeInfoMap = new Map<String, String>();
            if(!aeInfoRFQ.isEmpty() || System.Test.isRunningTest()){
                for(Message_Group_Junction__c mgj : aeInfoRFQ){
                    if(mgj.RFQ_Specification__r.ERPInquiryNo__c != null){
                        aeInfoMap.put(mgj.RFQ_Specification__r.ERPInquiryNo__c, mgj.RFQ_Specification__r.ERPInquiryNo__c);

                        //Alert 세팅
                        this.alertTargetSetting(alertId, 'Email', mgj.FM_UserEmail__c, 'ko', mgj.RFQ_Specification__r.ERPInquiryNo__c);
                    }else{
                        this.alertTargetSetting(alertId, 'Email', 'sejin.kwon@dncompany.com', 'ko', 'ERP Inquiry no없는 RFQ : ' + mgj.RFQ_Specification__c);
                    }
                }
            }

            //AE팀장
            List<Message_Group_Junction__c> aeInfo = [SELECT Id, User__c, FM_UserEmail__c FROM Message_Group_Junction__c WHERE Message_Group__r.Name = 'AE 팀장'];
            
            for(PS__c ps : scope){
                if(ps.ERPInquiryNo__c != null || System.Test.isRunningTest()){
                    if(ps.Status__c == SalesReview){
                        //Alert 세팅
                        this.alertTargetSetting(alertId, 'Email', jisaEmailMap.get(ps.Opportunity__r.Owner.SalesOffice__c), 'ko', ps.ERPInquiryNo__c);
                    }else if(ps.Status__c == SalesConfirm || ps.Status__c == SEReceipt){
                        statusOthers.add(ps);
                        //Alert 세팅
                        //ae가 등록된게 없으면 AE 팀장 전체에게 Mail
                        if(!aeInfoMap.containsKey(ps.ERPInquiryNo__c)){
                            if(!aeInfo.isEmpty()){
                                for(Message_Group_Junction__c mgj : aeInfo){
                                    this.alertTargetSetting(alertId, 'Email', mgj.FM_UserEmail__c, 'ko', ps.ERPInquiryNo__c);
                                }
                            }
                        }
                    }
                }else{
                    this.alertTargetSetting(alertId, 'Email', 'sejin.kwon@dncompany.com', 'ko', 'ERP Inquiry no없는 RFQ : ' + ps.Id);
                }
                
            }
        }catch (Exception e) {
            this.alertTargetSetting(alertId, 'Email', 'sejin.kwon@dncompany.com', 'ko', 'Error Line : ' + e.getLineNumber() + 'Error MSG : ' + e.getMessage());
        }
        

        if(!historyWrappers.isEmpty()){
            UTIL_Alert.runAlertEvent(historyWrappers);
        }

    }

    public void finish(Database.BatchableContext bc){
        System.debug('DN_RFQActivityAlertBatch completed :: ' + System.now());
    }

    public void execute(SchedulableContext sc) {
        DN_RFQActivityAlertBatch batch = new DN_RFQActivityAlertBatch();
        Database.executeBatch(batch);
    }

    public void alertTargetSetting(String alertId, String alertType, String emailAddr, String language, String erpInquiryNo){
        UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
            wrapEmail.alertID            = alertId;
            wrapEmail.alertType          = 'Email';
            wrapEmail.receiverforEmail   = new List<String>{emailAddr};
            wrapEmail.alertLanguage      = language;
            wrapEmail.elementList        = new List<String>{erpInquiryNo};
            historyWrappers.add(wrapEmail);
        
    }
}