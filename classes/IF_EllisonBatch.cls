/**
 * @description       : 
 * @author            : deokjun.kim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-07-2025   deokjun.kim@sbtglobal.com   Initial Version
**/
global with sharing class IF_EllisonBatch
                    implements Database.Batchable<IF_EllisonBatch.EllisonBatchDto>,
                    Database.AllowsCallouts, 
                    Database.Stateful  {

    public IF_EllisonBatch(){}
                        
    public IF_EllisonBatch(List<IF_EllisonBatch.EllisonBatchDto> requestDataList) {
        this.requestDataList = requestDataList  ;
    }


    // REQUEST 
    public List<IF_EllisonBatch.EllisonBatchDto> requestDataList {get;set;}

    // BATCH RESULT FIELDS 
    public String  status       {get;set;}
    public Integer successCnt   {get;set;}
    public Integer failCnt      {get;set;}

    // START
    public Iterable<IF_EllisonBatch.EllisonBatchDto> start(Database.BatchableContext BC){
        return this.requestDataList;
    }

    // EXECUTE
    public void execute(Database.BatchableContext BC, List<IF_EllisonBatch.EllisonBatchDto> scope ){
        List<IF_ET__c> etList = convertToET(scope);
        insert etList;
    }

    // FINISH
    public void finish(Database.BatchableContext BC){
        System.debug('test');
    }


    /**
        REQUEST DTO
    */
    global class EllisonBatchDto{
        public EllisonBatchDto(){}
        public String typeNm  {get;set;}
        public String OwnerId {get;set;}
        public String DNSAModel {get;set;}
        public String Probability {get;set;}
        public String CloseDate {get;set;}
        public String RequestDelieveryDate {get;set;}
        public String PO {get;set;}
        public String Name {get;set;}
        public String Competitor {get;set;}
        public String OpportunityId {get;set;}
        public String CustomerCode {get;set;}
        public String Representative {get;set;}
        public String CountryLookup {get;set;}
        public String RegionLookup {get;set;}
        public String ShippingCountry {get;set;}
        public String ShippingStreet {get;set;}
        public String ShippingCity {get;set;}
        public String ShippingState {get;set;}
        public String ShippingPostalCode {get;set;}
        public String Phone {get;set;}
        public String AccountId {get;set;}
        public String LastName {get;set;}
        public String MiddleName {get;set;}
        public String FirstName {get;set;}
        public String Email {get;set;}
        public String MobilePhone {get;set;}    
        public String AccountName {get;set;}    
        public String AccountOwnerId {get;set;}    
        public String AccountPhone {get;set;}    
        public String AccountEmail {get;set;}    
        public String AccountShippingAddress {get;set;}    
        public String AlternateShipToAddress {get;set;}    
        public String AltShipToName {get;set;}    
        public String ContactOwnerId {get;set;}    
        public String ContactAccountId {get;set;}    
        public String ContactEmail {get;set;}    
        public String ContactPhone {get;set;}    
        public String OpportunityOwnerId {get;set;}    
        public String OpportunityName {get;set;}
    }


    /** convert To Et
     */
    public List<IF_ET__c> convertToET(List<EllisonBatchDto> requestList){
        List<IF_ET__c> etList = new List<IF_ET__c>();
        
        for(EllisonBatchDto requestDto : requestList){
                IF_ET__c ifTableET = new IF_ET__c();

                // Account
                ifTableET.CustomerCode__c = requestDto.CustomerCode;
                ifTableET.Name__c = requestDto.AccountName;
                ifTableET.AccountOwnerId__c = requestDto.AccountOwnerId;
                ifTableET.Representative__c = requestDto.Representative;
                ifTableET.CountryLookup__c = requestDto.CountryLookup;
                ifTableET.RegionLookup__c = requestDto.RegionLookup;
                ifTableET.ShippingCountry__c = requestDto.ShippingCountry;
                ifTableET.ShippingStreet__c = requestDto.ShippingStreet;
                ifTableET.ShippingCity__c = requestDto.ShippingCity;
                ifTableET.ShippingState__c = requestDto.ShippingState;
                ifTableET.ShippingPostalCode__c = requestDto.ShippingPostalCode;
                ifTableET.AccountPhone__c = requestDto.AccountPhone;
                ifTableET.AccountEmail__c = requestDto.AccountEmail;
                ifTableET.AccountShippingAddress__c = requestDto.AccountShippingAddress;
                ifTableET.AlternateShipToAddress__c = requestDto.AlternateShipToAddress;
                ifTableET.AltShipToName__c = requestDto.AltShipToName;
                ifTableET.AccountId__c = requestDto.AccountId;

                // Contact
                ifTableET.ContactOwnerId__c = requestDto.ContactOwnerId;
                ifTableET.LastName__c = requestDto.LastName;
                ifTableET.MiddleName__c = requestDto.MiddleName;
                ifTableET.FirstName__c = requestDto.FirstName;
                ifTableET.ContactAccountId__c = requestDto.ContactAccountId;
                ifTableET.ContactEmail__c = requestDto.ContactEmail;
                ifTableET.MobilePhone__c = requestDto.MobilePhone;
                ifTableET.ContactPhone__c = requestDto.ContactPhone;

                // Opportunity
                ifTableET.OpportunityOwnerId__c = requestDto.OpportunityOwnerId;
                ifTableET.DNSAModel__c = requestDto.DNSAModel;
                ifTableET.Probability__c = requestDto.Probability;
                ifTableET.CloseDate__c = requestDto.CloseDate;
                ifTableET.RequestDelieveryDate__c = requestDto.RequestDelieveryDate;
                ifTableET.PO__c = requestDto.PO;
                ifTableET.OpportunityName__c = requestDto.OpportunityName;
                ifTableET.Competitor__c = requestDto.Competitor;
                ifTableET.OpportunityId__c = requestDto.OpportunityId;

            etList.add(ifTableET);
        }

        return etList;
    }

}