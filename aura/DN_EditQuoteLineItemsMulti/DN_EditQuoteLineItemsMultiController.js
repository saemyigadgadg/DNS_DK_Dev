({
    editInit : function(component, event, helper) {
        // console.log('selectedData : ' + JSON.stringify(component.get('v.selectedRows')));
        // console.log('lineItemList : ' + component.get('v.lineItemList').length);
        // component.get('v.selectedRows');
        component.set('v.recordId', component.get('v.lineItemList')[0].Id);

        var recordId = component.get('v.recordId');
        var extraQtlineId = component.get('v.lineItemList').filter(item => item.Id !== recordId).map(item => item.Id);;
        component.set('v.extraQtlineId', extraQtlineId);
        // console.log('extraQtlineId : ' + JSON.stringify(extraQtlineId));
        // console.log('recordId : ' + recordId);
        var action = component.get("c.getRecordName");
        var dealerPriceTotal = 0;
        var TotalPrice = 0;
        var TotalNetPrice = 0;
        var NetAdjustmentPrice = 0;
        var WarrantyPrice = 0;
        var FinalPrice = 0;
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var returnVal = response.getReturnValue();
            // console.log('return : ' + returnVal);
            component.set('v.recordName', returnVal.RecordName);
            component.set('v.quoteId', returnVal.Quote);
            // console.log('result.isPortal : ' + returnVal.isPortal);
            component.set('v.isPortal', returnVal.isPortal);
            if(returnVal.RecordName == 'Korea'){
                component.set('v.recordBoolean', true);
            }else if(returnVal.RecordName == 'Global'){
                component.set('v.recordBoolean', false);
                const unitPriceField = component.find("unitPrice");
                const adjustmentPriceField = component.find("adjustmentPrice");
                const dealerPriceField = component.find("dealerPrice");
                const sqPriceField = component.find("sqPrice");
                const accPriceField = component.find("accPrice");
                // const warPriceField = component.find("warPrice");
                // console.log(' returnVal.ERPQuotationNo__c : ' + returnVal.ERPQuotationNo__c);
            try {
                
                TotalPrice = returnVal.UnitPrice + returnVal.SQ_Total__c + returnVal.Accessory_Total__c + returnVal.CV_Total__c;
                TotalNetPrice = TotalPrice + returnVal.DC_Price__c;
                NetAdjustmentPrice = TotalNetPrice + returnVal.Adjustment_Price__c;
                // WarrantyPrice = NetAdjustmentPrice * returnVal.WarrantyPercent * 0.01;
                WarrantyPrice = returnVal.Warranty_Price__c;
                FinalPrice = NetAdjustmentPrice + WarrantyPrice;
                // console.log('returnVal.DC_Price__c : ' + returnVal.DC_Price__c);

                // console.log('warrantypercent : ' + returnVal.WarrantyPercent);
                component.set('v.WarrantyPercent', returnVal.WarrantyPercent);
                component.set('v.TotalPrice', TotalPrice.toLocaleString());
                component.set('v.DCPercent', returnVal.DC__c);
                component.set('v.DCPrice', returnVal.DC_Price__c.toLocaleString());
                component.set('v.TotalNetPrice', TotalNetPrice.toLocaleString());
                component.set('v.AdjustmentPrice', returnVal.Adjustment_Price__c.toLocaleString());
                component.set('v.NetAdjustmentPrice', NetAdjustmentPrice.toLocaleString());
                component.set('v.WarrantyPrice', WarrantyPrice.toLocaleString());
                component.set('v.WarrantyLabel', returnVal.WarrantyLabel);
                component.set('v.FinalPrice', FinalPrice.toLocaleString());

                component.set('v.globalWarMap', returnVal.globalWarMap);

                // console.log('dealerPriceTotal : ' + dealerPriceTotal);
                // dealerPriceField.set("v.value", dealerPriceTotal);
                // component.set("v.originDealerPrice", dealerPriceTotal);
                // component.set("v.adjustPercent", ((returnVal.Adjustment_Price__c / (returnVal.UnitPrice + returnVal.SQ_Total__c + returnVal.Accessory_Total__c + returnVal.Warranty_Price__c))*100));
                // console.log('adpercent : ' + component.get('v.adjustPercent'));

            } catch (error) {
                console.log('error : ' + error);
            }
            }
            component.set("v.dataLoad", true);
            
        });
        $A.enqueueAction(action);
        // console.log('isportal : ' + component.get('v.isPortal'));
        component.set('v.title', $A.get("$Label.c.DNS_T_EditQuoteTitle"));
        component.set('v.cancel', $A.get("$Label.c.DNS_M_Cancel"));
        component.set('v.confirm', $A.get("$Label.c.DNS_M_Confirm"));


    },

    handleClickClose : function(component, event, helper) {
        helper.handleClose(component, event);
    },

    handleWarranty : function(component, event, helper){
        component.set('v.changeWarranty', true);
        // console.log('value : ' + JSON.stringify(event));
        // console.log('value : ' + event.getParam("value"));
        try {
            var value = event.getParam("value");
            var returnVal;
            var action = component.get("c.getPickLabel");
                action.setParams({
                    value : value
                });
                action.setCallback(this, function(response){
                    // console.log(response.getState());
                    returnVal = response.getReturnValue();
                    // console.log('returnVal : ' + returnVal);
                    component.set('v.WarrantyLabel', returnVal);

                });
                $A.enqueueAction(action);
            helper.priceCalculation(component, value, 'Warranty');
        } catch (error) {
            console.log('error : ' + error);
        }
        
    },

    handleDC : function(component, event, helper){
        component.set('v.changeDC', true);
        var value = event.getParam("value");
        // console.log('value : ' + event.getParam("value"));
        helper.priceCalculation(component, value, 'DC');

    },

    handleAdjustment : function(component, event, helper){
        component.set('v.changeAdjustment', true);
        var value = event.getParam("value");
        // console.log('value : ' + event.getParam("value"));
        helper.priceCalculation(component, value, 'Adjustment');
    },

    handleClickApply: function(component, event, helper){
        component.set("v.dataLoad", true);

        const fields = event.getParam('fields');
        // console.log(fields);
        var warranty = component.get('v.changeWarranty');
        var changeAdjustment = component.get('v.changeAdjustment');
        var changeDC = component.get('v.changeDC');
        const upRecord = {};
        // console.log('component.get : ' + component.get('v.quoteId'));
        var quoteId = component.get('v.quoteId');
        var recordName = component.get('v.recordName');
        var recordId = component.get('v.recordId');
        var action = component.get('c.updateRDD');
        if(recordName == 'Korea'){
            upRecord.Id = recordId;
            upRecord.ExpectedDelivDate__c = fields.ExpectedDelivDate__c;
            upRecord.UnitPrice = fields.UnitPrice;
            upRecord.Dealer_Price__c = fields.Dealer_Price__c;
            upRecord.CVComplete__c = fields.CVComplete__c;

            // if(warranty == true){
            //     upRecord.QuotePriceIF__c = false;
            // }
            
        }else if(recordName == 'Global'){
            if(component.get('v.isPortal') == 'true'){
                upRecord.Id = recordId;
                upRecord.RequestedDelivDate__c = fields.RequestedDelivDate__c;
                upRecord.Warranty__c = fields.Warranty__c;
                upRecord.CVComplete__c = fields.CVComplete__c;

                // upRecord.UnitPrice = fields.UnitPrice;
                // upRecord.Dealer_Price__c = fields.Dealer_Price__c;
            }else{
                upRecord.Id = recordId;
                upRecord.RequestedDelivDate__c = fields.RequestedDelivDate__c;
                upRecord.UnitPrice = fields.UnitPrice;
                upRecord.Adjustment_Price__c = fields.Adjustment_Price__c;
                // upRecord.Dealer_Price__c = fields.Dealer_Price__c;
                upRecord.Warranty__c = fields.Warranty__c;
                upRecord.Warranty_Percent__c = component.get('v.WarrantyPercent');
                upRecord.Warranty_Price__c = component.get('v.WarrantyPrice');

                upRecord.DC__c = component.get('v.DCPercent');
                upRecord.CVComplete__c = fields.CVComplete__c;

                upRecord.Adjustment_Price__c = component.get('v.AdjustmentPrice');
                upRecord.Dealer_Price__c = component.get('v.FinalPrice');

            }

            // if(warranty == true || changeDC == true || changeAdjustment){
            //     upRecord.QuotePriceIF__c = false;
            // }
            
        }
        action.setParams({
            recordId : recordId,
            upRecord : upRecord,
            recordName : recordName,
            extraQtlineId : component.get('v.extraQtlineId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if(returnVal === "SUCCESS"){
                var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type" : "Success",
                            "title": $A.get("$Label.c.DNS_M_Success"),
                            "message": $A.get("$Label.c.DNS_M_Success")
    
                        });
                        resultsToast.fire();
                        // $A.get('e.force:refreshView').fire();
                    var modalEvent = component.getEvent('modalEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_EditQuoteLineItems',
                        "actionName"    : 'Close',
                        "message"       : ['updateRDD', quoteId]
                    });
                    modalEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.DNS_M_Error"),
                        "message": $A.get("$Label.c.DNS_M_Error"),
                        "type": "error"
                    });
                    toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        component.set('v.changeWarranty', false);
        component.set("v.dataLoad", false);
        // helper.handleClose(component, event);
    },

    handleFieldChange: function(component, event, helper){
        // UnitPrice와 Adjustment_Price__c 값 가져오기
        const unitPriceField = component.find("unitPrice");
        const adjustmentPriceField = component.find("adjustmentPrice");
        const dealerPriceField = component.find("dealerPrice");
        const sqPriceField = component.find("sqPrice");
        const accPriceField = component.find("accPrice");
        const warPriceField = component.find("warPrice");
        const adjustPercentField = component.find("adjustpercent");

        const unitPrice = parseFloat(unitPriceField.get("v.value")) || 0;
        // const adjustmentPrice = parseFloat(adjustmentPriceField.get("v.value")) || 0;
        const dealerPrice = parseFloat(dealerPriceField.get("v.value")) || 0;
        const sqPrice = parseFloat(sqPriceField.get("v.value")) || 0;
        const accPrice = parseFloat(accPriceField.get("v.value")) || 0;
        const warPrice = parseFloat(warPriceField.get("v.value")) || 0;
        // Dealer_Price__c 값 계산
        // const dealerPrice = unitPrice + adjustmentPrice + sqPrice + accPrice + warPrice;
        const adjustmentPrice = dealerPrice - (unitPrice + sqPrice + accPrice + warPrice);
        const adjustPercentPrice = (adjustmentPrice / (unitPrice + sqPrice + accPrice + warPrice))*100;
        // Dealer_Price__c 필드에 값 설정
        // dealerPriceField.set("v.value", dealerPrice);
        adjustmentPriceField.set("v.value", adjustmentPrice);
        adjustPercentField.set("v.value", adjustPercentPrice);
        // component.set("v.adjustPercent", (adjustmentPrice / (unitPrice + sqPrice + accPrice + warPrice))*100);
       
        
    }
})