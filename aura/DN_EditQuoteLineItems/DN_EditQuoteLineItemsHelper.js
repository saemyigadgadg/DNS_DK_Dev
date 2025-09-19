({
    handleClose : function(component, event) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_EditQuoteLineItems',
            "actionName"    : 'CloseQuoteItemEdit',
            "message"       : 'CloseQuoteItemEdit'
        });
        modalEvent.fire();
    },
    priceCalculation : function(component, value, field){
        // console.log('진입?');
        var Warranty; 
        var TotalPrice = component.get('v.TotalPrice');
        var DCPrice = component.get('v.DCPrice');
        var TotalNetPrice = component.get('v.TotalNetPrice');
        var AdjustmentPrice = component.get('v.AdjustmentPrice');
        var NetAdjustmentPrice = component.get('v.NetAdjustmentPrice');
        var WarrantyPrice = component.get('v.WarrantyPrice');
        var WarrantyPercent = component.get('v.WarrantyPercent');
        var FinalPrice = component.get('v.FinalPrice');
        try{
            if(field == 'DC'){
                // console.log('DC : ' + value);

                if(value == ''){
                    value = 0;
                }

                if (value && typeof value === 'string') {
                    value = value.replace(/^0+/, '');  // 정규식을 사용하여 앞의 0을 제거
                }

                // console.log('dc value : ' + value);
                DCPrice = parseFloat(TotalPrice.replace(/,/g, '')) * parseFloat(value) * 0.01;
                DCPrice = -1 * parseFloat(DCPrice.toFixed(2));
                component.set('v.DCPercent', value);
                component.set('v.DCPrice', DCPrice.toLocaleString());

                TotalNetPrice = parseFloat(TotalPrice.replace(/,/g, '')) + DCPrice;
                TotalNetPrice = parseFloat(TotalNetPrice.toFixed(2));
                component.set('v.TotalNetPrice', TotalNetPrice.toLocaleString());

                NetAdjustmentPrice = TotalNetPrice + parseFloat(AdjustmentPrice.replace(/,/g, ''));
                NetAdjustmentPrice = parseFloat(NetAdjustmentPrice.toFixed(2));
                component.set('v.NetAdjustmentPrice', NetAdjustmentPrice.toLocaleString());

                WarrantyPrice = NetAdjustmentPrice * parseFloat(WarrantyPercent) * 0.01;
                WarrantyPrice = parseFloat(WarrantyPrice.toFixed(2));
                WarrantyPrice = Math.round(WarrantyPrice / 10) * 10;
                component.set('v.WarrantyPrice', WarrantyPrice.toLocaleString());

                FinalPrice = NetAdjustmentPrice + WarrantyPrice;
                FinalPrice = parseFloat(FinalPrice.toFixed(2)); 
                component.set('v.FinalPrice', FinalPrice.toLocaleString());
                
            }else if(field == 'Warranty'){
                // console.log('Warranty : ' + value);

                Warranty = value;
                
                var globalWarMap = component.get('v.globalWarMap');
                var warrantypercentMap = globalWarMap[Warranty].Percent__c;
                component.set('v.WarrantyPercent', warrantypercentMap);
                // console.log('warrantypercent : ' + warrantypercentMap);
                WarrantyPrice = parseFloat(NetAdjustmentPrice.replace(/,/g, '')) * parseFloat(warrantypercentMap) * 0.01;
                WarrantyPrice = parseFloat(WarrantyPrice.toFixed(2)); 
                WarrantyPrice = Math.round(WarrantyPrice / 10) * 10;
                component.set('v.WarrantyPrice', WarrantyPrice.toLocaleString());

                FinalPrice = parseFloat(NetAdjustmentPrice.replace(/,/g, '')) + WarrantyPrice;
                FinalPrice = parseFloat(FinalPrice.toFixed(2)); 

                component.set('v.FinalPrice', FinalPrice.toLocaleString());

            }else if(field == 'Adjustment'){
                // console.log('adjustment : ' + value);
                if(value == ''){
                    value = 0;
                }
                component.set('v.AdjustmentPrice', value.toLocaleString());
                NetAdjustmentPrice = parseFloat(TotalNetPrice.replace(/,/g, '')) + parseFloat(value);
                NetAdjustmentPrice = parseFloat(NetAdjustmentPrice.toFixed(2));
                component.set('v.NetAdjustmentPrice', NetAdjustmentPrice.toLocaleString());

                WarrantyPrice = NetAdjustmentPrice * parseFloat(WarrantyPercent) * 0.01;
                WarrantyPrice = parseFloat(WarrantyPrice.toFixed(2));
                WarrantyPrice = Math.round(WarrantyPrice / 10) * 10;
                component.set('v.WarrantyPrice', WarrantyPrice.toLocaleString());

                FinalPrice = NetAdjustmentPrice + WarrantyPrice;
                FinalPrice = parseFloat(FinalPrice.toFixed(2)); 
                component.set('v.FinalPrice', FinalPrice.toLocaleString());
            }
        }catch (error){
            console.log('error : ' + error);
        }
        
    },

    priceCalculationdnsa : function(component, value, field){
        // console.log('진입?');
        const unitPriceField = component.find("unitPricednsa");
        const unitPrice = parseFloat(unitPriceField.get("v.value")) || 0;

        var Warranty; 
        var ZPR1 = component.get('v.ZPR1');
        if(ZPR1 == null || ZPR1 == undefined){
            ZPR1 = 0;
        }
        var TotalPrice = component.get('v.TotalPrice');
        var AdjustmentPrice = component.get('v.AdjustmentPrice');
        var NetAdjustmentPrice = component.get('v.NetAdjustmentPrice');
        var WarrantyPrice = component.get('v.WarrantyPrice');
        var WarrantyPercent = component.get('v.WarrantyPercent');
        var FinalPrice = component.get('v.FinalPrice');
        try{
            if(field == 'Warranty'){
                // console.log('Warranty : ' + value);

                Warranty = value;
                
                var dnsaWarMap = component.get('v.dnsaWarMap');
                var warrantypercentMap = dnsaWarMap[Warranty].Percent__c;
                component.set('v.WarrantyPercent', warrantypercentMap);
                // console.log('warrantypercentMap : ' + warrantypercentMap);
                // WarrantyPrice = parseFloat(NetAdjustmentPrice.replace(/,/g, '')) * parseFloat(warrantypercentMap) * 0.01;
                WarrantyPrice = parseFloat(ZPR1) * parseFloat(warrantypercentMap) * 0.01;
                WarrantyPrice = parseFloat(WarrantyPrice.toFixed(2)); 
                WarrantyPrice = Math.round(WarrantyPrice / 10) * 10;
                component.set('v.WarrantyPrice', WarrantyPrice.toLocaleString());

                // FinalPrice = parseFloat(NetAdjustmentPrice.replace(/,/g, '')) + WarrantyPrice;
                FinalPrice = parseFloat(NetAdjustmentPrice.replace(/,/g, ''));
                FinalPrice = parseFloat(FinalPrice.toFixed(2)); 

                component.set('v.FinalPrice', FinalPrice.toLocaleString());

            }else if(field == 'Adjustment'){
                // console.log('adjustment : ' + value);
                if(value == ''){
                    value = 0;
                }
                component.set('v.AdjustmentPrice', value.toLocaleString());
                NetAdjustmentPrice = parseFloat(TotalPrice.replace(/,/g, '')) + parseFloat(value);
                // NetAdjustmentPrice = parseFloat(NetAdjustmentPrice.toFixed(2));
                NetAdjustmentPrice = parseFloat(NetAdjustmentPrice);
                component.set('v.NetAdjustmentPrice', NetAdjustmentPrice.toLocaleString());

                WarrantyPrice = parseFloat(ZPR1) * parseFloat(WarrantyPercent) * 0.01;
                // WarrantyPrice = parseFloat(WarrantyPrice.toFixed(2));
                WarrantyPrice = parseFloat(WarrantyPrice);
                // WarrantyPrice = Math.round(WarrantyPrice / 10) * 10;
                component.set('v.WarrantyPrice', WarrantyPrice.toLocaleString());

                // FinalPrice = NetAdjustmentPrice + WarrantyPrice;
                FinalPrice = NetAdjustmentPrice;
                // FinalPrice = parseFloat(FinalPrice.toFixed(2)); 
                FinalPrice = parseFloat(FinalPrice); 
                component.set('v.FinalPrice', FinalPrice.toLocaleString());
            }
        }catch (error){
            console.log('error : ' + error);
        }
        
    }
})