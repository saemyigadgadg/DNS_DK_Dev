/**
* @Class : DN_DNSAPreCallConfirmController
*
* @Author : Junyeong, Choi
* @Date : 2025. 01. 15.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2025-01-15 | Junyeong, Choi   | 최초작성
*
*/
public without sharing class DN_DNSAPreCallConfirmController {
    public String recordID 			{get;set;}
    public String Reason 			{get;set;} 
    public Boolean hasResponse		{get;set;}
    public Boolean isCompleted		{get;set;}
    public Boolean isDelete			{get;set;}
    /**
    @description       : DNSA Pre-Call 및 Missing Part 시행 확인 여부 Page
    **/
    public DN_DNSAPreCallConfirmController() {
        recordID 	= ApexPages.currentPage().getParameters().get('recordID');
        System.debug('recordID'+recordID);
        hasResponse = False;
        isCompleted = False;    // Thank you

        CampaignAsset__c checkDelete = [SELECT Id, EmailStatus__c, Reason__c FROM CampaignAsset__c WHERE Id =: recordID];
        if(checkDelete != null) {
            isDelete = False;
        } else {
            isDelete = True;
        }

        if(checkDelete.EmailStatus__c == 'Completed' || checkDelete.EmailStatus__c == 'Not Completed') {
            hasResponse = true;
        }
    }
    
    public void saveReject() {  // Not Completed
        try{
            CampaignAsset__c ca = [SELECT Id, EmailStatus__c, Reason__c FROM CampaignAsset__c WHERE Id =: recordID];    
            ca.EmailStatus__c   = 'Not Completed';
            ca.Reason__c        = Reason;
            Update ca;
            isCompleted = True; // Thank you
        }catch(Exception e){
            hasResponse = True;
        }
    }
    
    public void updateRec() {  // Completed
        try{
            CampaignAsset__c ca = [SELECT Id, EmailStatus__c, Reason__c FROM CampaignAsset__c WHERE Id =: recordID];
            if(ca.EmailStatus__c != 'Send') {
                ca.EmailStatus__c = 'Completed';
                ca.Reason__c      = Reason;
                Update ca;
            } else {
                hasResponse = True;
            }
            isCompleted = True; // Thank you
        }catch(Exception e){
            hasResponse = True;
        }
    }
}