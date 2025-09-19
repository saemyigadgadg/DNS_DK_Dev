/**
 * @description       : 
 * @author            : jiyoung.p@dncompany.com
 * @group             : 
 * @last modified on  : 2025-09-15
 * @last modified by  : jiyoung.p@dncompany.com
**/
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//import initData from '@salesforce/apex/DNSA_NewTicketController.initData';


//Label
import DNS_SearchEquipment  from '@salesforce/label/c.DNS_SearchEquipment';
import DNS_SearchContact  from '@salesforce/label/c.DNS_SearchContact';
import DNS_T_NewTicket  from '@salesforce/label/c.DNS_T_NewTicket';
import ServiceReception  from '@salesforce/label/c.ServiceReception';


export default class Dnsa_NewTicket extends LightningElement {
    @track isLoading = true;

    @track isClosed = false;
    @track isCallService = false;
    @track isClosedReasonDetails = false;
    @track isAssignHoldingReason = false;
    @track isRejectReasonDetails = false;

    //Label
    cLabel = {
          DNS_SearchEquipment : DNS_SearchEquipment
        , DNS_SearchContact : DNS_SearchContact
        , DNS_T_NewTicket : DNS_T_NewTicket
        , ServiceReception : ServiceReception
    };

    is

    connectedCallback() {
        console.log('티켓 생성✏️');
        this.isLoading = false;
        this.recordTypeId = '012JO0000001F9tYAE';
    }

    handleEquipmentSearch(){
        console.log('장비 버튼 클릭✏️');
    }

    handleContactSearch(){
        console.log('연락처 버튼 클릭✏️');
    }

    // 값 변경 시 필드 여부
    handleStatusChange(event){
        const statusValue = event.detail.value;
        this.isClosed = statusValue === 'Closed';
        this.isAssignHoldingReason = statusValue === 'Waiting (Assignment delay)';
        this.isRejectReasonDetails = statusValue === 'Reject';
    }
    handleEndOfReasonChange(event){
        this.isCallService = event.detail.value === 'Call Service';
        this.isClosedReasonDetails = (event.detail.value === 'Customer Cancellation' || event.detail.value === 'Call Service');
    }

}