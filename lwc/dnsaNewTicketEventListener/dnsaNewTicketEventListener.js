/**
 * @description       : 
 * @author            : sunwoong.han@dkbmc.com
 * @group             : 
 * @last modified on  : 2025-09-15
 * @last modified by  : sunwoong.han@dkbmc.com
**/
import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";

export default class DnsaNewTicketEventListener extends NavigationMixin(LightningElement) {
    currentPageReference;

    @wire(CurrentPageReference)
    setPageReference(pageRef) {
        this.currentPageReference = pageRef;
    }

    @api
    doCancel() {
        const pageType = this.currentPageReference.type;
        if(pageType == 'comm__namedPage') {
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: "/partners/s/case/Case"
                }
            });
        }
    }
}