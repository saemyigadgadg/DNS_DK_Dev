({
    dayCount : function(selDay) {
        helper.apexCall(component, event, helper, 'getLoginUserInfo', {
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result),' < ===responseData');
            component.set('v.WorkCenter', {
                Name : result.r.workerInfo.Service_Territory__r.Name
            })
            const todaySet = new Date();
            const msInADay = 24 * 60 * 60 * 1000;
            const daySet = new Date(todaySet.getTime() - parseInt(112) * msInADay);
            component.find('Start').set('v.value', daySet.toISOString());
            component.find('End').set('v.value',todaySet.toISOString());
        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
        });
    },

    // 기간 계산
    dayCounter : function (sDate, eDate) {
        console.log('기간 계산')
        var diff = new Date(eDate) - new Date(sDate);
        var daySecond = 24*60*60*1000;
        var result = parseInt(diff/daySecond);
        return result
    },

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

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },
})