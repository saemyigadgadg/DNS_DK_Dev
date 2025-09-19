/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-04-18
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-07-23   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    closeModal: function (component) {
        var modal = component.find("locationModal");
        var modalBackGround = component.find("locationModalBackGround");

        //modal close
        $A.util.removeClass(modal, "slds-fade-in-open");
        //modalbackground close
        $A.util.removeClass(modalBackGround, "slds-backdrop_open");
        //modal hide
        $A.util.addClass(modal, "slds-hide");

        modalBackGround.getElement().removeEventListener("click", function (e) {
            e.stopPropagation();
        });
    },

    apexCall: function (component, event, helper, methodName, params) {
        return new Promise($A.getCallback(function (resolve, reject) {
            let action = component.get('c.' + methodName);

            if (typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function (response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({ 'c': component, 'h': helper, 'r': response.getReturnValue(), 'state': response.getState() });
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    sortingList: function(component, event, helper, sortingField, sortType) {
        var technicianList = component.get('v.technicianList');
        this.apexCall(component, event, helper, 'getTechnicianSortingList', {
            objList : technicianList,
            sortingField : sortingField,
            sortType : sortType
        }).then($A.getCallback(function(result) {
    
            let r = result.r;

            // console.log('result ::: ', r.sortingList);

            component.set('v.technicianList', r.sortingList);

        })).catch(function(error) {
            console.log('Error : ' + error.message);
        });
    },

    loadKakaoMap: function(component, paramObject) {

        // console.log('helper ::: Load Map');

        var jsonString = JSON.stringify(paramObject);
        var mapPageURL = '/apex/DN_ResourceTrakingComponentMap?paramObject=' + encodeURIComponent(jsonString);

        component.set('v.mapPageURL', mapPageURL);
        component.set('v.paramObject',paramObject);

        component.set('v.isLoading', false);
    },

    toast: function (message, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    },

    searchAddressInfo: function (component, event, helper) {
        component.set('v.isLoading', true);

        var self = this;
        var searchAddress = component.get('v.searchAddress');
        var addressList = [];
        if (searchAddress == null || searchAddress == '') {
            self.toast('검색할 주소를 입력해주세요.', 'Error', 'error');
            component.set('v.isLoading', false);
        } else {
            self.apexCall(component, event, helper, 'getSearchAddress', { 
                searchAddress : searchAddress
            }).then($A.getCallback(function(result) {

                let r = result.r;
    
                var resultJS = JSON.parse(r.getAddress);

                if (resultJS.results.juso == null) {
                    self.toast('주소를 상세히 입력해 주시기 바랍니다.', 'Error', 'error');
                } else {
                    addressList = resultJS.results.juso;
                    component.set('v.addressList', addressList);
                }

                component.set('v.isLoading', false);
            })).catch(function(error) {
                console.log('Error : ' + error.message);
                component.set('v.isLoading', false);
            });
        }
    },

    chunkArray : function(technicianList, size) {
        const result = [];
        for (let i = 0; i < technicianList.length; i += size) {
          result.push(technicianList.slice(i, i + size));
        }
        return result;
    }
})