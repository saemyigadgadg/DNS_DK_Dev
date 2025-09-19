({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.apexCall(component, event, helper, 'getDNSAInit', {})
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            
            component.set('v.loginUserCountry' , r.getUserInfo.Account.CountryLookup__c);
            component.set('v.countryCurrency' , r.getUserInfo.Account.CountryLookup__r.CurrencyIsoCode);
            component.set('v.loginUserRegion' , r.getUserInfo.Account.RegionLookup__c);
            component.set('v.recordTypeId' , r.getRecordTypeId);
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# search isDomesticUser check error : ' + error.message);
        });
        component.set('v.isLoading', false);
    },

    handleClickSave : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);

            var fieldMap = {};
            var inputs  = component.find('recordField');

            if (!Array.isArray(inputs)) {
                inputs = [inputs];
            }
            
            for (let i = 0; i < inputs.length; i++) {
                let input = inputs[i];
                let fieldName = input.get("v.fieldName");

                if (fieldName === 'RegionLookup__c' && typeof(input.get("v.value")) === 'object' && input.get("v.value").length === 0 ){
                    input.set("v.value", null);
                }
                        
                if (input.get("v.required") && (input.get("v.value") == null || input.get("v.value") === '')) {
                    helper.toast('WARNING', 'Please fill out all required fields : ' + fieldName);
                    component.set('v.isLoading', false);
                    input.getElement().focus();
                    return;
                } 

                fieldMap[fieldName] = input.get("v.value");
            }

            var shippingAddress = component.find('shippingAddress');
            if (Array.isArray(shippingAddress)) {
                shippingAddress = shippingAddress[0];
                
            }
    
            if (shippingAddress && typeof shippingAddress.get === 'function') {
                fieldMap['ShippingStreet'] = shippingAddress.get("v.street");
                fieldMap['ShippingCity'] = shippingAddress.get("v.city");
                fieldMap['ShippingState'] = shippingAddress.get("v.province");
                fieldMap['ShippingCountry'] = shippingAddress.get("v.country");
                fieldMap['ShippingPostalCode'] = shippingAddress.get("v.postalCode");
            } else {
                console.warn('Shipping Address component not found or invalid.');
            }

            if (
                !fieldMap['ShippingCity'] || 
                !fieldMap['ShippingPostalCode'] || 
                !fieldMap['ShippingCountry']
            ) {
                helper.toast('WARNING', 'Please enter an address.');
                component.set('v.isLoading', false);
                return;
            }

            helper.apexCall(component, event, helper, 'insertDnsaAccount', {
                objectName: component.get('v.objectName'),
                fieldMap: fieldMap,
                recordTypeId: component.get('v.recordTypeId')
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
                
                component.set('v.isLoading', false);
                if(r != null) {
                    if(r.includes('https://')) {
                        window.location.href = r;
                    } else {
                        helper.toast('Error', r);
                        console.log('errorMsg', r);
                    }
                }
            }))
            .catch(function(error) {
                helper.toast('ERROR', 'An error occurred, please contact your administrator.');
                console.log('# insertDnsaAccount error : ' + error.message);
            });
            // component.find("recordEditForm").submit();
        } catch (error) {
            console.log('error', error);
        }
    },

    // handleSuccess : function(component, event, helper) {
    //     helper.toast('SUCCESS', 'The account was successfully created.');
    //     component.set('v.isLoading', false);

    //     var response = event.getParam("response");
    //     var recordId = response.id;
    //     let externalLink = 'https://dn-solutions--dev.sandbox.my.site.com/partners/' + recordId;
    //     window.open(externalLink, '_top');
    // },

    // handleError: function(component, event, helper) {
    //     var errors = event.getParam('error');
    //     console.log('errors', errors);
        
    //     var message = 'An error occurred, please contact your administrator.';
        
    //     if (errors && errors.body) {
    //         if (errors.body.message) {
    //             message = errors.body.message;
    //         } else if (errors.body.output && errors.body.output.errors.length > 0) {
    //             message = errors.body.output.errors[0].message;
    //         }
    //     }

    //     helper.toast('ERROR', message);
    //     component.set('v.isLoading', false);
    // }
})