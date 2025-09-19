/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-03-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-03-2025   youjin.shim@sbtglobal.com   Initial Version
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
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    getUrlParams: function(component) {
        var searchParams = new URLSearchParams(window.location.search);
        var machineName = searchParams.get('machineName');
        var assetName = searchParams.get('assetName');

        component.set("v.machineName", machineName || '');
        component.set("v.assetName", assetName || '');
    },

    doSearch : function(component, event, helper) {
        console.log('---------search---------')
        var machineName = component.get('v.machineName'); // 기종
        var assetName = component.get('v.assetName');
        var isLoading = component.get("v.isLoading");

        // 기종 미선택시 경고문
        if (machineName == null || machineName == '') {
            helper.toast('WARNING', '기종을 선택해 주세요.');
            return ;
        }
        // 호기 미선택시 경고문
        if (assetName == null || assetName == '') {
            helper.toast('WARNING', '장비번호를 선택해 주세요.');
            return ;
        }

        component.set("v.isLoading", true)
        console.log("isLoading", isLoading);

        helper.apexCall(component, event, helper, 'getShippingInstructionInfo', {
            machineName : machineName,
            assetName : assetName,
        })
        .then($A.getCallback(function(result) {
            // no data
            let oReturn = result.r.O_RETURN;
            if(oReturn.TYPE =='E') {
                helper.toast('ERROR', oReturn.MESSAGE);
                component.set('v.equipment',{});
                component.set('v.isLoading', false);
                return;
            } else {
                // 출하지시서 Info
                component.set('v.equipment',result.r);
            }
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# error : ' + error.message);
            component.set('v.isLoading', false);
        });
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
})