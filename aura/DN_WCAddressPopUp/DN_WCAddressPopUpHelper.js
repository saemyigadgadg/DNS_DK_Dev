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

    calcPaging : function(component, event, helper) {
        var dividePageCount = component.get('v.dividePageCount');
        var totalPage           = Math.ceil(component.get('v.allResultCount') / dividePageCount);
        var pageAllCountList    = [];
        var pageCountList       = [];

        for (let i = 0; i < totalPage; i++) {
            if (pageCountList.length == 10) {
                pageAllCountList.push(pageCountList);
                pageCountList = [];
            }
            pageCountList.push(i);
        }
        pageAllCountList.push(pageCountList);

        component.set('v.totalPage',        totalPage);
        component.set('v.pageAllCountList', pageAllCountList);
        component.set('v.pageCountList',    pageAllCountList[0]);
        
    },

    searchAddress : function(component, event, helper) {
        component.set('v.isLoading', true);
        let searchText      = component.get("v.searchText");
        let pagingNumber    = component.get("v.pagingNumber");

        this.apexCall(component, event, helper, 'getAddress', {
            searchText : searchText,
            pagingNumber : pagingNumber
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r.flag == 'success') {
                component.set('v.searchResults', r.jusoList);
                if(component.get('v.allResultCount') != r.totalResultCount) {
                    component.set('v.allResultCount', r.totalResultCount);
                    helper.calcPaging(component, event, helper);
                }
            
                component.set('v.isLoading', false);
            } else {
                component.set('v.isLoading', false);
                helper.toast('error', 'An error occurred, please contact your administrator.');
                $A.get("e.force:closeQuickAction").fire();
            }
        }))
        .catch(function(error) {
            console.log('# searchAddress error : ' + error.message);
        });
    },

})