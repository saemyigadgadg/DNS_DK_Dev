({
    toast: function (type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title      : title
            , type     : type
            , message  : message
            , duration : 3000
            , mode     : 'dismissible'
        });
        toastEvent.fire();
    }

    , closeModal : function(component) {
        component.find("overlayLib").notifyClose();
    }

    , handleError : function(methodName, errorMsg) {
        var msg = errorMsg;
        if(typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
        if(msg.message) { msg = msg.message; }

        if(msg.includes('first error:')) msg = msg.split('first error:')[1];

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        this.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
    }

    , reverseSpinner: function(component){
        component.set('v.isLoading', !component.get('v.isLoading'));
    }

    , handleAccountValues : function(component) {
        const defaultValues = component.get("v.defaultValues");
        const segementation = component.get("v.orderSegmentation");
        const soldTo        = component.find("SoldTo__c").get("v.value");
        const shipTo        = component.find("ShipTo__c").get("v.value");
        
        if(defaultValues.isGlobal) return;

        let target = [];
        // SLS-ORD-027
        if(segementation == 'Consignment') {
            component.find('SoldTo__c').set('v.value', defaultValues.optyAccount);
            component.find('Payer__c').set('v.value',  defaultValues.optyAccount);
            component.find('BillTo__c').set('v.value', defaultValues.optyAccount);
            component.find('ShipTo__c').set('v.value', defaultValues.optyAccount);

            if(soldTo != defaultValues.optyAccount) {
                target.push({'fieldName' : 'SoldTo__c', value: defaultValues.optyAccount});
            } else if (shipTo != defaultValues.optyAccount) {
                target.push({'fieldName' : 'ShipTo__c', value: defaultValues.optyAccount});
            }
        } else if (segementation == 'Wholesale') {
            component.find('SoldTo__c').set('v.value', defaultValues.dealerAccount);
            component.find('Payer__c').set('v.value',  defaultValues.dealerAccount);
            component.find('BillTo__c').set('v.value', defaultValues.dealerAccount);
            component.find('ShipTo__c').set('v.value', defaultValues.optyAccount);
            if(soldTo != defaultValues.dealerAccount) {
                target.push({'fieldName' : 'SoldTo__c', value: defaultValues.dealerAccount});
            } else if (shipTo != defaultValues.optyAccount) {
                target.push({'fieldName' : 'ShipTo__c', value: defaultValues.optyAccount});
            }
        }
        
        if(target.length > 0) { this.fetchAccountAddress(component, target); }
    }

    , fetchAccountAddress : function(component, targt) {
        // SLS-ORD-028
        // console.log('fetchAccountAddress', JSON.stringify(targt, null, 2));
        
        const self = this;
        let accountIds = [];
        targt.forEach( row => accountIds.push(row.value) );
        
        var action = component.get("c.getAccountAddress");
        action.setParams({accountIds : accountIds});
        action.setCallback(component, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                // console.log('fetchAccountAddress - returnVal', JSON.stringify(returnVal, null, 2));
                
                targt.forEach(row => {
                    let acc = returnVal.filter(acc => acc.Id == row.value)[0];
                    // console.log('acc', JSON.stringify(acc, null, 2));
                    // console.log('row', JSON.stringify(row, null, 2));

                    if(acc.ShippingAddress) {
                        if(row.fieldName == 'SoldTo__c'){
                            component.set('v.soldToState',      acc.ShippingAddress.state      ? acc.ShippingAddress.state : '');
                            component.set('v.soldToCity',       acc.ShippingAddress.city       ? acc.ShippingAddress.city : '');
                            component.set('v.soldToStreet',     acc.ShippingAddress.street     ? acc.ShippingAddress.street : '');
                            component.set('v.soldToPostalCode', acc.ShippingAddress.postalCode ? acc.ShippingAddress.postalCode : '');
                            component.set('v.soldToCountry',    acc.ShippingAddress.country    ? acc.ShippingAddress.country : '');
                        } else if(row.fieldName == 'ShipTo__c') {
                            component.set('v.shippingState',      acc.ShippingAddress.state      ? acc.ShippingAddress.state : '');
                            component.set('v.shippingCity',       acc.ShippingAddress.city       ? acc.ShippingAddress.city : '');
                            component.set('v.shippingStreet',     acc.ShippingAddress.street     ? acc.ShippingAddress.street : '');
                            component.set('v.shippingPostalCode', acc.ShippingAddress.postalCode ? acc.ShippingAddress.postalCode : '');
                            component.set('v.shippingCountry',    acc.ShippingAddress.country    ? acc.ShippingAddress.country : '');
                        }
                    } else {
                        if(row.fieldName == 'SoldTo__c'){
                            component.set('v.soldToState',      '');
                            component.set('v.soldToCity',       '');
                            component.set('v.soldToStreet',     '');
                            component.set('v.soldToPostalCode', '');
                            component.set('v.soldToCountry',    '');
                        } else if(row.fieldName == 'ShipTo__c') {
                            component.set('v.shippingState',      '');
                            component.set('v.shippingCity',       '');
                            component.set('v.shippingStreet',     '');
                            component.set('v.shippingPostalCode', '');
                            component.set('v.shippingCountry',    '');
                        }
                    }
                });
                
            } else {
                self.handleError('fetchAccountAddress', response.getError());
            }
        });
        $A.enqueueAction(action);
    }

    , fetchAccountInformation : function(component) {
        console.log('fetchAccountInformation');
        const accId = component.find('AccountId').get('v.value');
        // SLS-ORD-029
        var self   = this;
        var action = component.get("c.getSalesAreaData");
        action.setParams({accountId : accId});
        action.setCallback(component, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                if(returnVal) {
                    // console.log('fetchAccountInformation - returnVal ::: ', returnVal);

                    component.find('Incoterms__c').set('v.value', returnVal.Incoterms__c);
                    component.find('PaymentTerms__c').set('v.value', returnVal.TermsOfPayment__c);
                } else {
                    self.handleError('fetchAccountInformation', $A.get("$Label.c.DNS_M_NoMatchSalesAreaData"));
                }
                
            } else {
                self.handleError('fetchAccountInformation', response.getError());
            }
        });
        $A.enqueueAction(action);
    }

    , checkSameKey : function(quoteLineItemInfo) {
        const keys = quoteLineItemInfo.map(item => item.key);
        const firstKey = keys[0];
        return keys.every(key => key === firstKey);
    }

    , setFieldValues : function(component, defaultValues) {
        const self = this;

        component.set("v.defaultValues", defaultValues);

        component.set('v.isUser',        defaultValues.isUser);
        component.set('v.isGlobal',      defaultValues.isGlobal);
        component.set('v.salesChannel',  defaultValues.salesChannel);
        component.set('v.country',       defaultValues.country);

        let target    = [];
        component.find('AccountId').set('v.value', defaultValues.optyAccount);

        if (defaultValues.isUser) {
            component.find('ShipTo__c').set('v.value', defaultValues.optyAccount);
            component.find('SoldTo__c').set('v.value', defaultValues.optyAccount);
            component.find('Payer__c').set('v.value',  defaultValues.optyAccount);
            component.find('BillTo__c').set('v.value', defaultValues.optyAccount);
            target.push({'fieldName' : 'ShipTo__c', 'value' : defaultValues.optyAccount});
            target.push({'fieldName' : 'SoldTo__c', 'value' : defaultValues.optyAccount});
            component.set('v.optionsForSeg', defaultValues.optionsForSeg);
            
            if(!defaultValues.isGlobal) {
                component.set('v.disabledSeg', true);
                component.set('v.orderSegmentation', 'DirectSales');
            }
        } else {
            const segOp = defaultValues.optionsForSeg.filter(s => s.value != 'DirectSales');
            if(defaultValues.isGlobal) {
                component.set('v.optionsForSeg', segOp);
                component.set('v.orderSegmentation', 'Wholesale');
                component.set('v.disabledSeg', true);
            } else {
                component.set('v.optionsForSeg', segOp);
            }

            component.find('ShipTo__c').set('v.value', defaultValues.optyAccount);
            target.push({'fieldName' : 'ShipTo__c', 'value' : defaultValues.optyAccount});

            component.find('Payer__c').set('v.value',  defaultValues.dealerAccount);
            component.find('BillTo__c').set('v.value', defaultValues.dealerAccount);
            component.find('SoldTo__c').set('v.value', defaultValues.dealerAccount);
            target.push({'fieldName' : 'SoldTo__c', 'value' : defaultValues.dealerAccount});
        }

        if(target.length > 0) { self.fetchAccountAddress(component, target) };
        self.fetchAccountInformation(component);

        const tempAccount = defaultValues.isUser ? defaultValues.dnsAccount : defaultValues.dealerAccount;
        
        component.find('SalesRep__c').set('v.value', tempAccount);
        component.find('CreditDealer__c').set('v.value', tempAccount);
        component.find('ServiceDealer__c').set('v.value', tempAccount);
        component.find('RelatedDealer__c').set('v.value', tempAccount);

        component.find('MainCategory__c').set('v.value', defaultValues.categoryLv1);
        component.find('SubCategory__c').set('v.value', defaultValues.categoryLv2);
        component.find('IsTooling__c').set('v.value', defaultValues.categoryLv3);


        const quoteLineItemInfo = component.get('v.quoteLineItemInfo');
        component.find('ReqDeliveryDate__c').set('v.value', quoteLineItemInfo[0].quoteRDD);

    }
})