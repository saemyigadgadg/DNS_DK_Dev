({
    doinit: function (component, event, helper) {
        component.set("v.isLoading", true);
        var cameraTypeSelectedList = [];
        cameraTypeSelectedList.push("A");
        helper.doInit(component, event, helper);
    },

    handleSelectRow: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        // console.log(document.querySelector("#quoteLineItems").getSelectedRows());
        component.set('v.selectedRows', selectedRows); 
        // console.log(event)
    },

    handleEdit: function (component, event){
        var actionType = event.getParam('action').name;
        var selectedRows = event.getParam('row');
            component.set('v.rowId', selectedRows.Id);
        if(actionType == 'Edit'){
            component.set('v.editRow', selectedRows);
            component.set('v.openEditModal', true);
        }else{
            component.set('v.openDelete', true);
            component.set("v.dataLoad", true);
        }        
    },

    handleClickClose: function(component, event){
        component.set('v.openDelete', false);

    },

    quoteLineDelete: function(component, event){
        component.set("v.dataLoad", false);

        var cancelReason = component.get('v.cancelReason');

        var action = component.get("c.deleteRecord");
        action.setParams({
            recordId : component.get('v.rowId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if(returnVal === "SUCCESS"){
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type" : "Success",
                    "title": $A.get("$Label.c.DNS_M_Success"),
                    "message": $A.get("$Label.c.DNS_M_DelSuccess")    
                });
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();
                component.set("v.dataLoad", true);
                component.set('v.openDelete', false);

            }else{
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.DNS_M_Error"),
                    "message": $A.get("$Label.c.DNS_M_DelFail"),
                    "type": "error"
                });
                toastEvent.fire();
                component.set("v.dataLoad", true);
                component.set('v.openDelete', false);
            }
        });
        $A.enqueueAction(action);
        component.set('v.cancelReason', '');
    },

    handlePriceModalBtn:function(component, event, helper){
        try {
            var selectedRows = component.get('v.selectedRows');

            var QuotePriceIfCheck = !selectedRows.some(function(item) {
                // console.log('item.QuotePrice : ' + item.QuotePriceIF);
                return item.QuotePriceIF === true;;
            });
            if(!QuotePriceIfCheck) {
                helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_M_QuotePriceDiff"));
                component.set('v.isLoading', false);
                component.find('quoteLineItems').set("v.selectedRows", []);
                return;
            }
            if (!selectedRows || selectedRows.length === 0) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.DNS_M_Error"),
                    "message": $A.get("$Label.c.DNS_M_SelectItem"),
                    "type": "error"
                });
                toastEvent.fire();
                return;
            }
            
            for(var i = 0; i < selectedRows.length; i++){
                if(selectedRows[i].CVComplete == false){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_SelectCV"),
                        "type": "error"
                    });
                    toastEvent.fire();
                    return;
                }
            }
            component.set('v.openPriceModal', true);
        } catch (error) {
            console.log('error : ' + error);
        }
        

    },

    handleClickRegistration: function (component, event, helper) {
        var selectedRows = component.get('v.selectedRows');
        if (!selectedRows || selectedRows.length === 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": $A.get("$Label.c.DNS_M_Error"),
                "message": $A.get("$Label.c.DNS_M_SelectItem"),
                "type": "error"
            });
            toastEvent.fire();
            return;
        }

        var hasOrderCreated = selectedRows.some(function(item) {
            return item.IsOrderCreated === true;
        });

        component.set('v.isLoading', true);
        if (hasOrderCreated) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_SQR_T_ALREADYORDER"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);
        } else {
            var toastEvent = $A.get("e.force:showToast");
    
            helper.apex(component, "validateQuoteLineItems", { quoteLineItems: selectedRows, btnCheck : 'SQ' })
            .then(function (result) {
                if (result.isValid) {
                    component.set('v.openSQModal', true);
                } else {
                    var errorMsg;
                    if(result.errorMessage == 'DNS_M_DiffProduct'){
                        errorMsg = $A.get('$Label.c.DNS_M_DiffProduct');
                    }else if(result.errorMessage == 'DNS_M_DiffOption'){
                        errorMsg = $A.get('$Label.c.DNS_M_DiffOption');
                    }else if(result.errorMessage == 'DNS_M_DiffCV'){
                        errorMsg = $A.get('$Label.c.DNS_M_DiffCV');
                    }
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": errorMsg,
                        "type": "Error"
                    });
                toastEvent.fire();
    
                }
                component.set('v.isLoading', false);
            })
            .catch(function (error) {
                console.error(error);
                component.set('v.isLoading', false);
            });
        }
    },

    handleSort: function (component, event, helper) {
        const sortedBy = event.getParam('fieldName');
        const sortDirection = event.getParam('sortDirection');
        
        component.set('v.sortedBy', sortedBy);
        component.set('v.sortDirection', sortDirection);
        
        let quoteLineItems = component.get("v.quoteLineItemList");
        quoteLineItems = helper.sortData(quoteLineItems, sortedBy, sortDirection);
        component.set("v.quoteLineItemList", quoteLineItems);
    },

    handleSaveEdition: function(component, event, helper){
        var draftValues = event.getParam('draftValues');

        var action = component.get("c.updateRDD");
        action.setParams({
            recordId : recordId,
            upRecord : draftValues
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success"),
                            "message": $A.get('$Label.c.DNS_M_UpdateSuccess')
    
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                "message": $A.get('$Label.c.DNS_M_UpdateFail'),
                                "type": "error"
                            });
                            toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        component.set("v.draftValues", []);
    },

    handleModalEvent : function(component,event,helper){
        var message = event.getParam('message');
        // console.log('handleModalEvent - message ::: ', message);

        component.set('v.openModal', false);
        component.set('v.openEditModal', false);
        component.set('v.openPriceModal', false);
        
        if(message == 'updateGroupId'){
            // console.log('reset? : ' + component.get('v.selectedRows'));
            // helper.doInit(component, event, helper);
            component.find('quoteLineItems').set("v.selectedRows", []);

        } else if(message == 'CloseSQ') {
            component.set('v.openSQModal', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

        } else if(message == 'CloseQuoteItemEdit') {
            component.set('v.openEditModal', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

        }else if(message[0] == 'updateRDD'){
            component.set('v.recordId', message[1]);
            helper.doInit(component, event, helper);
            component.find('quoteLineItems').set("v.selectedRows", []);

        } else if(message == 'CloseCV') {
            component.find('quoteLineItems').set("v.selectedRows", []);
            component.set('v.isLoading', false);

        } else if(message == 'Delete Success'){
            component.set('v.openDelete', false);
            helper.doInit(component, event, helper);
        }else if(message == 'ClosePrice'){
            component.set('v.openPriceModal', false);
            helper.doInit(component, event, helper);
        }else if(message == 'erpQuotePrice'){
            component.set('v.openPriceModal', false);
            component.find('quoteLineItems').set("v.selectedRows", []);
            helper.doInit(component, event, helper);
        }
    }, 

    handleAccessoryBtn : function(component,event,helper) {
        var selectedRows = component.get('v.selectedRows');
        let isPass = helper.verifyBtnConditions(selectedRows);
        // console.log('isPass : ', isPass);
        // console.log('selectedRows : ', selectedRows);
        

        if(isPass) {
            // if(component.get('v.recordTypeName') == 'DNSA Factory') {
            //     $A.createComponent("c:DN_QuoteItemAccessoryModal"
            //     , { selectedItems : selectedRows }
            //     , function(content, status) {
            //         if (status === "SUCCESS") {
            //             component.find('overlayLib').showCustomModal({
            //                 header: $A.get("$Label.c.DNS_S_SelectAccessory")
            //                 , body: content
            //                 , showCloseButton: true
            //                 , closeCallback: function() {
            //                     component.find('quoteLineItems').set("v.selectedRows", []);
            //                     component.set("v.selectedRows", []);
            //                     $A.get('e.force:refreshView').fire();
            //                 }
            //             });
            //         }
            //     });

            // } else if(component.get('v.recordTypeName') == 'DNSA Commodity') {

            //     var qliList = component.get('v.quoteLineItemList');
            //     $A.createComponent("c:DNSA_QuoteItemAccessoryModal"
            //     , { selectedItems : selectedRows, quoteId : qliList[0].Id }
            //     , function(content, status) {
            //         if (status === "SUCCESS") {
            //             component.find('overlayLib').showCustomModal({
            //                 header: $A.get("$Label.c.DNS_S_SelectAccessory")
            //                 , body: content
            //                 , showCloseButton: true
            //                 , closeCallback: function() {
            //                     component.find('quoteLineItems').set("v.selectedRows", []);
            //                     component.set("v.selectedRows", []);
            //                     $A.get('e.force:refreshView').fire();
            //                 }
            //             });
            //         }
            //     });
            try {
                var qliList = component.get('v.quoteLineItemList');
                // console.log('qliList : ' + JSON.stringify(qliList));
                $A.createComponent("c:DNSA_QuoteItemAccessoryModal"
                , { selectedItems : selectedRows, quoteId : qliList[0].Id }
                , function(content, status) {
                    if (status === "SUCCESS") {
                        component.find('overlayLib').showCustomModal({
                            header: $A.get("$Label.c.DNS_S_SelectAccessory")
                            , body: content
                            , showCloseButton: true
                            , closeCallback: function() {
                                component.find('quoteLineItems').set("v.selectedRows", []);
                                component.set("v.selectedRows", []);
                                $A.get('e.force:refreshView').fire();
                            }
                        });
                    }
                });
            } catch (error) {
                console.log('error~~ : ' + error);
            }
            
            
        } 
    },

    handleSelectOptionsBtn: function (component, event, helper) {
        var selectedRows = component.get('v.selectedRows');
        // console.log('1');
        if (!selectedRows || selectedRows.length === 0) {
            // alert('Select the Line Item to Review.');
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                // "message": $A.get("$Label.c.DNS_M_SelectItem"),
                                "message": 'Please Select the product first.',
                                "type": "error"
                            });
                            toastEvent.fire();
            return;
        }
        // console.log('2');

        // component.set('v.isLoading', true);
        // console.log('3');

        
        // console.log('4');

        helper.apex(component, "validateQuoteLineItems", { quoteLineItems: selectedRows, btnCheck : 'Option' })
        .then(function (result) {
            if (result.isValid) {
                component.set('v.openModal', true);
                // console.log('5');

            } else {
                // console.log('6');
                // 오류 메시지 표시
                var errorMsg;
                if(result.errorMessage == 'DNS_M_DiffProduct'){
                    errorMsg = $A.get('$Label.c.DNS_M_DiffProduct');
                }else if(result.errorMessage == 'DNS_M_DiffOption'){
                    errorMsg = $A.get('$Label.c.DNS_M_DiffOption');
                }else if(result.errorMessage == 'DNS_M_DiffCV'){
                    errorMsg = $A.get('$Label.c.DNS_M_DiffCV');
                }
                 
                // alert(result.errorMessage);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.DNS_M_Error"),
                    "message": errorMsg,
                    "type": "Error"
                });
                toastEvent.fire();
                component.set('v.isLoading', false);
            }
            
        })
        .catch(function (error) {
            console.error(error);
            component.set('v.isLoading', false);
        });

        // var quotelineItems = document.querySelector("#quoteLineItems").getSelectedRows();

        // var recordIds = component.get('v.recordIds');
        // recordIds.length = 0;
        // if (quotelineItems.length > 0) {
        //     quotelineItems.forEach(quoteLineItem => {
        //         console.log(quoteLineItem);
        //         console.log(quoteLineItem.Id);
        //         recordIds.push(quoteLineItem.Id);
        //     });
        // }
        // console.log(recordIds);
        // component.set('v.recordIds', recordIds);
        // component.set('v.openModal', true);
        // console.log('recordIds : ', component.get('v.recordIds'));
    }
})