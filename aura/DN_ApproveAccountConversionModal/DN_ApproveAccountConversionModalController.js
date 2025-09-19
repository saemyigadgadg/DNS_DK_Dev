({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        var objectName = component.get('v.sObjectName');

        if(objectName == 'Account') {
            helper.apexCall(component, event, helper, 'getConfirmInfo', {
                recordId    : component.get('v.recordId'),
                objectName  : objectName
            }).then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
                
                if(r.flag == 'success') {
                    component.set('v.isKorea',          r.getConfirmInit.isKorea);
                    component.set('v.isBVC',            r.getConfirmInit.isBVC);
                    component.set('v.customerSystem',   r.getConfirmInit.customerSystem == null ? '' : r.getConfirmInit.customerSystem);
                    component.set('v.orderList',        r.getOrderList);
                } else {
                    helper.toast('An error occurred, please contact your administrator.', 'error');
                }
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# doInit error : ' + error.message);
            });
        } else {
            helper.apexCall(component, event, helper, 'getConfirmInfo', {
                recordId    : component.get('v.recordId'),
                objectName  : objectName
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                let init = r.getInit;
                console.log('r', init);

                if(r.getInit.flag == 'success') {
                    component.set('v.isKorea',          init.isKorea);
                    component.set('v.orderList',        init.orderList);
                    component.set('v.customerSystem',   init.customerSystem == null ? '' : init.customerSystem);
                    if(init.customerSystem != null) {
                        component.set('v.csStartDate',  init.csStartDate);
                        component.set('v.csEndDate',    init.csEndDate);
                    }
                    component.set('v.isBVC', init.isBVC);
                    if(init.isBVC) {
                        component.set('v.bvcDealer',    init.BVCDealer);
                        component.set('v.bvcStartDate', init.BVCStartDate);
                        component.set('v.bvcEndDate',   init.BVCEndDate);
                    }
                } else {
                    helper.toast('An error occurred, please contact your administrator.', 'error');
                }
                
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# doInit error : ' + error.message);
            });
        }
    },

    handleClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
    },
})