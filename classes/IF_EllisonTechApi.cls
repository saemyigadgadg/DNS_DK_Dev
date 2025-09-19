/**
 * @description       : 
 * @author            : seouk.sung@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : deokjun.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-22-2025   seouk.sung@sbtglobal.com   Second Version
**/
@RestResource(urlMapping='/insert_ellison_objects/*')
global with sharing class IF_EllisonTechApi {
        
        global class  EllisonRequestDto{
            public EllisonRequestDto(){}
            public List<EllisonOpportunity> Opportunity {get;set;}

            public List<IF_EllisonBatch.EllisonBatchDto> toBatchDto(){
                List<IF_EllisonBatch.EllisonBatchDto> batchList = new List<IF_EllisonBatch.EllisonBatchDto>();
                // convert oppty to batch dto
                for(IF_EllisonTechApi.EllisonOpportunity oppty : this.Opportunity){
                    IF_EllisonBatch.EllisonBatchDto batchDto = new IF_EllisonBatch.EllisonBatchDto();

                    batchDto.CustomerCode = oppty.CustomerCode;
                    batchDto.AccountName = oppty.AccountName;
                    batchDto.AccountOwnerId = oppty.AccountOwnerId;
                    batchDto.Representative = oppty.Representative;
                    batchDto.CountryLookup = oppty.CountryLookup;
                    batchDto.RegionLookup = oppty.RegionLookup;
                    batchDto.ShippingCountry = oppty.ShippingCountry;
                    batchDto.ShippingStreet = oppty.ShippingStreet;
                    batchDto.ShippingCity = oppty.ShippingCity;
                    batchDto.ShippingState = oppty.ShippingState;
                    batchDto.ShippingPostalCode = oppty.ShippingPostalCode;
                    batchDto.AccountPhone = oppty.AccountPhone;
                    batchDto.AccountEmail = oppty.AccountEmail;
                    batchDto.AccountShippingAddress = oppty.AccountShippingAddress;
                    batchDto.AlternateShipToAddress = oppty.AlternateShipToAddress;
                    batchDto.AltShipToName = oppty.AltShipToName;
                    batchDto.AccountId = oppty.AccountId;

                    batchDto.ContactOwnerId = oppty.ContactOwnerId;
                    batchDto.LastName = oppty.LastName;
                    batchDto.MiddleName = oppty.MiddleName;
                    batchDto.FirstName = oppty.FirstName;
                    batchDto.ContactAccountId = oppty.ContactAccountId;
                    batchDto.ContactEmail = oppty.ContactEmail;
                    batchDto.MobilePhone = oppty.MobilePhone;
                    batchDto.ContactPhone = oppty.ContactPhone;

                    batchDto.OpportunityOwnerId = oppty.OpportunityOwnerId;
                    batchDto.DNSAModel = oppty.DNSAModel;
                    batchDto.Probability = oppty.Probability;
                    batchDto.CloseDate = oppty.CloseDate;
                    batchDto.RequestDelieveryDate = oppty.RequestDelieveryDate;
                    batchDto.PO = oppty.PO;
                    batchDto.OpportunityName = oppty.OpportunityName;
                    batchDto.Competitor = oppty.Competitor;
                    batchDto.OpportunityId = oppty.OpportunityId;

                    batchList.add(batchDto);    
                } 

                return batchList;
            }        
        }

        global class EllisonOpportunity{
            //Account
            public String CustomerCode {get;set;}
            public String AccountName {get;set;}
            public String AccountOwnerId {get;set;}
            public String Representative {get;set;}
            public String CountryLookup {get;set;}
            public String RegionLookup {get;set;}
            public String ShippingCountry {get;set;}
            public String ShippingStreet {get;set;}
            public String ShippingCity {get;set;}
            public String ShippingState {get;set;}
            public String ShippingPostalCode {get;set;}
            public String AccountPhone {get;set;}
            public String AccountEmail {get;set;}
            public String AccountShippingAddress {get;set;}
            public String AlternateShipToAddress {get;set;}
            public String AltShipToName {get;set;}
            public String AccountId {get;set;}
            // Contact
            public String ContactOwnerId {get;set;}
            public String LastName {get;set;}
            public String MiddleName {get;set;}
            public String FirstName {get;set;}
            public String ContactAccountId {get;set;}
            public String ContactEmail {get;set;}
            public String MobilePhone {get;set;}
            public String ContactPhone {get;set;}
            // Opportunity
            public String OpportunityOwnerId   {get;set;}
            public String DNSAModel            {get;set;}
            public String Probability          {get;set;}
            public String CloseDate            {get;set;}
            public String RequestDelieveryDate {get;set;}
            public String PO                   {get;set;}
            public String OpportunityName      {get;set;}
            public String Competitor           {get;set;}
            public String OpportunityId        {get;set;}
        }

    /**
        RESPONSE DTO
    */
        global class EllisionResponseDto{
            public String code {get;set;}
            public String message {get;set;}
            public Object data {get;set;}

            public EllisionResponseDto(){}
            public EllisionResponseDto(String code, String message, Object data){
                this.code     = code;
                this.message = message;
                this.data     = data;
                
            }
            public EllisionResponseDto OK(String code, String message, Object data){
                this.code     = '201';
                this.message = 'Create Success';
                this.data     = data;

                return new EllisionResponseDto(this.code,this.message,this.data);
            }
        }

    @HttpPost
    global static Map<String,String> callOut(){
        RestRequest  request   = RestContext.request;
        RestResponse response  = RestContext.response;

        // GET Request QueryString
        String urlInfo      = request.requestURI;

        // Get Request Body
        String requestBody = request.requestBody.toString();

        IF_EllisonTechApi.EllisonRequestDto requestDataList = (IF_EllisonTechApi.EllisonRequestDto) JSON.deserialize(requestBody, IF_EllisonTechApi.EllisonRequestDto.class);

        IF_EllisonBatch batch = new IF_EllisonBatch(requestDataList.toBatchDto());
        Database.executeBatch(batch, 50); 

        Map<String,String> testMap = new Map<String,String>();
        testMap.put('code','201');
        testMap.put('message','create success');
        return testMap;
    }               
}