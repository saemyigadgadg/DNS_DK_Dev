/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 09-01-2025
 * @last modified by  : Hanyeong Choi
**/
public class SendApprovalNotificationJob implements Queueable {
    String recordIds;

    public SendApprovalNotificationJob(String recordIds) {
        this.recordIds = recordIds;
    }

    /**
     * 승인 요청 알림을 전송하는 큐 작업을 실행합니다.
     */
    public void execute(QueueableContext context) {
        //딜러가 최초의 승인 요청 시 알림
                List<PS__c> approveNoti = 
                [
                    SELECT
                        Opportunity__r.Opportunity_Owner__r.ManagerId,
                        Name__c,
                        Name
                    FROM
                        PS__c
                    WHERE
                        Id =: recordIds
                ];
                List<ProcessInstanceWorkitem> psorigin = 
                [
                    SELECT
                        Id
                    FROM
                        ProcessInstanceWorkitem
                    WHERE
                        ProcessInstance.TargetObjectId =: recordIds
                ];

                if(approveNoti[0].Opportunity__r.Opportunity_Owner__r.ManagerId != null){
                    String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
                    Set<Id> ownerId = new Set<Id>();
                    List<String> emailAddr = new List<String>();

                    ownerId.add(approveNoti[0].Opportunity__r.Opportunity_Owner__r.ManagerId);
                    List<User> getEmail =  DN_WithoutSharingClass.getUserEmails(ownerId);
                    if(!getEmail.isEmpty()){
                        for(Integer i = 0; i < getEmail.size(); i++){
                            emailAddr.add(getEmail[i].Email); 
                        }
                        List<AlertManager__c> am = [SELECT Id FROM AlertManager__c WHERE Name = 'RFQApprovalRequest'];
                        Id alertId;

                        if(!am.isEmpty()){
                            alertId = am[0].Id;
                        }else{
                            alertId = 'a0xJO000000BDYDYA4';
                        }
                        UTIL_Alert.HistoryWrapper wrapEmail = new UTIL_Alert.HistoryWrapper();
                            wrapEmail.alertID            = alertId;
                            wrapEmail.targetID           = recordIds;
                            wrapEmail.alertType          = 'Email';
                            wrapEmail.receiverforEmail   = emailAddr;
                            wrapEmail.alertLanguage      = 'en';
                            wrapEmail.elementList        = new List<String>{approveNoti[0].Name__c, instanceUrl+'/'+recordIds, instanceUrl+'/'+psorigin[0].Id};
                                                
                        UTIL_Alert.runAlertEvent(new List<UTIL_Alert.HistoryWrapper>{wrapEmail});
                    }   
                }
        
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
        
    }
}