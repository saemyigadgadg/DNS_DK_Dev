/**
* @Class : DN_TicketDetailController
*
* @Author : Sangil, Park
* @Date : 2024. 12. 27.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-12-27 | Sangil, Park   | 최초작성
*/
public without sharing class DN_TicketDetailController {

    // Ticket 상세화면 Init
    @AuraEnabled
    public static TicketWrapper getTicketInfo(Id recordId){
        TicketWrapper res = new TicketWrapper();
        try{
            String profileId = [SELECT Id FROM Profile WHERE Name = 'DNS CS Receptionist'].Id;
            Case ticket = [SELECT 
                           // 접수
                           ID, Status, EndOfReason__c, ResultOfMeasure__c, ClosedReasonDetails__c, RejectReasonDetails__c, AssignHoldingReason__c, AccountId, AssetId, Asset.AccountId, Requester__c, InternalRequester__c, FM_PhoneNumber__c, Asset.ObjectType__c, RecordType.DeveloperName, Dealer__c, DealerContact__c,
                           isAlarmToCustomer__c, ReceptionDetails__c, Progress__c, TicketType__c, InternalTicketType__c, Campaign__c, ReceptionPath__c, ApplicationDateTime__c, BreakdownDateTime__c, OriginTicket__c, FailureStatus__c, IsUrgency__c, IsReGenerate__c, SalesOrder__c, Pendingprocessing__c, 
                           // 기술상담
                           FailureArea__c, FailureAreaValue__c, FailureAreaDetail__c, FailureAreaDetailValue__c, FailurePhenomenon__c, FailurePhenomenonValue__c, RepairRequestDateTime__c, 
                           // 미오후납
                           ModelCode__c, Producer__c, NotiNO__c, Occurrence_Classification__c, SVOrdNo__c, DeliveryOfRecoveredGoods__c,
                           // 납품 후 교육
                           ContactPosition__c, SalesDealer__c, ContactPhone__c, TrainingCount__c, TrainingType__c, TraineeLevel__c, TrainingDateTime1__c, TrainingDateTime2__c, TrainingDateTime3__c
                           FROM Case
                           WHERE ID =: recordId];
            // Ticket(DNSA)
            res.ticketRecordType                = ticket.RecordType.DeveloperName;
            res.isUserProfile                   = UserInfo.getProfileId() == profileId ? true : false;
            // res.isUserProfile                   = false;
            res.reception.status 				= ticket.Status;
            res.reception.ticketTypeMajor 		= ticket.TicketType__c;
            res.reception.accountId 			= ticket.AccountId;
            res.reception.ticketTypeSub 	 	= ticket.InternalTicketType__c;
            res.reception.assetId 				= ticket.AssetId;
            res.reception.campaignId 			= ticket.Campaign__c;
            res.reception.contactId 			= ticket.Requester__c;
            res.reception.channel 				= ticket.ReceptionPath__c;
            res.reception.internalUserId 		= ticket.InternalRequester__c;
            res.reception.receptionDate 		= ticket.ApplicationDateTime__c;
            res.reception.phone 				= ticket.FM_PhoneNumber__c;
            res.reception.failureDate 			= ticket.BreakdownDateTime__c;
            res.reception.alramTalk 			= ticket.isAlarmToCustomer__c;
            res.reception.originTicket 			= ticket.OriginTicket__c;
            res.reception.receptionDetail 		= ticket.ReceptionDetails__c;
            res.reception.failureStatus 		= ticket.FailureStatus__c;
            res.reception.progressDetail 		= ticket.Progress__c;
            res.reception.urgentFlag 			= ticket.IsUrgency__c;
            res.reception.recycleFalg 			= ticket.IsReGenerate__c;
            res.reception.closeReason			= ticket.EndOfReason__c;
            res.reception.assetAccountId	    = ticket.Asset.AccountId;
            res.reception.dealerId	            = ticket.Dealer__c;
            res.reception.dealerContactId	    = ticket.DealerContact__c;

            res.technical.failureArea           = ticket.FailureAreaValue__c;
            res.technical.failureAreaLabel      = ticket.FailureArea__c;
            res.technical.failureDetail         = ticket.FailureAreaDetailValue__c;
            res.technical.failureDetailLabel    = ticket.FailureAreaDetail__c;
            res.technical.failurePhen           = ticket.FailurePhenomenonValue__c;
            res.technical.failurePhenLabel      = ticket.FailurePhenomenon__c;
            res.technical.fixRequestDate        = ticket.RepairRequestDateTime__c == null ? '' : ticket.RepairRequestDateTime__c.format('yyyy. MM. dd. a hh:mm');
            
            //PickList Setting
            res.ticketSelectOption.ticketTypeMajor  = getPickList('Case', 'TicketType__c');
            res.ticketSelectOption.ticketStatus     = getPickList('Case', 'Status');
            res.ticketSelectOption.closeReason      = getPickList('Case', 'EndOfReason__c');
            res.ticketSelectOption.resultOfMeasure  = getPickList('Case', 'ResultOfMeasure__c');
            res.ticketSelectOption.failureAreaMajor = getFailureAreaMajor(ticket.Asset.ObjectType__c);
            if (!String.isEmpty(ticket.FailureAreaValue__c)) {
                res.ticketSelectOption.FailureAreaMiddle = getFailureAreaMiddle(ticket.FailureAreaValue__c);
                String middleValue = ticket.FailureAreaValue__c + ticket.FailureAreaDetailValue__c;
                res.ticketSelectOption.FailurePhenomenon = getFailurePhenomenon2(middleValue);
            }
        }catch(Exception e){
            res.callResponse.isSuccess 	= False;
            res.callResponse.errMsg 	= e.getMessage();
        }
        return res;
    }

    // Asset의 정보 가져오는 메서드
    @AuraEnabled
    public static Asset getSelectAssetAccount(String assetId) {
        Asset asset = [SELECT Id, AccountId, SoldTo__c, InstWorkCenter__c, ManufacturerName__c FROM Asset WHERE Id = :assetId];

        return asset;
    }

    // 해당 장비의 Account와 Ticket의 Account가 동일한지 판별하는 메서드
    @AuraEnabled
    public static AssetResultWrapper judgeAccountId(String assetId, String accountId){
        System.debug('assetId ::: ' + assetId);
        System.debug('accountId ::: ' + accountId);
        AssetResultWrapper result = new AssetResultWrapper();
        try {
            Asset asset = [SELECT Id, AccountId FROM Asset WHERE Id = :assetId];
            if (asset.AccountId != null && accountId != '' && asset.AccountId != accountId) {
                result.isSuccess = false;
                result.errMsg = '장비에 등록된 고객사와 다릅니다. 확인 부탁드립니다.';
            } else if (asset.AccountId != null && accountId == '') {
                result.isSuccess = false;
                result.errMsg = '장비에 등록된 고객사와 다릅니다. 확인 부탁드립니다.';
            }
        } catch (Exception e) {
            result.isSuccess = false;
            result.errMsg = 'Error ::: ' + e.getMessage() + 'Line ::: ' + e.getLineNumber();
        }
        return result;
    }

    // Ticket의 Owner와 Escalation Level의 정보를 가져오는 메서드
    @AuraEnabled
    public static Case getTicket(String ticketId) {
        Case ticket = [SELECT Id, OwnerId, EscLev__c FROM Case WHERE Id = :ticketId LIMIT 1];

        return ticket;
    }

    // Ticket이관 버튼 보달에서 선택한 유저와 Escalation Level로 Ticket을 업데이트하는 메서드
    @AuraEnabled
    public static ResultWrapper updateTicket(String ticketId, String escLev, String escUserId) {
        ResultWrapper result = new ResultWrapper();

        try {
            System.debug('ticketId ::: ' + ticketId);
            System.debug('escLev ::: ' + escLev);
            System.debug('escUserId ::: ' + escUserId);

            Case ticket = [SELECT Id, EscLev__c, OwnerId FROM Case WHERE Id = :ticketId LIMIT 1];
            ticket.EscLev__c = escLev;
            ticket.OwnerId = escUserId;
            
            Database.SaveResult sr = Database.update(ticket);

            if (sr.isSuccess()) {
                result.isSuccess = true;
                result.message = 'Update Success';
            } else {
                result.isSuccess = false;
                result.message = 'Update Fail';
            }

            
        } catch (Exception e) {
            System.debug('Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber());
            result.isSuccess = false;
            result.message = 'Error ::: ' + e.getMessage() + ' Line ::: ' + e.getLineNumber();
            
        }

        return result;
    }

    // 고장부위 가져오는 메서드
    public static List<CustomSelectOptionWrapper> getFailureAreaMajor(String objectType) {
        List<CustomSelectOptionWrapper> picklistvalues = new List<CustomSelectOptionWrapper>();
        List<DN_FailureAreaController.CustomSelectOption> resList = DN_FailureAreaController.getFailureAreaMajor(objectType);
        for (DN_FailureAreaController.CustomSelectOption res : resList) {
            CustomSelectOptionWrapper option = new CustomSelectOptionWrapper();
            option.label = res.label;
            option.value = res.value;
            picklistvalues.add(option);
        }

        return picklistvalues;
    }

        // 장비 변경시 해당 장비에 맞는 고장부위 List를 가져오는 메서드
    @AuraEnabled    
    public static List<CustomSelectOptionWrapper> changeAssetFailureAreaMajor(Id assetId) {

        String objectType = [SELECT Id, ObjectType__c FROM Asset WHERE Id = :assetId].ObjectType__c;

        List<CustomSelectOptionWrapper> picklistvalues = new List<CustomSelectOptionWrapper>();
        List<DN_FailureAreaController.CustomSelectOption> resList = DN_FailureAreaController.getFailureAreaMajor(objectType);
        for (DN_FailureAreaController.CustomSelectOption res : resList) {
            CustomSelectOptionWrapper option = new CustomSelectOptionWrapper();
            option.label = res.label;
            option.value = res.value;
            picklistvalues.add(option);
        }

        return picklistvalues;
    }

    // 고장부위에 맞는 고장부위(상세) List를 가져오는 메서드
    @AuraEnabled
    public static List<CustomSelectOptionWrapper> getFailureAreaMiddle(String majorValue) {
        List<CustomSelectOptionWrapper> picklistvalues = new List<CustomSelectOptionWrapper>();
        List<DN_FailureAreaController.CustomSelectOption> resList = DN_FailureAreaController.getFailureAreaMiddle(majorValue);
        for (DN_FailureAreaController.CustomSelectOption res : resList) {
            CustomSelectOptionWrapper option = new CustomSelectOptionWrapper();
            option.label = res.label;
            option.value = res.value;
            picklistvalues.add(option);
        }

        return picklistvalues;
    }

    // 고장부위(상세)에 맞는 고장현상 List를 가져오는 메서드
    @AuraEnabled
    public static List<CustomSelectOptionWrapper> getFailurePhenomenon2(String middleValue) {
        List<CustomSelectOptionWrapper> picklistvalues = new List<CustomSelectOptionWrapper>();
        List<DN_FailureAreaController.CustomSelectOption> resList = DN_FailureAreaController.getFailurePhenomenon(middleValue);
        for (DN_FailureAreaController.CustomSelectOption res : resList) {
            CustomSelectOptionWrapper option = new CustomSelectOptionWrapper();
            option.label = res.label;
            option.value = res.value;
            picklistvalues.add(option);
        }

        return picklistvalues;
    }

    // 오브젝트의 Picklist 필드의 값과 라벨을 가져오는 메서드
    public static List<CustomSelectOptionWrapper> getPickList(String objectName, String fieldName){
        List<CustomSelectOptionWrapper> picklistvalues = new List<CustomSelectOptionWrapper>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
        Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry a : ple){
            CustomSelectOptionWrapper option = new CustomSelectOptionWrapper();
            option.label = a.getLabel();
            option.value = a.getValue();
            picklistvalues.add(option);
        }
         return picklistvalues;
    }

    public class TicketSelectOptionWrapper{ 
        @AuraEnabled public List<CustomSelectOptionWrapper> ticketTypeMajor      {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> ticketTypeSub        {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> ticketStatus         {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> receptionPath        {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> failureStatus        {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> failureMajor         {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> failureSub           {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> failureSituation     {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> supplyCompany        {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> closeReason          {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> resultOfMeasure      {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> failureAreaMajor     {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> FailureAreaMiddle    {get; set;}
        @AuraEnabled public List<CustomSelectOptionWrapper> FailurePhenomenon    {get; set;}
        public TicketSelectOptionWrapper(){
            ticketTypeMajor         = new List<CustomSelectOptionWrapper>();
            ticketTypeSub           = new List<CustomSelectOptionWrapper>();
            ticketStatus            = new List<CustomSelectOptionWrapper>();
            receptionPath           = new List<CustomSelectOptionWrapper>();
            failureStatus           = new List<CustomSelectOptionWrapper>();
            failureMajor            = new List<CustomSelectOptionWrapper>();
            failureSub              = new List<CustomSelectOptionWrapper>();
            failureSituation        = new List<CustomSelectOptionWrapper>();
            supplyCompany           = new List<CustomSelectOptionWrapper>();
            closeReason             = new List<CustomSelectOptionWrapper>();
            resultOfMeasure         = new List<CustomSelectOptionWrapper>();
            failureAreaMajor        = new List<CustomSelectOptionWrapper>();
            FailureAreaMiddle        = new List<CustomSelectOptionWrapper>();
            FailurePhenomenon        = new List<CustomSelectOptionWrapper>();
        }
    }

    // Custom PickList Wrapper
    public class CustomSelectOptionWrapper{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}
    }


    // 전체 접수 이력 Wrapper
    public class TicketWrapper{
        @AuraEnabled public String ticketRecordType    					    {get; set;}
        @AuraEnabled public Boolean isUserProfile    					    {get; set;}
        @AuraEnabled public RecpetionWrapper reception    					{get; set;}
        @AuraEnabled public TechnicalWrapper technical     					{get; set;}
        @AuraEnabled public RecpetionWrapper missingParsts 					{get; set;}
        @AuraEnabled public ResponseWrapper  callResponse  					{get; set;}
        @auraEnabled public TicketSelectOptionWrapper ticketSelectOption	{get; set;}
        public TicketWrapper(){
            reception 				= new RecpetionWrapper();
            technical 				= new TechnicalWrapper();
            missingParsts 			= new RecpetionWrapper();
            callResponse 			= new ResponseWrapper();
            ticketSelectOption 		= new TicketSelectOptionWrapper();
        }
    }

    // 접수이력 Wrapper
    public class RecpetionWrapper{
        @AuraEnabled public String 		status 			{get; set;}
        @AuraEnabled public String 		ticketTypeMajor {get; set;}
        @AuraEnabled public ID     		accountId 		{get; set;}
        @AuraEnabled public String 		ticketTypeSub	{get; set;}
        @AuraEnabled public ID     		assetId 		{get; set;}
        @AuraEnabled public ID     		campaignId		{get; set;}
        @AuraEnabled public ID 	   		contactId 		{get; set;}
        @AuraEnabled public String 	    channel	 		{get; set;}
        @AuraEnabled public ID 	   		internalUserId	{get; set;}
        @AuraEnabled public DateTime   	receptionDate	{get; set;}
        @AuraEnabled public String  	phone			{get; set;}
        @AuraEnabled public DateTime  	failureDate		{get; set;}
        @AuraEnabled public Boolean  	alramTalk		{get; set;}
        @AuraEnabled public ID	  		originTicket	{get; set;}
        @AuraEnabled public String  	receptionDetail	{get; set;}
        @AuraEnabled public String  	failureStatus	{get; set;}
        @AuraEnabled public String  	progressDetail	{get; set;}
        @AuraEnabled public String  	closeReason 	{get; set;}
        @AuraEnabled public Boolean  	urgentFlag	    {get; set;}
        @AuraEnabled public Boolean  	recycleFalg	    {get; set;}
        @AuraEnabled public String      resultOfMeasure {get; set;}
        @AuraEnabled public String      assetAccountId  {get; set;}
        @AuraEnabled public String      dealerId        {get; set;}
        @AuraEnabled public String      dealerContactId {get; set;}
    }

    // 기술상담 Wrapper
    public class TechnicalWrapper{
        @AuraEnabled public String 		failureArea		    {get; set;}
        @AuraEnabled public String 		failureAreaLabel    {get; set;}
        @AuraEnabled public String 		failureDetail 	    {get; set;}
        @AuraEnabled public String 		failureDetailLabel 	{get; set;}
        @AuraEnabled public String 		failurePhen 	    {get; set;}
        @AuraEnabled public String 		failurePhenLabel 	{get; set;}
        @AuraEnabled public String 		fixRequestDate      {get; set;}
    }

    // 미오후납 Wrapper
    public class MissingPartsWrapper{
        @AuraEnabled public String 		modelCode		{get; set;}
        @AuraEnabled public String 		accureType   	{get; set;}
        @AuraEnabled public ID 		    installCompany 	{get; set;}
        @AuraEnabled public String 		svOrder         {get; set;}
        @AuraEnabled public String 		supplyCompany   {get; set;}
        @AuraEnabled public String 		doDeilvery      {get; set;}
        @AuraEnabled public String 		notiNo          {get; set;}
    }
    
    // API CALL Status Wrapper
    public class ResponseWrapper{
        @AuraEnabled public Boolean		isSuccess  		{get; set;}
        @AuraEnabled public String 		errMsg   		{get; set;}
        public ResponseWrapper(){
            isSuccess 	= true;
            errMsg 		= '';
        }
    }

    public class AssetResultWrapper{
        @AuraEnabled public Boolean		isSuccess  		{get; set;}
        @AuraEnabled public String 		errMsg   		{get; set;}
        public AssetResultWrapper(){
            isSuccess 	= true;
            errMsg 		= '';
        }
    }

    public class ResultWrapper {
        @AuraEnabled public Boolean		isSuccess  		{get; set;}
        @AuraEnabled public String 		message   		{get; set;}

        public ResultWrapper(){
            this.isSuccess 	= true;
            this.message    = '';
        }
    }
}