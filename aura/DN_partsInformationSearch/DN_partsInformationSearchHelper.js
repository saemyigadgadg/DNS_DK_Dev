({
    apexCall : function(component, methodName, params) {
        console.log('helper 동작 확인')
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

    formatCurrency: function (value) {
        if (isNaN(value)) {
            return "0";
        }
        return Math.floor(value).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },

    formatDate: function (dateString) {
        if (!dateString) {
            return "";
        }
        let [year, month, day] = dateString.split("-").map(function (part) {
            return parseInt(part, 10);
        });
        return `${year}-${month}-${day}`;
    },

    getNextValue: function(component, rList , target) {
        let nextValue = null;
        console.log('target >> '+ target);
        console.log('대체품 리스트 :: >> '+JSON.stringify(rList, null, 4));
        if(rList.length > 0) {
            for (let i = 0; i < rList.length; i++) {
                if (rList[i].MATNR == target) {
                    if (i + 1 < rList.length) {
                        nextValue = rList[i + 1].MATNR;
                        console.log('nextValue : ' +nextValue);
                    }
                    break;
                }else {
                    nextValue = rList[i].MATNR;
                    break;
                }
            }
    
            if (nextValue) {
                console.log("Next Value: " + nextValue);
            } else {
                console.log("No next value found for " + target);
            }
    
            return nextValue;    
        }
        else {
            return '';
        }
    }
})