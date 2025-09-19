import { LightningElement, api, track } from 'lwc';
import { showToast, style, label } from 'c/commonUtils';
import getNotClosedServiceHistory from '@salesforce/apex/DN_ServiceHistoryController.getNotClosedServiceHistory';

export default class DN_PendingServiceHistory extends LightningElement {
    @api recordId;

    @track ticketSortBy;
    @track ticketSortDirection = 'asc';
    @track workOrderSortBy;
    @track workOrderSortDirection = 'asc';

    dataLoaded = false;
    cLabel = label;

    isTicketSpinner = true;
    @track ticketData = [];
    ticketColumns = [
        {label : label.DNS_C_DateOfReceipt, fieldName : 'ApplicationDateTime', type : 'date', sortable: true, initialWidth: 200,
            typeAttributes:{hour: "2-digit", minute: "2-digit", day: "2-digit", month: "2-digit", year: "numeric"}},
        {label : label.DNS_C_Ticket, fieldName : 'TicketURL', type : 'url', sortable : true, initialWidth: 200,
            typeAttributes: {label: {fieldName:'CaseNumber'}, target: '_blank'}},
        {label : label.DNS_C_Status, fieldName : 'TicketStatus', type : 'text', sortable: true, initialWidth: 200},
        {label : label.DNS_C_Manager, fieldName : 'Owner', type : 'text', sortable: true, initialWidth: 200},
        {label : 'Esc.Lev', fieldName : 'EscLev', type : 'text', sortable: true},
        {label : label.DNS_C_Equipment, fieldName : 'AssetURL', type : 'url', sortable : true, initialWidth: 150,
            typeAttributes: {label: {fieldName:'AssetName'}, target: '_blank'}},
        {label : label.DNS_C_Model, fieldName : 'Model', type : 'text', sortable: true, initialWidth: 200},
        {label : label.DNS_C_InstallDate, fieldName : 'InstallDate', type : 'date', sortable: true, initialWidth: 200,
            typeAttributes:{hour: "2-digit", minute: "2-digit", day: "2-digit", month: "2-digit", year: "numeric"}},
        {label : label.DNS_C_ReceptionDetails, fieldName : 'ReceptionDetails', type : 'text', sortable: true, initialWidth: 600},
        // {label : label.DNS_C_ProgressDetail, fieldName : 'Progress', type : 'text', sortable: true},
        
                    
    ];

    isWorkOrderSpinner = true;
    @track workOrderData = [];
    workOrderColumns = [
        {label : label.DNS_C_DateOfReceipt, fieldName : 'ApplicationDateTime', type : 'date', sortable: true,  initialWidth: 200,
            typeAttributes:{hour: "2-digit", minute: "2-digit", day: "2-digit", month: "2-digit", year: "numeric"}},
        // {label : label.DNS_C_Ticket, fieldName : 'TicketURL', type : 'url', sortable : true,
        //     typeAttributes: {label: {fieldName:'CaseNumber'}, target: '_blank'}},
        {label : label.DNS_C_OrderNumber, fieldName : 'OrderURL', type : 'url', sortable : true, initialWidth: 200,
            typeAttributes: {label: {fieldName:'OrderNumber'}, target: '_blank'}},
        {label : label.DNS_C_OrderType, fieldName : 'OrderType', type : 'text', sortable: true, initialWidth: 200},
        {label : label.DNS_C_OrderStatus, fieldName : 'OrderStatus', type : 'text', sortable: true, initialWidth: 200},
        // {label : label.DNS_C_OnSiteDate, fieldName : 'OnSiteDate', type : 'date', sortable: true,
        //     typeAttributes:{hour: "2-digit", minute: "2-digit", day: "2-digit", month: "2-digit", year: "numeric"}},
        {label : label.DNS_C_Equipment, fieldName : 'AssetURL', type : 'url', sortable : true,
            typeAttributes: {label: {fieldName:'AssetName'}, target: '_blank'}},
        {label : label.DNS_C_Model, fieldName : 'Model', type : 'text', sortable: true},  
        {label : label.DNS_C_InstallDate, fieldName : 'InstallDate', type : 'date', sortable: true,
            typeAttributes:{hour: "2-digit", minute: "2-digit", day: "2-digit", month: "2-digit", year: "numeric"}},         
        {label : label.DNS_C_ReceptionDetails, fieldName : 'ReceptionDetails', type : 'text', sortable: true, initialWidth: 600},            
        {label : label.DNS_C_ActionDetails, fieldName : 'InspectionDetails', type : 'text', sortable: true, initialWidth: 600},  
        {label : label.DNS_C_WorkCenter, fieldName : 'WorkCenter', type : 'text', sortable: true},            
        {label : label.DNS_C_ServiceResource, fieldName : 'ServiceResource', type : 'text', sortable: true},          
    ];

