/**
* @Class : DN_ServiceHistoryController
* @Description : Ticket 상세화면의 서비스 접수 이력 목록
* @Author : Hayeong, Min
* @Date : 2024. 11. 08.
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ---------------------------------------------- 
*  1. | 2024-11-08 | Hayeong, Min   | 최초작성
*
*/
public with sharing class DN_ServiceHistoryController {
    /*
     * @Description
     * 	- 서비스 접수 이력 
     * 
     * @Parameter
     *  - ticketId	    : ticket Id
     *  - isTicket	    : Ticket Refresh 유무
     *  - isWorkOrder	: WorkOrder Refresh 유무
     */ 
    @AuraEnabled
    public static CommonWrapper getServiceHistory(String ticketId, Boolean isTicket, Boolean isWorkOrder){
        CommonWrapper cw = new CommonWrapper();
        try {
            Case ticket = [SELECT Id, AccountId, AssetId FROM Case WHERE Id = :ticketId];
            String accountId = String.isNotEmpty(String.valueOf(ticket.AccountId)) ? ticket.AccountId : '';
            String assetId = String.isNotEmpty(String.valueOf(ticket.AssetId)) ? ticket.AssetId : '';

            //서비스접수이력
            List<TicketWrapper> ticketResult = new List<TicketWrapper>();
            List<WorkOrderWrapper> workOrderResult = new List<WorkOrderWrapper>();
            if(isTicket || isWorkOrder){
                if((accountId != '') && (assetId != '')){
                    //Ticket List
                    List<Case> ticketList = [SELECT Id, CaseNumber, ReceptionDetails__c, Progress__c, toLabel(Status), ApplicationDateTime__c, Owner.Name
                                            FROM Case 
                                            WHERE AccountId = :accountId AND AssetId = :assetId 
                                            ORDER BY ApplicationDateTime__c DESC NULLS LAST];
                    System.debug('Ticket Length '+ticketList.size());
                    for(Case obj : ticketList){
                        TicketWrapper data = new TicketWrapper();
                        data.ApplicationDateTime 	= obj.ApplicationDateTime__c;
                        data.CaseNumber 	        = obj.CaseNumber;
                        data.TicketURL 	            = URL.getOrgDomainUrl().toExternalForm() + '/' + obj.Id;
                        data.Owner 	                = obj.Owner.Name;
                        data.ReceptionDetails 	    = obj.ReceptionDetails__c;
                        data.Progress 	            = obj.Progress__c;
                        data.TicketStatus 	        = obj.Status;
                        ticketResult.add(data); 
                    }
                    cw.ticketWrapper = ticketResult;
    
                    //WorkOrder List
                    List<WorkOrder> workOrderList = [SELECT FM_ApplicationDateTime__c, CaseId, Case.CaseNumber, 
                                                    Id, ServiceOrderNumber__c, toLabel(Status), toLabel(OrderType__c), TimeAgreedOnSite__c, 
                                                    ServiceTerritory.Name, Worker__r.Name, ScheduledDispatchTime__c,
                                                    ReceptionDetail__c, PendingOrCustomerMatters__c
                                                    FROM WorkOrder 
                                                    WHERE AccountId = :accountId AND AssetId = :assetId
                                                    ORDER BY FM_ApplicationDateTime__c DESC NULLS LAST];
                    System.debug('WorkOrder Length '+workOrderList.size());
                    for(WorkOrder obj : workOrderList){
                        WorkOrderWrapper data = new WorkOrderWrapper();
                        data.ApplicationDateTime 		    = obj.FM_ApplicationDateTime__c;
                        data.CaseNumber 	                = obj.Case.CaseNumber;
                        data.TicketURL 	                    = String.isNotEmpty(String.valueOf(obj.CaseId)) ? URL.getOrgDomainUrl().toExternalForm() + '/' + obj.CaseId : '';
                        data.OrderNumber 	                = obj.ServiceOrderNumber__c;
                        data.OrderURL 	                    = URL.getOrgDomainUrl().toExternalForm() + '/' + obj.Id;
                        data.OrderStatus 	                = obj.Status;
                        data.OnSiteDate 	                = obj.TimeAgreedOnSite__c;
                        data.OrderType 	                    = obj.OrderType__c;
                        data.WorkCenter 	                = obj.ServiceTerritory.Name;
                        data.ServiceResource 	            = obj.Worker__r.Name;
                        data.ReceptionDetails 	            = obj.ReceptionDetail__c;
                        data.InspectionDetails 	            = obj.PendingOrCustomerMatters__c;
                        data.ScheduledDispatchTime          = obj.ScheduledDispatchTime__c;
                        workOrderResult.add(data); 
                    }
    
                    cw.workOrderWrapper = workOrderResult;
                    System.debug('result '+workOrderResult);
                }
            }
            

        } catch (Exception e) {
            cw.isSuccess= false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /*
     * @Description
     * 	- 미결 접수 이력(=종결되지 않은 Ticket/WorkOrder 이력)
     * 
     * @Parameter
     *  - ticketId	    : ticket Id
     *  - isTicket	    : Ticket Refresh 유무
     *  - isWorkOrder	: WorkOrder Refresh 유무
     */ 
    @AuraEnabled
    public static CommonWrapper getNotClosedServiceHistory(String ticketId, Boolean isTicket, Boolean isWorkOrder){
        CommonWrapper cw = new CommonWrapper();
        try {
            Case ticket = [SELECT Id, AccountId, AssetId FROM Case WHERE Id = :ticketId];
            String accountId = String.isNotEmpty(String.valueOf(ticket.AccountId)) ? ticket.AccountId : '';
            String assetId = String.isNotEmpty(String.valueOf(ticket.AssetId)) ? ticket.AssetId : '';

            //미결접수이력
            List<TicketWrapper> ticketResult = new List<TicketWrapper>();
            List<WorkOrderWrapper> workOrderResult = new List<WorkOrderWrapper>();
            if(isTicket || isWorkOrder){
                if(accountId != ''){
                    //Ticket List
                    List<Case> ticketList = [SELECT Id, ApplicationDateTime__c, CaseNumber, toLabel(Status), Owner.Name,
                                            AssetId, Asset.Name, Asset.MachineName__c, ReceptionDetails__c, Progress__c,Asset.InstallationFinish__c, toLabel(EscLev__c)
                                            FROM Case 
                                            WHERE Status != 'Closed' AND AccountId = :accountId
                                            ORDER BY ApplicationDateTime__c DESC NULLS LAST];
                    System.debug('Ticket Length '+ticketList.size());
                    for(Case obj : ticketList){
                        TicketWrapper data = new TicketWrapper();
                        data.ApplicationDateTime 	= obj.ApplicationDateTime__c;
                        data.CaseNumber 	        = obj.CaseNumber;
                        data.TicketURL 	            = URL.getOrgDomainUrl().toExternalForm() + '/' + obj.Id;
                        data.TicketStatus 	        = obj.Status;
                        data.Owner 	                = obj.Owner.Name;
                        data.EscLev 	            = obj.EscLev__c;
                        data.AssetName 	            = obj.Asset.Name;
                        data.AssetURL 	            = String.isNotEmpty(String.valueOf(obj.AssetId)) ? URL.getOrgDomainUrl().toExternalForm() + '/' + obj.AssetId : '';
                        data.Model 	                = obj.Asset.MachineName__c;
                        data.ReceptionDetails 	    = obj.ReceptionDetails__c;
                        data.Progress 	            = obj.Progress__c;
                        data.InstallDate 	        = obj.Asset.InstallationFinish__c;
                        ticketResult.add(data); 
                    }
                    cw.ticketWrapper = ticketResult;
    
                    //WorkOrder List
                    List<WorkOrder> workOrderList = [SELECT FM_ApplicationDateTime__c, CaseId, Case.CaseNumber, ScheduledDispatchTime__c,
                                                    Id, ServiceOrderNumber__c, toLabel(Status), toLabel(OrderType__c), TimeAgreedOnSite__c, 
                                                    ServiceTerritory.Name, Worker__r.Name, 
                                                    AssetId, Asset.Name, Asset.MachineName__c,
                                                    ReceptionDetail__c, PendingOrCustomerMatters__c
                                                    FROM WorkOrder 
                                                    WHERE Status != 'Closed' AND AccountId = :accountId
                                                    ORDER BY FM_ApplicationDateTime__c DESC NULLS LAST];
                    System.debug('WorkOrder Length '+workOrderList.size());
                    for(WorkOrder obj : workOrderList){
                        WorkOrderWrapper data = new WorkOrderWrapper();
                        data.ApplicationDateTime 		    = obj.FM_ApplicationDateTime__c;
                        data.CaseNumber 	                = obj.Case.CaseNumber;
                        data.TicketURL 	                    = String.isNotEmpty(String.valueOf(obj.CaseId)) ? URL.getOrgDomainUrl().toExternalForm() + '/' + obj.CaseId : '';
                        data.OrderNumber 	                = obj.ServiceOrderNumber__c;
                        data.OrderURL 	                    = URL.getOrgDomainUrl().toExternalForm() + '/' + obj.Id;
                        data.OrderStatus 	                = obj.Status;
                        data.OnSiteDate 	                = obj.TimeAgreedOnSite__c;
                        data.OrderType 	                    = obj.OrderType__c;
                        data.WorkCenter 	                = obj.ServiceTerritory.Name;
                        data.ServiceResource 	            = obj.Worker__r.Name;
                        data.AssetURL 	                    = String.isNotEmpty(String.valueOf(obj.AssetId)) ? URL.getOrgDomainUrl().toExternalForm() + '/' + obj.AssetId : '';
                        data.AssetName 	                    = obj.Asset.Name;
                        data.Model 	                        = obj.Asset.MachineName__c;
                        data.ReceptionDetails 	            = obj.ReceptionDetail__c;
                        data.InspectionDetails 	            = obj.PendingOrCustomerMatters__c;
                        data.ScheduledDispatchTime          = obj.ScheduledDispatchTime__c;
                        workOrderResult.add(data); 
                    }
    
                    cw.workOrderWrapper = workOrderResult;
                    System.debug('result '+workOrderResult);
                }
            }
            

        } catch (Exception e) {
            cw.isSuccess= false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /*
     * @Description
     * 	- 동일하자이력
     *  - 동일기종의 고장부위, 현상 모두 일치하는 Ticket/Work Order 이력
     * 
     * @Parameter
     *  - ticketId	    : ticket Id
     *  - isTicket	    : Ticket Refresh 유무
     *  - isWorkOrder	: WorkOrder Refresh 유무
     */ 
    @AuraEnabled
    public static CommonWrapper getSameFailureHistory(String ticketId, Boolean isTicket, Boolean isWorkOrder){
        CommonWrapper cw = new CommonWrapper();
        try {
            Case ticket = [SELECT Id, AssetId, FM_AssetMachineName__c, FailureAreaValue__c, FailureAreaDetailValue__c, FailurePhenomenonValue__c
                            FROM Case 
                            WHERE Id = :ticketId];

            //동일하자이력
            List<TicketWrapper> ticketResult = new List<TicketWrapper>();
            List<WorkOrderWrapper> workOrderResult = new List<WorkOrderWrapper>();
            if(isTicket || isWorkOrder){
                if(String.isNotEmpty(String.valueOf(ticket.AssetId))){
                    String model = ticket.FM_AssetMachineName__c;//기종
                    String failurePart = String.isNotEmpty(String.valueOf(ticket.FailureAreaValue__c)) ? ticket.FailureAreaValue__c : '';//고장부위
                    String failurePartDetail = String.isNotEmpty(String.valueOf(ticket.FailureAreaDetailValue__c)) ? ticket.FailureAreaDetailValue__c : '';//고장부위(상세)
                    String phenomenon = String.isNotEmpty(String.valueOf(ticket.FailurePhenomenonValue__c)) ? ticket.FailurePhenomenonValue__c : '';//고장현상
                    Boolean isEmpty = true;

                    //Ticket List
                    String ticketFields = 'Id, ApplicationDateTime__c, CaseNumber, toLabel(Status), Owner.Name, toLabel(EscLev__c), AssetId, Asset.Name, FM_AssetMachineName__c, ReceptionDetails__c, Progress__c,Asset.InstallationFinish__c ';
                    String ticketQuery = 'SELECT '+ ticketFields +' FROM Case WHERE FM_AssetMachineName__c = \''+ model +'\'';
                    List<Case> ticketList = new List<Case>();
                    if(String.isNotEmpty(String.valueOf(ticket.FailureAreaValue__c))){
                        ticketQuery += ' AND FailureAreaValue__c = \''+ failurePart +'\'';
                        isEmpty = false;
                    }
                    if(String.isNotEmpty(String.valueOf(ticket.FailureAreaDetailValue__c))){
                        ticketQuery += ' AND FailureAreaDetailValue__c = \''+ failurePartDetail +'\'';
                        isEmpty = false;
                    }
                    if(String.isNotEmpty(String.valueOf(ticket.FailurePhenomenonValue__c))){
                        ticketQuery += ' AND FailurePhenomenonValue__c = \''+ phenomenon +'\'';
                        isEmpty = false;
                    }
                    ticketQuery += ' ORDER BY ApplicationDateTime__c DESC NULLS LAST';
                    System.debug('ticketQuery :::'+ticketQuery);

                    if(!isEmpty) ticketList = Database.query(ticketQuery);
                    System.debug('Ticket Length '+ticketList.size());

                    for(Case obj : ticketList){
                        TicketWrapper data = new TicketWrapper();
                        data.ApplicationDateTime 	= obj.ApplicationDateTime__c;
                        data.CaseNumber 	        = obj.CaseNumber;
                        data.TicketURL 	            = URL.getOrgDomainUrl().toExternalForm() + '/' + obj.Id;
                        data.TicketStatus 	        = obj.Status;
                        data.Owner 	                = obj.Owner.Name;
                        data.EscLev 	            = obj.EscLev__c;
                        data.AssetName 	            = obj.Asset.Name;
                        data.AssetURL 	            = URL.getOrgDomainUrl().toExternalForm() + '/' + obj.AssetId;
                        data.Model 	                = obj.FM_AssetMachineName__c;
                        data.ReceptionDetails 	    = obj.ReceptionDetails__c;
                        data.Progress 	            = obj.Progress__c;
                        data.InstallDate 	        = obj.Asset.InstallationFinish__c;
                        ticketResult.add(data); 
                    }
                    cw.ticketWrapper = ticketResult;
    
                    //WorkOrder List
                    String workOrderFields = 'FM_ApplicationDateTime__c, CaseId, Case.CaseNumber, Id, ScheduledDispatchTime__c, ServiceOrderNumber__c, toLabel(Status), toLabel(OrderType__c), TimeAgreedOnSite__c, ServiceTerritory.Name, Worker__r.Name, AssetId, Asset.Name, Asset.MachineName__c, ReceptionDetail__c, PendingOrCustomerMatters__c';

                    String workOrderQuery = 'SELECT '+ workOrderFields +' FROM WorkOrder WHERE Asset.MachineName__c = \''+ model +'\'';
                    List<WorkOrder> workOrderList = new List<WorkOrder>();

                    //Service Order에 고장정보가 없는 경우 Ticket에 있는 고장정보 보기
                    if(String.isNotEmpty(String.valueOf(ticket.FailureAreaValue__c)) && String.isNotEmpty(String.valueOf(ticket.FailureAreaDetailValue__c)) && String.isNotEmpty(String.valueOf(ticket.FailurePhenomenonValue__c))){
                        workOrderQuery += ' AND ((FailureAreaValue__c = \''+ failurePart +'\' AND FailureAreaGroupValue__c  = \''+ failurePartDetail +'\' AND FailurePhenomenonValue__c = \''+ phenomenon +'\')';

                        workOrderQuery += ' OR (Case.FailureAreaValue__c = \''+ failurePart +'\' AND Case.FailureAreaValue__c = \''+ failurePart +'\' AND AND Case.FailurePhenomenonValue__c = \''+ phenomenon +'\'))';
                        isEmpty = false;
                    }


                    workOrderQuery += ' ORDER BY FM_ApplicationDateTime__c DESC NULLS LAST';
                    System.debug('workOrderQuery :::'+workOrderQuery);


                    if(!isEmpty) workOrderList = Database.query(workOrderQuery);
                        
                    System.debug('WorkOrder Length '+workOrderList.size());
                    for(WorkOrder obj : workOrderList){
                        WorkOrderWrapper data = new WorkOrderWrapper();
                        data.ApplicationDateTime 		    = obj.FM_ApplicationDateTime__c;
                        data.CaseNumber 	                = obj.Case.CaseNumber;
                        data.TicketURL 	                    = String.isNotEmpty(String.valueOf(obj.CaseId)) ? URL.getOrgDomainUrl().toExternalForm() + '/' + obj.CaseId : '';
                        data.OrderNumber 	                = obj.ServiceOrderNumber__c;
                        data.OrderURL 	                    = URL.getOrgDomainUrl().toExternalForm() + '/' + obj.Id;
                        data.OrderStatus 	                = obj.Status;
                        data.OnSiteDate 	                = obj.TimeAgreedOnSite__c;
                        data.OrderType 	                    = obj.OrderType__c;
                        data.WorkCenter 	                = obj.ServiceTerritory.Name;
                        data.ServiceResource 	            = obj.Worker__r.Name;
                        data.AssetURL 	                    = String.isNotEmpty(String.valueOf(obj.AssetId)) ? URL.getOrgDomainUrl().toExternalForm() + '/' + obj.AssetId : '';
                        data.AssetName 	                    = obj.Asset.Name;
                        data.Model 	                        = obj.Asset.MachineName__c;
                        data.ReceptionDetails 	            = obj.ReceptionDetail__c;
                        data.InspectionDetails 	            = obj.PendingOrCustomerMatters__c;
                        data.ScheduledDispatchTime 	        = obj.ScheduledDispatchTime__c;
                        workOrderResult.add(data); 
                    }
    
                    cw.workOrderWrapper = workOrderResult;
                    System.debug('result '+workOrderResult);
                }
            }
            

        } catch (Exception e) {
            cw.isSuccess= false;
            cw.errMessage = e.getMessage();
        }
        return cw;
    }

    /*
     * @Description 
     *  - Ticket Wrapper
     * 
     * @Variable 
     *  - ApplicationDateTime 		: 접수일자
     *  - TicketNumber 	            : 티켓번호
     *  - TicketURL 		        : TicketURL
     *  - Owner 		            : 상담사
     *  - ReceptionDetails 	        : 접수내용
     *  - Progress 	                : 진행사항
     *  - TicketStatus 	            : 티켓상태
     * 
     */
    public class TicketWrapper {
        @AuraEnabled
        public DateTime ApplicationDateTime	    {get; set;} 
        @AuraEnabled
        public String CaseNumber		        {get; set;}
        @AuraEnabled
        public String TicketURL		            {get; set;}
        @AuraEnabled
        public String Owner		                {get; set;}
        @AuraEnabled
        public String ReceptionDetails		    {get; set;}
        @AuraEnabled
        public String Progress		            {get; set;}
        @AuraEnabled
        public String TicketStatus		        {get; set;}
        @AuraEnabled
        public String EscLev		            {get; set;}
        @AuraEnabled
        public String AssetName		            {get; set;}
        @AuraEnabled
        public String AssetURL		            {get; set;}
        @AuraEnabled
        public String Model		                {get; set;}
        @AuraEnabled
        public Date InstallDate	                {get; set;} 
        
        public TicketWrapper(){
            this.ApplicationDateTime 		    = System.now();
            this.CaseNumber 	                = '';
            this.TicketURL 	                    = '';
            this.Owner 	                        = '';
            this.ReceptionDetails 	            = '';
            this.Progress 	                    = '';
            this.TicketStatus 	                = '';
            this.EscLev 	                    = '';
            this.AssetName 	                    = '';
            this.AssetURL 	                    = '';
            this.Model 	                        = '';
            this.InstallDate 	                = Date.today();
        }
    }

    /*
     * @Description 
     *  - WorkOrder Wrapper
     * 
     * @Variable 
     *  - ApplicationDateTime 		: 접수일자
     *  - TicketNumber 	            : 티켓번호
     *  - TicketURL 		        : TicketURL
     *  - Owner 		            : 상담사
     *  - ReceptionDetails 	        : 접수내용
     *  - Progress 	                : 진행사항
     *  - TicketStatus 	            : 티켓상태
     * 
     */
    public class WorkOrderWrapper {
        @AuraEnabled
        public DateTime ApplicationDateTime	    {get; set;} 
        @AuraEnabled
        public DateTime ScheduledDispatchTime	{get; set;}
        @AuraEnabled
        public String CaseNumber		        {get; set;}
        @AuraEnabled
        public String TicketURL		            {get; set;}
        @AuraEnabled
        public String OrderNumber		        {get; set;}
        @AuraEnabled
        public String OrderURL		            {get; set;}
        @AuraEnabled
        public String OrderStatus		        {get; set;}
        @AuraEnabled
        public DateTime OnSiteDate		        {get; set;}
        @AuraEnabled
        public String OrderType		            {get; set;}
        @AuraEnabled
        public String WorkCenter		        {get; set;}
        @AuraEnabled
        public String ServiceResource		    {get; set;}
        @AuraEnabled
        public String ReceptionDetails		    {get; set;}
        @AuraEnabled
        public String InspectionDetails		    {get; set;}
        @AuraEnabled
        public String AssetName		            {get; set;}
        @AuraEnabled
        public String AssetURL		            {get; set;}
        @AuraEnabled
        public String Model		                {get; set;}
        
        public WorkOrderWrapper(){
            this.ApplicationDateTime 		    = System.now();
            this.CaseNumber 	                = '';
            this.TicketURL 	                    = '';
            this.OrderNumber 	                = '';
            this.OrderURL 	                    = '';
            this.OrderStatus 	                = '';
            this.OnSiteDate 	                = System.now();
            this.OrderType 	                    = '';
            this.WorkCenter 	                = '';
            this.ServiceResource 	            = '';
            this.ReceptionDetails 	            = '';
            this.InspectionDetails 	            = '';
            this.AssetName 	                    = '';
            this.AssetURL 	                    = '';
            this.Model 	                        = '';
        }
    }

    /*
     * @Description 
     *  - CommonWrapper
     * 
     * @Variable 
     *  - isSuccess 		: 성공여부
     *  - errMessage 	    : 에러메시지
     *  - ticketWrapper 	: Ticket 정보
     * 
     */ 
    public class CommonWrapper {
        @AuraEnabled
        public Boolean isSuccess		                {get; set;}
        @AuraEnabled
        public String errMessage		                {get; set;}
        @AuraEnabled
        public List<TicketWrapper> ticketWrapper		{get; set;}
        @AuraEnabled
        public List<WorkOrderWrapper> workOrderWrapper		{get; set;}
    
        public CommonWrapper(){
            this.isSuccess 		    = true;
            this.errMessage 	    = '';
            this.ticketWrapper 	    = new List<TicketWrapper>();
            this.workOrderWrapper 	= new List<WorkOrderWrapper>();
        }
    }
}