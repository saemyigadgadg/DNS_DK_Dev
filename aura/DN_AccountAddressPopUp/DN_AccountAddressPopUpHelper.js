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

    // 2024-12-05 iltae.seo 딜러포탈/대리점재고관리에서 사용하기 위해 별도로 설정
    getSiteUrlList : function(component, event, helper) {
        let self = this;
        this.apexCall(component, event, helper, 'getSiteUrlList', {
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            // console.log('r', r);
            // console.log('r2222', JSON.stringify(r));
            let urlList =r;
            let currentUrl = window.location.href;
            const isUrl2InList = urlList.some(baseUrl => currentUrl.startsWith(baseUrl)); 
            //self.getDealerCustomer(component, event, helper);
            if(isUrl2InList) {
                component.set("v.isCommunity", isUrl2InList);
            }
            
        }))
        .catch(function(error) {
            console.log('# searchAddress error : ' + error.message);
        });
    },
    
    // 2025-01-22 iltae.seo 딜러포탈/대리점재고관리에서 대리점 고객은 수정 가능 확인
    getDealerCustomer: function(component, event, helper) {
        let recordId = component.get('v.recordId')
        let pathname = window.location.pathname;
        let self =this;
        if(recordId !=null && pathname.includes('dealercustomer')) {
            this.apexCall(component, event, helper, 'getDealerCustomer', {
                recordId : component.get('v.recordId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                // 수정불가
                if(r) {
                    self.toast('error', '대리점 고객은 수정이 불가능합니다.');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                } 
            }))
            .catch(function(error) {
                console.log('# searchAddress error : ' + error.message);
            });
        }
    }

})