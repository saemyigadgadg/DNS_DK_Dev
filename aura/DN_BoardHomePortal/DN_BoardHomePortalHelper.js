({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
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

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    fetchBoardList : function( component, event, helper ){
        let that = this;
        that.apexCall(component, event, helper, 'getHomeBoardList', {
            category            : component.get('v.searchCategory'),
            searchBoardMonth    : component.get('v.searchBoardMonth'),
            recordType          : component.get('v.recordType')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;

            console.log('response Board ::: ', JSON.stringify(r, null, 2));

            const todaySet = new Date();
            const msInADay = 24 * 60 * 60 * 1000;
            const daySet = new Date(todaySet.getTime() - parseInt(30) * msInADay);
            const dateOnlySet = daySet.toISOString().split('T')[0];
            const todayOnlySet = todaySet.toISOString().split('T')[0];
            console.log(dateOnlySet, ' < ==dateOnly');
            console.log(todayOnlySet, ' < ==todayOnlySet');
            r.forEach(element => {
                if(element.PostingDate__c >=dateOnlySet && todayOnlySet >= element.PostingDate__c) {
                    element.isNew = true;
                } else {
                    element.isNew = false;
                }
            });
            console.log(r, ' <>==== rrrrrrr');
            component.set('v.boardList', r);
        }))
        .catch(function(error) {
            console.log('# fetchBoardList error : ' + error.message);
        });
    },

})