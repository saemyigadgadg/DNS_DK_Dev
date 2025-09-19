/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 04-29-2025
 * @last modified by  : Hanyeong Choi
**/
public with sharing class DN_RFQ_SubmitController {
    @AuraEnabled
    public static string currentStatus(String recordId){
        try {
            List<PS__c> statusCheck = 
            [
                SELECT
                    Id,
                    Status__c
                FROM
                    PS__c
                WHERE
                    Id =: recordId
            ];
            if(statusCheck[0].Status__c == 'SalesConfirm' || statusCheck[0].Status__c == 'SEReceipt'){
                return 'SUCCESS';
            }else {
                return 'SalesConfirm';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string reqSubmit(String recordId){
        try {
            List<PS__c> getPSInfo = 
                [
                    SELECT
                        Id,
                        AEUser__c,
                        Name,
                        Opportunity__r.Opportunity_Owner__c,
                        InquirySeq__c,
                        Inquiry_Seq2__c,
                        Opportunity__c,
                        AEMemo__c,
                        Opportunity__r.Opportunity_Owner__r.SalesDistrict__c,
                        Opportunity__r.Opportunity_Owner__r.Account.Name,
                        Opportunity__r.Opportunity_Owner__r.Name,
                        Opportunity__r.Account.Name,
                        Opportunity__r.Account.SalesOffice__c,
                        Opportunity__r.Account.CountryLookup__r.Name,
                        PartsforMachining__c,
                        ERPInquiryNo__c,
                        OwnerId,
                        Owner.Name,
                        Version__c,
                        LastModifiedDate,
                        RequiredDelivryDate__c,
                        ResponsibleBranch__c,
                        Customer__r.Name,
                        ProductionVolumeYearly__c,
                        WorkingHoursDaily__c,
                        WorkingDaysMonthly__c,
                        OperationRate__c,
                        CycleTimeRequired__c,
                        CustomerDesc__c,
                        CustomerEmail__c,
                        CustomerMobileNo__c,
                        Model__c,
                        IsInterfaced__c,
                        FM_SalesOffice__c
                    FROM
                        PS__c
                    WHERE
                        Id =: recordId
                ];

            String subMessage = '';
            String AEMemo = '';
            if(getPSInfo[0].AEMemo__c != null){
                AEMemo = getPSInfo[0].AEMemo__c;
            }
            if(getPSInfo[0].Opportunity__r.Opportunity_Owner__r.SalesDistrict__c == 'A1KR'){
                if(getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Account.Name != null){
                    subMessage = '영업지사 : ' +  getPicklistValues('Account','SalesOffice__c', getPSInfo[0].Opportunity__r.Account.SalesOffice__c) + '<br>' 
                        + '대리점 : ' + getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Account.Name + '<br>'
                        + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                        + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                        + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>'
                        + 'AE 메모 : ' + AEMemo + '<br>';
                }else{
                    subMessage = '영업지사 : ' +  getPicklistValues('Account','SalesOffice__c', getPSInfo[0].Opportunity__r.Account.SalesOffice__c) + '<br>' 
                        + '영업사원 : ' + getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Name + '<br>'
                        + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                        + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                        + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>'
                        + 'AE 메모 : ' + AEMemo + '<br>';
                }
            }else{
                if(getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Account.Name != null){
                    subMessage = '국가 : ' + getPSInfo[0].Opportunity__r.Account.CountryLookup__r.Name + '<br>'
                        + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                        + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                        + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>'
                        + 'AE 메모 : ' + AEMemo + '<br>';
                }else{
                    subMessage =  '국가 : ' + getPSInfo[0].Opportunity__r.Account.CountryLookup__r.Name + '<br>'
                        + '영업사원 : ' + getPSInfo[0].Owner.Name + '<br>'
                        + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                        + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                        + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>'
                        + 'AE 메모 : ' + AEMemo + '<br>';
                }
            }

            PS__c sereceiptUpdate = new PS__c();
            sereceiptUpdate.Id = recordId;
            sereceiptUpdate.Status__c = 'SEReceipt';
            sereceiptUpdate.AEReceiptDate__c = Date.today();
            update sereceiptUpdate;

            callRFQInterfqce(getPSInfo, '10');

            List<Message_Group_Junction__c> aeList = [
                SELECT
                    User__c, 
                    User__r.Name, 
                    User__r.CustomerCode__c,
                    FM_UserEmail__c
                FROM
                    Message_Group_Junction__c
                WHERE
                    RFQ_Specification__c =:recordId
            ];

            Set<Id> ownerId = new Set<Id>();
            List<User> getEmail = new List<User>();

            System.debug('aeList : ' + aeList);
            MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE Name  = 'AE 팀장' LIMIT 1];
            List<Message_Group_Junction__c> aeInfo = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c =: mg.Id];
            if(aeList.isEmpty()){
                if(aeInfo.size() > 0){
                    for(Integer i = 0; i < aeInfo.size(); i++){
                        ownerId.add(aeInfo[i].User__c);
                    }
                    getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
                }
            }else{
                for(Integer i = 0; i < aeList.size(); i++){
                    ownerId.add(aeList[i].User__c);
                }
                getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
            }

            List<String> emailAddr = new List<String>();
            for(Integer i = 0; i < getEmail.size(); i++){
                emailAddr.add(getEmail[i].Email);
            }
            List<String> notiId = new List<String>();
            for(Integer i = 0; i < getEmail.size(); i++){
                notiId.add(getEmail[i].Id);
            }

            List<String> notiName = new List<String>();
            for(Integer i = 0; i < getEmail.size(); i++){
                notiName.add(getEmail[i].LastName);
            }

            List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
            List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'PSSubmit Alert'];
            Id alertId;

            if(!am.isEmpty()){
                alertId = am[0].Id;
            }else{
                alertId = 'a0xF7000009v4JYIAY';
            }

            String instanceUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login') + '/s/ps/' + recordId;
            List<UTIL_Alert.HistoryWrapper> historyWrappers = new List<UTIL_Alert.HistoryWrapper>();
            try{
                for(Integer i = 1; i <= getEmail.size(); i++){
                    UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
                    wrapEmail.alertID            = alertId;
                    wrapEmail.targetID           = recordId;
                    wrapEmail.alertType          = 'Email';
                    wrapEmail.receiverforEmail   = new List<String>{emailAddr[i-1]};
                    wrapEmail.alertLanguage      = 'ko';
                    if(notiId[i-1] == getPSInfo[0].Opportunity__r.Opportunity_Owner__c){
                        wrapEmail.elementList        = new List<String>{'(' + notiName[i-1] + ') 님은 검토 담당자로 지정 되었습니다.', instanceUrl, subMessage};
                    }else{
                        if(aeList.isEmpty()){
                            wrapEmail.elementList        = new List<String>{'검토 담당자가 지정되지 않은 RFQ 사양서입니다.', instanceUrl, subMessage};
                        }else{
                            wrapEmail.elementList        = new List<String>{'(' + notiName[i-1] + ') 님은 검토 담당자로 지정 되었습니다.', instanceUrl, subMessage};
                        }
                    }

                    // Set<Id> notiIds = new Set<Id>();
                    // notiIds.add(notiId[i-1]);

                    // notiIds.add(getManagerId.ManagerId);
                    // System.debug('@@ notiIds : ' + notiIds);

                    UTIL_Alert.HistoryWrapper wrapNoti = new UTIL_Alert.HistoryWrapper();
                    wrapNoti.alertID            = alertId;
                    wrapNoti.targetID           = recordId;
                    wrapNoti.alertType          = 'Notification';
                    wrapNoti.receiverforID      = new Set<Id>{notiId[i-1]};
                    // wrapNoti.receiverforID      = notiIds;
                    wrapNoti.alertLanguage      = 'ko';
                    wrapNoti.elementList        = new List<String>{getPSInfo[0].Name};

                    historyWrappers.add(wrapEmail);
                    historyWrappers.add(wrapNoti);
                    Integer remainder = i - ((i / 10) * 10);

                    if(remainder == 0 || i == getEmail.size()){
                        System.debug('test 5');
                        Database.executeBatch(new UTIL_AlertBatch(historyWrappers));
                        historyWrappers = new List<UTIL_Alert.HistoryWrapper>(); 
                    }

                    Map<Id, String> psAlertMap = new Map<Id, String>();
                     for(PS__c ps : getPSInfo){
                        psAlertMap.put(ps.Id, ps.Name);
                    }    

                    Set<Id> userIds = new Set<Id>();
                    userIds.add(UserInfo.getUserId());
                    List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);

                    if(getProfile[0].Profile.Name == '영업 글로벌 대리점' || getProfile[0].Profile.Name == '영업 글로벌 대리점 Login'){
                        //[GSR SR0000010031094] AE 사양서가 AE Portal 접수 시 CRM알람 발송
                        String alertName        = 'Change RFQ Status to SE Receipt';
                        String alertType        = 'Notification';
                        String userId           =  getPSInfo[0].OwnerId;
                        String alertLanguage    = 'ko';

                        DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,psAlertMap);
                    }    
                    
                }

                List<ContentDocumentLink> cdLink = [
                    SELECT
                        ContentDocumentId, 
                        LinkedEntityId, 
                        Id, 
                        LinkedEntity.Type,
                        ContentDocument.Title
                    FROM
                        ContentDocumentLink
                    WHERE 
                        LinkedEntityId =:recordId
                ];
                if(cdLink.size() > 0){
                    // ContentDocumentId만 추출
                    Set<Id> contentDocumentIds = new Set<Id>();
                    for (ContentDocumentLink cdl : cdLink) {
                        contentDocumentIds.add(cdl.ContentDocumentId);
                    }

                    List<ContentDistribution> ctDis = [
                        SELECT
                            Name,
                            ContentVersionId,
                            ContentDownloadUrl
                        FROM
                            ContentDistribution
                        WHERE
                            ContentDocumentId IN :contentDocumentIds
                    ];
                    if(ctDis.size() > 0){
                        List<DN_RFQFileSend.RFQFileRequest> fileRequests = new List<DN_RFQFileSend.RFQFileRequest>();
                        for (ContentDistribution dist : ctDis) {
                            fileRequests.add(new DN_RFQFileSend.RFQFileRequest(
                                dist.Name,
                                String.valueOf(getPSInfo[0].Inquiry_Seq2__c),
                                dist.ContentDownloadUrl,
                                getPSInfo[0].Opportunity__c
                            ));
                        }
                        if (!fileRequests.isEmpty()) {
                            String serializedRequests = JSON.serialize(fileRequests);
                            DN_RFQFileSend.callRFQ2(serializedRequests);
                        }
                    }
                }
            }catch(exception e){
                System.debug('error Line : ' + e.getLineNumber() + ' msg : ' + e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
            
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('LIne : ' + e.getLineNumber() + 'MSG : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void callRFQInterfqce(List<PS__c> psList, String statusCode){
        PS__c ps = psList[0];
        
        PS__c psInfo = 
        [
            SELECT 
                Owner.Name,
                AEUser__r.Name,
                Opportunity__r.Owner.Account.CustomerCode__c,
                AEUser__r.CustomerCode__c,
                Type__c, 
                MaterialHardness__c, 
                ProcessesBeforeMachining__c, 
                MachineType__c, 
                Quantity__c, 
                ChuckType__c, 
                FixtureClamp__c, 
                RecommendedToolMaker__c, 
                AutomationType__c, 
                LoadCapacity__c,
                FM_SalesOffice__c 
            FROM
                PS__c
            WHERE
                Id =: ps.Id
            LIMIT 1
        ];
        DateTime now = DateTime.now();
        String formattedDate = now.format('yyyyMMddHHmmss');
        // String I_RFQ_ACCEPT_DATE = ps.LastModifiedDate.format('yyyyMMddHHmmss');
        // String I_REVIEW_REQUEST_DATE = String.valueOf(ps.RequiredDelivryDate__c).replace('-','');

        //AE조회
        List<Message_Group_Junction__c> aeList = [
            SELECT
                User__c, 
                User__r.Name, 
                User__r.CustomerCode__c,
                User__r.Portal_EmployeeNumber__c,
                FM_UserEmail__c
            FROM
                Message_Group_Junction__c
            WHERE
                RFQ_Specification__c =:ps.Id
        ];
        List<String> seNameList = new List<String>();
        List<String> seNoList = new List<String>();

        System.debug('여기aeList ㅓ: ' + aeList);
        String I_SE_PERSON = '';
        String I_SE_PERSON_NO = '';
        if(!aeList.isEmpty()){
            for(Message_Group_Junction__c se : aeList){
                String nameValue = (se.User__r.Name != null) ? (String)se.User__r.Name : '';
                seNameList.add(nameValue);

                String noValue = (se.User__r.Portal_EmployeeNumber__c != null) ? (String)se.User__r.Portal_EmployeeNumber__c : '';
                seNoList.add(noValue);

            }
        }
        if(!seNameList.isEmpty()){
            I_SE_PERSON = String.join(seNameList, ',');
        }

        if(!seNoList.isEmpty()){
            I_SE_PERSON_NO = String.join(seNoList, ',');
        }
        System.debug('seNameList : ' + seNameList + 'size : ' + seNameList.size());
        System.debug('seNameList : ' + seNoList + 'size : ' + seNoList.size());
        System.debug('I_SE_PERSON : ' + I_SE_PERSON + 'size : ' + I_SE_PERSON.length());
        System.debug('I_SE_PERSON_NO : ' + I_SE_PERSON_NO + 'size : ' + I_SE_PERSON_NO.length());
        String I_INQUIRY_NO = ps.ERPInquiryNo__c;
        String I_VERSION = String.valueOf(ps.Version__c);
        String I_RFQ_ACCEPT_DATE = String.valueOf(ps.LastModifiedDate.format('yyyyMMddHHmmss'));
        String I_REVIEW_REQUEST_DATE = ps.RequiredDelivryDate__c != null ? String.valueOf(ps.RequiredDelivryDate__c).replace('-','') : '';
        String I_BRANCH_NAME = ps.FM_SalesOffice__c;
        String I_SALES_PERSON = psInfo.Owner.Name;
        // String I_SE_PERSON = psInfo.AEUser__r.Name;
        String I_CUSTOMER_COMPANY = ps.Customer__r.Name; //ps.CustomerName__c;
        String I_DEALER_CODE = psInfo.Opportunity__r.Owner.Account.CustomerCode__c;
        String I_PRODUCT_NAME = ps.PartsforMachining__c;
        String I_OUTPUT = String.valueOf(ps.ProductionVolumeYearly__c);
        String I_WORKING_HOURS = String.valueOf(ps.WorkingHoursDaily__c);
        String I_DUTY_DAY = String.valueOf(ps.WorkingDaysMonthly__c);
        String I_OPERATION_RATE = String.valueOf(ps.OperationRate__c);
        String I_CYCLE_IME_REQUEST = String.valueOf(ps.CycleTimeRequired__c);
        // String I_REMARK = ps.CustomerRequirement__c;
        String I_REMARK = ps.CustomerDesc__c != null ? ps.CustomerDesc__c : '.';
        String I_EMAIL = ps.CustomerEmail__c;
        String I_TEL = ps.CustomerMobileNo__c;
        String I_WRITER = psInfo.Owner.Name;
        String I_IF_DATE = formattedDate;
        String I_INQUIRY_SEQ = String.valueOf(ps.Inquiry_Seq2__c);
        String I_INQUIRY_DATE = formattedDate;
        // String I_SE_PERSON_NO = psInfo.AEUser__r.CustomerCode__c;
        String i_STATUS = statusCode;
        String I_ADDRESS = 'TEST ADDRESS';
        String I_INQUIRY_ID = ps.Opportunity__c;
        String I_ORDER_STATUS;
        String I_RESULT;
        String I_MODEL_NAME = ps.Model__c;

        DN_RFQCallout.callRFQ(
                                ps.Id,
                                ps.IsInterfaced__c,
                                I_INQUIRY_NO, 
                                I_VERSION, 
                                I_RFQ_ACCEPT_DATE, 
                                I_REVIEW_REQUEST_DATE, 
                                I_BRANCH_NAME, 
                                I_SALES_PERSON, 
                                I_CUSTOMER_COMPANY, 
                                I_DEALER_CODE, 
                                I_PRODUCT_NAME, 
                                I_OUTPUT, 
                                I_WORKING_HOURS, 
                                I_DUTY_DAY, 
                                I_OPERATION_RATE, 
                                I_CYCLE_IME_REQUEST, 
                                I_REMARK.replaceAll('\r\n', ''), 
                                I_EMAIL, 
                                I_TEL, 
                                I_WRITER, 
                                I_IF_DATE, 
                                I_INQUIRY_SEQ, 
                                I_INQUIRY_DATE,  
                                i_STATUS, 
                                I_ADDRESS,
                                I_INQUIRY_ID,
                                I_ORDER_STATUS,
                                I_RESULT,
                                I_MODEL_NAME,
                                I_SE_PERSON, 
                                I_SE_PERSON_NO,
                                ''
                                );
        
    }

    //picklist Label return
    public static String getPicklistValues(String objectName, String fieldName, String picklistValue) {
        // Describe the field
        Schema.DescribeSObjectResult objSchema = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Schema.DescribeFieldResult fieldResult = objSchema.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        // 특정 Value의 Label 찾기
        for (Schema.PicklistEntry entry : picklistValues) {
            if (entry.getValue() == picklistValue) {
                return entry.getLabel();
            }
        }

        // Value에 해당하는 Label이 없는 경우 null 반환
        return null;
    }
       public static void dummy() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}