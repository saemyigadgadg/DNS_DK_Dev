({
    apexCall : function(component, methodName, params) {
        console.log('helper 동작 확인' + ' || ' + methodName)
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.'+methodName);
            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(self, function(response) {
                    if(response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'r':response.getReturnValue(), 's': response.getState()});
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

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    updateFieldValue: function(component, event) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");

        component.set("v." + fieldName, fieldValue);
        console.log(fieldName+' :: '+fieldValue);
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

    formatDate: function (dateString) {
        if (!dateString || dateString === "0000-00-00") {
            return "";
        }

        let [year, month, day] = dateString.split("-").map(function (part) {
            return parseInt(part, 10); 
        });

        return `${year}.${month}.${day}`;
    },

    formatCurrency: function (value) {
        if (isNaN(value)) {
            return "0";
        }
        return Math.floor(value).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },
})