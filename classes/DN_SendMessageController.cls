/**
 * @author            : Jiyeong Park
 * @Description       : Utility Bar의 쪽지 화면
 * @last modified on  : 07-22-2025
 * @last modified by  : sungheum.yeon@sobetec.com
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   2025-04-04   Jiyeong Park     Initial Version
**/
public with sharing class DN_SendMessageController {

    /**
     * @Description
     * 	- 경로 : 쪽지 > 수신함
     *  - 조건에 부합하는 쪽지 수신 목록 조회
     * @author Jiyeong Park
    **/
    @AuraEnabled
    public static List<messageList> getData(String type, date dateTo, date dateFrom, String sender, String content){
        List<messageList> res = new List<messageList>();
        Datetime fromDate = Datetime.newInstance(dateFrom.year(), dateFrom.month(), dateFrom.day(), 0, 0, 0);
        Datetime toDate = Datetime.newInstance(dateTo.year(), dateTo.month(), dateTo.day(), 23, 59, 59);
        System.debug('fromDate::'+fromDate);
        System.debug('toDate::'+toDate);
        List<Message__c> msgList;
        if(type == '수신'){
            msgList = [SELECT Id, Owner.Name, CreatedDate, CreatedById, CreatedBy.Name, Recipient__c, Recipient__r.Name, ReceivedDateTime__c, Type__c, Content__c, Status__c
                       FROM Message__c
                       WHERE (CreatedDate <=: toDate AND CreatedDate >=: fromDate)
                       AND Recipient__c =:UserInfo.getUserId()
                       AND Content__c LIKE :'%'+content+'%'
                       AND CreatedBy.Name LIKE :'%'+sender+'%'
                       AND isDeletedByRecipient__c = false
                       ORDER BY CreatedDate DESC];
        } else {
            msgList = [SELECT Id, Owner.Name, CreatedDate, CreatedById, CreatedBy.Name, Recipient__c, Recipient__r.Name, ReceivedDateTime__c, Type__c, Content__c, Status__c
                       FROM Message__c
                       WHERE (CreatedDate <=: toDate AND CreatedDate >=: fromDate)
                       AND CreatedById =:UserInfo.getUserId()
                       AND Recipient__r.Name LIKE :'%'+sender+'%'
                       AND isDeletedBySender__c = false
                       ORDER BY CreatedDate DESC];
        }

        for(Message__c m : msgList){
            messageList s = new messageList();
            if(type == '수신'){
                s.Sender = m.Owner.Name;
                s.SenderId = m.CreatedById;
            } else { //발신
                s.Recipient = m.Recipient__r.Name;
                s.RecipientId = m.Recipient__c;
                if(m.ReceivedDateTime__c != null){
                    s.ReceivedDate = String.valueOf(m.ReceivedDateTime__c.Date());
                    s.ReceivedTime = String.valueOf(m.ReceivedDateTime__c.Time()).substring(0, 8);
                }
            }
            s.Id = m.Id;
            s.SentDate = String.valueOf(m.CreatedDate.Date());
            s.SentTime = String.valueOf(m.CreatedDate.Time()).substring(0, 8);
            s.Type = m.Type__c;
            s.Content = m.Content__c;
            s.Status = m.Status__c=='읽음'?'V':'';

            res.add(s);
        }
        return res;
    }

    /**
     * @Description
     * 	- 경로 : 쪽지 > 쪽지전송
     *  - 입력한 대상에게 쪽지 전송 및 알림 발송
     * @author Jiyeong Park
    **/
    @AuraEnabled
    public static String setSendMessage(String sendType, String sendContent, List<targetList> recipient){
        System.debug('---recipient---'+recipient);
        String senderName = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Name;

        List<Message__c> msgList = new List<Message__c>();

        for(targetList t : recipient){
            Message__c msg = new Message__c();
            msg.Name = '['+sendType+'] 수신자: '+t.Name+' 발신자: '+senderName;
            msg.Type__c = sendType;
            msg.Content__c = sendContent;
            msg.Recipient__c = t.Id;
            msgList.add(msg);
        }

        try {
            insert msgList;

            //쪽지 수신 Notification
            List<UTIL_Alert.HistoryWrapper> hwlist = new List<UTIL_Alert.HistoryWrapper>();
            String alertManagerId = [SELECT Id FROM AlertManager__c WHERE Name = 'Message Received Notification'].Id;
            for(Message__c msg : msgList) {
                UTIL_Alert.historyWrapper notihw = new UTIL_Alert.HistoryWrapper();
                notihw.alertID = alertManagerId;
                notihw.alertType = 'Notification';
                notihw.pageRef = '#';
                notihw.receiverforID = new Set<Id>{msg.Recipient__c};
                notihw.alertLanguage = 'ko';  // 언어 설정
                hwlist.add(notihw);
            }

            if(hwList.size() > 0) {
                UTIL_Alert.runAlertEvent(hwList);
            }

            return 'Success';
        } catch (DmlException e) {
            return 'error: ' + e.getMessage();
        }
    }

    /**
     * @Description
     * 	- 경로 : 쪽지 > 쪽지전송
     *  - 쪽지전송 대상자 리스트조회
     * @author Jiyeong Park
    **/
    @AuraEnabled
    public static List<targetList> getGradeUser(String grade, String recipUser){
        System.debug('grade =>' + grade);
        List<targetList> res = new List<targetList>();
        List<User> us;
        if(grade == '내부직원'){
            us =  [SELECT Id, Name, Profile.Name, EmployeeNumber, Department, Division
                    FROM User
                    WHERE (Profile.Name ='DNS CS Admin' OR Profile.Name ='DNS CS Service')
                    AND Name LIKE :'%'+recipUser+'%'
                    ORDER BY Name ASC];
        } else if(grade == '') {
            us =  [SELECT Id, Name, Profile.Name, EmployeeNumber, Department, Division
                    FROM User
                    WHERE (Profile.Name ='DNS CS Admin' OR Profile.Name ='DNS CS Service' OR Profile.Name ='DNS CS Receptionist' OR Profile.Name ='DNS CS Technical Consultant')
                    AND Name LIKE :'%'+recipUser+'%'
                    ORDER BY Name ASC];
        } else {
            us =  [SELECT Id, Name, Profile.Name, EmployeeNumber, Department, Division
                    FROM User
                    WHERE ProfileId =: grade
                    AND Name LIKE :'%'+recipUser+'%'
                    ORDER BY Name ASC];
        }

        for(User u:us){
            targetList t = new targetList();
            t.Id = u.Id;
            t.Name = u.Name;
            t.grade = u.Profile.Name == 'DNS CS Receptionist' ? '접수 상담사' : (u.Profile.Name == 'DNS CS Technical Consultant' ? '기술 상담사' : '내부직원');
            t.userId = u.EmployeeNumber;
            t.center = u.Division;
            t.team = u.Department;
            res.add(t);
        }

        return res;
    }

    /**
     * @Description
     * 	- 경로 : 쪽지 > 수신함
     *  - 수신 쪽지 상세 내용 조회 및 읽음 처리
     * @author Jiyeong Park
    **/
    @AuraEnabled
    public static String readMessage(String readMsgId){
        try {
            Message__c msg = [SELECT Id, Status__c FROM Message__c WHERE Id = :readMsgId LIMIT 1];
            msg.Status__c = '읽음';
            msg.ReceivedDateTime__c = System.Now();
            update msg;

            return 'Success';
        } catch (DmlException e) {
            return 'error: ' + e.getMessage();
        }
    }

    /**
     * @Description
     * 	- 경로 : 쪽지 > 수신함
     *  - 쪽지 삭제처리
     * @author Jiyeong Park
    **/
    @AuraEnabled
    public static String deleteMessage(String type, List<messageList> deleteData){
        Set<Id> del = new Set<Id>();
        for(messageList m:deleteData){
            del.add(m.Id);
        }

        List<Message__c> msgList = [SELECT Id, isDeletedByRecipient__c, IsDeletedBySender__c FROM Message__c WHERE Id = :del FOR UPDATE];

        try {
            if(type == '수신'){
                for(Message__c msg : msgList){
                    msg.isDeletedByRecipient__c = true;
                    // update msg;
                    if(msg.IsDeletedBySender__c == true) { // 발신자 삭제 true 이면 데이터삭제
                        delete msg;
                    } else {
                        update msg;
                    }
                }
            } else { //발신
                for(Message__c msg : msgList){
                    msg.IsDeletedBySender__c = true;
                    // update msg;
                    if(msg.isDeletedByRecipient__c == true) { // 수신자 삭제 true 이면 데이터삭제
                        delete msg;
                    } else {
                        update msg;
                    }
                }
            }

            return 'Success';
        } catch (DmlException e) {
            return 'error: ' + e.getMessage();
        }
    }

    /**
     * @Description
     * 	- 경로 : 쪽지 > 쪽지전송
     *  - 구분 등급 콤보박스 Setting
     * @author Jiyeong Park
    **/
    @AuraEnabled
    public static List<gradeOption> setGrade(){
        List<gradeOption> res = new List<gradeOption>();
        List<Profile> pro = [SELECT Id, Name FROM Profile WHERE (Name ='DNS CS Receptionist' OR Name ='DNS CS Technical Consultant')];

        for(Profile p:pro){
            gradeOption gr = new gradeOption();
            gr.label = p.Name=='DNS CS Receptionist'?'접수 상담사':'기술 상담사';
            gr.value = p.Id;
            res.add(gr);
        }
        // 내부직원 옵션 추가 2025. 03. 10
        gradeOption internalGr = new gradeOption();
        internalGr.label = '내부직원';
        internalGr.value = '내부직원';
        res.add(internalGr);

        return res;
    }

    //구분 등급 콤보박스 Wrapper
    public class gradeOption{
        @AuraEnabled public String label { get;set; }
        @AuraEnabled public String value { get;set; }

        public gradeOption(){
            this.label = '';
            this.value = '';
        }
    }

    //쪽지전송 대상 Wrapper
    public class targetList{
        @AuraEnabled public String Id { get;set; }
        @AuraEnabled public String Name { get;set; }
        @AuraEnabled public String userId { get;set; }
        @AuraEnabled public String grade { get;set; }
        @AuraEnabled public String center { get;set; }
        @AuraEnabled public String team { get;set; }

        public targetList(){
            this.Id = '';
            this.Name = '';
            this.userId = '';
            this.grade = '';
            this.center = '';
            this.team = '';
        }
    }

    //쪽지 조회 Wrapper
    public class messageList{
        @AuraEnabled public String Id             { get;set; }
        @AuraEnabled public String Sender         { get;set; } // 보낸사람
        @AuraEnabled public String SenderId       { get;set; } // 보낸사람Id
        @AuraEnabled public String SentDate       { get;set; } // 보낸날짜
        @AuraEnabled public String SentTime       { get;set; } // 보낸시간
        @AuraEnabled public String Recipient      { get;set; } // 받는사람
        @AuraEnabled public String RecipientId    { get;set; } // 받는사람Id
        @AuraEnabled public String ReceivedDate   { get;set; } // 받은날짜
        @AuraEnabled public String ReceivedTime   { get;set; } // 받은시간
        @AuraEnabled public String Type           { get;set; } // 유형
        @AuraEnabled public String Content        { get;set; } // 내용
        @AuraEnabled public String Status         { get;set; } // 확인

        public messageList(){
            this.Id = '';
            this.Sender = '';
            this.SenderId = '';
            this.SentDate = '';
            this.SentTime = '';
            this.Recipient = '';
            this.RecipientId = '';
            this.ReceivedDate = '';
            this.ReceivedTime = '';
            this.Type = '';
            this.Content = '';
            this.Status = '';
        }
    }
}