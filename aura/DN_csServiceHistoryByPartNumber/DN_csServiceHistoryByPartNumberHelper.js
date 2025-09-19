/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-19-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-29-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    apexCall : function( component, event, helper, methodName, params ) {
        let self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },
    clearField: function (component, fieldName, fieldLabel) {
        const fieldValue = component.get(`v.${fieldName}`);
        
        if (!fieldValue) {
            this.toast("WARNING", `저장된 ${fieldLabel} 값이 없습니다.`);
            return;
        }
        
        component.set(`v.${fieldName}`, "");
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    closeModal : function (component) {
        const modals = [
            'v.brokenAreaModal', 
            'v.phenomenonModal', 
            'v.causeModal', 
            'v.detailActionModal', 
            'v.statusModal'
        ];
    
        modals.forEach(modal => component.set(modal, false));
    },

    daycounter : function (sDate, eDate) {
        var diff = new Date(eDate) - new Date(sDate);
        var daySecond = 24*60*60*1000;
        var result = parseInt(diff/daySecond);
        console.log('result :: ' + result + '일');
        return result
    },

    fetchNCTypeList : function( component, event, helper ){
        let that = this;
        
        that.apexCall(component, event, helper, 'getpicklistValues', {})
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log(r);
            
            if(r.flag == 'success') {
                component.set('v.ncTypeOption', r.picklistValues);
                
            } else {
                that.toast('ERROR', 'An error occurred, please contact your administrator.');
            }
        }))
        .catch(function(error) {
            console.log('# fetchNCTypeList error : ' + error.message);
        });
    },
})