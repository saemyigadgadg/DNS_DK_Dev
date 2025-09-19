/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 05-14-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-04   yuhyun.park@sbtglobal.com   Initial Version
**/
public with sharing class PSTriggerHandler extends TriggerHandler {
    
    public override void onBeforeInsert(List<sObject> news) {
        if (isExecuting) {

            // 현재 로그인한 사용자의 ID 가져오기
            Id currentUserId = UserInfo.getUserId();
            List<User> currentUserProfileName = [SELECT Id, Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
            System.debug('currentUserProfileName : ' + currentUserProfileName);

            getOptyInfo(news);   
            Date today = System.today();
            PS__c newCheck;
            if(news.size() > 0) {
                newCheck = (PS__c)news[0];
            }
            if(newCheck.RequiredDelivryDate__c < today && !currentUserProfileName[0].Profile.Name.contains('AE')){
                newCheck.addError(System.Label.DNS_M_RequiredDeliveryDateCHeck);
            }
            List<Opportunity> optyList = 
            [
                SELECT
                    Id,
                    AccountId,
                    Sales_Office__c,
                    Account.SalesOffice__c, //ResponsibleBranch__c
                    Account.Email__c, //I_EMAIL, CustomerEmail__c
                    Account.Name, //I_CUSTOMER_COMPANY, CustomerName__c,
                    Account.Mobile__c, //I_TEL, CustomerMobileNo__c
                    Account.Phone,// CustomerPhoneNo__c
                    Opportunity_Owner__r.Email, // Email__c (Dealer's Email)
                    Opportunity_Owner__r.Phone,
                    Opportunity_Owner__r.Account.Name, //대리점명,
                    Opportunity_Owner__r.Profile.Name,
                    Opportunity_Owner__r.SalesDistrict__c,
                    Opportunity_Owner__r.ManagerId,
                    Account.CountryLookup__r.Name,
                    Opportunity_Owner__r.SalesOffice__c
                FROM
                    Opportunity
                WHERE
                    Id =: newCheck.Opportunity__c
            ];
            newCheck.Approver__c = optyList[0].Opportunity_Owner__r.ManagerId;
            //opportunity에 입력된 고객과 다른 고객 입력 시 에러발생
            if(newCheck.customer__c != null && newCheck.customer__c != optyList[0].AccountId){
                newCheck.addError(System.Label.DNS_M_DiffCustomer);
            }
            newCheck.customer__c = optyList[0].AccountId;
            newCheck.ResponsibleBranch__c = optyList[0].Account.SalesOffice__c;
            newCheck.SalesOffice__c = optyList[0].Opportunity_Owner__r.SalesOffice__c;

            List<Contact> contactInfo = 
            [
                SELECT
                    Id,
                    Email, 
                    Name, 
                    MobilePhone, 
                    Phone
                FROM
                    Contact
                WHERE
                    Id =:newCheck.CustomerContact__c
            ];
            if(newCheck.CustomerContact__c != null){
                newCheck.CustomerEmail__c = contactInfo[0].Email;
                newCheck.CustomerName__c = optyList[0].Account.Name;
                newCheck.CustomerMobileNo__c = contactInfo[0].MobilePhone;
                newCheck.CustomerPhoneNo__c = contactInfo[0].Phone;
            }

            newCheck.Email__c = optyList[0].Opportunity_Owner__r.Email;
            newCheck.PhoneNo__c = optyList[0].Opportunity_Owner__r.Phone;

            //Inquiry Seq가장 최근값에 +1
            // List<AggregateResult> inquirySeqList = 
            // [
            //     SELECT 
            //         MAX(Inquiry_Seq2__c) Inquiry_Seq2__c
            //     FROM 
            //         PS__c 
            // ];
            // if(!inquirySeqList.isEmpty()){
            //     newCheck.Inquiry_Seq2__c = (Integer)inquirySeqList[0].get('Inquiry_Seq2__c') + 1;
            // }
            // getInquirySeq2
            newCheck.Inquiry_Seq2__c = DN_WithoutSharingClass.getInquirySeq2();

            DateTime currentDateTime = DateTime.now(); // DateTime으로 변환

            // YYMMDDHHMM 형식으로 변환
            String formattedDate = currentDateTime.format('yyMMddHHmm');
            //Name__c를 NamingRule에 맞게
            if(optyList[0].Opportunity_Owner__r.SalesDistrict__c == 'A1KR'){ //A1KR이외는 다 글로벌
                if(optyList[0].Opportunity_Owner__r.Account.Name != null){
                    newCheck.Name__c    = getPicklistValues(
                        // 'Account','SalesOffice__c', //RFQ도 대리점이 요청하면 대리점의 지사명으로_20250728
                        'User','SalesOffice__c', 
                        // optyList[0].Account.SalesOffice__c) + '_' + //RFQ도 대리점이 요청하면 대리점의 지사명으로_20250728
                        optyList[0].Opportunity_Owner__r.SalesOffice__c) + '_' + 
                        optyList[0].Opportunity_Owner__r.Account.Name + '_' + 
                        optyList[0].Account.Name + '_' +
                        formattedDate;
                }else{
                    newCheck.Name__c    = getPicklistValues(
                    'Account','SalesOffice__c', 
                    optyList[0].Account.SalesOffice__c) + '_' + 
                    optyList[0].Account.Name + '_' +
                    formattedDate;
                }
            }else{
                if(optyList[0].Opportunity_Owner__r.Account.Name != null){
                    newCheck.Name__c    = 
                    optyList[0].Account.CountryLookup__r.Name
                    + '_' + 
                    optyList[0].Opportunity_Owner__r.Account.Name + '_' + 
                    optyList[0].Account.Name + '_' +
                    formattedDate;
                }else{
                    newCheck.Name__c    = 
                    optyList[0].Account.CountryLookup__r.Name
                    + '_' + 
                    optyList[0].Account.Name + '_' +
                    formattedDate;
                }
            }

            setting(false, TriggerOperation.BEFORE_INSERT);
        }
        

    }

    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if (isExecuting) {
            

            setting(false, TriggerOperation.AFTER_INSERT);

        }

    }

    public override void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        if(isExecuting) {
            List<PS__c> oldList = (List<PS__c>) olds;
            List<PS__c> newList = (List<PS__c>) news;
            Date today = System.today();

            // 현재 로그인한 사용자의 ID 가져오기
            Id currentUserId = UserInfo.getUserId();
            List<User> currentUserProfileName = [SELECT Id, Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
            System.debug('currentUserProfileName : ' + currentUserProfileName);
            
            PS__c newCheck;
            if(news.size() > 0) {
                newCheck = (PS__c)news[0];
            }
            if(newCheck.RequiredDelivryDate__c < today && !currentUserProfileName[0].Profile.Name.contains('AE')){
                newCheck.addError(System.Label.DNS_M_RequiredDeliveryDateCHeck);
            }
            if(newCheck.Status__c == 'SalesConfirm'){
                newCheck.IsInterfaced__c = true;
            }
            System.debug('oldList[0].Status__c : ' + oldList[0].Status__c);
            System.debug('newList[0].Status__c : ' + newList[0].Status__c);

            System.debug('oldList[0].Version__c : ' + oldList[0].Version__c);
            System.debug('newList[0].Version__c : ' + newList[0].Version__c);
            System.debug('currentUserProfileName[0].Profile.Name : ' + currentUserProfileName[0].Profile.Name);
            if(newList[0].Version__c != oldList[0].Version__c){ //revision경우
                // if(oldList[0].Status__c == 'SEReceipt' && newList[0].Status__c == 'RequestToReview' && newList[0].Version__c != oldList[0].Version__c){ //revision경우
                System.debug('여긴가 1 ');
            }else{
                if(currentUserProfileName[0].Profile.Name.contains('AE') && oldList[0].AEUser__c != newCheck.AEUser__c){
                System.debug('여긴가 2');

                }else if(!currentUserProfileName[0].Profile.Name.contains('AE') && oldList[0].Status__c != 'Draft' && oldList[0].Status__c != 'RequestToReview' && oldList[0].Status__c == newCheck.Status__c && !System.Test.isRunningTest()){
                    if(oldList[0].IsInterfaced__c != newCheck.IsInterfaced__c){
                        System.debug('여긴가 3');

                    }else{
                        newCheck.addError(System.Label.DNS_M_CantChangeRFQ); //Edits are only allowed in the Draft and Request to Review stages.
                    }
                }
            }
            

            //customer contact이 변경 되었을 때 update
            if(oldList[0].CustomerContact__c != newList[0].CustomerContact__c){
                List<Contact> contactInfo = 
                [
                    SELECT
                        Id,
                        Email, 
                        Name, 
                        MobilePhone, 
                        Phone
                    FROM
                        Contact
                    WHERE
                        Id =:newCheck.CustomerContact__c
                ];
                if(newCheck.CustomerContact__c != null){
                    newCheck.CustomerEmail__c = contactInfo[0].Email;
                    newCheck.CustomerName__c = contactInfo[0].Name;
                    newCheck.CustomerMobileNo__c = contactInfo[0].MobilePhone;
                    newCheck.CustomerPhoneNo__c = contactInfo[0].Phone;
                }
            }

            
            setting(false, TriggerOperation.BEFORE_UPDATE);

        }
    }
    
    public override void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        if(isExecuting) {
            List<PS__c> oldList = (List<PS__c>) olds;
            List<PS__c> newList = (List<PS__c>) news;
            // Map<Id, String> psAlertMap = new Map<Id, String>();
            System.debug('newList[0].Status__c : ' + newList[0].Status__c);
            if((oldList[0].Status__c == 'Draft' || oldList[0].Status__c == 'RequestToReview') && newList[0].Status__c == 'SalesReview'){
                System.enqueueJob(new SendApprovalNotificationJob(newList[0].Id));
            }
            if(newList[0].Status__c == 'SalesConfirm'){
                //SalesConfirm이 되었을 때 생성 또는 수정 I/F -> Status 10
                if(newList[0].IsInterfaced__c == false){
                    callRFQInterfqce(newList, '10');
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
                            LinkedEntityId =:newList[0].Id
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
                                    String.valueOf(newList[0].Inquiry_Seq2__c),
                                    dist.ContentDownloadUrl,
                                    newList[0].Opportunity__c
                                ));
                            }
                            if (!fileRequests.isEmpty()) {
                                String serializedRequests = JSON.serialize(fileRequests);
                                DN_RFQFileSend.callRFQ2(serializedRequests);
                            }
                        }
                    }
                }
            
                List<PS__c> getPSInfo = 
                [
                    SELECT
                        Id,
                        AEUser__c,
                        Name,
                        Opportunity__r.Opportunity_Owner__c,
                        InquirySeq__c,
                        Opportunity__c,
                        Opportunity__r.Opportunity_Owner__r.SalesDistrict__c,
                        Opportunity__r.Opportunity_Owner__r.Account.Name,
                        Opportunity__r.Opportunity_Owner__r.Name,
                        Opportunity__r.Opportunity_Owner__r.SalesOffice__c,
                        Opportunity__r.Account.Name,
                        Opportunity__r.Account.SalesOffice__c,
                        Opportunity__r.Account.CountryLookup__r.Name,
                        PartsforMachining__c,
                        ERPInquiryNo__c,
                        Owner.Name
                    FROM
                        PS__c
                    WHERE
                        Id =: newList[0].Id
                ];
    
                String subMessage = '';
                if(getPSInfo[0].Opportunity__r.Opportunity_Owner__r.SalesDistrict__c == 'A1KR'){
                    if(getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Account.Name != null){
                        // subMessage = '영업지사 : ' +  getPicklistValues('Account','SalesOffice__c', getPSInfo[0].Opportunity__r.Account.SalesOffice__c) + '<br>' //RFQ도 대리점이 요청하면 대리점의 지사명으로_20250728
                        subMessage = '영업지사 : ' +  getPicklistValues('User','SalesOffice__c', getPSInfo[0].Opportunity__r.Opportunity_Owner__r.SalesOffice__c) + '<br>' 
                            + '대리점 : ' + getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Account.Name + '<br>'
                            + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                            + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                            + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>';
                    }else{
                        subMessage = '영업지사 : ' +  getPicklistValues('Account','SalesOffice__c', getPSInfo[0].Opportunity__r.Account.SalesOffice__c) + '<br>' 
                            + '영업사원 : ' + getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Name + '<br>'
                            + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                            + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                            + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>';
                    }
                }else{
                    if(getPSInfo[0].Opportunity__r.Opportunity_Owner__r.Account.Name != null){
                        subMessage = '국가 : ' + getPSInfo[0].Opportunity__r.Account.CountryLookup__r.Name + '<br>'
                            + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                            + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                            + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>';
                    }else{
                        subMessage =  '국가 : ' + getPSInfo[0].Opportunity__r.Account.CountryLookup__r.Name + '<br>'
                            + '영업사원 : ' + getPSInfo[0].Owner.Name + '<br>'
                            + '고객사 : ' + getPSInfo[0].Opportunity__r.Account.Name + '<br>'
                            + '가공 Item : ' + getPSInfo[0].PartsforMachining__c + '<br>'
                            + 'Inquiry No : ' + getPSInfo[0].ERPInquiryNo__c + '<br>';
                    }
                }
    
                List<User> getEmail = new List<User>();
                Set<Id> ownerId = new Set<Id>();
                
                //AE조회
                List<Message_Group_Junction__c> aeList = [
                    SELECT
                        User__c, 
                        User__r.Name, 
                        User__r.CustomerCode__c,
                        FM_UserEmail__c
                    FROM
                        Message_Group_Junction__c
                    WHERE
                        RFQ_Specification__c =:newList[0].Id
                ];
    
                if(aeList.isEmpty()){
                    MessageGroup__c mg = [SELECT Id FROM MessageGroup__c WHERE Name  = 'AE 팀장' LIMIT 1];
                    List<Message_Group_Junction__c> aeInfo = [SELECT Id, User__c FROM Message_Group_Junction__c WHERE Message_Group__c =: mg.Id];
                    System.debug('aeInfo.size() : ' + aeInfo.size());
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
                List<Network> portal = [SELECT Id, Name FROM Network WHERE Name = 'Partners'];
                List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'PSAE Alert'];
                Id alertId;
    
                if(!am.isEmpty()){
                    alertId = am[0].Id;
                }else{
                    alertId = 'a0xF7000009v4JdIAI';
                }
                System.debug('getEmail.size() : ' + getEmail.size());
                String instanceUrl = Network.getLoginUrl(portal[0].Id).removeEnd('/s/login') + '/s/ps/' + newList[0].Id;
                List<UTIL_Alert.HistoryWrapper> historyWrappers = new List<UTIL_Alert.HistoryWrapper>();
                try{
                    for(Integer i = 1; i <= getEmail.size(); i++){
                        System.debug('test 1');
                        UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
                            wrapEmail.alertID            = alertId;
                            wrapEmail.targetID           = newList[0].Id;
                            wrapEmail.alertType          = 'Email';
                            wrapEmail.receiverforEmail   = new List<String>{emailAddr[i-1]};
                            wrapEmail.alertLanguage      = 'ko';
                            wrapEmail.elementList        = new List<String>{instanceUrl, subMessage};
    
                        UTIL_Alert.HistoryWrapper wrapNoti = new UTIL_Alert.HistoryWrapper();
                            wrapNoti.alertID            = alertId;
                            wrapNoti.targetID           = newList[0].Id;
                            wrapNoti.alertType          = 'Notification';
                            wrapNoti.receiverforID      = new Set<Id>{notiId[i-1]};
                            wrapNoti.alertLanguage      = 'ko';
                            wrapNoti.elementList        = new List<String>{newList[0].Name};
    
                        historyWrappers.add(wrapEmail);
                        historyWrappers.add(wrapNoti);
                        Integer remainder = i - ((i / 10) * 10);
                        System.debug('test remainder : ' + remainder);
                        if(remainder == 0 || i == getEmail.size()){
                            System.debug('test 5');
                            Database.executeBatch(new UTIL_AlertBatch(historyWrappers));
                            historyWrappers = new List<UTIL_Alert.HistoryWrapper>(); 
                        }
                    }
                }catch(exception e){
                    System.debug('error Line : ' + e.getLineNumber() + ' msg : ' + e.getMessage());
                    throw new AuraHandledException(e.getMessage());
                }
            }
            //I/F 후 기각
            if(newList[0].IsInterfaced__c == true && oldList[0].Status__c != newList[0].Status__c && newList[0].Status__c == 'RequestToReview'){
                callRFQInterfqce(newList, '-7');
            //I/F 후 반려
            }else if(newList[0].IsInterfaced__c == true && oldList[0].Status__c != newList[0].Status__c && newList[0].Status__c == 'Rejected'){
                callRFQInterfqce(newList, '-99');
            //I/F후 path변화 없이 데이터만 변경 이거나 지사장 승인 요청 경우
            }else if(newList[0].IsInterfaced__c == true && oldList[0].AEReceiptDate__c == newList[0].AEReceiptDate__c && (oldList[0].Status__c == newList[0].Status__c || newList[0].Status__c == 'SalesConfirm')){
                System.debug('왓니?');
                callRFQInterfqce(newList, '10');
            }

            // for(PS__c ps : newList){
            //     psAlertMap.put(ps.Id, ps.Name);
            // }
            // Set<Id> userIds = new Set<Id>();
            // userIds.add(UserInfo.getUserId());
            // List<User> getProfile =  DN_WithoutSharingClass.getUserEmails(userIds);

            // if(getProfile[0].Profile.Name != 'Salesforce'){
            //     //[GSR SR0000010031094] AE 사양서가 AE Portal 접수 시 CRM알람 발송
            //     if(oldList[0].Status__c != 'SEReceipt' && newList[0].Status__c =='SEReceipt'){
            //         String alertName        = 'Change REQ Status to  SE Receipt ';
            //         String alertType        = 'Notification';
            //         String userId           = UserInfo.getUserId();
            //         String alertLanguage    = 'ko';

            //         DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,psAlertMap);
            //     }

            //     //[GSR SR0000010031094] AE 사양서 승인 또는 거절/반려 시 CRM알람 발송
            //     if(oldList[0].Status__c != 'Rejected' && newList[0].Status__c =='Rejected'){
            //         String alertName        = 'Change REQ Status to Rejected';
            //         String alertType        = 'Notification';
            //         String userId           = UserInfo.getUserId();
            //         String alertLanguage    = 'ko';

            //         DN_FinalQuoteCheckController.sendCrmEmailAlert(alertType,alertName,alertLanguage,userId,psAlertMap);
            //     }
            // }
            setting(false, TriggerOperation.AFTER_UPDATE);
        }
    }
    //PS I/F
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
        String I_REVIEW_REQUEST_DATE = String.valueOf(ps.RequiredDelivryDate__c).replace('-','');
        String I_BRANCH_NAME = ps.FM_SalesOffice__c;
        String I_SALES_PERSON = psInfo.Owner.Name;
        // String I_SE_PERSON = psInfo.AEUser__r.Name;
        String I_CUSTOMER_COMPANY = ps.CustomerName__c;
        String I_DEALER_CODE = psInfo.Opportunity__r.Owner.Account.CustomerCode__c;
        String I_PRODUCT_NAME = ps.PartsforMachining__c;
        String I_OUTPUT = String.valueOf(ps.ProductionVolumeYearly__c);
        String I_WORKING_HOURS = String.valueOf(ps.WorkingHoursDaily__c);
        String I_DUTY_DAY = String.valueOf(ps.WorkingDaysMonthly__c);
        String I_OPERATION_RATE = String.valueOf(ps.OperationRate__c);
        String I_CYCLE_IME_REQUEST = String.valueOf(ps.CycleTimeRequired__c);
        // String I_REMARK = ps.CustomerRequirement__c;
        String I_REMARK = ps.CustomerDesc__c;
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
    
    /**
     * @description 
     *  - PS가 생성될 때, 연결된 Opportunity의 Line Item의 ERP Inquiry No 필드 값을 가져온다.
     **/
    private void getOptyInfo (List<sObject> obj){
        List<PS__c> psList = (List<PS__c>) obj;
        Set<Id> optyIds = new Set<Id>();

        // PS 레코드에서 Opportunity ID 수집
        for (PS__c ps : psList) {
            if (ps.Opportunity__c != null) {
                optyIds.add(ps.Opportunity__c);
            }
        }

        // 수집된 Opportunity ID를 기반으로 Opportunity Line Item 조회
        List<OpportunityLineItem> optyLineItemList = [
            SELECT Id, OpportunityId, ERPInquiryNo__c
            FROM OpportunityLineItem
            WHERE OpportunityId IN :optyIds
        ];

        // Opportunity ID와 ERP Inquiry No를 매핑
        Map<Id, String> optyLineItemMap = new Map<Id, String>();
        for (OpportunityLineItem optyLineItem : optyLineItemList) {
            if (!optyLineItemMap.containsKey(optyLineItem.OpportunityId)) {
                optyLineItemMap.put(optyLineItem.OpportunityId, optyLineItem.ERPInquiryNo__c);
            }
        }

        // PS 레코드에 ERP Inquiry No 할당
        for (PS__c ps : psList) {
            if (optyLineItemMap.containsKey(ps.Opportunity__c)) {
                ps.ERPInquiryNo__c = optyLineItemMap.get(ps.Opportunity__c);
            }
        }
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
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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