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
    // 2024-12-05 iltae.seo 딜러포탈/대리점재고관리에서 사용하기 위해 별도로 설정
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
                pathName = pathName.substring(0, pathName.lastIndexOf('/') + 1);
                console.log(window.location,' < ==window.location');
                console.log(hostname,' < ==hostname');
                
                let pageReference = {
                    type: "standard__webPage",
                    attributes: {
                        url: hostname + pathName +'CustomerManagementCreate',
                    }
                };
                navService.navigate(pageReference)
            }
            

        }))
        .catch(function(error) {
            console.log('# searchAddress error : ' + error.message);
        });
    }
})