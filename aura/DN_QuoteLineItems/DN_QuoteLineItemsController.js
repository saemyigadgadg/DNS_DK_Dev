/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 05-21-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-17   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doinit: function (component, event, helper) {
        // console.log('DN_QuoteLineItems');
        
        component.set("v.isLoading", true);
        var cameraTypeSelectedList = [];
        cameraTypeSelectedList.push("A");
        // console.log(cameraTypeSelectedList);
        helper.doInit(component, event, helper);

        // var quoteLineItemList = component.get('v.quoteLineItemList');
        // var recentlyVersion = true;
        // if(quoteLineItemList.length > 0){
        //     recentlyVersion = quoteLineItemList[0].recentlyVersion;
        // }
        // console.log('data : ' + JSON.stringify(quoteLineItemList[0]));
        // var actions = [];
        // if(recentlyVersion){
        //     actions = [
        //         { label: 'Edit', name: 'Edit' },
        //         { label: 'Delete', name: 'delete' }
        //     ]
        // }
        
        // let columns = [
        //     {
        //         label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true,
        //         typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
        //     },
        //     { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true },
        //     { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true },
        //     { label: 'Sales Price', fieldName: 'SalesPrice', type: 'text', sortable: true },
        //     { label: 'Quantity', fieldName: 'Quantity', type: 'text', sortable: true },
        //     { label: 'Subtotal', fieldName: 'Subtotal', type: 'text', sortable: true },
        //     { label: 'Discount(Percentage)', fieldName: 'Discount', type: 'text', sortable: true },
        //     { label: 'Total Price', fieldName: 'TotalPrice', type: 'text', sortable: true },
        //     { label: 'List Price', fieldName: 'ListPrice', type: 'text', sortable: true },
        //     { label: 'GroupId', fieldName: 'GroupId', type: 'text'},
        //     { label: 'CV Complete', fieldName: 'CVComplete', type:'boolean'},
        //     { label: 'Is Order Created', fieldName: 'IsOrderCreated', type:'boolean'},
        //     { 
        //         type: "action",
        //         typeAttributes: { rowActions: actions }
        //     }
        // ];
        // component.set('v.columns', columns);
    },

    handleSelectRow: function (component, event) {
        var selectedRows = event.getParam('selectedRows');
        // console.log(document.querySelector("#quoteLineItems").getSelectedRows());
        component.set('v.selectedRows', selectedRows);
        // console.log(component.get('v.seletedRows'));  
        // console.log(event)
    },

    handleEdit: function (component, event){
        var actionType = event.getParam('action').name;
        var selectedRows = event.getParam('row');
            // console.log('asdsada', selectedRows);
            // console.log('qweqweqweq', selectedRows.Id);
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
        component.set('v.openDeleteMulti', false);
        component.find('quoteLineItems').set("v.selectedRows", []);

    },
    quoteLineDelete: function(component, event){
        component.set("v.dataLoad", false);

        // console.log('delId : ' + component.get('v.rowId'));
        // console.log(component.get('v.cancelReason'));
        var cancelReason = component.get('v.cancelReason');

        var action = component.get("c.deleteRecord");
        action.setParams({
            recordId : component.get('v.rowId')
            // cancelReason : component.get('v.cancelReason')
        });
        action.setCallback(this, function(response){
            var state = response.getReturnValue();
            if(state === "SUCCESS"){
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
                                "message": state,
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
    quoteLineDeleteMulti: function(component, event){
        var selectedRows = component.get('v.selectedRows');
        var QtlineId = selectedRows.map(item => item.Id);;
        // console.log('QtlineId : ' + QtlineId);
        component.set("v.dataLoad", false);
        var action = component.get("c.deleteRecordMulti");
        action.setParams({
            QtlineId : QtlineId
        });
        action.setCallback(this, function(response){
            var state = response.getReturnValue();
            if(state === "SUCCESS"){
                var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success"),
                            "message": $A.get("$Label.c.DNS_M_DelSuccess")
    
                        });
                        resultsToast.fire();
                        $A.get('e.force:refreshView').fire();
                        component.set("v.dataLoad", true);
                        component.set('v.openDeleteMulti', false);
            }else{
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                "message": state,
                                "type": "error"
                            });
                            toastEvent.fire();
                            component.set("v.dataLoad", true);
                            component.set('v.openDeleteMulti', false);
            }
        });
        $A.enqueueAction(action);
        component.find('quoteLineItems').set("v.selectedRows", []);
    },
    handlePriceModalBtn:function(component, event, helper){
        var recordType = component.get('v.recordType');
        var selectedRows = component.get('v.selectedRows');
        if (!selectedRows || selectedRows.length === 0) {
            // alert('Select the Line Item to Review.');
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                "message": $A.get("$Label.c.DNS_M_SelectItem"),
                                "type": "error"
                            });
                            toastEvent.fire();
            return;
        }
        
        var erpNumCheck = selectedRows.every(function(item, _, arr) {
            // console.log('item.ERPQutaionNO :', item.ERPQutaionNO);
            return item.ERPQutaionNO === arr[0].ERPQutaionNO;
        });
        
        if(!erpNumCheck) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_SQR_T_ERPNUMCHECK"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);
            return;
        }

        var warrantyCheck = selectedRows.every(function(item, _, arr) {
            return item.Warranty === arr[0].Warranty;
        });
        var QuotePriceIfCheck = !selectedRows.some(function(item) {
            // console.log('item.QuotePrice : ' + item.QuotePriceIF);
            return item.QuotePriceIF === true;;
        });

        let isPass = helper.verifyBtnConditions(selectedRows, recordType);
        // console.log('isPass : ' + isPass);
        if(!isPass) {
            return;
        }

        // if(!warrantyCheck) {
        //     helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_M_DiffWarranty"));
        //     component.set('v.isLoading', false);
        //     component.find('quoteLineItems').set("v.selectedRows", []);
        //     return;
        // }
        // console.log('QuotePriceIfCheck : ' + QuotePriceIfCheck);
        // if(!QuotePriceIfCheck) {
        //     helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_M_QuotePriceDiff"));
        //     component.set('v.isLoading', false);
        //     component.find('quoteLineItems').set("v.selectedRows", []);
        //     return;
        // }

        
        // if(selectedRows.length > 1){
        //     var toastEvent = $A.get("e.force:showToast");
        //                     toastEvent.setParams({
        //                         "title": $A.get("$Label.c.DNS_M_Error"),
        //                         "message": $A.get("$Label.c.DNS_M_OnlyOneQuotePrice"), //견적 가격 정보 확인은 한 건씩 진행 해 주세요., Please review the quotation price information one at a time.
        //                         "type": "error"
        //                     });
        //                     toastEvent.fire();
        //     return;
        // }

        // component.set('v.isLoading', true);
        for(var i = 0; i < selectedRows.length; i++){
            if(selectedRows[i].CVComplete == false && selectedRows[i].isPilot == false){
                // alert('CV 선택이 완료 된 건만 선택 해 주세요.');
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

        helper.apex(component, "validateQuoteLineItems", { quoteLineItems: selectedRows, btnCheck : 'Price' })
        .then(function (result) {
            if (result.isValid) {
                component.set('v.openPriceModal', true);

            } else {
                // 오류 메시지 표시
                var errorMsg;
                if(result.errorMessage == 'DNS_M_DiffProduct'){
                    errorMsg = $A.get('$Label.c.DNS_M_DiffProduct');
                }else if(result.errorMessage == 'DNS_M_DiffOption'){
                    errorMsg = $A.get('$Label.c.DNS_M_DiffOption');
                }else if(result.errorMessage == 'DNS_M_DiffCV'){
                    errorMsg = $A.get('$Label.c.DNS_M_DiffCV');
                }else if(result.errorMessage == 'DNS_M_SelectedDiffSpecs'){
                    errorMsg = $A.get('$Label.c.DNS_M_SelectedDiffSpecs');
                }else if(result.errorMessage == 'DNS_M_DiffSQ'){
                    errorMsg = $A.get('$Label.c.DNS_M_DiffSQ');
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
                component.find('quoteLineItems').set("v.selectedRows", []);

            }
            
        })
        .catch(function (error) {
            console.error(error);
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

        });

    },

    handleMultiEdit: function(component, event, helper){
        try {
            var selectedRows = component.get('v.selectedRows');
        if(!selectedRows || selectedRows.length === 0) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_M_SelectItem"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

            return;
        }
        var erpNumCheck = selectedRows.every(function(item, index, arr) {
            // console.log(`Index ${index}:`, item);
            // console.log(`item.ERPQutaionNO :`, item.ERPQutaionNO);
        
            // 첫 번째 요소의 ERPQutaionNO 값을 기준으로 설정 (키가 없거나 undefined면 null로 처리)
            const referenceValue = arr[0].ERPQutaionNO !== undefined ? arr[0].ERPQutaionNO : null;
            const currentValue = item.ERPQutaionNO !== undefined ? item.ERPQutaionNO : null;
        
            return currentValue === referenceValue;
        });
        
        if(!erpNumCheck) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_M_DiffInquiryNo"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

            return;
        }
        // console.log('1');
        const mainData = selectedRows[0];
        // console.log('2');

        const getValue = (obj, key) => obj.hasOwnProperty(key) ? obj[key] : null;
        // console.log('3');

        const isSame = selectedRows.every(obj =>
            getValue(obj, 'SalesPrice') === getValue(mainData, 'SalesPrice') &&
            getValue(obj, 'CVTotal') === getValue(mainData, 'CVTotal') &&
            getValue(obj, 'SQTotal') === getValue(mainData, 'SQTotal') &&
            getValue(obj, 'AccTotal') === getValue(mainData, 'AccTotal')
        );
        // console.log('4');
        // console.log('isSam : ' + isSame);
        component.set('v.openEditMultiModal', isSame);
        
        if(!isSame) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_M_DiffPrice"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

            return;

        }
        } catch (error) {
            console.log('error : ' + error);
        }
        
    },
    handleMultiDelete: function(component, event, helper){
        try {
            var selectedRows = component.get('v.selectedRows');
            if(!selectedRows || selectedRows.length === 0) {
                helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_M_SelectItem"));
                component.set('v.isLoading', false);
                component.find('quoteLineItems').set("v.selectedRows", []);

                return;
            }
            component.set('v.openDeleteMulti', true);
            component.set("v.dataLoad", true);

        } catch (error) {
            console.log('error : ' + error);
        }
    },
    handleSelectOptionsBtn: function (component, event, helper) {
        var selectedRows = component.get('v.selectedRows');
        // console.log('1');

        var erpNumCheck = selectedRows.every(function(item, _, arr) {
            // console.log('item.ERPQutaionNO :', item.ERPQutaionNO);
            return item.ERPQutaionNO === arr[0].ERPQutaionNO;
        });

        if(!erpNumCheck) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_SQR_T_ERPNUMCHECK"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

            return;

        }
        if (!selectedRows || selectedRows.length === 0) {
            // alert('Select the Line Item to Review.');
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": $A.get("$Label.c.DNS_M_Error"),
                                "message": $A.get("$Label.c.DNS_M_SelectItem"),
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
    },

    handleClickRegistration: function (component, event, helper) {
        var selectedRows = component.get('v.selectedRows');
        if (!selectedRows || selectedRows.length === 0) {
            // alert('Select the Line Item to Review.');
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
        
        var erpNumCheck = selectedRows.every(function(item, _, arr) {
            // console.log('item.ERPQutaionNO :', item.ERPQutaionNO);
            return item.ERPQutaionNO === arr[0].ERPQutaionNO;
        });

        component.set('v.isLoading', true);
        if (hasOrderCreated) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_SQR_T_ALREADYORDER"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);
        } else if(!erpNumCheck) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_SQR_T_ERPNUMCHECK"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);
        } else {
            var toastEvent = $A.get("e.force:showToast");
    
            helper.apex(component, "validateQuoteLineItems", { quoteLineItems: selectedRows, btnCheck : 'SQ' })
            .then(function (result) {
                if (result.isValid) {
                    component.set('v.openSQModal', true);
                } else {
                    // 오류 메시지 표시
                    // alert(result.errorMessage);
                    var errorMsg;
                    if(result.errorMessage == 'DNS_M_DiffProduct'){
                        errorMsg = $A.get('$Label.c.DNS_M_DiffProduct');
                    }else if(result.errorMessage == 'DNS_M_DiffOption'){
                        errorMsg = $A.get('$Label.c.DNS_M_DiffOption');
                    }else if(result.errorMessage == 'DNS_M_DiffCV'){ 
                        errorMsg = $A.get('$Label.c.DNS_M_DiffCV'); //같은 제품에 대해 다른 옵션을 허용할 수 없습니다.
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
        
        // console.log(sortedBy);
        // console.log(sortDirection);
        component.set('v.sortedBy', sortedBy);
        component.set('v.sortDirection', sortDirection);
        
        let quoteLineItems = component.get("v.quoteLineItemList");
        quoteLineItems = helper.sortData(quoteLineItems, sortedBy, sortDirection);
        component.set("v.quoteLineItemList", quoteLineItems);
    },

    handleSaveEdition: function(component, event, helper){
        var draftValues = event.getParam('draftValues');
        // console.log(draftValues);
        // console.log(event);
        // draftValues.forEach(draft => {
        //     console.log(draft.Id);
        //     let rowId = draft.Id;
        //     let fullRow  = component.get('v.quoteLineItemList').find(row => row.Id === rowId);
        //     console.log(fullRow);
        // })

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
        // helper.doInit(component, event, helper);

        
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
        } else if(message == 'CloseQuoteItemEditMulti') {
            component.set('v.openEditMultiModal', false);
            component.find('quoteLineItems').set("v.selectedRows", []);

        }else if(message[0] == 'updateRDD'){
            // console.log('message 1 : ' + message[1]);
            component.set('v.recordId', message[1]);
            component.set('v.openEditModal', false);
            component.set('v.openEditMultiModal', false);
            component.find('quoteLineItems').set("v.selectedRows", []);
            helper.doInit(component, event, helper);

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
        var recordType = component.get('v.recordType');

        var erpNumCheck = selectedRows.every(function(item, _, arr) {
            // console.log('item.ERPQutaionNO :', item.ERPQutaionNO);
            return item.ERPQutaionNO === arr[0].ERPQutaionNO;
        });

        if(!erpNumCheck) {
            helper.toast('ERROR', 'ERROR',  $A.get("$Label.c.DNS_SQR_T_ERPNUMCHECK"));
            component.set('v.isLoading', false);
            component.find('quoteLineItems').set("v.selectedRows", []);
            return;
        }

        // console.log('recordType in handle Acc : ', recordType);

        let isPass = helper.verifyBtnConditions(selectedRows, recordType);
        // console.log('isPass : ', isPass);
        

        if(isPass) {

            if(recordType == 'Global'){

                $A.createComponent("c:DN_QuoteItemAccessoryModalforGlobal"
                , { selectedItems : selectedRows }
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

            }else{
                $A.createComponent("c:DN_QuoteItemAccessoryModal"
                , { selectedItems : selectedRows }
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
            }
        } 
    }

    // handleAccessoryBtn : function(component,event,helper) {
    //     var selectedRows = component.get('v.selectedRows');
    //     let isPass = helper.verifyBtnConditions(selectedRows);
    //     console.log('isPass : ', isPass);
        

    //     if(isPass) {
    //         $A.createComponent("c:DN_QuoteItemAccessoryModal"
    //         , { selectedItems : selectedRows }
    //         , function(content, status) {
    //             if (status === "SUCCESS") {
    //                 component.find('overlayLib').showCustomModal({
    //                     header: $A.get("$Label.c.DNS_S_SelectAccessory")
    //                     , body: content
    //                     , showCloseButton: true
    //                     , closeCallback: function() {
    //                         component.find('quoteLineItems').set("v.selectedRows", []);
    //                         component.set("v.selectedRows", []);
    //                         $A.get('e.force:refreshView').fire();
    //                     }
    //                 });
    //             }
    //         });
    //     } 
    // }


    , handleCreateOrder : function(component,event,helper) {
        var selectedRows = component.get('v.selectedRows');

        if (!selectedRows || selectedRows.length === 0) {
            helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_NoSelectItem"));
            // No items selected. Please select an item first.
            return;
        }

        // Apex Call
        // helper.apexCall(component, event, helper, 'validateCreateOrder', {
        //     selectedItems : selectedRows
        // })
        // .then($A.getCallback(function(result) {
        //     let r = result.r;
        //     console.log('validateCreateOrder r', r);
            
        //     if(r) {
        //         helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_Q_T_INPROGRESSSQ"));
        //         // An in-progress SQ exists.
        //         return;
        //     }
            
        // }))
        // .catch(function(error) {
        //     console.log('# validateCreateOrder error : ' + error.message);
        // });

        // console.log('handleCreateOrder - selectedRows', selectedRows);

        $A.createComponent("c:DN_Order_Create"
        , { selectedItems : selectedRows, recordId : component.get('v.recordId') }
        , function(content, status) {
            if (status === "SUCCESS") {
                component.find('overlayLib').showCustomModal({
                    // header: $A.get("$Label.c.DNS_S_RequestSpecialDC")
                    body: content
                    , showCloseButton: true
                    , closeCallback: function() {
                        component.find('quoteLineItems').set("v.selectedRows", []);
                        component.set("v.selectedRows", []);
                        $A.get('e.force:refreshView').fire();
                    }
                });
            }
        });
    }
})