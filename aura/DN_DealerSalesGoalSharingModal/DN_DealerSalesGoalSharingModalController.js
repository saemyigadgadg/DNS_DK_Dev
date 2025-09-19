/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-04-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-12-07   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        helper.apexCall(component, event, helper, 'getInitSharingModal', {
            recordId: component.get('v.recordId')
        })
            .then($A.getCallback(function (result) {
                let r = result.r;
                // console.log('r ::: ', r);

                if (r.error) {
                    component.find('overlayLib').notifyClose();
                    helper.toast('error', $A.get("$Label.c.DNS_M_NoRepresentative"));
                    // helper.toast('error', 'Contact or Representative is doesn\'t exist.');
                    component.set('v.isLoading', false);
                    return;
                }

                if (r.getAccContactInfo.contactCheck) {
                    component.set('v.accountName', r.getAccContactInfo.accountName);
                    component.set('v.contactName', r.getAccContactInfo.name);
                    component.set('v.contactEmail', r.getAccContactInfo.email);
                    component.set('v.contactMobile', r.getAccContactInfo.mobile);
                    component.set('v.shareRecordId', r.getAccContactInfo.shareRecordId);
                    component.set('v.userId', r.getAccContactInfo.userId);
                    component.set('v.isRepresentative', r.getAccContactInfo.isRepresentative);
                    component.set('v.contactPosition', r.getAccContactInfo.position);
                    component.set('v.contactRole', r.getAccContactInfo.role);
                } else {
                    component.find('overlayLib').notifyClose();
                    helper.toast('error', $A.get("$Label.c.DNS_M_NoRepresentative"));
                    // helper.toast('error', 'Contact or Representative is doesn\'t exist.');
                }

                component.set('v.isLoading', false);
            }))
            .catch(function (error) {
                console.log('# doInit error : ' + error.message);
                component.set('v.isLoading', false);
            });
    },

    handleConfirm: function (component, evnet, helper) {
        helper.apexCall(component, event, helper, 'changeOwner', {
            shareRecordId: component.get('v.shareRecordId'),
            userId: component.get('v.userId')
        })
            .then($A.getCallback(function (result) {
                let r = result.r;

                if (r == 'Success') {
                    component.find('overlayLib').notifyClose();
                    helper.toast('success', $A.get("$Label.c.DNS_M_SharingToRepresentativeSuccess"));
                    // helper.toast('success', 'The owner change was successful.');
                    $A.get('e.force:refreshView').fire();
                } else if (r == 'Already') {
                    component.find('overlayLib').notifyClose();
                    helper.toast('error', $A.get("$Label.c.DNS_M_SharingToRepresentativeAlready"));
                    // helper.toast('error', 'The user is already the Owner.');
                } else {
                    component.find('overlayLib').notifyClose();
                    helper.toast('error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
                    // helper.toast('error', 'An error occurred, please contact your administrator.');
                }

                component.set('v.isLoading', false);
            }))
            .catch(function (error) {
                console.log('# handleConfirm error : ' + error.message);
            });
    },

    handleCloseModal: function (component, event, helper) {
        component.find('overlayLib').notifyClose();
    }
})