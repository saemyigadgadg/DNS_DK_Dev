({
    doInit : function(component, event, helper) {
        console.log('doInit');

        const recordId      = component.get('v.recordId');
        const selectedItems = component.get('v.selectedItems');
        console.log("🚀 ~ selectedItems:", selectedItems);
        
        const notCV = selectedItems.find(item => !item.CVComplete);
        const pilot = selectedItems.find(item => !item.isPilot);
        if(pilot) {
            if(notCV) {
                helper.handleError('doInit', $A.get("$Label.c.DNS_M_CVCompleted")); // Only quote product with completed CV selection can proceed to order.
                component.find("overlayLib").close();
            }
        }
        const hasOrder = selectedItems.find(item => item.IsOrderCreated);
        if(hasOrder) {
            helper.handleError('doInit', $A.get("$Label.c.DNS_M_DonotOrderAgain")); // Quote product that has already been ordered cannot be ordered again.
            component.find("overlayLib").close();
        }
        
        const selItemIds    = selectedItems.map(item => item.Id);
        var action = component.get("c.fetchInit");
        action.setParams({ quoteId : recordId, selItemIds : selItemIds});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("🚀 ~ action.setCallback ~ state:", state);
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('doInit result - ', JSON.stringify(returnVal, null, 1));

                if(returnVal.isPass) {
                    const data = returnVal.data;
                    const defaultValues = data.defaultValues;
                    console.log('defaultValues : ' + JSON.stringify(defaultValues));
                    console.log('defaultValues.dnsAccount : ' + defaultValues.dnsAccount);
                    // validate
                    if(defaultValues.isUser && !defaultValues.isGlobal && (!defaultValues.dnsAccount || defaultValues.dnsAccount == null)) {
                        helper.handleError('doInit', $A.get("$Label.c.DNS_M_NoDirectAcc")); // There is no DNS direct account.
                        helper.closeModal(component);
                    } else if(!defaultValues.isFinal) {
                        helper.handleError('doInit', $A.get("$Label.c.DNS_M_NotFinalQuote")); // The Order can be created with the final quote.
                        helper.closeModal(component);
                    }  else if(defaultValues.isAccBlocked) {
                        helper.handleError('doInit', $A.get("$Label.c.DNS_M_OrderAccountBlocked")); // The associated Account is blocked, so the order cannot be created or modified.
                        helper.closeModal(component);
                    } else if(defaultValues.connectedAccCnt > 1) {
                        helper.handleError('doInit', $A.get("$Label.c.DNS_M_OrderCreationRealtedDealer")); // Order creation is not allowed if the Account has more than one 'Related Dealer' or 'Sales Reps'.
                        helper.closeModal(component);
                    } else if(!helper.checkSameKey(data.quoteLineItemInfo)) {
                        if(defaultValues.isGlobal) {
                            helper.handleError('doInit', $A.get("$Label.c.DNS_M_SelectSameGlobal")); // Only the same product can be ordered simultaneously. (Product, CV, SQ, accessories, RDD, Warranty, DC Price, Adjustment Price)
                        } else {
                            helper.handleError('doInit', $A.get("$Label.c.DNS_M_SelectSame")); // Only the same product can be ordered simultaneously. (Product, CV, SQ, accessories, RDD)
                        }
                        helper.closeModal(component);
                    } else if(defaultValues.isGlobal && !defaultValues.isOptyClosed) {
                        helper.handleError('doInit', $A.get("$Label.c.DNS_M_OpportunityClosed")); // Please close the opportunity first.
                        helper.closeModal(component);
                    }

                    component.set('v.quoteLineItemInfo', data.quoteLineItemInfo);
                    helper.setFieldValues(component, defaultValues);

                } else {
                    helper.handleError('doInit', returnVal.errorMsg);
                    helper.closeModal(component);
                }

                component.set('v.isLoading', false);
            } else {
                helper.handleError('doInit', response.getError());
            }
        });
        $A.enqueueAction(action);
        component.set('v.isLoading', false);

    },

    closeClick: function(component, event, helper) {
        helper.closeModal(component);
    },

    handleSubmit: function(component, event, helper) {
        console.log('orderCreate');
        
        event.preventDefault();

        const orderSeg = component.get('v.orderSegmentation');
        const combobox = component.find("OrderSegmentation__c");

        if(orderSeg == null || orderSeg == '' || !orderSeg) {
            combobox.setCustomValidity($A.get("$Label.c.DNS_M_RequiredMissing")); // Required field(s) is missing.
            combobox.reportValidity();
            return;
        }
        
        component.set('v.isLoading', true);

        const fields = event.getParam('fields');
        const isGlobal = component.get('v.isGlobal');
        const defaultValues = component.get('v.defaultValues');
        
        fields.OpportunityId = defaultValues.OpportunityId;
        fields.QuoteId       = defaultValues.QuoteId;

        // let tempChannel = defaultValues.distributionChannel;
        // if(defaultValues.salesChannel != 'DNSA') {
        //     tempChannel = defaultValues.salesChannel.includes('Domestic') ? '10' : '20';
        // }
        // fields.DistributionChannel__c = tempChannel;

        fields.BillingState       = component.get('v.soldToState');
        fields.BillingCity        = component.get('v.soldToCity');
        fields.BillingStreet      = component.get('v.soldToStreet');
        fields.BillingPostalCode  = component.get('v.soldToPostalCode');
        fields.BillingCountry     = component.get('v.soldToCountry');

        fields.ShippingState      = component.get('v.shippingState');
        fields.ShippingCity       = component.get('v.shippingCity');
        fields.ShippingStreet     = component.get('v.shippingStreet');
        fields.ShippingPostalCode = component.get('v.shippingPostalCode');
        fields.ShippingCountry    = component.get('v.shippingCountry');

        if(!defaultValues.isUser) { fields.DealerContact__c = defaultValues.dealerContact; }

        fields.CurrencyIsoCode      = defaultValues.currCode;
        fields.OrderSegmentation__c = orderSeg;

        if(isGlobal && defaultValues.quotePort) { fields.Port__c = defaultValues.quotePort; }

        let itemInfo = component.get('v.quoteLineItemInfo')
        console.log('handleSubmit - orderInfo ::: ', fields);
        // console.log('handleSubmit - itemInfo ::: ', JSON.stringify(itemInfo, null, 1));
        
        var action = component.get("c.saveOrders");
        action.setParams({ 
            orderInfo  : fields
            , itemInfo : itemInfo
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                helper.toast('success', $A.get("$Label.c.DNS_M_Success"), $A.get("$Label.c.DNS_M_OrderCreation"));
                helper.closeModal(component);
            } else {
                component.set('v.isLoading', false);
                helper.handleError('handleSubmit', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    changeOrderSeg: function(component, event, helper) {
        let segValue = event.getSource().get('v.value');
        console.log('changeOrderSeg - segValue ::: ', segValue);
        
        if(segValue == 'Consignment' || segValue == 'Wholesale') {
            helper.handleAccountValues(component);
        }

        const combobox = component.find("OrderSegmentation__c");
        if(segValue != null && segValue) {
            combobox.setCustomValidity(""); 
        }
    },

    handleAddress: function(component, event, helper) {
        var fieldName = event.getSource().get('v.fieldName');
        var accountId = event.getSource().get('v.value');
        
        helper.fetchAccountAddress(component, [{'fieldName' : fieldName, 'value' : accountId}]);
    },

    handleError: function(component, event, helper) {
        helper.handleError('handleError', event.getParam("message"));
        console.log("Error error : " + JSON.stringify(event.getParam("error"), null, 1));
    },

    handleCommission: function(component, event, helper) {
        console.log('handleCommission');
        const commission = event.getSource().get('v.value');
        
        if(commission && commission != 0) { component.set('v.hasCommission', true); }
        else { component.set('v.hasCommission', false); }

        console.log('handleCommission ::: ', commission , component.get('v.hasCommission'));
    },

    handleExport: function(component, event, helper) {
        console.log('handleExport');
        const isExport = event.getSource().get('v.value');

        if(isExport == 'Y') { component.set('v.isExport', true); }
        else { component.set('v.isExport', false); }

        console.log('handleExport ::: ', isExport , component.get('v.isExport'));
    },
})