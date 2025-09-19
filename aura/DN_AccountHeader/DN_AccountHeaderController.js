({
    doInit : function(component, event, helper) {
        helper.apexCall(component, event, helper, 'portalHeaderInit', {
            recordId    : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            var url = window.location.protocol + '//' + window.location.hostname;
            component.set('v.url', url);
            component.set('v.accInfo', r.getInit);

            component.set('v.language', r.getUserInfo_portalHeader.language);
            component.set('v.profileName', r.getUserInfo_portalHeader.profileName);

            if(r.getInit.country == 'KR') {
                component.set('v.isKorea', true);
            }
        }))
        .catch(function(error) {
            console.log('# portalHeaderInit error : ' + error.message);
        });
    },

    handleEdit : function(component, event, helper) {
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: component.get('v.recordId'), // recordId를 가져옵니다.
                objectApiName: 'Account', // 수정할 객체의 API 이름을 입력하세요.
                actionName: 'edit' // 'edit' 액션을 설정합니다.
            }
        };
    
        var navService = component.find("navService");
        navService.navigate(pageReference);
    },

    showConvertToCustomerComponent : function(component, event, helper) {

        component.set('v.selectedComponent', 'ConvertToCustomer');
    },

    showAddressSearchComponent : function(component, event, helper) {

        component.set('v.selectedComponent', 'AddressSearch');
    },

    showBusinessStatusCheckComponent : function(component, event, helper) {

        component.set('v.selectedComponent', 'BusinessStatusCheck');
    },

    showSalesAreaDataComponent : function(component, event, helper) {

        component.set('v.selectedComponent', 'SalesAreaData');
    },

    handleModalEvent: function (component, event, helper) {
        var message = event.getParam("message");
        var modalBg = component.find("modalBackground");
        // Close Modal BG
        $A.util.removeClass(modalBg, "slds-backdrop_open");
        if (message === 'Close') {
            component.set('v.selectedComponent', '');
        }
    },
})