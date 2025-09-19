/**
* @Class : EmailMessageTriggerHandler
*
* @Author : Hayeong, Min
* @Date : 2024. 11. 29.
* @Version : 1.0
* @Modified : 2024. 11. 29.
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-29 | Hayeong, Min   | 최초작성
*
*/
public with sharing class EmailMessageTriggerHandler extends TriggerHandler{

    /**
     * @Description
     * 	- EmailMessage Before Insert
     * @author Hayeong Min | 2024-11-29
    **/
    public override void onBeforeInsert(List<sObject> news){
        if(isExecuting){

            System.debug('EmailMessageTriggerHandler onBeforeInsert');

            List<EmailMessage> emailList = (List<EmailMessage>) news;

            EmailServicesAddress esa = [SELECT DeveloperName, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE Function.FunctionName = 'EmailService' LIMIT 1];
            String emailServiceCC = esa.LocalPart + '@' + esa.EmailDomainName;
            
            Set<Id> caseIDs = new Set<Id>();
            for(EmailMessage obj : emailList){
                if(String.isNotEmpty(obj.ParentId) && String.isEmpty(obj.EmailRoutingAddressId)){
                    String type = obj.ParentId.getSObjectType().getDescribe().getName();
                    System.debug('type ::: ' + type);
                    if(type == 'Case'){
                        System.debug('obj.CcAddress ::: ' + obj.CcAddress);

                        if (String.isNotEmpty(obj.CcAddress)) {
                            List<String> ccList = obj.CcAddress.split(',');
                            if (!ccList.contains(emailServiceCC)) {
                                ccList.add(emailServiceCC);
                            }
                            obj.CcAddress = String.join(ccList, ',');
                        } else {
                            obj.CcAddress = emailServiceCC + ',';
                        }
                    }
                }

                if(String.isNotEmpty(obj.ParentId) && obj.Incoming == FALSE){
                    caseIDs.add(obj.ParentId);
                }
            }

            //DNSA 이메일 접수로 생성된 Ticket의 Relpy일 때 Subject에 Ticket 번호 넣기
            if(caseIDs.size()>0){
                List<Case> ticketList = [SELECT Id, Origin, CaseNumber, Asset.Name, Account.Name, ReceptionDetails__c FROM Case WHERE ID IN : caseIDs];
                Map<Id, Case> caseMap = new Map<Id, Case>();
                for(Case c : ticketList){
                    if(c.Origin == 'DNSA_Email'){
                        caseMap.put(c.Id, c);
                    }
                }
                
                for(EmailMessage obj : emailList){
                    if(caseMap.containsKey(obj.ParentId)){
                        Case ticket = caseMap.get(obj.ParentId);
                        String title = '[' + ticket.CaseNumber + ']['+ ticket.Asset.Name +'][' + ticket.Account.Name + ']'+ticket.ReceptionDetails__c;
                        obj.Subject = title;
                    }
                }
            }            
        }
    }
    
    /**
     * @Description
     * 	- EmailMessage After Insert
     * @author Hayeong Min | 2024-11-29
    **/
    public override void onAfterInsert(List<sObject> news, Map<Id, sObject> newMap){
        if(isExecuting){
            System.debug('EmailMessageTriggerHandler onAfterInsert');
            List<EmailMessage> emailList = (List<EmailMessage>) news;

            //1. HomePage를 통해 접수되는 Ticket Update
            Set<Id> caseIds = new Set<Id>();
            Set<Id> emIds = new Set<Id>();
            //Case RecordType
            String dns_ticket = [SELECT Id FROM RecordType WHERE SobjectType  = 'Case' AND DeveloperName = 'Ticket_Domestic'].Id;
            String dns_voc = [SELECT Id FROM RecordType WHERE SobjectType  = 'Case' AND DeveloperName = 'VOC_Domestic'].Id;
            // String dnsa_ticket = [SELECT Id FROM RecordType WHERE SobjectType  = 'Case' AND DeveloperName = 'Ticket_DNSA'].Id;

            for(EmailMessage obj : emailList){

                //ParenId에는 CaseId가 기입된다. Incoming = true여야 함
                //Email-to-Case로 진행되었을 때는 EmailRoutingAddressId가 기입된다.
                if(String.isNotEmpty(obj.ParentId) && String.isNotEmpty(obj.EmailRoutingAddressId)){
                    caseIds.add(obj.ParentId);
                    emIds.add(obj.Id);
                }
            }

            System.debug('@@ caseIds : '+caseIds);
            List<EmailMessage> emList = [SELECT Id, ParentId, Subject, EmailRoutingAddressId, EmailRoutingAddress.Address, ToAddress FROM EmailMessage WHERE Id IN :emIds];
            if(caseIds.size()>0){
                System.debug('@@ emList :: ' +emList);
                
                Map<Id, String> countryMap = new Map<Id, String>();
                //Set<Id> dnsa_Email = new Set<Id>();
                Map<Id, String> dnsa_Email = new Map<Id, String>();
                Map<Id, String> dnsa_EmailSubject = new Map<Id, String>(); 
                Set<String> equipNums = new Set<String>();


                for(EmailMessage e : emList){
                    if(e.EmailRoutingAddress.Address == 'cs.dnsawebinq@dncompany.com'){
                        countryMap.put(e.ParentId, 'DNSA');
                    }else if(e.EmailRoutingAddress.Address == 'cs.dnswebinq@dncompany.com'){
                        countryMap.put(e.ParentId, 'DNS');
                    }else if(e.EmailRoutingAddress.Address == 'cs.dnsacrm@dncompany.com'){
                        //System.debug('@@ e.subject :: '+ e.Subject);
                        String title = e.Subject;
                        String cleanTitle = title.toUpperCase().replaceAll(' ', '');
						cleanTitle = cleanTitle.replaceAll('^RE:|^FW:', '');
                        
                        System.debug('@@ cleanTitle : ' + cleanTitle);
                        //if(String.isNotEmpty(e.Subject) && title.replaceAll(' ', '').left(1) == '['){
                        //if(String.isNotEmpty(e.Subject) && cleanTitle.left(1) == '['){
                        if(String.isNotEmpty(e.Subject)){
                            Pattern regex = Pattern.compile('\\[(.*?)\\]');
                            Matcher matcher = regex.matcher(title);
                            
                            if(matcher.find()) {
                                String extractedValue = matcher.group(1); // [] 안의 값
                                System.debug('@@ extractedValue : ' + extractedValue);
                                
                                dnsa_Email.put(e.ParentId, extractedValue);
                                equipNums.add(extractedValue.toLowerCase()); //소문자포함
                                
                                // ']' 이후 문자열 자르기
                                Integer idx = title.indexOf(']');
                                if(idx != -1 && idx < title.length()-1){
                                    dnsa_EmailSubject.put(e.ParentId, title.substring(idx+1).trim());
                                }
                            }
                        }
                    }             
                }

                System.debug('@@ dnsa_Email : ' + dnsa_Email);
                System.debug('@@ equipNums : ' + equipNums);
                //DNSA Email 접수
                if(!dnsa_Email.isEmpty()){
                    System.debug('@@ dnsa_Email.keySet() : ' + dnsa_Email.keySet());
                    List<Case> emailTicket = [SELECT Id, Status, ReceptionPath__c, AccountId, ContactId, Dealer__c, DealerContact__c, OwnerId , FM_RecordType__c, FM_TicketName__c FROM Case WHERE ID IN :dnsa_Email.keySet()];
                    //List<Asset> equipList = [SELECT Id, Name, AccountId, Account.Name FROM Asset WHERE SerialNumber != null AND Name IN :equipNums];
                    List<Asset> equipList = [SELECT Id, Name, AccountId, Account.Name FROM Asset WHERE SerialNumber != null AND lowerToName__c IN :equipNums]; //소문자포함
                    Map<String, Asset> equipMap = new Map<String, Asset>();

                    Id teamRoleId = [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'ETC'].Id;
                    CS_Util.AssignmentWrapper dnsaTicketTeam = setOwnerSequential('DNSA_TicketTeam', 1);
                    List<CaseTeamMember> csMem = new List<CaseTeamMember>();
                    
                    System.debug('@@ equipList : ' + equipList);
                    if(equipList.size()>0){
                        for(Asset eq : equipList){
                            equipMap.put(eq.Name, eq);
                        }
                        System.debug('@@ equipMap : ' + equipMap);
                        System.debug('@@ emailTicket : ' + emailTicket);

                        List<Case> updateCase = new List<Case>();
                        for(Case c : emailTicket){
                            String equipNumber = dnsa_Email.get(c.Id);
                            String upperEquipNumber = equipNumber.toUpperCase();//소문자포함
                            if(equipMap.containsKey(upperEquipNumber)){
                                c.ReceptionPath__c = 'Email';
                                c.Status = 'New';
                                
                                // System.debug('Account ID ::: '+c.AccountId);
                                // System.debug('ContactId ID ::: '+c.ContactId);
                                if(String.isNotEmpty(c.AccountId)){
                                    c.Dealer__c = c.AccountId;
                                }
                                if(String.isNotEmpty(c.ContactId)){
                                    c.DealerContact__c = c.ContactId;
                                }

                                //c.AssetId = equipMap.get(equipNumber).Id;
                                //c.AccountId = equipMap.get(equipNumber).AccountId;
                                c.AssetId = equipMap.get(upperEquipNumber).Id;	//소문자포함
                                c.AccountId = equipMap.get(upperEquipNumber).AccountId;	//소문자포함
                                c.ContactId = null;
                                c.ReceptionDetails__c = dnsa_EmailSubject.get(c.Id);

                                for(Integer i=0; i<dnsaTicketTeam.userList.size(); i++){
                                    CaseTeamMember mem = new CaseTeamMember();
                                    mem.MemberId = dnsaTicketTeam.userList[i];
                                    mem.ParentId = c.Id;
                                    mem.TeamRoleId = teamRoleId;
                                    csMem.add(mem);
                                }
                                updateCase.add(c);
                            }
                        }

                        System.debug('@@ updateCase ::: '+updateCase);
                        if(updateCase.size()>0) {
                            update updateCase;

                            Set<Id> caseNewId = new Set<id>();
                            for(Case c : updateCase){
                                caseNewId.add(c.Id);
                            }
                            List<Case> caseNewList = [SELECT Id, Status FROM Case WHERE Id IN :caseNewId AND Status = 'NEW'];
                            System.debug('@@ caseNewList : '+ caseNewList);
                
                            //티켓의 상태가 New 일 경우만  Owner에게 Ticket 배정 보내기
                            if(!caseNewList.isEmpty()){
                                
                                List<UTIL_Alert.HistoryWrapper> hwList = new List<UTIL_Alert.HistoryWrapper>();
                                List<AlertManager__c> alertManagerList = [SELECT Id, Name FROM AlertManager__c WHERE IsActive__c = TRUE AND Name = 'DNSA Ticket Assignment Alart' LIMIT 1];
                                List<String> receiver = new List<String>();

                                Set<Id> ownerIds = new Set<Id>();
                                for (Case obj : updateCase) {
                                    ownerIds.add(obj.OwnerId);
                                }

                                List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerIds);
                                    if(!getEmail.isEmpty()){
                                        // receiver.add(getEmail[0].Email); 
                                        receiver.add('wonjung.lee@dncompany.com'); 
                                }

                                Map<Id, User> ownerMap = new Map<Id, User>(
                                    [SELECT Id, Name, Email FROM User WHERE Id IN :ownerIds]
                                );

                                Set<Id> newParentIds = new Set<Id>();
                                for (Case caseList : caseNewList) {
                                    newParentIds.add(caseList.Id);
                                }
                                System.debug('@@ newParentIds : '+ newParentIds);

                                List<Case> targetCases = new List<Case>();
                                for (Case c : updateCase) {
                                    if (newParentIds.contains(c.Id)) {
                                        targetCases.add(c);
                                    }
                                }
                                System.debug('@@ targetCases : '+ targetCases);

                                for(Case obj : targetCases){
                                    User u = ownerMap.get(obj.OwnerId); // 이미 쿼리해둔 값 재활용
                                    String ownerName = (u != null) ? u.Name : 'Unknown';

                                    UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                                    notihw.alertID = alertManagerList[0].Id;
                                    notihw.targetID = obj.Id;
                                    // notihw.alertType = 'Notification';
                                    // notihw.elementList = new List<String>{obj.FM_RecordType__c +'  '+ obj.FM_TicketName__c};
                                    // notihw.receiverforID = new Set<Id>{obj.OwnerId};
                                    notihw.alertType = 'Email';
                                    notihw.elementList.add(ownerName);
                                    notihw.elementList.add(URL.getOrgDomainURL().toExternalForm() + '/' + obj.Id);
                                    notihw.receiverforEmail = receiver;
                                    notihw.alertLanguage = 'en';
                                    System.debug('notihw ::: '+notihw);
                                    hwList.add(notihw);
                                }
                                UTIL_Alert.runAlertEvent(hwList);      
                            }
                        } 
                        if(csMem.size()>0) insert csMem;
                        
                    }
                }

                if(!countryMap.isEmpty()){
                    List<Case> ticketList = [SELECT Id, RecordTypeId, RecordType.Name, Description, 
                                                ReceptionPath__c, ApplicationRoute__c, ApplicationRoute2__c,
                                                ReceptionDetails__c, OwnerId, 
                                                AssetId, Asset.Name, Status,
                                                Requester__c, TicketType__c, InternalTicketType__c, 
                                                FM_TicketName__c, FM_RecordType__c, FM_Country__c
                                                FROM Case WHERE Id IN : caseIds];
                
                    //일반상담사 순차배정
                    Integer generalCnt = 0;
                    //고객의소리는 김성엽파트장님
                    Id voc_Website = [SELECT Id FROM AssignmentRule__c WHERE Name = 'VOC_홈페이지접수'].Id;
                    CS_Util.AssignmentRequest voc_Website_assign = new CS_Util.AssignmentRequest();
                    voc_Website_assign.aID = voc_Website;
                    voc_Website_assign.size = 1;
                    CS_Util.AssignmentWrapper voc_Website_assignResult = CS_Util.getAssignmentUser(voc_Website_assign);
                    
                    Map<Id, String> contactMap = new Map<Id,String>();
                    Map<Id, String> assetMap = new Map<Id,String>();

                    Id teamRoleId = [SELECT Id, Name FROM CaseTeamRole WHERE Name = 'ETC'].Id;
                    CS_Util.AssignmentWrapper dnsaTicketTeam = setOwnerSequential('DNSA_TicketTeam', 1);
                    List<CaseTeamMember> csMem = new List<CaseTeamMember>();
                    for(Case c : ticketList){

                        EmailWrapper ew = emailWrapperCheck(c.Description);
                        //DNSA & DNS 구분
                        if(countryMap.get(c.Id) == 'DNSA'){
                            c.ReceptionDetails__c = emailReceptionDetail_DNSA(ew);
                            c.Status = 'New';

                            //250311 by Hayeong Min : DNSA 김기현 Team member 자동 추가
                            for(Integer i=0; i<dnsaTicketTeam.userList.size(); i++){
                                CaseTeamMember mem = new CaseTeamMember();
                                mem.MemberId = dnsaTicketTeam.userList[i];
                                mem.ParentId = c.Id;
                                mem.TeamRoleId = teamRoleId;
                                csMem.add(mem);
                            }
                        }else{
                            c.RecordTypeId = ew.receptionType == '고객의 소리' ? dns_voc : dns_ticket;
                            c.ReceptionDetails__c = emailReceptionDetail_DNS(ew);
                        }

                        c.ApplicationDateTime__c = System.now();
                        c.ReceptionPath__c = 'Homepage';
                        c.ApplicationRoute__c = 'Service';
                        c.ApplicationRoute2__c = 'Website';
                        c.Subject = '';
                        c.Status = ew.receptionType == '고객의 소리' ? 'Receipt' : 'New';
                        c.Phone__c = ew.phone;

                        if(ew.receptionType != '고객의 소리'){
                            c.TicketType__c = 'General inquiry';
                            c.InternalTicketType__c = 'Other inquiry';
                            if(c.RecordTypeId == dns_ticket){
                                generalCnt++;
                            }
                        }else{
                            c.OwnerId = voc_Website_assignResult.userList[0];
                        }

                        String val = ew.receptionType == '고객의 소리' ? ew.prdName : ew.srNumber;
                        assetMap.put(c.Id, val);
                        if(String.isNotEmpty(ew.phone)){
                            contactMap.put(c.Id, ew.phone);
                        }
                    }

                    insert csMem;
                    Map<Id, FieldWrapper> fwMap = getFieldInfo(assetMap, contactMap);


                    if(generalCnt > 0){
                        Id generalRuleId = [SELECT Id FROM AssignmentRule__c WHERE Name = '일반상담사 순차배정'].Id;
                        CS_Util.AssignmentRequest generalAssign = new CS_Util.AssignmentRequest();
                        generalAssign.aID = generalRuleId;
                        generalAssign.size = generalCnt;
                        CS_Util.AssignmentWrapper generalAssignResult = CS_Util.getAssignmentUser(generalAssign);
                        System.debug('generalAssignResult : '+generalAssignResult);
                        System.debug('generalCnt : '+generalCnt);
                        Integer generalNum = 0;

                        for(Case c : ticketList){
                            c.AssetId = fwMap.containsKey(c.Id) ? fwMap.get(c.Id).assetId : null;
                            c.Requester__c = fwMap.containsKey(c.Id) ? fwMap.get(c.Id).contactId : null;
                            c.AccountId = fwMap.containsKey(c.Id) ? fwMap.get(c.Id).accountId : null;

                            c.OwnerId = generalAssignResult.userList[generalNum];
                            generalNum++;
                        }
                        
                    }else{
                        for(Case c : ticketList){
                            c.AssetId = fwMap.containsKey(c.Id) ? fwMap.get(c.Id).assetId : null;
                            c.Requester__c = fwMap.containsKey(c.Id) ? fwMap.get(c.Id).contactId : null;
                            c.AccountId = fwMap.containsKey(c.Id) ? fwMap.get(c.Id).accountId : null;
                        }
                    }

                    update ticketList;
                    
                    //접수상담사 리더에게 알림 전송
                    List<UTIL_Alert.HistoryWrapper> hwList = new List<UTIL_Alert.HistoryWrapper>();
                    String homepageLeaderId = [SELECT Id FROM AlertManager__c WHERE Name = 'Homepage Ticket Assignment Receptionist Alert' AND IsActive__c = TRUE].Id;
                    NotiReceptionList__c noRecep = NotiReceptionList__c.getInstance('AlarmTalk');
                    String alarmLeaderName = noRecep.UserName__c;
                    User alarmLeader = [SELECT Id FROM User WHERE UserName =:alarmLeaderName];
                    Map<Id, UserWrapper> userInfo = getUserInfoMap();
                    for(Case c : ticketList){
                        //접수상담사 리더에게 알림 전송
                        if(c.FM_Country__c == 'DNS'){
                            UTIL_Alert.historyWrapper homepageNoti = new UTIL_Alert.historyWrapper();
                            homepageNoti.alertID = homepageLeaderId;
                            homepageNoti.targetID = c.Id;
                            homepageNoti.alertType = 'Notification';
                            homepageNoti.elementList = new List<String>{c.FM_TicketName__c, userInfo.get(c.OwnerId).Name};
                            homepageNoti.receiverforID = new Set<Id>{alarmLeader.Id};
                            homepageNoti.alertLanguage = userInfo.get(alarmLeader.Id).language;
                            System.debug('homepageNoti ::: '+homepageNoti);
                            hwList.add(homepageNoti);
                        }
                    }                
                    if(hwList.size()>0) UTIL_Alert.runAlertEvent(hwList);
                }                
            }
        }
    }

    /**
    * @description Email-to-Case로 접수된 Ticket의 Owner 배정
    * @operationtype after insert
    * @author Hayeong Min | 2025-06-17 
    * @param 
        - ruleName : 배정 Rule
        - ticketCnt : 배정해야할 Ticket 갯수
    **/
    private static CS_Util.AssignmentWrapper setOwnerSequential(String ruleName, Integer ticketCnt){
        Id ruleId = [SELECT Id FROM AssignmentRule__c WHERE Name = :ruleName].Id;
        CS_Util.AssignmentRequest assign = new CS_Util.AssignmentRequest();
        assign.aID = ruleId;
        assign.size = ticketCnt;
        CS_Util.AssignmentWrapper assignResult = CS_Util.getAssignmentUser(assign);
        return assignResult;
    }

    /**
    * @description User 정보 Map으로 반환
    * @author yeongju.yun | 2024-10-24 
    **/
    private static Map<Id, UserWrapper> getUserInfoMap(){
        List<User> users = [SELECT Id, FirstName, LastName, Email, LanguageLocaleKey FROM User WHERE IsActive = TRUE];
        Map<Id, UserWrapper> userMap = new Map<Id, UserWrapper>();
        for(User u : users){
            UserWrapper uw = new UserWrapper();
            uw.Id = String.valueOf(u.Id);
            if(u.FirstName == null){
                uw.Name = u.LastName;
            }else{
                uw.Name = u.LastName+' '+u.FirstName;
            }
            uw.Email = u.Email;
            uw.language = (u.LanguageLocaleKey == 'ko') ? 'ko' : 'en';
            userMap.put(u.Id, uw);
        }
        return userMap;
    }

    /**
    * @description 접수된 장비번호, MobilePhone 정보를 기반으로 생성된 Ticket에 장비, 요청자 정보 Mapping
    * @operationtype after insert
    * @author Hayeong Min | 2025-06-17 
    * @param 
        - assetMap : Ticket Id, Asset Name 으로 묶은 map 
        - contactMap : Ticket Id, Contact MobilePhone 으로 묶은 map 
    **/
    private static Map<Id, FieldWrapper> getFieldInfo(Map<Id, String> assetMap, Map<Id, String> contactMap){
        Map<Id, FieldWrapper> fwMap = new Map<Id, FieldWrapper>();
        // 1. Asset Name 기준으로 Asset 조회
        Map<String, Asset> assetNameToAssetMap = new Map<String, Asset>();
        if(!assetMap.isEmpty()){
            Set<String> assetNames = new Set<String>(assetMap.values());
            System.debug('assetNames : '+assetNames);
            List<Asset> assets = [SELECT Id, Name, AccountId FROM Asset WHERE Name IN :assetNames];
            
            for (Asset asset : assets) {
                assetNameToAssetMap.put(asset.Name, asset);
            }
            System.debug('assetNameToAssetMap '+assetNameToAssetMap);
        }

        // 2. MobilePhone 기준으로 Contact 조회
        Map<String, Contact> phoneToContactMap = new Map<String, Contact>();
        if(!contactMap.isEmpty()){
            Set<String> contactPhones = new Set<String>(contactMap.values());
            if(!contactPhones.isEmpty()){
                List<Contact> contacts = [SELECT Id, Name, MobilePhone, AccountId FROM Contact WHERE MobilePhone IN :contactPhones AND Inactive__c = FALSE];
                for (Contact con : contacts) {
                    phoneToContactMap.put(con.MobilePhone, con);
                }
            }
            System.debug('phoneToContactMap '+phoneToContactMap);
        }
        
        // 3. Account ID 비교
        if(!assetMap.isEmpty()){
            for (Id caseId : assetMap.keySet()) {                
                String assetName = assetMap.get(caseId);
                String contactPhone = contactMap.get(caseId);
                System.debug('assetName '+assetName);
                System.debug('contactPhone '+contactPhone);
                Asset asset = assetNameToAssetMap.get(assetName);
                Contact contact = phoneToContactMap.get(contactPhone);
                System.debug('asset '+asset);
                System.debug('contact '+contact);

                FieldWrapper fw = new FieldWrapper();
                if(asset != null){
                    fw.assetId = asset.Id;
                }
                if(contact != null){
                    fw.contactId = contact.Id;
                }
    
                if (asset != null && contact != null) {
                    Boolean isAccountIdSame = (asset.AccountId == contact.AccountId) ? true : false;
    
                    // 로그 출력 또는 결과 저장
                    System.debug('Case ID: ' + caseId);
                    System.debug('Asset ID: ' + (asset != null ? asset.Id : 'No Asset Found'));
                    System.debug('Contact ID: ' + (contact != null ? contact.Id : 'No Contact Found'));
                    System.debug('Account ID Match: ' + isAccountIdSame);
    
                    if(isAccountIdSame){
                        fw.accountId = asset.AccountId;
                    }
                } else {
                    System.debug('Case ID: ' + caseId + ' - Missing Asset or Contact');
                }
                fwMap.put(caseId, fw);
            }
        }
        return fwMap;
    }


    /**
    * @description Email-to-Case로 접수된 내용 분리하여 Wrapper로 묶기
    * @operationtype after insert
    * @author Hayeong Min 
    * @param 
        - emailStr : Email-to-Case로 접수된 Json serialize된 String 
    **/
    private static EmailWrapper emailWrapperCheck(String emailStr){
        Map<String, Object> emailJson = (Map<String, Object>) JSON.deserializeUntyped(emailStr);
        EmailWrapper ew = new EmailWrapper();
        ew.country = (String) emailJson.get('country');
        ew.srNumber = (String) emailJson.get('srNumber');
        ew.inqType = (String) emailJson.get('inqType');
        ew.prdName = (String) emailJson.get('prdName');
        ew.cpName = (String) emailJson.get('cpName');
        ew.prdClass = (String) emailJson.get('prdClass');
        ew.receptionType = (String) emailJson.get('receptionType');
        ew.industry = (String) emailJson.get('industry');
        ew.pdCategory = (String) emailJson.get('pdCategory');
        ew.drInput = (String) emailJson.get('drInput');
        ew.title = (String) emailJson.get('title');
        ew.content = (String) emailJson.get('content');
        ew.receptionChannel = (String) emailJson.get('receptionChannel');
        ew.prdSeries = (String) emailJson.get('prdSeries');
        ew.phone = (String) emailJson.get('phone');
        ew.name = (String) emailJson.get('name');
        String region = (String) emailJson.get('region');
        ew.region = ew.country == 'Korea, South' ? region.split(';')[0] : region;
        ew.email = (String) emailJson.get('email'); 
        System.debug('EW :'+ew);

        return ew;
    }

    /**
    * @description DNS Wrapper로 묶인 내용 정리해서 Ticket의 Description에 입력
    * @operationtype after insert
    * @author Hayeong Min
    * @param 
        - ew : Email-to-Case로 접수된 내용 Wrapper
    **/
    private static String emailReceptionDetail_DNS(EmailWrapper ew){
        String receptionDetail = '';
        // String receptionDetail = JSON.serialize(ew);
        receptionDetail += '문의유형 : '+ew.inqType+',\n';
        //제품명
        if(ew.drInput == 'N'){
            receptionDetail += '제품 종류 : '+ew.pdCategory+' '+ew.prdClass+' '+(String.isNotEmpty(ew.prdSeries) ? ew.prdSeries+',\n' : ',\n');
        }else{
            receptionDetail += '제품명 : '+ew.prdName+',(직접입력)\n';
        }

        receptionDetail += ew.receptionType != '고객의 소리' ? '제조번호 : '+ew.srNumber+',\n' : '';
        receptionDetail += String.isNotEmpty(ew.cpName) ? '회사명 : '+ew.cpName+',\n' : '';
        receptionDetail += '이메일 : '+ew.email+',\n';
        receptionDetail += '주소 : '+ew.country+', '+ ew.region.split(';')[0]+',\n';
        receptionDetail += '연락처 : '+ew.phone+',\n';
        receptionDetail += '이름 : '+ew.name+',\n';
        receptionDetail += String.isNotEmpty(ew.title) ? '제목 : '+ew.title+',\n' : '';
        receptionDetail += '내용 : '+ew.content+',\n';
        receptionDetail += String.isNotEmpty(ew.receptionChannel) ? '유입경로 : '+ew.receptionChannel+',\n' : '';
        receptionDetail += String.isNotEmpty(ew.industry) ? '산업군 : '+ew.industry+'\n' : '';

        return receptionDetail;
    
    }

    /**
    * @description DNSA Wrapper로 묶인 내용 정리해서 Ticket의 Description에 입력
    * @operationtype after insert
    * @author Hayeong Min
    * @param 
        - ew : Email-to-Case로 접수된 내용 Wrapper
    **/
    private static String emailReceptionDetail_DNSA(EmailWrapper ew){
        String receptionDetail = '';
        // String receptionDetail = JSON.serialize(ew);
        receptionDetail += 'Inquiry Type : '+ew.inqType+',\n';
        //제품명
        if(ew.drInput == 'N'){
            receptionDetail += 'Type of Machine : '+ew.pdCategory+' '+ew.prdClass+' '+(String.isNotEmpty(ew.prdSeries) ? ew.prdSeries+',\n' : ',\n');
        }else{
            receptionDetail += 'Type of Machine : '+ew.prdName+',(Input manually)\n';
        }

        receptionDetail += 'Serial Number : '+ew.srNumber+',\n';
        receptionDetail += String.isNotEmpty(ew.cpName) ? 'Company : '+ew.cpName+',\n' : '';
        receptionDetail += 'E-mail : '+ew.email+',\n';
        receptionDetail += 'Address : '+ew.country+', '+ ew.region.replaceAll(';', ' ')+',\n';
        receptionDetail += 'Phone Number : '+ew.phone+',\n';    
        receptionDetail += 'Name : '+ew.name+',\n';
        receptionDetail += String.isNotEmpty(ew.title) ? 'Subject : '+ew.title+',\n' : '';
        receptionDetail += 'Details : '+ew.content+',\n';
        receptionDetail += String.isNotEmpty(ew.receptionChannel) ? 'Inflow path : '+ew.receptionChannel+',\n' : '';
        receptionDetail += String.isNotEmpty(ew.industry) ? 'Industry : '+ew.industry+'\n' : '';

        return receptionDetail;
    }

    /*
     * @Description 
     *  - Email to Case로 접수된 내용 정리하는 Wrapper
     */
    public class EmailWrapper{
        @AuraEnabled public String  country { get; set;}
        @AuraEnabled public String  srNumber { get; set;}
        @AuraEnabled public String  inqType { get; set;}
        @AuraEnabled public String  prdName { get; set;}
        @AuraEnabled public String  cpName { get; set;}
        @AuraEnabled public String  prdClass { get; set;}
        @AuraEnabled public String  receptionType { get; set;}
        @AuraEnabled public String  industry { get; set;}
        @AuraEnabled public String  pdCategory { get; set;}
        @AuraEnabled public String  drInput { get; set;}
        @AuraEnabled public String  title { get; set;}
        @AuraEnabled public String  content { get; set;}
        @AuraEnabled public String  receptionChannel { get; set;}
        @AuraEnabled public String  prdSeries { get; set;}
        @AuraEnabled public String  phone { get; set;}
        @AuraEnabled public String  name { get; set;}
        @AuraEnabled public String  region { get; set;}
        @AuraEnabled public String  email { get; set;}

        public EmailWrapper(){
            this.country = '';
            this.srNumber = '';
            this.inqType = '';
            this.prdName = '';
            this.cpName = '';
            this.prdClass = '';
            this.receptionType = '';
            this.industry = '';
            this.pdCategory = '';
            this.drInput = '';
            this.title = '';
            this.content = '';
            this.receptionChannel = '';
            this.prdSeries = '';
            this.phone = '';
            this.name = '';
            this.region = '';
            this.email = '';
        }
    }

    /*
     * @Description 
     *  - Email to Case로 접수된 Account, Contact, Asset ID 관리하는 Wrapper
     * 
     * @Variable 
     *  - assetId 	    : 장비 ID 
     *  - contactId 	: 요청자 ID
     *  - accountId 	: 고객사 ID
     */
    public class FieldWrapper{
        @AuraEnabled public String  assetId { get; set;}
        @AuraEnabled public String  contactId { get; set;}
        @AuraEnabled public String  accountId { get; set;}

        public FieldWrapper(){
            this.assetId = null;
            this.contactId = null;
            this.accountId = null;
        }
    }

    /*
     * @Description 
     *  - User 정보 Wrapper
     * 
     * @Variable 
     *  - Id 	    : 사용자 아이디
     *  - Name 	    : 사용자 이름
     *  - Email 	: 사용자 이메일
     *  - language 	: 사용자 언어
     */ 
    public class UserWrapper{
        @AuraEnabled public String Id       { get; set;}
        @AuraEnabled public String Name     { get; set;}
        @AuraEnabled public String Email    { get; set;}
        @AuraEnabled public String language { get; set;}
        
        public UserWrapper(){
            this.Id = '';
            this.Name = '';
            this.Email = '';
            this.language = '';
        }
    }
}