    connectedCallback() {
        if(this.recordId){
            this.refreshList(); 
        }
    }

    renderedCallback(){
        if (this.recordId && !this.dataLoaded) {
            this.dataLoaded = true; // 데이터를 한 번만 로드
            this.refreshList();
            style.set(this.customstyle);
        }
    }

    ticketRefresh(){
        this.isTicketSpinner = true;
        this.refreshList();
    }

    workOrderRefresh(){
        this.isWorkOrderSpinner = true;
        this.refreshList();
    }

    refreshList(){
        getNotClosedServiceHistory({
            ticketId: this.recordId, 
            isTicket : this.isTicketSpinner,
            isWorkOrder : this.isWorkOrderSpinner
        }).then(result => {
            console.log('getInitInfo',result);
            if(this.isTicketSpinner){
                this.ticketData = result.ticketWrapper;
                this.ticketLength = result.ticketWrapper.length;
            }
            if(this.isWorkOrderSpinner){
                this.workOrderData = result.workOrderWrapper;
                this.workOrderLength = result.workOrderWrapper.length;
            }
            this.isTicketSpinner = false;
            this.isWorkOrderSpinner = false;
        }).catch(error => {
            console.log('Error', error);
            showToast(this, 'ERROR','ERROR', 'ERROR : '+ JSON.stringify(error));
            this.isSpinner = false;
        });
    }

    customstyle = {
        id: 'DN_PendingServiceHistory',
        style: `
        `,
    }

    //Ticket Sorting
    doTicketSorting(event) {
        const fieldName = event.detail.fieldName;
        if (this.ticketSortBy === fieldName) {
            this.ticketSortDirection = this.ticketSortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.ticketSortBy = fieldName;
            this.ticketSortDirection = 'asc';
        }
    
        console.log('this.ticketSortBy:', this.ticketSortBy);
        console.log('this.ticketSortDirection:', this.ticketSortDirection);
    
        this.ticketData = this.sortData(this.ticketSortBy, this.ticketSortDirection, this.ticketData);
    }

    //WorkOrder Sorting
    doWorkOrderSorting(event) {
        const fieldName = event.detail.fieldName;
        if (this.workOrderSortBy === fieldName) {
            this.workOrderSortDirection = this.workOrderSortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.workOrderSortBy = fieldName;
            this.workOrderSortDirection = 'asc';
        }
    
        console.log('this.workOrderSortBy:', this.workOrderSortBy);
        console.log('this.workOrderSortDirection:', this.workOrderSortDirection);
    
        this.workOrderData = this.sortData(this.workOrderSortBy, this.workOrderSortDirection, this.workOrderData);
    }
    
    sortData(fieldname, direction, data) {
        let parseData = JSON.parse(JSON.stringify(data));
    
        let keyValue = (a) => {
            return a[fieldname];
        };
    
        let isReverse = direction === 'asc' ? 1 : -1;
    
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
    
        return parseData;
    } 
}