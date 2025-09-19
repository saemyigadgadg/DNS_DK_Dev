/**
 * @description       : DNSA Pre-Call 에서 대상장비의 Email 이 빈칸일 시 Batch 를 통해 Sold-to 에서 담당자 메일 가져옴
**/
public without sharing class DN_DNSAPreCallEmailBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful{
    public List<SObject> start(Database.BatchableContext context){
        List<CampaignAsset__c> caList = [ SELECT Id, Equipment__c, Equipment__r.SoldTo__r.ServiceManager__c, Equipment__r.SoldTo__r.PartsManagerEmail__c,
                                            SendDate__c, EmailType__c, Campaign__r.Pre__c, Campaign__r.MailContents__c, Equipment__r.SoldTo__c,
                                            EmailStatus__c, Email__c, Campaign__c, Equipment__r.Name, FM_MachineName__c, Equipment__r.Order__r.OrderNumber, 
                                            Equipment__r.Order__r.ReqDeliveryDate_PSO__c, Equipment__r.Order__r.ServiceDealer__r.Name, Equipment__r.Account.Name, 
                                            Equipment__r.SoldTo__r.Name, Equipment__r.Account.FM_Address__c, Equipment__r.Order__r.IsBilled__c, Equipment__r.Order__r.BillingDate__c
                                        FROM CampaignAsset__c 
                                        WHERE EmailStatus__c = '' AND Email__c = ''];
        return caList;
    }

    public void execute(Database.BatchableContext context, List<SObject> scope){
        System.debug(' =============== Batch Execute ================');
        System.debug('scope.Size() : ' + scope.size());
        System.debug('scope : ' + scope);
        
        Savepoint sp;
        try {
            List<CampaignAsset__c> caList = (List<CampaignAsset__c>) scope;
            List<CampaignAsset__c> sendList = new List<CampaignAsset__c>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<String> saveEMail = new List<String>();
            List<PreCallEmailHistory__c> historyList = new List<PreCallEmailHistory__c>();

            //장비의 Sold-to party에 ServiceManager 가 Part Manager Email이 있는 대상장비만 가져오기
            for(CampaignAsset__c ca : caList) {
                if(String.isBlank(ca.Campaign__r.MailContents__c)){
                    continue;
                }
                if(String.isBlank(ca.Equipment__r.Order__r.IsBilled__c)) {
                    continue;    
                }
                String sendEmail='';
                if(!String.isBlank(ca.Equipment__r.SoldTo__r.ServiceManager__c)){
                    sendEmail += ca.Equipment__r.SoldTo__r.ServiceManager__c;
                }

                if(!String.isBlank(ca.Equipment__r.SoldTo__r.PartsManagerEmail__c)) {
                    if(!String.isBlank(sendEmail)){
                        sendEmail += ';';
                    }
                    sendEmail += ca.Equipment__r.SoldTo__r.PartsManagerEmail__c;
                }
                
                if(sendEmail != '') {
                    ca.Email__c         = sendEmail;
                    ca.EmailType__c     = ca.Campaign__r.Pre__c == 'Pre-call' ? 'Pre-Call Request' : 'Missing Part Request';
                    ca.EmailStatus__c   = 'Send';
                    ca.SendDate__c      = System.now().date();

                    sendList.add(ca);
                }
            }

            System.debug('실제 메일보낼 LIST >>'+sendList);
            if(sendList.size() == 0){
                return;
            }

            Set<Id> campaignIds = new Set<Id>();
            for(CampaignAsset__c ca : sendList) {
                campaignIds.add(ca.Campaign__c);
            }
            
            List<Campaign> campaigns = [SELECT Id, MailContents__c, Pre__c, EmailTitle__c FROM Campaign WHERE Id IN: campaignIds];
            
            List<CommonPart__c> commonParts = [SELECT Id, Campaign__c, FM_ProductName__c, Quantity__c, PartsNo__c, FM_Name__c FROM CommonPart__c WHERE Campaign__c IN: campaignIds];
            Map<Id, List<CommonPart__c>> commonPartMap = new Map<Id, List<CommonPart__c>>();
            for(CommonPart__c cp : commonParts) {
                if(!commonPartMap.containsKey(cp.Campaign__c)){
                    commonPartMap.put(cp.Campaign__c, new List<CommonPart__c>());
                }
                commonPartMap.get(cp.Campaign__c).add(cp);
            }

            // 첨부파일
            Map<Id, List<Messaging.EmailFileAttachment>> campaignAttachmentsMap = new Map<Id, List<Messaging.EmailFileAttachment>>();

            List<ContentDocumentLink> cdlList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: campaignIds];

            for (ContentDocumentLink cdl : cdlList) {
                if (!campaignAttachmentsMap.containsKey(cdl.LinkedEntityId)) {
                    campaignAttachmentsMap.put(cdl.LinkedEntityId, new List<Messaging.EmailFileAttachment>());
                }
            
                List<ContentVersion> cvList = [
                    SELECT Id, Title, ContentSize, ContentDocumentId, FileExtension, CreatedDate, VersionData
                    FROM ContentVersion
                    WHERE ContentDocumentId = :cdl.ContentDocumentId
                ];
            
                for (ContentVersion cv : cvList) {
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(cv.Title + '.' + cv.FileExtension);
                    attachment.setBody(cv.VersionData);
                    campaignAttachmentsMap.get(cdl.LinkedEntityId).add(attachment);
                }
            }

            // Email 발송 준비 및 히스토리 저장
            for(Campaign obj : campaigns) {
                List<CommonPart__c> cpList = commonPartMap.get(obj.Id); 

                Map<String, List<CampaignAsset__c>> emailToEquipmentMap = new Map<String, List<CampaignAsset__c>>();

                for(CampaignAsset__c ca : sendList) {
                    List<String> tmpMail = ca.Email__c.split('[,;]');
                    for(String emailStr : tmpMail) {
                        if(!emailToEquipmentMap.containsKey(emailStr)) {
                            emailToEquipmentMap.put(emailStr, new List<CampaignAsset__c>());
                        }
                        emailToEquipmentMap.get(emailStr).add(ca);
                    }
                }

                for(String singleEmail : emailToEquipmentMap.keySet()) {
                    Set<Id> processedIds = new Set<Id>(); // 이미 추가된 레코드 추적
                    List<CampaignAsset__c> equipmentList = emailToEquipmentMap.get(singleEmail);
                    
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
                        tableHtml += '<td>' + (ca.Equipment__r.Name != null ? ca.Equipment__r.Name : '') + '</td>';
                        tableHtml += '<td>' + (ca.FM_MachineName__c != null ? ca.FM_MachineName__c : '') + '</td>';
                        tableHtml += '<td>' + (ca.Equipment__r.Order__r.OrderNumber != null ? ca.Equipment__r.Order__r.OrderNumber : '') + '</td>';
                        tableHtml += '<td>' + (ca.Equipment__r.Order__r.BillingDate__c != null ? String.valueOf(ca.Equipment__r.Order__r.BillingDate__c) : '') + '</td>'; // Billing Date
                        tableHtml += '<td>' + (ca.Equipment__r.SoldTo__r.Name != null ? ca.Equipment__r.SoldTo__r.Name : '') + '</td>'; // Sales Dealer(Sold-to party)
                        tableHtml += '<td>' + (ca.Equipment__r.Account.Name != null ? ca.Equipment__r.Account.Name : '') + '</td>';
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

                    String modifiedBody = obj.MailContents__c;
                    modifiedBody = modifiedBody.replace('{Equipment}', tableHtml);
                    modifiedBody = modifiedBody.replace('{Parts}', partHtml);

                    // 이메일 객체 설정
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] { singleEmail });
                    email.setSubject(obj.EmailTitle__c);
                    email.setHtmlBody(modifiedBody);

                    // 첨부 파일 추가
                    if(campaignAttachmentsMap.containsKey(obj.Id)){
                        for(Messaging.EmailFileAttachment attachment : campaignAttachmentsMap.get(obj.Id)){
                            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                        }
                    }
                    emailList.add(email);

                    // 히스토리
                    Date sendDate = System.now().date();
                    for(CampaignAsset__c ca : equipmentList) {
                        if(!processedIds.contains(ca.Id)){
                            PreCallEmailHistory__c history = new PreCallEmailHistory__c();
                            history.SendDate__c       = sendDate;
                            history.SendTo__c	      = singleEmail;
                            history.EmailType__c      = obj.Pre__c == 'Pre-call' ? 'Pre-Call Request' : 'Missing Part Request';
                            history.Campaign__c       = obj.Id;
                            historyList.add(history);
                            processedIds.add(ca.Id);
                        }
                    }
                }

            }

            // 이메일 발송
            if(!emailList.isEmpty()) {
                Messaging.sendEmail(emailList);
            }

            // 대상장비 업데이트
            update sendList;

            // 히스토리 저장
            insert historyList;
        }
        catch(Exception ex) {
            System.debug('ERROR: ' + ex.getMessage());
            Database.rollback(sp);
        }
    }


    public void finish(Database.BatchableContext context){
        System.debug('배치실행완료');
    }

    public void execute(SchedulableContext sc) {
        DN_DNSAPreCallEmailBatch batch = new DN_DNSAPreCallEmailBatch();
        Database.executeBatch(batch, 200);
    }
}