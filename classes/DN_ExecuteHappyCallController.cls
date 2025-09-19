/**
 * @description       : DNSA Pre-Call 요청
 * @author            : junyeong.choi@sbtglobal.com
 * @group             : 
 * @last modified on  : 2024-07-31
 * @last modified by  : junyeong.choi@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   07-31-2024   junyeong.choi@sbtglobal   Initial Version
 * 2.0   01-14-2025   junyeong.choi@sbtglobal   Version 2.
 * 3.0   02-04-2025   junyeong.choi@sbtglobal   Version 3.
**/
public without sharing class DN_ExecuteHappyCallController {

    /**
    @ description       : DNSA Pre-Call 요청 메일 장비 선택 화면(장비조회)
    **/
    @AuraEnabled
    public static List<TargetListWrapper> initEquipment(String recordId){
        List<TargetListWrapper> wrappers   = new List<TargetListWrapper>();
        List<CampaignAsset__c> caList      = getCampaignAsset(recordId);

        for(CampaignAsset__c ca : caList) {
            TargetListWrapper wrapper = new TargetListWrapper();
            wrapper.tId              = ca.Id;
            wrapper.SerialNumber     = ca.Equipment__r.Name;
            wrapper.Model            = ca.FM_MachineName__c;
            wrapper.Account          = ca.Equipment__r.Account.Name;
            wrapper.AccountAddress   = ca.Equipment__r.Account.FM_Address__c;
            wrapper.Dealer           = ca.Equipment__r.SoldTo__r.Name;
            wrapper.EmailStatus      = ca.EmailStatus__c;
            wrapper.BillingDate      = ca.Equipment__r.Order__r.BillingDate__c;
            wrapper.IsBilled         = ca.Equipment__r.isBilled__c;
            wrapper.Email            = ca.Email__c;
            wrappers.add(wrapper);
        }
        return wrappers;
    }

    /**
    @ description       : DNSA Pre-Call 시행 요청 메일 전송
    **/
    @AuraEnabled
    public static ResultWrapper sendPreCallEmail(Id recordId, String jsonSelectedData) {
        System.debug('jsonSelectedData ->' + jsonSelectedData);
        ResultWrapper rw = new ResultWrapper();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        try {
            Campaign obj                    = getCampaign(recordId);
            List<CommonPart__c> cpList      = getCommonParts(recordId);
            
            // 메일 내용 없을 때 Return
            if (String.isBlank(obj.MailContents__c)) {
                rw.isSuccess = false;
                return rw;
            }

            List<TargetListWrapper> targetList = new List<TargetListWrapper>();
            if (!String.isEmpty(jsonSelectedData)) {
                targetList = (List<TargetListWrapper>) JSON.deserialize(jsonSelectedData, List<TargetListWrapper>.class);
            }
            System.debug('targetList'+targetList);
            List<CampaignAsset__c> caList   = getEmailCampaignAsset(targetList);

            // Email과 장비 목록 매핑
            Map<String, List<CampaignAsset__c>> emailToEquipmentMap = new Map<String, List<CampaignAsset__c>>();

            for(CampaignAsset__c ca : caList) {    
                List<String> tmpMail = ca.Email__c.split('[,;]');
                System.debug('tmpMail'+tmpMail);
                for(String emailStr : tmpMail) {
                    if(!emailToEquipmentMap.containsKey(emailStr)) {
                        emailToEquipmentMap.put(emailStr, new List<CampaignAsset__c>());
                    }
                    emailToEquipmentMap.get(emailStr).add(ca);
                }
            }
            System.debug('emailToEquipmentMap: ' + emailToEquipmentMap);

            // history 저장용 Email
            List<String> saveEMail = new List<String>();

            // 첨부파일 처리
            List<ContentDocumentLink> cdlList =
            [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId =: recordId
            ];
            
            SET<Id> cdIds = new SET<Id>();
            for(ContentDocumentLink cdl : cdlList) {
                cdIDs.add(cdl.ContentDocumentId);
            }

            List<ContentVersion> cvList = 
            [
                SELECT ID, Title, ContentSize, ContentDocumentId, FileExtension, CreatedDate, VersionData
                FROM ContentVersion
                WHERE ContentDocumentId IN :cdIDs
            ];

            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            if(!cvList.isEmpty()){
                for(ContentVersion cv : cvList) {
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(cv.Title + '.' + cv.FileExtension);
                    attachment.setBody(cv.VersionData);
                    attachments.add(attachment);
                }
            }

            Set<Id> processedIds = new Set<Id>(); // 이미 추가된 레코드 추적
            List<CampaignAsset__c> updateCAList = new List<CampaignAsset__c>();
            List<DNSAPrecallRecipient__mdt> emailCCList = [
                SELECT Id, Email__c, Active__c
                FROM DNSAPrecallRecipient__mdt
                WHERE Active__c = true
            ];

            Set<String> emailIds = new Set<String>();
            for(DNSAPrecallRecipient__mdt emailObj : emailCCList) {
                emailIds.add(emailObj.Email__c);
            }

            // Email 생성
            for (String singleEmail : emailToEquipmentMap.keySet()) {
                List<CampaignAsset__c> equipmentList = emailToEquipmentMap.get(singleEmail);
                for(CampaignAsset__c updateCA : equipmentList) {
                    if (!processedIds.contains(updateCA.Id)) { // 중복 방지
                        updateCA.EmailType__c   = obj.Pre__c == 'Pre-call' ? 'Pre-Call Request' : 'Missing Part Request';
                        updateCA.EmailStatus__c = 'Send';
                        updateCA.SendDate__c    = System.now().date();
                        
                        updateCAList.add(updateCA);
                        processedIds.add(updateCA.Id); // 추가된 레코드 추적
                    }
                }

                // 장비 헤더 생성
                String tableHtml = '<style>';
                tableHtml += '.equipment-table { width: 100%; border-collapse: collapse; font-family: Arial, sans-serif; }';
                tableHtml += '.equipment-table th, .equipment-table td { border: 1px solid #ccc; padding: 10px; text-align: left; }';
                tableHtml += '.equipment-table th { background-color: #eaf2f8; font-weight: bold; }';
                tableHtml += '.equipment-table tr:nth-child(even) { background-color: #fdfefe; }';
                tableHtml += '.equipment-table tr:nth-child(odd) { background-color: #f8f9f9; }';
                tableHtml += '.equipment-table th { color: #2c3e50; }';
                tableHtml += '</style>';
                tableHtml += '<table class="equipment-table">';
                tableHtml += '<thead>';
                tableHtml += '<tr>';
                tableHtml += '<th>Serial #</th>';
                tableHtml += '<th>Model Name</th>';
                tableHtml += '<th>DNSA S/O</th>';
                tableHtml += '<th>Billing Date</th>';
                tableHtml += '<th>Customer (Sales Dealer)</th>';
                tableHtml += '<th>Ship-to-Name (Customer)</th>';
                tableHtml += '</tr>';
                tableHtml += '</thead>';
                tableHtml += '<tbody>';
                
                // 장비 목록 데이터 -> 테이블 행
                for (CampaignAsset__c ca : equipmentList) {
                    tableHtml += '<tr>';
                    tableHtml += '<td>' + (ca.Equipment__r.Name != null ? ca.Equipment__r.Name : '') + '</td>'; // Serial Number
                    tableHtml += '<td>' + (ca.FM_MachineName__c != null ? ca.FM_MachineName__c : '') + '</td>'; // Model Name
                    tableHtml += '<td>' + (ca.Equipment__r.Order__r.OrderNumber != null ? ca.Equipment__r.Order__r.OrderNumber : '') + '</td>'; // DNSA Sales Order
                    tableHtml += '<td>' + (ca.Equipment__r.Order__r.BillingDate__c != null ? String.valueOf(ca.Equipment__r.Order__r.BillingDate__c) : '') + '</td>'; // Billing Date
                    tableHtml += '<td>' + (ca.Equipment__r.SoldTo__r.Name != null ? ca.Equipment__r.SoldTo__r.Name : '') + '</td>'; // Sales Dealer(Sold-to party)
                    tableHtml += '<td>' + (ca.Equipment__r.Account.Name != null ? ca.Equipment__r.Account.Name : '') + '</td>'; // Account
                    tableHtml += '</tr>';
                }

                tableHtml += '</tbody>';
                tableHtml += '</table>';

                // 부품 헤더 생성
                String partHtml = '<style>';
                partHtml += '.parts-table { width: 100%; border-collapse: collapse; font-family: Arial, sans-serif; }';
                partHtml += '.parts-table th, .parts-table td { border: 1px solid #aaa; padding: 8px; text-align: left; }';
                partHtml += '.parts-table th { background-color: #DDEBF7; font-weight: bold; }';
                partHtml += '.parts-table tr:nth-child(even) { background-color: #fdebd0; }';
                partHtml += '.parts-table tr:nth-child(odd) { background-color: #fcf3cf; }';
                partHtml += '.parts-table th { color: #2c3e50; }';
                partHtml += '</style>';
                partHtml += '<table class="parts-table">';
                partHtml += '<thead>';
                partHtml += '<tr>';
                partHtml += '<th>Part Number</th>';
                partHtml += '<th>Part Description</th>';
                partHtml += '<th>Quantity</th>';
                partHtml += '</tr>';
                partHtml += '</thead>';
                partHtml += '<tbody>';
                
                // 부품 목록 데이터 -> 테이블 행
                for (CommonPart__c cp : cpList) {
                    partHtml += '<tr>';
                    partHtml += '<td>' + (cp.PartsNo__c != null ? cp.PartsNo__c : '') + '</td>';
                    partHtml += '<td>' + (cp.FM_Name__c != null ? cp.FM_Name__c : '') + '</td>';
                    partHtml += '<td>' + (cp.Quantity__c != null ? String.valueOf(cp.Quantity__c) : '') + '</td>';
                    partHtml += '</tr>';
                }

                partHtml += '</tbody>';
                partHtml += '</table>';

                // 메일 본문 수정
                String modifiedBody = obj.MailContents__c;
                modifiedBody = modifiedBody.replace('{Equipment}', tableHtml);
                modifiedBody = modifiedBody.replace('{Parts}', partHtml);

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { singleEmail });
                if(emailIds != null) {
                    email.setCcAddresses(new List<String>(emailIds));
                }
                // email.setBccAddresses(new String[] { 'bccEmail@example.com' });
                email.setSubject(obj.EmailTitle__c);
                email.setHtmlBody(modifiedBody);
                email.setFileAttachments(attachments);
                emailList.add(email);

                // history 용 주소저장
                saveEMail.add(singleEmail);
            }

            // Email 발송
            if (!emailList.isEmpty()) {
                Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(emailList);
                List<PreCallEmailHistory__c> historyList = new List<PreCallEmailHistory__c>();
                Date sendDate = System.now().date();
                for (Integer i = 0; i < sendResults.size(); i++) {
                    Messaging.SendEmailResult result = sendResults[i];
                    String emailAddress = saveEMail[i];
                    List<CampaignAsset__c> equipmentList = emailToEquipmentMap.get(emailAddress);

                    if(result.isSuccess()) {
                        PreCallEmailHistory__c history = new PreCallEmailHistory__c();
                        history.SendDate__c       = sendDate;
                        history.SendTo__c	      = emailAddress;
                        history.EmailType__c      = obj.Pre__c == 'Pre-call' ? 'Pre-Call Request' : 'Missing Part Request';
                        history.Campaign__c       = obj.Id;
                        historyList.add(history);
                    } else {
                        System.debug('메일 발송 실패: ' + result.getErrors()[0].getMessage());
                    }
                }
                System.debug('historyList'+historyList);
                // 성공한 이메일 히스토리 저장
                if (!historyList.isEmpty()) {
                    insert historyList;
                }

                // 메일 전송 후 대상 장비 상태 업데이트
                if (!updateCAList.isEmpty()) {
                    update updateCAList;
                }

            } else {
                rw.isSuccess = false;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            rw.isSuccess = false;
        }
        return rw;
    }

    /**
    @ description       : Campaign Data 조회
    **/
    public static Campaign getCampaign(Id recordId) {
        return [SELECT Id, MailContents__c, Pre__c, EmailTitle__c FROM Campaign WHERE Id =: recordId];
    }

    /**
    @ description       : 대상장비 Data 조회
    **/
    public static List<CampaignAsset__c> getCampaignAsset(Id recordId) {
        return 
        [
            SELECT Id, Email__c, Campaign__c, Equipment__c, Equipment__r.Name, FM_MachineName__c, Equipment__r.Order__r.OrderNumber, Equipment__r.SoldTo__r.Name, Equipment__r.Order__r.BillingDate__c,
            Equipment__r.Order__r.ReqDeliveryDate_PSO__c, Equipment__r.Order__r.ServiceDealer__r.Name, Equipment__r.Account.Name, Equipment__r.Account.FM_Address__c, EmailStatus__c, Equipment__r.isBilled__c
            FROM CampaignAsset__c 
            WHERE Campaign__c =: recordId
            ORDER BY Equipment__r.Name ASC
        ];
    }

    /**
    @ description       : 등록된 공통부품 조회
    **/
    public static List<CommonPart__c> getCommonParts(Id recordId) {
        return [SELECT Id, Campaign__c, FM_ProductName__c, Quantity__c, PartsNo__c, FM_Name__c FROM CommonPart__c WHERE Campaign__c =: recordId];
    }

    /**
     * @Description
     * 	- Email Confirm get CampaignAsset List
     * @Return
     *  - List<CampaignAsset__c>
     * @author Junyeong Choi | 20250207
    **/
    @AuraEnabled
    public static List<CampaignAsset__c> getEmailCampaignAsset(List<TargetListWrapper> targetList){
        SET<Id> ids = new SET<Id>();
        for(TargetListWrapper tg : targetList) {
            ids.add(tg.tId);
        }
        System.debug('ids' + ids);
        List<CampaignAsset__c> caList = 
        [
            SELECT Id, Email__c, Campaign__c, Equipment__c, Equipment__r.Name, FM_MachineName__c, Equipment__r.Order__r.OrderNumber, Equipment__r.SoldTo__r.Name, Equipment__r.Order__r.BillingDate__c,
            Equipment__r.Order__r.ReqDeliveryDate_PSO__c, Equipment__r.Order__r.ServiceDealer__r.Name, Equipment__r.Account.Name, Equipment__r.Account.FM_Address__c, EmailStatus__c, Equipment__r.Order__r.IsBilled__c
            FROM CampaignAsset__c 
            WHERE Id = :ids
        ];
        System.debug('caList' + caList);
        for (CampaignAsset__c ca : caList) {
            for (TargetListWrapper tg : targetList) {
                if (tg.tId == ca.Id) {
                    ca.Email__c = tg.Email;
                    break;
                }
            }
        }
        update caList;
        return caList;
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
        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }

    /*
     * @Description 
     *  - DNSA Send Email Init 시 출력되는 Target Equipment List
     * 
     */ 
    public class TargetListWrapper{
        @AuraEnabled public String tId              { get; set;}
        @AuraEnabled public String SerialNumber     { get; set;}
        @AuraEnabled public String Model            { get; set;}
        @AuraEnabled public String Account          { get; set;}
        @AuraEnabled public String AccountAddress   { get; set;}
        @AuraEnabled public String Dealer           { get; set;}
        @AuraEnabled public String EmailStatus      { get; set;}
        @AuraEnabled public Date   BillingDate      { get; set;}
        @AuraEnabled public Boolean IsBilled        { get; set;}
        @AuraEnabled public String Email            { get; set;}
        
        public TargetListWrapper(){
            this.tId              = '';
            this.SerialNumber     = '';
            this.Model            = '';
            this.Account          = '';
            this.AccountAddress   = '';
            this.Dealer           = '';
            this.EmailStatus      = '';
            this.BillingDate      = null;
            this.IsBilled         = false;
            this.Email            = '';
        }
    }
}