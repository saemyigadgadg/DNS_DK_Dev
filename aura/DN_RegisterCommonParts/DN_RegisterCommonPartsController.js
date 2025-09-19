({
    doInit: function (component, event, helper) {
        
    },

    clickSearch: function (component, event, helper) {
        // component.set('v.isLoading', true);
        // var productName = component.get('v.productName');
        // var productNo = component.get('v.productNo');
        // var action = component.get('c.searchCommonParts');
        // action.setParams(
        //     {
        //         productName: productName,
        //         productNo: productNo
        //     }
        // );
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     console.log('state:', state);
        //     if (state == "SUCCESS") {
        //         var result = response.getReturnValue();
        //         console.log('result:', result);
        //         component.set('v.productList', result);
        //     } else {
        //         helper.showMyToast('Error', 'Failed Search Data');
        //     }
        //     component.set('v.isLoading', false);
        // });
        // $A.enqueueAction(action);
    },

    selectData: function (component, event, helper) {
        try {
            var prodId = event.getParam("value")[0];
            console.log('prodId', JSON.stringify(prodId));
            var productList = component.get('v.productList');
            console.log('productList', JSON.stringify(productList));

            var isDup = productList.some(function (item) {
                return item.ProductId == prodId;
            });
            if (isDup) {
                helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_EXISTCOMMONPARTS"));
                return;
            }
            
            var data = {
                prodId: prodId
            }
            var jsonData = JSON.stringify(data);
            var action = component.get('c.selectCommonParts');
            action.setParams(
                {
                    pdData: jsonData
                }
            );
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state:', state);
                if (state == "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('result:', result);
                    var originProductList = component.get('v.productList') || [];
                    var updateProductList = originProductList.concat(result);
                    component.set('v.productList', updateProductList);
                    component.set('v.productName', null);
                } else {
                    helper.showMyToast('Error', 'Failed Search Data');
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            console.log(error.getMessage());
        }
    },

    commonPartsDelete: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        console.log('rowIndex', rowIndex);
        var productList = component.get('v.productList');
        console.log('productList', productList);

        if (productList && rowIndex >= 0) {
            productList.splice(rowIndex, 1);
        }
        component.set('v.productList', productList);
    },

    registerCommonParts: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var productList = component.get('v.productList');
        console.log('productList', productList);
    
        if (productList.length < 1) {
            helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_ATLEASTPARTS"));
            return;
        }
        for (var i = 0; i < productList.length; i++) {
            var quantity = productList[i].prodQuantity;
            if (quantity <= 0 || quantity == null || !Number.isInteger(Number(productList[i].prodQuantity))) {
                helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_INPUTONLYINTEGER"));
                return;
            }
            if (quantity.toString().length > 5) {
                helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_TOOMANYQUANTITY"));
                return;
            }
            if (productList[i].prodNote.length > 255) {
                helper.showMyToast('Error', $A.get("$Label.c.DNS_CAM_T_REMARKSLIMIT"));
                return;
            }
        }
        var registerData = [];
        productList.forEach((item) => {
            registerData.push({
                prodId: item.ProductId,
                prodName: item.ProductName,
                prodNumber: item.ProductNo,
                prodQuantity: item.prodQuantity,
                prodNote: item.prodNote
            });
        });
        console.log('registerData', JSON.stringify(registerData));
        component.set('v.isLoading', true);
        var action = component.get('c.saveCommonParts');
        action.setParams({
            recordId: recordId,
            registerData: registerData
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.isSuccess == true) {
                    helper.showMyToast('SUCCESS', $A.get("$Label.c.DNS_CAM_T_REGISTERCOMMONPARTS"));
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    helper.showMyToast('ERROR', $A.get("$Label.c.DNS_CAM_T_EXISTPARTS"));
                }
            } else {
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    console.log("Apex 에러: " + errors[0].message);
                } else {
                    console.log("에러 발생");
                }
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    
    updateQuantity: function (component, helper, event) {
        console.log('updateQuantity');
    },

    closeModal: function (component, helper, event) {
        $A.get("e.force:closeQuickAction").fire();
    }

})