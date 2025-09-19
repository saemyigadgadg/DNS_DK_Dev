/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-28-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-27-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    closeModal : function(component) {
        var modal = component.find("wamdDetailModal");
        var modalBackGround = component.find("wamdDetailModalBackGround");

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

    getDueOut : function(component) {
        return new Promise((resolve, reject) => {
            component.set('v.isLoading', true);
            let self = this;
            this.apexCall(component,event,this, 'dueOutDetails', {
                partCode : component.get('v.docNum')
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(JSON.stringify(r), ' ::: r');
                component.set('v.dataList',r);
                if(result.r.length > 0) {
                    component.set('v.isDataCheck', true);
                } else {
                    component.set('v.isDataCheck', false);
                }
                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                component.set('v.isLoading', false);
            });
        });   
    },


    // Due In
    getDueIn : function(component, message, toastMessage) {
        return new Promise((resolve, reject) => {
            component.set('v.isLoading', true);
            let self = this;
            this.apexCall(component,event,this, 'dueInDetails', {
                partCode : component.get('v.docNum')
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(JSON.stringify(r), ' ::: r');
                component.set('v.dataList', r);

                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                component.set('v.isLoading', false);
            });
        });    
    },

    getStockQty : function(component) {
        return new Promise((resolve, reject) => {
            component.set('v.isLoading', true);
            let self = this;
            this.apexCall(component,event,this, 'getStock', {
                partCode : component.get('v.docNum')
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(JSON.stringify(r), ' ::: r');
                component.set('v.dataList',r);
                if(result.r.length > 0) {
                    component.set('v.isDataCheck', true);
                } else {
                    component.set('v.isDataCheck', false);
                }
                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                component.set('v.isLoading', false);
            });
        });   
    },

    // get WAMD
    getWAMD : function(component, message, toastMessage) {
        return new Promise((resolve, reject) => {
            component.set('v.isLoading', true);
            let self = this;
            this.apexCall(component,event,this, 'getAMD', {
                partCode : component.get('v.docNum')
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                console.log(JSON.stringify(r), ' ::: r');
                component.set('v.dataList',r)
                resolve();
            })).catch(function(error) {
                reject(error);
                self.toast('error', error[0].message);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                component.set('v.isLoading', false);
            });
        });    
    },
})