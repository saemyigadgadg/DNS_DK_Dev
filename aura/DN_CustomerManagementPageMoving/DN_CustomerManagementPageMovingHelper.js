({
    closeModal : function(component) {
        var modal = component.find("customerManagementModal");
        var modalBackGround = component.find("customerManagementModalBackGround");
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
                        //console.log(JSON.stringify(errors),' errors helpler');
                        //console.log(methodName, errors);
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

    getSiteUrlList : function(component, event, helper) {
        this.apexCall(component, event, helper, 'getSiteUrlList', {
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            // console.log('r', r);
            // console.log('r2222', JSON.stringify(r));
            let urlList =r;
            let currentUrl = window.location.href;
            const isUrl2InList = urlList.some(baseUrl => currentUrl.startsWith(baseUrl)); 
            console.log(isUrl2InList,' < ====isUrl2InList');
            if(isUrl2InList) {
                let hostname = window.location.hostname;
                let pathName = window.location.pathname;
                let navService = component.find('navService');
                let urlList =[];

                let href = window.location.href;
                urlList = href.split('/');
                let recordId = urlList[urlList.length-2];
            
                let pageReference = {
                    type: "standard__webPage",
                    attributes: {
                        url: `/CustomerManagementCreate?recordId=${recordId}&isCustom=true`,
                    }
                };
                navService.navigate(pageReference);
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            

        }))
        .catch(function(error) {
            console.log('# searchAddress error : ' + error.message);
        });
    },

    userAccess : function(component, event, helper) {
        let self = this;
        let recordId = component.get('v.recordId');
        console.log(recordId,' ::: recordId');
        this.apexCall(component, event, helper, 'getDealerCustomer', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {

            let r = result.r;
            console.log(r,' ::: rrr');
            // 수정불가
            if(r) {
                self.toast('error', '대리점 고객은 수정이 불가능합니다.');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } else { // 수정가능
                self.getSiteUrlList(component, event, helper);
            }
        }))
        .catch(function(error) {
            console.log('# searchAddress error : ' + error.message);
        });
    },
})