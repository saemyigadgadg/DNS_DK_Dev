({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.apexCall(component, event, helper, 'createOrderInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('DNSA result', r);

            if(r.flag == 'empty') {
                helper.toast('Error', r.message);
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                return;
            } else if(r.flag == 'order') {
                helper.toast('Error', r.message);
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                return;
            }

            if(r.seq != '1' && r.recordType == 'Commodity') {
                helper.toast('Error', 'Only the first booker can create an Order.');
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                return;
            }

            let today = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
            component.set('v.today', today);
            component.set('v.countryCode', r.CountryCode);
            component.set('v.salesOffice', r.salesOffice);
            component.set('v.Incoterms', r.Incoterms);
            component.set('v.payment', r.payment);
            component.set('v.Country', r.Country);
            component.set('v.dcValue', r.dcValue);
            component.set('v.openNote', r.openNote);
            component.set('v.Warranty', 'S24');
            if(r.recordType == 'Factory'){
                component.set('v.isFactory', true);
                // component.set('v.Country', r.Country);
                // component.set('v.Incoterms', r.Incoterms);
                if(r.final == false){
                    helper.toast('Error', 'Please Check Final Quotation');
                    component.set('v.isLoading', false);
                    component.find('overlayLib').notifyClose();
                    $A.get('e.force:refreshView').fire();
                }
            } else {
                component.set('v.sqTXT', r.sqTXT);
            }
            
            // var message = '';
            // if(r.checkRequiredFields.TermsOfPayment__c) {
            //     message += '[Terms Of Payment], '
            // }
            // if(r.checkRequiredFields.MachinePartsWarranty__c) {
            //     message += '[Machine Parts Warranty], '
            // }
            // if(r.checkRequiredFields.FOBPoint__c) {
            //     message += '[FOB Point], '
            // }
            // if (message.endsWith(', ')) {
            //     message = message.slice(0, -2);
            //     helper.toast('Error', 'Please Check ' + message);
            //     component.set('v.isLoading', false);
            //     component.find('overlayLib').notifyClose();
            //     $A.get('e.force:refreshView').fire();
            // }

            // if(!r.TermsOfPayment__c && !r.MachinePartsWarranty__c && !r.FOBPoint__c) {
            // if(!r.TermsOfPayment__c && !r.FOBPoint__c) {
            // }
            // component.set('v.shipValue', r.getLookupId.accId);
            component.set('v.shipValue', r.getLookupId.accId);
            component.set('v.accValue', r.getLookupId.accId);
            component.set('v.opptyId', r.getLookupId.opptyId);
            component.set('v.prbId', r.getLookupId.prbId);
            component.set('v.currency', r.getLookupId.currency);
            component.set('v.recordTypeId', r.getLookupId.recordTypeId);
            component.set('v.userAccId', r.getLookupId.userAccId);
            component.set('v.opptyPO', r.getLookupId.opptyPO);
            component.set('v.rddValue', r.getLookupId.rddValue);
            // Apex Call
            helper.apexCall(component, event, helper, 'getFieldSet', {
                objectName : 'Order'
            })
            .then($A.getCallback(function(result) {
                let res = result.r;
                console.log('DNSA result', res);
                
                component.set('v.fieldList', res);
                helper.fetchAccountAddress(component, [{'fieldName' : 'ShipTo__c', 'value' : component.get('v.shipValue')}]);
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# getFieldSet error : ' + error.message);
            });
            // helper.fetchAccountAddress(component, [{'fieldName' : 'ShipTo__c', 'value' : component.get('v.shipValue')}]);

        }))
        .catch(function(error) {
            console.log('# createOrderInit error : ' + error.message);
        });
    },

    handleClickSubmit : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            event.preventDefault();

            const fields = event.getParam('fields');
            fields.ShippingState      = component.get('v.shippingState');
            fields.ShippingCity       = component.get('v.shippingCity');
            fields.ShippingStreet     = component.get('v.shippingStreet');
            fields.ShippingPostalCode = component.get('v.shippingPostalCode');
            fields.ShippingCountry    = component.get('v.shippingCountry');

            component.find('recordEditForm').submit(fields);
        } catch (error) {
            console.log('error', error.message);
        }
    },
    handleClickFactorySubmit : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            event.preventDefault();

            const fields = event.getParam('fields');
            if(fields.RequestedShipDate__c <= fields.EffectiveDate){
                component.set('v.isLoading', false);
                helper.toast('Error', 'The requested ship date must be set to tomorrow or later');

                return;
            }

            fields.ShippingState      = component.get('v.shippingState');
            fields.ShippingCity       = component.get('v.shippingCity');
            fields.ShippingStreet     = component.get('v.shippingStreet');
            fields.ShippingPostalCode = component.get('v.shippingPostalCode');
            fields.ShippingCountry    = component.get('v.shippingCountry');

            // component.set('v.shipValue', shipVal);
            component.find('recordEditFormFactory').submit(fields);
        } catch (error) {
            console.log('error', error.message);
        }
    },

    handleSubmitSuccess : function(component, event, helper) {
        helper.toast('Success', 'The Order has been created.');
        var response = event.getParam('response');
        var recordId = response.id;
        // Apex Call
        helper.apexCall(component, event, helper, 'insertOrderItems', {
            orderId : recordId,
            quoteId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('DNSA result', r);

            if(r == 'Success') {
                helper.toast('Success', 'Order creation is complete.');
            } else if(r == 'empty') {
                helper.toast('Error', 'Quote Line Item does not exist.');
            } else {
                helper.toast('Error', 'An error occurred, please contact your administrator.');
            }
            
        }))
        .catch(function(error) {
            console.log('# getFieldSet error : ' + error.message);
        });
        component.set('v.isLoading', false);
        component.find('overlayLib').notifyClose();
        $A.get('e.force:refreshView').fire();
    },

    handleSubmitError : function(component, event, helper) {
        var errors = event.getParam('error');
        console.log('errors', errors);
        console.log('errors.message', errors.body.output.errors[0].message);
        
        var message = $A.get('$Label.c.DNS_ACC_T_ADMIN');
        
        if (errors && errors.body) {
            if (errors.body.message) {
                message = errors.body.message;
            } else if (errors.body.output && errors.body.output.errors.length > 0) {
                message = errors.body.output.errors[0].message;
            }
        }

        helper.toast('Error', message);
        component.set('v.isLoading', false);
        component.find('overlayLib').notifyClose();
    },

    handleClickClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
    },
    handleAddress: function(component, event, helper) {
        var fieldName = event.getSource().get('v.fieldName');
        var accountId = event.getSource().get('v.value');
        
        helper.fetchAccountAddress(component, [{'fieldName' : fieldName, 'value' : accountId}]);
    },
})