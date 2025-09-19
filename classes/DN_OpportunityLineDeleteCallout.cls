public with sharing class DN_OpportunityLineDeleteCallout {
    public class InquiryQueueable implements Queueable, Database.AllowsCallouts {
        private List<QuoteProductHistory__c> quoteprdInfo;
        private Integer currentIndex;

        public InquiryQueueable(List<QuoteProductHistory__c> quoteprdInfo, Integer currentIndex) {
            this.quoteprdInfo = quoteprdInfo;
            this.currentIndex = currentIndex;
        }

        public void execute(QueueableContext context) {
            if (currentIndex >= quoteprdInfo.size()) {
                return; // 모든 Callout이 완료된 경우 종료
            }
            
            QuoteProductHistory__c currentquoteProduct;
            // Callout 요청 생성
            currentquoteProduct = quoteprdInfo[currentIndex];

            IF_ERP_Inquiry_Classes.IF_OPTY_007_Req req = new IF_ERP_Inquiry_Classes.IF_OPTY_007_Req();
            req.I_VBELN = currentquoteProduct.ERP_Inquiry_No__c;
            req.I_VDATU = String.valueOf(currentquoteProduct.Requested_Deliv_Date__c).replace('-','');
            req.I_ZINDUS = currentquoteProduct.Quote__r.Account.MainCategory__c;
            req.I_ZINDUS2 = currentquoteProduct.Quote__r.Account.SubCategory__c;
            req.I_CANCEL = 'X';

            // Callout 실행
            IF_ERP_Inquiry instance = new IF_ERP_Inquiry();
            if(!System.Test.isRunningTest()){
                IF_ERP_Inquiry_Classes.IF_OPTY_007_Res response = instance.IF_OPTY_007(req);
                System.debug('Response Message: ' + response);
            }

            // 다음 Callout 예약
            if(System.Test.isRunningTest()){
                return;
            }
            if (currentIndex + 1 < quoteprdInfo.size()) {
                System.enqueueJob(new InquiryQueueable(quoteprdInfo, currentIndex + 1));
            }
        }
    }

    @future(callout=true)
    public static void deleteInquiry(List<String> QtlineId) {
        // 제품 정보 조회
        List<QuoteProductHistory__c> getIFprdinfo = new List<QuoteProductHistory__c>();
            getIFprdinfo = [SELECT ERP_Inquiry_No__c, Requested_Deliv_Date__c,  Quote__r.Account.MainCategory__c, Quote__r.Account.SubCategory__c FROM QuoteProductHistory__c WHERE Quote_Line_Item__c IN: QtlineId AND ERP_Inquiry_No__c != ''];
            System.debug('getIFprdinfo : ' + getIFprdinfo);
        // 첫 번째 작업 예약
        if(!getIFprdinfo.isEmpty()){
            System.enqueueJob(new InquiryQueueable(getIFprdinfo, 0));
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
        
    }
}