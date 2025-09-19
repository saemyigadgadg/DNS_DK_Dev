/**
 * @description       : 
 * @author            : Hanyeong Choi
 * @last modified on  : 06-02-2025
 * @last modified by  : Hanyeong Choi
**/
public class InsertCdaQueueable implements Queueable, Database.AllowsCallouts {
    private List<DNS_CustomerDealerAssociation__c> insertCdaList;
    private User u;
    private Integer retryCount;
    private String jobName;
    private static final Integer MAX_RETRIES = 3;
    private static final Integer RETRY_DELAY_MINUTES = 5;

    public InsertCdaQueueable(List<DNS_CustomerDealerAssociation__c> insertCdaList, User u) {
        this.insertCdaList = insertCdaList;
        this.u = u;
        this.retryCount = 0;
        this.jobName = 'RetryInsertCda_' + System.now().getTime();
    }

    public InsertCdaQueueable(List<DNS_CustomerDealerAssociation__c> insertCdaList, User u, Integer retryCount, String jobName) {
        this.insertCdaList = insertCdaList;
        this.u = u;
        this.retryCount = retryCount;
        this.jobName = jobName + '_' + retryCount;
    }

    public void execute(QueueableContext context) {
        List<DNS_CustomerDealerAssociation__c> finalInsertList = new List<DNS_CustomerDealerAssociation__c>();
        List<DNS_CustomerDealerAssociation__c> retryList = new List<DNS_CustomerDealerAssociation__c>();
        Set<Id> accIds = new Set<Id>();
        
        for (DNS_CustomerDealerAssociation__c cda : insertCdaList) {
            if (cda.Customer__c != null) {
                accIds.add(cda.Customer__c);
            }
            if (cda.Dealer__c != null) {
                accIds.add(cda.Dealer__c);
            }
        }

        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Id, CustomerCode__c
            FROM Account
            WHERE Id IN :accIds
        ]);

        List<DNS_CustomerDealerAssociation__c> cdaList = new List<DNS_CustomerDealerAssociation__c>();
        for (DNS_CustomerDealerAssociation__c cda : insertCdaList) {
            IF_ERP_Dealer_Classes.IF_DEALER_008_Req erpParameters = new IF_ERP_Dealer_Classes.IF_DEALER_008_Req();

            if (accMap.containsKey(cda.Customer__c)) {
                erpParameters.I_KUNNR = accMap.get(cda.Customer__c).CustomerCode__c;
            }
            if (accMap.containsKey(cda.Dealer__c)) {
                erpParameters.I_DEALER = accMap.get(cda.Dealer__c).CustomerCode__c;
            }
            erpParameters.I_VKORG = u.SalesOrganization__c;
            erpParameters.I_VTWEG = u.DistributionChannel__c;
            erpParameters.I_SPART = u.Division__c;

            IF_ERP_Dealer erpService = new IF_ERP_Dealer();
            IF_ERP_Dealer_Classes.IF_DEALER_008_Res erpResponse = erpService.IF_DEALER_008(erpParameters);

            if (erpResponse.O_RECODE == 'S') {
                cdaList.add(cda);
                System.debug('Response 성공');
            } else {
                if (retryCount < MAX_RETRIES) {
                    retryList.add(cda);
                    System.debug('재시도 리스트에 추가됨: ' + cda + ', 재시도 횟수: ' + retryCount);
                } else {
                    cda.addError('ERP 검증 실패, ' + MAX_RETRIES + '번 재시도 후: ' + (erpResponse.O_REMSG != null ? erpResponse.O_REMSG : '알 수 없는 오류'));
                    System.debug('최대 재시도 횟수 도달: ' + cda + ', 오류: ' + erpResponse.O_REMSG);
                }
            }
        }

        if(!cdaList.isEmpty()) {
            insert cdaList;
        }

        if (!retryList.isEmpty() && retryCount < MAX_RETRIES) {
            InsertCdaQueueable retryJob = new InsertCdaQueueable(retryList, u, retryCount + 1, jobName);
            Datetime nextRunTime = System.now().addMinutes(RETRY_DELAY_MINUTES);
            String cronExp = '0 ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
            try {
                System.enqueueJob(retryJob, 5);
                System.debug('재시도 ' + (retryCount + 1) + '번이 ' + nextRunTime + '에 스케줄링됨, 대상 레코드 수: ' + retryList.size());
            } catch (Exception e) {
                System.debug('재시도 스케줄링 오류: ' + e.getMessage());
            }
        }
    }
}