import { LightningElement, api, track } from 'lwc';
import { showToast, label } from 'c/commonUtils';
import getAllActivityList from '@salesforce/apex/DN_TicketActivityListController.getAllActivityList';

export default class DN_AllConsultationHistory extends LightningElement {
    @api recordId;
    @track sortBy;
    @track sortDirection = 'asc';

    dataLoaded = false;
    cLabel = label;

    isSpinner = true;
    @track data = [];

    columns = [
        {label : label.DNS_C_Ticket, fieldName : 'TicketURL', type : 'url', sortable : true,
            typeAttributes: {label: {fieldName:'Ticket'}, target: '_blank'}},
        {label : label.DNS_C_ConsultationChannel, fieldName : 'Channel', type : 'text', sortable: true},
        {label : label.DNS_C_ConsultationDate, fieldName : 'ConsultDate', type : 'date', sortable: true,
            typeAttributes:{day: "2-digit", month: "2-digit", year: "numeric"}},
        {label : label.DNS_C_Consultant, fieldName : 'Consultant', type : 'text', sortable: true},
        {label : 'In/Out', fieldName : 'InOutBound', type : 'text', sortable: true},   
        {label : label.DNS_C_ContactName, fieldName : 'ContactURL', type : 'url', sortable : true,
        typeAttributes: {label: {fieldName:'Contact'}, target: '_blank'}},
        {label : label.DNS_C_Phone, fieldName : 'Phone', type : 'text', sortable: true},
        {label : label.DNS_C_Equipment, fieldName : 'AssetURL', type : 'url', sortable : true,
            typeAttributes: {label: {fieldName:'Asset'}, target: '_blank'}},
        {label : label.DNS_C_Model, fieldName : 'Model', type : 'text', sortable: true},   
        {label : label.DNS_C_ConsultStartTime, fieldName : 'StartTime', type : 'date', sortable: true,
            typeAttributes:{hour: "2-digit", minute: "2-digit", second: "2-digit"}},
        {label : label.DNS_C_ConsultEndTime, fieldName : 'EndTime', type : 'date', sortable: true,
            typeAttributes:{hour: "2-digit", minute: "2-digit", second: "2-digit"}},
        {label : label.DNS_C_ConsultationDetails, fieldName : 'Description', type : 'text', sortable: true, initialWidth: 600},            
    ];

    refreshList(){
        getAllActivityList({
            recordId: this.recordId
        }).then(result => {
            console.log('getAllActivityList',result);
            this.data = result.activityWrapper;
            this.activityLength = result.activityWrapper.length;
            this.isSpinner = false;
        }).catch(error => {
            console.log('Error', error);
            showToast(this, 'ERROR','ERROR', label.DNS_M_GeneralError);
            this.isSpinner = false;
        });
    } 


    connectedCallback() {
        if(this.recordId){
            this.refreshList(); 
        }
    }

    renderedCallback(){
        if (this.recordId && !this.dataLoaded) {
            this.dataLoaded = true; // 데이터를 한 번만 로드
            this.refreshList();
        }
    }

    handleRefresh(){
        this.isSpinner = true;
        this.refreshList();
    }

    doSorting(event) {
        const fieldName = event.detail.fieldName;
        if (this.sortBy === fieldName) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortBy = fieldName;
            this.sortDirection = 'asc';
        }
    
        console.log('this.sortBy:', this.sortBy);
        console.log('this.sortDirection:', this.sortDirection);
    
        this.data = this.sortData(this.sortBy, this.sortDirection, this.data);
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