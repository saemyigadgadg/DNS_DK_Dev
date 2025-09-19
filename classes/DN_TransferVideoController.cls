/**
* @Class : DN_TransferVideoController
* @Author : Hayeong, Min
* @Date : 2024. 05. 28.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-05-28 | Hayeong, Min   | 최초작성
*  1. | 2024-12-20 | Junyeong, Choi | ver 2
*
*/
public with sharing class DN_TransferVideoController {
    
    // @description : 해당 Ticket 의 요청자 번호 조회
    @AuraEnabled
    public static ResultWrapper getContactPhone(String contactId){
        System.debug('contact'+contactId);
        ResultWrapper rw = new ResultWrapper();
        Contact con = [SELECT Id, Phone, MobilePhone FROM Contact WHERE Id = :contactId];
        System.debug(con);
        if(String.isNotEmpty(con.MobilePhone)){
            rw.returnValue = con.MobilePhone;
        }else if(String.isNotEmpty(con.Phone)){
            rw.returnValue = con.Phone;
        }
        System.debug('rw'+rw);
        return rw;
    }

    // @description : 영상자료 URL 조회
    @AuraEnabled
    public static ResultWrapper getViedoURL(String recordId, String searchKey){
        ResultWrapper rw = new ResultWrapper();
        List<EducationVideo__c> videoList = new List<EducationVideo__c>();
        try {
            Case ticket = [SELECT Id, ContactId, Contact.Phone, Contact.MobilePhone, Requester__c, Requester__r.MobilePhone FROM Case WHERE Id = :recordId];
            if(String.isNotEmpty(ticket.Requester__c)){
                rw.returnValue = ticket.Requester__c;
                if(String.isNotEmpty(ticket.Requester__r.MobilePhone)){
                    rw.phoneNum = ticket.Requester__r.MobilePhone; 
                }
            }
            
            String query = 'SELECT Id, Name, SourceURL__c FROM EducationVideo__c ';
            if(String.isNotEmpty(searchKey)){
                query += 'WHERE Name Like \'%'+searchKey+'%\'';
            }
            query += ' ORDER BY Name ASC';

            videoList = Database.query(query);
            if(videoList.size() > 0){
                rw.returnList = videoList;
            }
        } catch (Exception e) {
            rw.isSuccess = false;
            rw.errMessage = e.getMessage();
        }
        return rw;
    }

    // @description : 요청자에게 알림톡으로 영상자료 URL 전송
    @AuraEnabled
    public static ResultWrapper sendVideoURL(String recordId, String phone, List<Map<String, Object>> selectedVideoList) {
        System.debug('recordId: ' + recordId);
        System.debug('phone: ' + phone);
        System.debug('selectedVideoList: ' + selectedVideoList);
        ResultWrapper rw = new ResultWrapper();
        List<UTIL_Alert.historyWrapper> wrappers = new List<UTIL_Alert.historyWrapper>();

        try {
            Case caseObj = [
                SELECT Id, Account.Name
                FROM Case
                WHERE Id = :recordId
                LIMIT 1
            ];
            String accountName = caseObj.Account.Name;
    
            AlertManager__c alertManager = [
                SELECT Id, Name
                FROM AlertManager__c
                WHERE Name = 'Video Send Alarm Talk'
                LIMIT 1
            ];
    
            for (Map<String, Object> video : selectedVideoList) {
                String fileName = (String)video.get('Name');
                String fileURL = (String)video.get('SourceURL__c');
                String subFileURL = fileURL != null ? fileURL.replace('https://youtu.be/', '') : '';
                Id fileId = (Id)video.get('Id');
        
                Map<String, String> alarmMap = new Map<String, String>{
                    'rep_clnt_nm' => accountName,
                    'video_name'  => fileName,
                    'video_url'   => subFileURL
                };
    
                UTIL_Alert.historyWrapper wrapper = new UTIL_Alert.historyWrapper();
                wrapper.alertID = alertManager.Id;
                wrapper.targetID = fileId;
                wrapper.alertType = 'AlarmTalk';
                wrapper.receiverforPhone = new Set<String>{ phone };
                wrapper.alertLanguage = 'ko';
                wrapper.elementMap = alarmMap;
                wrappers.add(wrapper);
            }
    
            if (!wrappers.isEmpty()) {
                UTIL_Alert.runAlertEvent(wrappers);
            }
    
        } catch (Exception e) {
            throw new AuraHandledException('Error' + e.getMessage());
        }
    
        return rw;
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
        @AuraEnabled public String  returnValue { get; set;}
        @AuraEnabled public String  phoneNum { get; set;}
        @AuraEnabled public List<EducationVideo__c>  returnList { get; set;}

        public ResultWrapper(){
            this.isSuccess = true;
            this.returnValue = '';
            this.phoneNum = '';
        }
    }
}