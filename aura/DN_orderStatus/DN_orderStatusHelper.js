/**
 * @description       : 
 * @author            : jiyoung.p@dncompany.com
 * @group             : 
 * @last modified on  : 2025-09-12
 * @last modified by  : jiyoung.p@dncompany.com
**/
({
    updateFieldValue: function(component, event) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");

        if(fieldName == 'orderType') {
            fieldValue == 'All' ? '' : fieldValue;
            component.set("v." + fieldName, fieldValue);
        }else {
            component.set("v." + fieldName, fieldValue);
        }
    }, 

    dayCount : function(selDay) {
        console.log('헬퍼 데이 카운트')
        let year  = selDay.getFullYear(); 
        let month = ('0' + (selDay.getMonth() + 1)).slice(-2);
        let day   = ('0' + selDay.getDate()).slice(-2);

        return year + '-' + month + '-' + day;
    },

    dayCounter : function (sDate, eDate) {
        console.log('기간 계산')
        var diff = new Date(eDate) - new Date(sDate);
        var daySecond = 24*60*60*1000;
        var result = parseInt(diff/daySecond);
        return result
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    apexCall : function(component, methodName, params) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's':response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log('error :: ' + methodName + 'message :: ' + errors);
                        reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },
})