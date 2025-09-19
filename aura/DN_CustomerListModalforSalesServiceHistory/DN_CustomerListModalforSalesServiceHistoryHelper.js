/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 11-13-2024
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-12   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("customerListModal");
        var modalBackGround = component.find("modalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");
        
        modalBackGround.getElement().removeEventListener("click", function(e) {
            e.stopPropagation();
        });
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

    paginateResults: function(component, customerList) {
        let dividePageCount = component.get("v.listViewOption"); 
        let totalPage = Math.ceil(customerList.length / dividePageCount);
    
        let pageList = [];
        let pageAllCountList = [];
        let pageCountList = [];
    
        for (let i = 0; i < totalPage; i++) {
            if (pageCountList.length === 10) {
                pageAllCountList.push(pageCountList);
                pageCountList = [];
            }
            pageCountList.push(i);
            let objList = customerList.slice(i * dividePageCount, (i + 1) * dividePageCount);
            pageList.push(objList);
        }
        pageAllCountList.push(pageCountList);
    
        component.set('v.pageAllCountList', pageAllCountList);
        component.set('v.pageCountList', pageAllCountList[0]);
        component.set('v.pageList', pageList);
        component.set('v.allResultCount', customerList.length);
        component.set('v.totalPage', totalPage);
        component.set('v.customerList', pageList[0]); 
    },
})