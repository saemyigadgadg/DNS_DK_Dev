/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-07-25
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-07-09   yeongdeok.seo@sbtglobal.com   Initial Version
**/
public without sharing class UTIL_Alert {
    
    /*
     * @Description Alert을 위한 Wrapper
     * @Variable
     * - [Id]           (*) alertID         : Alert Manager Id
     * - [Id]           (*) targetID        : Row recordId
     * - [String]       (*) alertType       : Email, Notification, AlarmTalk
     * - [String]       (*) alertLanguage   : Korean = ko, English = en
     * - [String]       title               : Email, Notification Title (template에 있는 title을 사용하지 않는 경우에만)
     * - [String]       pageRef             : Notification 클릭시 이동할 외부 사이트 주소 (Notification만)
     * - [List<String>] elementList         : Body에 replace할 리스트 (template에 있는 text replace가 필요한 경우에만)
     * - [Map<String, String>]  elementMap  : Parameter에 담고, Body에 replace할 맵 (AlarmTalk의 경우)
     * - [List<String>] receiverforEmail    : 수신자 Email address List (email 발송 필수)
     * - [List<String>] receiverforEmailCC  : 수신자 Email address List (email 발송 필수)
     * - [Set<Id>]      attachmentIDS       : Attachment or ContentDocument Id (Email 발송 시 필요하다면 추가)
     * - [Set<Id>]      receiverforID       : 수신자 User Id List (bell noti 발송 필수) 
     * - [Set<String>]  receiverforPhone    : 수신자 전화번호 List (AlarmTalk 발송 필수, 최대 10개..)
     */
    public class HistoryWrapper {
        @AuraEnabled public Id alertID 					    { get; set; }  
        @AuraEnabled public Id targetID 			        { get; set; } 
        @AuraEnabled public String alertType 		        { get; set; }
        @AuraEnabled public String alertLanguage	        { get; set; }
        @AuraEnabled public String title  			        { get; set; } 
        @AuraEnabled public String pageRef  			    { get; set; } 
        @AuraEnabled public List<String> elementList        { get; set; } 
        @AuraEnabled public Map<String, String> elementMap	{ get; set; }
        @AuraEnabled public List<String> receiverforEmail   { get; set; } 
        @AuraEnabled public List<String> receiverforEmailCC { get; set; } 
        @AuraEnabled public Set<Id> attachmentIDS	        { get; set; } 
        @AuraEnabled public Set<Id> receiverforID	        { get; set; } 
        @AuraEnabled public Set<String> receiverforPhone	{ get; set; }

        public HistoryWrapper(){
            this.elementList        = new List<String>();
            this.elementMap         = new Map<String, String>();
            this.receiverforEmail   = new List<String>();
            this.receiverforEmailCC = new List<String>();
            this.attachmentIDS      = new Set<Id>();
            this.receiverforID      = new Set<Id>();
            this.receiverforPhone   = new Set<String>();
        }
    }

    /*
    * @Description 
    *  - Apex Callout 실행 결과용 Wrapper
    * @Variable 
    *  - isSuccess 	: 성공 여부
    *  - errMessage 	: 실패 시 에러 메시지 
    */ 
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess  { get; set;}
        @AuraEnabled public String  errMessage { get; set;}
        
        public ResultWrapper(){
            this.isSuccess = true;
        }
    }

    /**
    * @description AlertHistory__c 생성 및 이벤트 호출
    * @author yeongju.yun | 2024-10-23 
    * @param wrappers 
    * @return ResultWrapper 

    UTIL_Alert.HistoryWrapper wrap = new UTIL_Alert.HistoryWrapper();
    wrap.alertID            = 'a0xF7000009uv6uIAA';
    wrap.targetID           = '801F7000001Kd7lIAC';
    wrap.alertLanguage      = 'en';
    wrap.elementList        = new List<String>{'테스트 일!'};
    wrap.alertType          = 'Email';
    wrap.receiverforEmail   = new List<String>{'yeongju.yun@dncompany.com'};
    // wrap.receiverforEmailCC = new List<String>{'yunyj227@gmail.com'};
    // wrap.attachmentIDS      = new Set<Id>{'069F7000002GhFxIAK'};
    // wrap.alertType          = 'Notification';
    // wrap.receiverforID      = new Set<Id>{'005F7000006D9sjIAC'};
    // wrap.receiverforPhone   = new Set<String>{'01071913896'};

    UTIL_Alert.runAlertEvent(new List<UTIL_Alert.HistoryWrapper>{wrap});

    **/
    public static ResultWrapper runAlertEvent(List<HistoryWrapper> wrappers){
        ResultWrapper result = new ResultWrapper();

        try {
            List<AlertHistory__c> ahList = makeHistoryData(wrappers);

            if(ahList != null && ahList.size() > 0){
                Database.SaveResult[] srList = Database.Insert(ahList);

                Set<Id> historyIdSet = new Set<Id>();
                for(Database.SaveResult sr : srList){
                    if (sr.isSuccess()) {
                        historyIdSet.add(sr.getId());
                    } else {
                        result.isSuccess = false;
                        for (Database.Error err : sr.getErrors()) {
                            result.errMessage = err.getMessage();
                        }
                        break;
                    }
                }

                if(!historyIdSet.isEmpty() && result.isSuccess) {
                    AlertEvent__e alertEvt = new AlertEvent__e(Histories__c = String.join(historyIdSet, ','));
                    List<Database.SaveResult> eventResults = EventBus.publish(new List<AlertEvent__e>{alertEvt});
                    for(Database.SaveResult evtResult : eventResults) {
                        System.debug('eventResults - evtResult ::: ' + evtResult);
                    }
                }

            } else {
                result.isSuccess  = false;
                result.errMessage = System.Label.DNS_M_NotiDeliveryFail; // Notification delivey failed.
            }
            
        } catch (Exception e) {
            result.isSuccess  = false;
            result.errMessage = e.getLineNumber() + ' / ' + e.getMessage();
        }

        System.debug('runAlertEvent - result ::: ' + result);
        return result;
    }

    /**
    * @description Error 대비 Draft 전체 이벤트 실행
    * @author yeongju.yun | 2024-10-23 
    * UTIL_Alert.runDraft(new Set<Id>{'테스트할 아이디 추가'});
    **/
    public static void runDraft(Set<Id> target){

        List<AlertHistory__c> historyList = [SELECT Id FROM AlertHistory__c WHERE AlertResult__c = 'Draft' AND Id =:target];
        Map<Id, AlertHistory__c> historyMap = new Map<Id, AlertHistory__c>(historyList);
        AlertEvent__e alertEvt = new AlertEvent__e(Histories__c = String.join(historyMap.keySet(), ','));
        List<Database.SaveResult> eventResults = EventBus.publish(new List<AlertEvent__e>{alertEvt});
    }

    /**
    * @description 알림 히스토리 데이터 생성
    **/
    private static List<AlertHistory__c> makeHistoryData(List<HistoryWrapper> wrappers){
        List<AlertHistory__c> result = new List<AlertHistory__c>();

        Set<Id> managerIdSet = new Set<Id>();
        for(HistoryWrapper wrap : wrappers) {
            managerIdSet.add(wrap.alertID);
        }
        
        List<AlertManager__c> managerList = [
            SELECT  Id, Name, IsActive__c 
            FROM    AlertManager__c 
            WHERE   IsActive__c = true 
            AND     Id =:managerIdSet
        ];

        if(managerList.isEmpty()) { 
            System.debug('No Alert Manager. Please check the manager\'s activation.');
            return null; 
        }

        Map<Id, AlertManager__c> managerMap = new Map<Id, AlertManager__c>(managerList);

        // bell template 
        Map<String, AlertNotificationTemplate__c> bellMap = new Map<String, AlertNotificationTemplate__c>(); // key : AlertManagerID__c + Language__c, value : AlertNotificationTemplate__c
        Map<String, Id> customNotiMap = new Map<String, Id>(); // key : custom notification name, vlaue : cusotm notification id

        List<AlertNotificationTemplate__c> bellTemplateList = [
            SELECT  Id, AlertManagerID__c, CustomNotificationName__c, Language__c, Title__c, Body__c
            FROM    AlertNotificationTemplate__c 
            WHERE   AlertManagerID__c =: managerMap.keySet()
        ];
        
        Set<String> cusotmNotiNameSet = new Set<String>();
        for(AlertNotificationTemplate__c bellTemplate : bellTemplateList){
            bellMap.put(bellTemplate.AlertManagerID__c + bellTemplate.Language__c, bellTemplate);
            cusotmNotiNameSet.add(bellTemplate.CustomNotificationName__c);
        }

        List<CustomNotificationType> cusNotiTypeList = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName =:cusotmNotiNameSet ];
        for(CustomNotificationType type : cusNotiTypeList) {
            customNotiMap.put(type.DeveloperName, type.Id);
        }
        
        // email temaplte
        Map<String, String> emailMap = new Map<String, String>(); // key : AlertManagerID__c + Language__c, value : EmailTemplateName__c
        Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>(); // key : tempalte DeveloperName, value : EmailTemplate

        List<AlertEmailTemplate__c> emailTemplateList = [
            SELECT  Id, AlertManagerID__c, EmailTemplateName__c, Language__c
            FROM    AlertEmailTemplate__c
            WHERE   AlertManagerID__c =: managerMap.keySet()
        ];

        Set<String> templateNameSet = new Set<String>();
        for(AlertEmailTemplate__c eTem : emailTemplateList) {
            emailMap.put(eTem.AlertManagerID__c + eTem.Language__c, eTem.EmailTemplateName__c);
            templateNameSet.add(eTem.EmailTemplateName__c);
        }

        List<EmailTemplate> emailTemaplateList = [
            SELECT  Id, DeveloperName, TemplateType, Subject, HtmlValue, Body
            FROM    EmailTemplate
            WHERE   IsActive = true
            AND     DeveloperName =: templateNameSet
        ];
        for(EmailTemplate eTem : emailTemaplateList){
            emailTemplateMap.put(eTem.DeveloperName , eTem);
        }

        // alarmtalk template
        Map<String, String> alarmtalkMap = new Map<String, String>(); // key : AlertManagerID__c + Language__c, value : AlarmTalkTemplateCode__c
        Map<String, Alimtalk_Tamplate__mdt> alarmtalkTemplateMap = new Map<String, Alimtalk_Tamplate__mdt>();

        List<AlertAlarmTalkTemplate__c> alarmtalkTemplateList = [
            SELECT  Id, AlertManagerID__c, AlarmTalkTemplateCode__c, Language__c
            FROM    AlertAlarmTalkTemplate__c
            WHERE   AlertManagerID__c =: managerMap.keySet()
        ];

        Set<String> templateCodeSet = new Set<String>();
        for (AlertAlarmTalkTemplate__c alarmTem : alarmtalkTemplateList) {
            alarmtalkMap.put(alarmTem.AlertManagerID__c + alarmTem.Language__c, alarmTem.AlarmTalkTemplateCode__c);
            templateCodeSet.add(alarmTem.AlarmTalkTemplateCode__c);
        }

        List<Alimtalk_Tamplate__mdt> alarmtalkTemaplateList = [
            SELECT  Id, TemplateCode__c, TemplateBody__c, MoblieLink1__c, TemplateName__c
            FROM    Alimtalk_Tamplate__mdt
            WHERE   TemplateCode__c =: templateCodeSet
        ];
        for (Alimtalk_Tamplate__mdt alarmTem : alarmtalkTemaplateList) {
            alarmtalkTemplateMap.put(alarmTem.TemplateCode__c, alarmTem);
        }

        String errorMsg;
        Boolean isPass = true;
        Integer count = 0;
        for(HistoryWrapper wrap : wrappers) {
            if (System.isBatch()) count ++;

            AlertHistory__c history   = new AlertHistory__c();
            history.AlertManagerID__c = wrap.alertID;
            history.AlertResult__c    = 'Draft';
            history.TargetId__c       = wrap.targetID;
            history.AlertType__c      = wrap.alertType;
            history.Sender__c         = UserInfo.getUserId();
            history.Language__c       = wrap.alertLanguage;

            if(wrap.attachmentIDS.size() > 0) { history.Attachment__c = String.Join(wrap.attachmentIDS, ','); }
            
            if(history.AlertType__c == 'Notification') {

                AlertNotificationTemplate__c bell;
                if(bellMap.containsKey(history.AlertManagerID__c+history.Language__c)) {
                    bell = bellMap.get(history.AlertManagerID__c+history.Language__c);

                    history.Title__c    = String.isBlank(wrap.title) ? bell.Title__c : wrap.title;
                    history.Body__c     = wrap.elementList.size() > 0 ? replaceBody(bell.Body__c, wrap.elementList) : bell.Body__c;
                    history.BodyText__c = wrap.elementList.size() > 0 ? replaceBody(bell.Body__c, wrap.elementList) : bell.Body__c;
                    history.CustomNotificationTypeId__c = customNotiMap.get(bell.CustomNotificationName__c);
                    history.ReceiverForBell__c = String.join(wrap.receiverforID, ',');
                    history.NotificationPageRef__c = wrap.pageRef;
                } else {
                    isPass   = false;
                    errorMsg = 'No AlertNotificationTemplate__c';
                    break;
                }
            } else if (history.AlertType__c == 'Email') {

                AlertEmailTemplate__c email;
                System.debug('emailMap : ' + emailMap);
                if(emailMap.containsKey(history.AlertManagerID__c+history.Language__c)) {
                    String emailTemplateName = emailMap.get(history.AlertManagerID__c+history.Language__c);
                    System.debug('emailTemplateName : ' + emailTemplateName);
                    EmailTemplate emailTem   = emailTemplateMap.get(emailTemplateName);
                    System.debug('emailTemplateMap : ' + emailTemplateMap);
                    System.debug('emailTem : ' + emailTem);
                    
                    String temBody = emailTem.TemplateType == 'Text' ? emailTem.Body : emailTem.HtmlValue;

                    history.Title__c = String.isBlank(wrap.title) ? emailTem.Subject : wrap.title;
                    history.Body__c  = wrap.elementList.size() > 0 ? replaceBody(temBody, wrap.elementList) : temBody;
                    history.BodyText__c  = wrap.elementList.size() > 0 ? replaceBody(temBody, wrap.elementList) : temBody;
                    history.ReceiverForEmail__c = String.join(wrap.receiverforEmail, ',');

                    if(wrap.receiverforEmailCC.size() > 0) { history.ReceiverForEmailCC__c = String.join(wrap.receiverforEmailCC, ','); }
                } else {
                    isPass   = false;
                    errorMsg = 'No AlertEmailTemplate__c';
                    break;
                } 
            } else if (history.AlertType__c == 'AlarmTalk') {

                Alimtalk_Tamplate__mdt alarmtalk;
                if (alarmtalkMap.containsKey(history.AlertManagerID__c+history.Language__c)) {
                    String templateCode = alarmtalkMap.get(history.AlertManagerID__c+history.Language__c);
                    alarmtalk = alarmtalkTemplateMap.get(templateCode);
                    String bodyText = replaceBodyAndButton(alarmtalk.TemplateBody__c, wrap.elementMap);
                    history.TemplateName__c = alarmtalk.TemplateName__c;
                    history.TemplateCode__c = templateCode;
                    history.ReplaceMap__c = JSON.serialize(wrap.elementMap);
                    history.Body__c = bodyText;
                    history.BodyText__c = bodyText;
                    history.ReceiverForAlarmTalk__c = String.join(wrap.receiverforPhone, ',');

                    if (wrap.targetID != null && wrap.targetID.getSObjectType().getDescribe().getName() == 'Case') {
                        history.Ticket__c = wrap.targetID;
                    }

                } else {
                    isPass   = false;
                    errorMsg = 'No AlertAlarmTalkTemplate__c';
                    break;
                } 
                
            }
            result.add(history);
            if (count == wrappers.size()) IF_SWEET_TRACKER.utils.saveInterfaceLog();
        }

        if(!isPass) {
            System.debug(errorMsg);
            return null;
        } 

        return result;
    }

    /**
    * @description AlarmTalk 메시지를 개별 수신자에게 발송하고, 마지막 수신자 처리 후 인터페이스 로그 저장 (트리거용)
    **/
    @future(callout=true)
    public static void futureAlarmTalkAPIcall(List<String> phoneList, String templateCode, Map<String, String> elementMap) {

        Integer count = 0;
        for (String phone : phoneList) {
            count++;

            String if_result = IF_SWEET_TRACKER.invoke('AT', phone, 'sendMessage', templateCode, elementMap);

            if (count == phoneList.size())  IF_SWEET_TRACKER.utils.saveInterfaceLog();
            
        }

    }

    /**
    * @description 본문 문자열에서 {0}, {1} 등 인덱스 기반 텍스트를 리스트 값으로 치환
    **/
    private static String replaceBody(String body, List<String> elementList) {
        for (Integer i = 0; i < elementList.size(); i ++) {
            body = body.replace('{' + i + '}', elementList[i]);
        }

        return body;
    }

    /**
    * @description 본문 문자열에서 #{key} 형식의 텍스트를 실제 값으로 치환
    **/
    private static String replaceBodyAndButton(String body, Map<String, String> elementMap) {
        for (String key : elementMap.keySet()) {
            body = body.replace('#{' + key + '}', elementMap.get(key));
        }

        return body;
    }
}