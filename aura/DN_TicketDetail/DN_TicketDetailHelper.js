/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-01
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-03   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        try {
            var self 					= this,
                // test				= '500F700000G6abGIAR';
                recordId = component.get('v.recordId');
            self.apex(component, "getTicketInfo", {recordId : recordId})
            .then(function(result){
                console.log('result', result);
                if(result.callResponse.isSuccess){
                    const profileName = component.get('v.CurrentUser.Profile.Name');
		            console.log('profileName',profileName);


                    component.set('v.TicketWrapper', result);
                    component.set('v.recordType', result.ticketRecordType);
                    if (result.ticketRecordType == 'Ticket_DNSA' && result.reception.ticketTypeMajor == 'General inquiry') {
                        component.set('v.isDNSAGeneral', false);
                    }
                    component.set('v.isUserProfile', result.isUserProfile);
                    component.set('v.selectStatus', result.reception.status);
                    component.set('v.selectCloseReason', result.reception.closeReason);
                    component.set('v.selectTicketMajor', result.reception.ticketTypeMajor);
                    component.set('v.selectTicketMiddle', result.reception.ticketTypeSub);
                    component.set('v.selectedFailureArea', result.technical.failureArea);
                    component.set('v.selectedFailureAreaLabel', result.technical.failureAreaLabel);
                    component.set('v.selectedFailureAreaDetail', result.technical.failureDetail);
                    component.set('v.selectedFailureAreaDetailLabel', result.technical.failureDetailLabel);
                    component.set('v.selectedFailurePhenomenon', result.technical.failurePhen);
                    component.set('v.selectedFailurePhenomenonLabel', result.technical.failurePhenLabel);
                    component.set('v.majorOptions', result.ticketSelectOption.failureAreaMajor);
                    component.set('v.middleOptions', result.ticketSelectOption.FailureAreaMiddle);
                    component.set('v.phenomenonOptions', result.ticketSelectOption.FailurePhenomenon);
                    component.set('v.assetAccountId', result.reception.assetAccountId);
                    component.set('v.selectAccountId', result.reception.assetAccountId);

                    if (result.ticketSelectOption.FailureAreaMiddle.length > 0) {
                        component.set('v.isFailureAreaDetail', false);
                    } else {
                        component.set('v.isFailureAreaDetail', true);
                    }
                    if (result.ticketSelectOption.FailurePhenomenon.length > 0) {
                        component.set('v.isFailurePhenomenon', false);
                    } else {
                        component.set('v.isFailurePhenomenon', true);
                    }

                    var ticketMiddleType = result.reception.ticketTypeSub;
                    var isUserProfile = result.isUserProfile;

                    if (ticketMiddleType == 'Failure receipt') {
                    	if (!isUserProfile) {
                    		component.set('v.failureRquired', true);
                    	}
                    } else {
                        component.set('v.failureRquired', false);
                    }
                    console.log('isFailureAreaDetail ::: ', component.get('v.isFailureAreaDetail'));
                    component.set('v.isLoading', false);
                } else {
                    self.showMyToast('error', result.callResponse.errMsg);
                }
            }).then(function(result){
                component.set('v.isLoading', false);
            })
        } catch (error) {
            console.log('Error ::: ', error.message);
        }
    },
	apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },
    showMyToast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    }
})