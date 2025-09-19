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
    fetchAccountAddress : function(component, targt) {
        // SLS-ORD-028
        console.log('fetchAccountAddress', JSON.stringify(targt, null, 2));
        
        const self = this;
        let accountIds = [];
        targt.forEach( row => accountIds.push(row.value) );
        accountIds = accountIds.map(id => String(id));
        try {
            var action = component.get("c.getAccountShipAddress");
        console.log('1');
        action.setParams({accountIds : accountIds});
        action.setCallback(component, function(response) {
        console.log('2');
            console.log('acc : ' + accountIds);
            var state = response.getState();
            console.log('state : ' + state);
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('fetchAccountAddress - returnVal', JSON.stringify(returnVal, null, 2));
                
                targt.forEach(row => {
                    let acc = returnVal.filter(acc => acc.Id == row.value)[0];
                    // console.log('acc', JSON.stringify(acc, null, 2));
                    // console.log('row', JSON.stringify(row, null, 2));

                    if(acc.ShippingAddress) {
                        component.set('v.shippingState',      acc.ShippingAddress.state      ? acc.ShippingAddress.state : '');
                        component.set('v.shippingCity',       acc.ShippingAddress.city       ? acc.ShippingAddress.city : '');
                        component.set('v.shippingStreet',     acc.ShippingAddress.street     ? acc.ShippingAddress.street : '');
                        component.set('v.shippingPostalCode', acc.ShippingAddress.postalCode ? acc.ShippingAddress.postalCode : '');
                        component.set('v.shippingCountry',    acc.ShippingAddress.country    ? acc.ShippingAddress.country : '');
                    } else {
                        component.set('v.shippingState',      '');
                        component.set('v.shippingCity',       '');
                        component.set('v.shippingStreet',     '');
                        component.set('v.shippingPostalCode', '');
                        component.set('v.shippingCountry',    '');
                    }
                });
                
            } else {
                // self.handleError('fetchAccountAddress', response.getError());
            }
        });
        $A.enqueueAction(action);
        } catch (error) {
            console.log('error : ' + error);
        }
        
    },
    // handleError : function(methodName, errorMsg) {
    //     var msg = errorMsg;
    //     if(typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
    //     if(msg.message) { msg = msg.message; }

    //     if(msg.includes('first error:')) msg = msg.split('first error:')[1];

    //     console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
    //     this.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
    // }
})