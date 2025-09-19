/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-03-24
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-02-20   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');

        helper.apexCall(component, event, helper, 'getTicket', {
            ticketId : recordId
        }).then(result => {

            var r = result.r;
            console.log('r ::: ', r);

            document.getElementById('escUser').value = result.r.OwnerId;
            component.set('v.escalLevel', r.EscLev__c);
        }).catch(error => {
            console.log('Error ::: ', error.message);
            document.getElementById('escUser').value = null;
        }).finally(() => {
            component.set('v.isLoading', false);
        });

    },

    handleSave : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            var recordId = component.get('v.recordId'); 
            var escalLevel = component.get('v.escalLevel'); 
            var escLev = document.getElementById('escLev').value;
            var escUser = document.getElementById('escUser').value;
    
            console.log('recordId ::: ', recordId);
            console.log('escalLevel ::: ', escalLevel);
            console.log('escLev ::: ', escLev);
            console.log('escUser ::: ', escUser);

            var DNS_EB_LevelValidation = $A.get('$Label.c.DNS_EB_LevelValidation');
            var DNS_EB_UserValidation = $A.get('$Label.c.DNS_EB_UserValidation');
            // var DNS_EB_SameValidation = $A.get('$Label.c.DNS_EB_SameValidation');

            if (escLev == '' || escLev == null) {
                helper.toast(component, 'Error', DNS_EB_LevelValidation, 'error');
                component.set('v.isLoading', false);
            } else if (escUser == null || escUser == '') {
                helper.toast(component, 'Error', DNS_EB_UserValidation, 'error');
                component.set('v.isLoading', false);
            }
            // else if (escLev == escalLevel) {
            //     helper.toast(component, 'Error', DNS_EB_SameValidation, 'error');
            //     component.set('v.isLoading', false);
            // }
            else {
                helper.apexCall(component, event, helper, 'updateTicket', {
                    ticketId : recordId,
                    escLev : escLev,
                    escUserId : escUser
                }).then(result => {

                    var r = result.r;

                    console.log('r ::: ', r);
                    
                    if (r.isSuccess) {
                        helper.toast(component, 'Success', r.message, 'success');
                        window.location.reload();
                    } else {
                        helper.toast(component, 'Error', r.message, 'error');
                    }
                    
                }).catch(error => {
                    console.log('Error ::: ', error.message);

                }).finally(() => {
                    component.set('v.isLoading', false);
                });
            }
            
        } catch (error) {
            console.log('Error ::: ', error.message);
        }
    },

    closeModal : function(component, event, helper) {
        helper.closeModal();
    }
})