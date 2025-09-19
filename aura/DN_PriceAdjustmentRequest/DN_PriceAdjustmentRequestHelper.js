/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-31-2025
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-31-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    addList : function(component, event, helper, addNum) {
        var partsList = component.get('v.partsList');
        var num = 0;
        if(partsList.length > 0) {
            num = Number(partsList[partsList.length-1].itemNo);
        }
        for (var i = 0; i < addNum; i++) {
            var objSelectItem = {
                itemNo      : String(num + 10).padStart(4, '0'), // 항목
                partNo      : null, // 품번
                partName    : null, // 품명
                currency    : null, // 통화
                systemPrice : null, // 시스템 가격
                sugestPrice : null, // 제안 가격
                request     : null  // 요청사항
            };
            num = num + 10;
            partsList.push(Object.assign({}, objSelectItem));
        }
        component.set('v.partsList', partsList);
    },

    apexCall : function(component, methodName, params) {
        console.log('methodName >> ' +methodName);
        console.log('params >> ' +JSON.stringify(params,null,4));
        
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

    deleteFile: function (component, deleteList) {        
        console.log('정보 :: '+JSON.stringify(deleteList,null,4));
        const self = this;
        const action = component.get("c.DeleteFile");
        action.setParams({ fileId : deleteList });

        action.setCallback(self, function (response) {
            const state = response.getState();
            if (state !== "SUCCESS") {
                let result = response.getError();
                console.log('result '+result);
            }
        });

        $A.enqueueAction(action);
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    deepCopy: function(obj) {
        if (typeof obj !== "object" || obj === null) return obj;
        let copy = Array.isArray(obj) ? [] : {};
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                copy[key] = this.deepCopy(obj[key]);
            }
        }
        return copy;
    },

    backDetailview: function (component, event, helper) {
        let peNo = component.get('v.peNo');
        component.set('v.isLoading', true);
        const navPriceDetailView = component.find("navPriceDetailView");
        const page = {
            type: "standard__webPage",
            attributes: {
                url: `/partners/s/price-detail-view?peNo=${peNo}`,
            }
        };
        navPriceDetailView.navigate(page);
        component.set('v.isLoading', false);
    }, 
})