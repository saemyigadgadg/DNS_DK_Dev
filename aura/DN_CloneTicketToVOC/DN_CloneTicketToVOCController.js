({
    init : function(component, event, helper) {
        // Apex Call
        helper.apex(component, "getTicketInfo", {
            recordId : component.get('v.recordId')
        })
        .then(function(result){
            console.log('getTicketInfo',result);
            if(result.isSuccess){
                var ticketInfo = result.returnCase;
                component.set('v.ticketInfo', ticketInfo);
                component.set('v.isSpinner', false);
            }else{
                component.set('v.isSpinner', false);
            }
        });
    },
    handleSave : function(component, event, helper) {
        component.set('v.isSpinner', true);
        var ticketInfo = component.get('v.ticketInfo');
        console.log('ticketInfo',ticketInfo);
        delete ticketInfo.Id;

        if($A.util.isEmpty(ticketInfo.AssetId) || $A.util.isEmpty(ticketInfo.ReceptionDetails__c)){
            helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_M_InsertRequiredField'), 'Error');
            component.set('v.isSpinner', false);
            return;
        }

        helper.apex(component, "saveRecord", {
            ticketData : JSON.stringify(ticketInfo)
        })
        .then(function(result){
            console.log('saveVOC',result);
            if(result.isSuccess){
                helper.navigateToRecord(component, result.returnValue, 'Case');
                helper.toast(component, 'SUCCESS', $A.get('$Label.c.DNS_S_CreateVOCSuccess'), 'Success');
            }else{
                helper.toast(component, 'ERROR', $A.get('$Label.c.DNS_E_VOCError'), 'Error');
                component.set('v.isSpinner', false);
            }
        });
    },
    handleCancel : function(component, event, helper) {
        helper.closeModal(component);
    },
})