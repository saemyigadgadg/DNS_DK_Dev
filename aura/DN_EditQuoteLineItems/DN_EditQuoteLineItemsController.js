({
    editInit: function(component, event, helper) {
        component.set('v.recordId', component.get('v.selectedRows')[0].Id);
        var recordId = component.get('v.recordId');
        var action = component.get("c.getRecordName");
        var dealerPriceTotal = 0;
        var TotalPrice = 0;
        var TotalNetPrice = 0;
        var NetAdjustmentPrice = 0;
        var WarrantyPrice = 0;
        var FinalPrice = 0;
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var returnVal = response.getReturnValue();
            component.set('v.recordName', returnVal.RecordName);
            component.set('v.quoteId', returnVal.Quote);
            component.set('v.isPortal', returnVal.isPortal);
            if (returnVal.RecordName == 'Korea') {
                component.set('v.recordBoolean', true);
            } else if (returnVal.RecordName == 'Global') {
                component.set('v.recordBoolean', false);
                const unitPriceField = component.find("unitPrice");
                const adjustmentPriceField = component.find("adjustmentPrice");
                const dealerPriceField = component.find("dealerPrice");
                const sqPriceField = component.find("sqPrice");
                const accPriceField = component.find("accPrice");
                try {
                    TotalPrice = returnVal.UnitPrice + returnVal.SQ_Total__c + returnVal.Accessory_Total__c + returnVal.CV_Total__c;
                    TotalNetPrice = TotalPrice + returnVal.DC_Price__c;
                    NetAdjustmentPrice = TotalNetPrice + returnVal.Adjustment_Price__c;
                    WarrantyPrice = returnVal.ZPR1__c * returnVal.WarrantyPercent * 0.01;
                    FinalPrice = NetAdjustmentPrice + WarrantyPrice;
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
                    component.set('v.ZPR1', returnVal.ZPR1__c);
                    component.set('v.globalWarMap', returnVal.globalWarMap);
                } catch (error) {
                    console.log('error : ' + error);
                }
            } else {
                component.set('v.isDNSA', true);
                const unitPriceField = component.find("unitPricednsa");
                const adjustmentPriceField = component.find("adjustmentPricednsa");
                const dealerPriceField = component.find("dealerPricednsa");
                const sqPriceField = component.find("sqPricednsa");
                const accPriceField = component.find("accPricednsa");
                try {
                    // 입력 데이터 디버깅
                    console.log('DNSA recordId:', recordId);
                    console.log('DNSA UnitPrice:', returnVal.UnitPrice);
                    console.log('DNSA Accessory_Total__c:', returnVal.Accessory_Total__c);
                    console.log('DNSA Adjustment_Price__c:', returnVal.Adjustment_Price__c);
                    console.log('DNSA ZPR1__c:', returnVal.ZPR1__c);
                    console.log('DNSA WarrantyPercent:', returnVal.WarrantyPercent);
    
                    // 숫자로 변환, 쉼표 제거 및 null 처리
                    let unitPrice = parseFloat(String(returnVal.UnitPrice).replace(/,/g, '')) || 0;
                    let accessoryTotal = parseFloat(String(returnVal.Accessory_Total__c).replace(/,/g, '')) || 0;
                    let adjustmentPrice = parseFloat(String(returnVal.Adjustment_Price__c).replace(/,/g, '')) || 0;
                    let zpr1 = parseFloat(String(returnVal.ZPR1__c).replace(/,/g, '')) || 0;
                    let warrantyPercent = parseFloat(returnVal.WarrantyPercent) || 0;
    
                    console.log('DNSA Parsed UnitPrice:', unitPrice);
                    console.log('DNSA Parsed Accessory_Total__c:', accessoryTotal);
                    console.log('DNSA Parsed Adjustment_Price__c:', adjustmentPrice);
    
                    TotalPrice = unitPrice + accessoryTotal;
                    NetAdjustmentPrice = TotalPrice + adjustmentPrice;
                    WarrantyPrice = zpr1 * warrantyPercent * 0.01;
                    FinalPrice = TotalPrice + adjustmentPrice;
    
                    console.log('DNSA TotalPrice (calculated):', TotalPrice);
                    console.log('DNSA NetAdjustmentPrice (calculated):', NetAdjustmentPrice);
                    console.log('DNSA WarrantyPrice (calculated):', WarrantyPrice);
                    console.log('DNSA FinalPrice (calculated):', FinalPrice);
    
                    // 소숫점 2자리 및 천단위 쉼표 포맷팅
                    component.set('v.ZPR1', returnVal.ZPR1__c);
                    component.set('v.WarrantyPercent', warrantyPercent);
                    component.set('v.TotalPrice', TotalPrice.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
                    component.set('v.AdjustmentPrice', adjustmentPrice.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
                    component.set('v.NetAdjustmentPrice', NetAdjustmentPrice.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
                    component.set('v.WarrantyPrice', WarrantyPrice.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
                    component.set('v.WarrantyLabel', returnVal.WarrantyLabel);
                    component.set('v.FinalPrice', FinalPrice.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }));
                    component.set('v.dnsaWarMap', returnVal.dnsaWarMap);
    
                    component.set("v.originDealerPrice", WarrantyPrice);
                } catch (error) {
                    console.log('DNSA error : ', error);
                }
            }
            component.set("v.dataLoad", true);
        });
        $A.enqueueAction(action);
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

    handleWarrantydnsa : function(component, event, helper){
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
            helper.priceCalculationdnsa(component, value, 'Warranty');
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

    handleAdjustmentdnsa : function(component, event, helper){
        component.set('v.changeAdjustment', true);
        var value = event.getParam("value");
        // console.log('value : ' + event.getParam("value"));
        helper.priceCalculationdnsa(component, value, 'Adjustment');
    },

    handleClickApply: function(component, event, helper){
        component.set("v.dataLoad", true);

        const fields = event.getParam('fields');
        // console.log(fields);
        var warranty = component.get('v.changeWarranty');
        var changeAdjustment = component.get('v.changeAdjustment');
        var changeDC = component.get('v.changeDC');
        var quoteId = component.get('v.quoteId');

        const upRecord = {};

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
            
        }else if(recordName == 'DNSA Factory' || recordName == 'DNSA Commodity'){
            // console.log('component.get : ' + component.get('v.WarrantyPrice'));
            upRecord.Id = recordId;

            upRecord.Warranty__c = fields.Warranty__c;
            const accPriceField = component.find("upoptiondnsa");

            upRecord.US_Option_Total__c = fields.US_Option_Total__c;
            // console.log('upRecord.US_Option_Total__c : ' + accPriceField);
            upRecord.Warranty_Percent__c = component.get('v.WarrantyPercent');
            upRecord.Warranty_Price__c = component.get('v.WarrantyPrice');

            upRecord.Dealer_Price__c = component.get('v.FinalPrice');

            upRecord.Requested_Ship_Date__c = fields.Requested_Ship_Date__c;

            upRecord.UnitPrice = fields.UnitPrice;
            upRecord.Adjustment_Price__c = fields.Adjustment_Price__c;
            if(fields.Adjustment_Price__c == 0 || fields.Adjustment_Price__c == '' || fields.Adjustment_Price__c == null){
                upRecord.Adjustment_Price__c = 0;
                upRecord.ZSSS__c = 0;
                upRecord.ZSSD__c = 0;
            }else if(fields.Adjustment_Price__c < 0){
                upRecord.ZSSD__c = fields.Adjustment_Price__c;
                upRecord.ZSSS__c = 0;
            }else{
                upRecord.ZSSS__c = fields.Adjustment_Price__c;
                upRecord.ZSSD__c = 0;
            }
            upRecord.AdjustmentPercent__c = fields.AdjustmentPercent__c;
            upRecord.CustomerPrice__c = fields.CustomerPrice__c;
            if(warranty == true || (component.get("v.originDealerPrice") != fields.Adjustment_Price__c)){
                upRecord.QuotePriceIF__c = false;
            }
        }
        // console.log('check : ' + (component.get("v.originDealerPrice") != fields.Dealer_Price__c));
        
        // console.log(JSON.stringify(upRecord));
        action.setParams({
            recordId : recordId,
            upRecord : upRecord,
            recordName : recordName,
            extraQtlineId : []
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
                        $A.get('e.force:refreshView').fire();

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
       
        
    },

    handleDNSAChange : function(component, event, helper){
        const unitPriceField = component.find("unitPricednsa");
        const adjustmentPriceField = component.find("adjustmentPricednsa");
        const dealerPriceField = component.find("dealerPricednsa");
        const sqPriceField = component.find("sqPricednsa");
        const accPriceField = component.find("accPricednsa");
        const adjustPercentField = component.find("adjustpercentdnsa");

        const unitPrice = parseFloat(unitPriceField.get("v.value")) || 0;
        const sqPrice = parseFloat(sqPriceField.get("v.value")) || 0;
        const accPrice = parseFloat(accPriceField.get("v.value")) || 0;
        const dealerPrice = parseFloat(dealerPriceField.get("v.value")) || 0;

        const adjustmentPrice = dealerPrice - (unitPrice + sqPrice + accPrice);
        const adjustPercentPrice = (adjustmentPrice / (unitPrice + sqPrice + accPrice))*100;

        adjustmentPriceField.set("v.value", adjustmentPrice);
        adjustPercentField.set("v.value", adjustPercentPrice);

    }
})