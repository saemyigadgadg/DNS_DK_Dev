/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 05-07-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-18   yuhyun.park@sbtglobal.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
        var self 		= this;
        var recordId 	= component.get('v.recordId');
        var recentlyVersion = true;
        var columns = [];
        component.set('v.quotePrice',           $A.get("$Label.c.DNS_M_QuotePriceBTN"));
        // 0318 이주현 수정 
        // component.set('v.selectAccessories',    'Select Accessory(US Option)');
        component.set('v.selectAccessories',    'Select US Option');
        component.set('v.selectOptions',        $A.get("$Label.c.DNS_M_QuoteOptions"));
        component.set('v.sqReview',             $A.get("$Label.c.DNS_M_QuoteSQReview"));
        component.set('v.delete',               $A.get("$Label.c.DNS_M_Delete"));
        component.set('v.cancel',               $A.get("$Label.c.DNS_M_Cancel"));
        component.set('v.reason',               $A.get("$Label.c.DNS_M_RFQRejectReason"));
        component.set('v.reasonPlace',          $A.get("$Label.c.DNS_M_RFQRejectReasonPlace"));
        component.set('v.title',                $A.get("$Label.c.DNS_M_QuoteDeleteTitle"));
        component.set('v.subtitle',             $A.get("$Label.c.DNS_M_QuoteDeleteSubtitle"));
        // console.log('흠 : ' + recordId);

		self.apex(component,"getQuoteLineItemList",{recordId :component.get('v.recordId')})
        .then(function(result){
            console.log('result A' , result);
            // console.log('quoteLineItemList : ' + JSON.stringify(result.quoteLineItemWrapperList));
            component.set('v.recordTypeName', result.recordType);
            component.set('v.isFirst', result.isFirst);

            result.quoteLineItemWrapperList.forEach(function(item) {
                item.CustomListPrice = self.formatPrice(item.CustomListPrice);
                item.AdjustmentPrice = self.formatPrice(item.AdjustmentPrice);
                item.CustomDealerPrice = self.formatPrice(item.CustomDealerPrice);
                item.CustomerPrice = self.formatPrice(item.CustomerPrice);
                item.DNSATotalPrice = self.formatPrice(item.DNSATotalPrice);
            });
            
            component.set('v.quoteLineItemList', result.quoteLineItemWrapperList);
            if(result.recordType == 'DNSA Commodity' || result.recordType == 'DNSA Factory') {
                component.set('v.selectedRows', result.quoteLineItemWrapperList);
            }
            var size = result.quoteLineItemSize;
            var review = result.Review;
            if(size > 0){
                component.set('v.size', ' (' + size + ')');
                recentlyVersion = result.quoteLineItemWrapperList[0].recentlyVersion
                component.set('v.recentlyVersion', recentlyVersion);
                
                var actions = [
                    { label: 'Edit', name: 'Edit' },
                    { label: 'Delete', name: 'delete' }
                ];
                if(result.recordType == 'DNSA Commodity') {
                    actions = [
                        { label: 'Edit', name: 'Edit' }
                    ];
                    columns = [
                        {
                            label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true,
                            typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                        },
                        { label: 'DNSA Model Name',         fieldName: 'ModelName',         type: 'text', sortable: true },
                        // { label: 'RDD',                     fieldName: 'RDD',               type: 'text', sortable: true },
                        { label: 'List Price',              fieldName: 'CustomListPrice',   type: 'text', sortable: true },
                        { label: 'Adjustment Price',        fieldName: 'AdjustmentPrice',   type: 'text', sortable: true },
                        // { label: 'Sales Price',             fieldName: 'CustomDealerPrice', type: 'text', sortable: true },
                        { label: 'Dealer Net Price',             fieldName: 'CustomDealerPrice', type: 'text', sortable: true },
                        // 0327 이주현 주석
                        // { label: 'Accessory Total',         fieldName: 'AccTotal',          type: 'text', sortable: true },
                        // { label: 'Accessory Complete',      fieldName: 'AccessoryComplete', type:'boolean'},
                        { label: 'US Option Total',         fieldName: 'AccTotal',          type: 'text', sortable: true },
                        { label: 'US Option Complete',      fieldName: 'AccessoryComplete', type:'boolean'},
                        
                        { label: 'Is Order Created',        fieldName: 'IsOrderCreated', type:'boolean'}
                        // { 
                        //     type: "action",
                        //     typeAttributes: { rowActions: actions }
                        // }
                    ];
                }
                if(result.recordType == 'DNSA Factory' && result.isPortal == true) {
                    if(!result.isFinal){//Final Quote인경우 Edit불가
                        actions = [
                            { label: 'Edit', name: 'Edit' }
                        ];
                    }else{
                        actions = [
                        ];
                    }
                    
                    if(!result.isFinal){
                        columns = [
                            {
                                label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true
                                ,cellAttributes: {class: { fieldName: 'highLight' }},
                                typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                            },
                            { label: 'DNSA Model Name',     fieldName: 'ModelName',         type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // 0313 이주현 주석 { label: 'List Price',       fieldName: 'SalesPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'RSD',                 fieldName: 'RequestedShipDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'Delaer Net Price',               type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'Customer Price',       fieldName: 'CustomerPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // 0313 이주현 주석 { label: 'Accessory Total',     fieldName: 'AccTotal',          type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'Is Order Created',    fieldName: 'IsOrderCreated',    type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}}
                        ];
                    }else{
                        columns = [
                            {
                                label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true
                                ,cellAttributes: {class: { fieldName: 'highLight' }},
                                typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                            },
                            { label: 'DNSA Model Name',     fieldName: 'ModelName',         type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // 0313 이주현 주석 { label: 'List Price',       fieldName: 'SalesPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'RSD',                 fieldName: 'RequestedShipDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'Delaer Net Price',       fieldName: 'DNSATotalPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'Customer Price',       fieldName: 'CustomerPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // 0313 이주현 주석 { label: 'Accessory Total',     fieldName: 'AccTotal',          type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'Is Order Created',    fieldName: 'IsOrderCreated',    type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}}
                        ];
                    }
                }else if(result.recordType == 'DNSA Factory' && result.isPortal == false){
                    columns = [
                        {
                            label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true
                            ,cellAttributes: {class: { fieldName: 'highLight' }},
                            typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                        },
                        { label: 'DNSA Model Name',     fieldName: 'ModelName',         type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        // 0313 이주현 주석 { label: 'List Price',       fieldName: 'SalesPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        { label: 'RSD',                 fieldName: 'RequestedShipDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        { label: 'Dealer Net Price',       fieldName: 'DNSATotalPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        { label: 'Customer Price',       fieldName: 'CustomerPrice',        type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        // 0313 이주현 주석 { label: 'Accessory Total',     fieldName: 'AccTotal',          type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        // { label: 'Accessory Complete',  fieldName: 'AccessoryComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                        // { label: 'SQ Total',            fieldName: 'SQTotal',           type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        { label: 'CV Complete',         fieldName: 'CVComplete',        type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                        { label: 'ERP Quotation NO',    fieldName: 'ERPQutaionNO',      type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                        { label: 'Is Order Created',    fieldName: 'IsOrderCreated',    type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                        { 
                            type: "action",
                            typeAttributes: { rowActions: actions }
                            ,cellAttributes: {class: { fieldName: 'highLight' }}
                        }
                    ];
                }
                
                component.set('v.columns', columns); 
            }           
            // console.log('role : ' + result.role);
            component.set('v.role', result.role);
            
        }).then(function(result){
            component.set('v.isLoading');
        });
        component.set('v.isLoading', false);
        
	},

    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    // console.log('ERROR quotelineitems', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));  
    },

    sortData: function (data, fieldName, sortDirection) {
        let sortedData = data.slice().sort((a, b) => {
            let fieldA = a[fieldName];
            let fieldB = b[fieldName];
            
            // URL 필드를 정렬할 때는 `ProductName`을 기준으로 설정
            if (fieldName === 'ProductURL') {
                fieldA = a['ProductName'];
                fieldB = b['ProductName'];
            }

            let result = 0;
            if (fieldA < fieldB) {
                result = -1;
            } else if (fieldA > fieldB) {
                result = 1;
            }

            return sortDirection === 'asc' ? result : -result;
        });

        return sortedData;
    },

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


    , verifyBtnConditions : function(selectedRows) {
        const self = this;
        
        
        if (!selectedRows || selectedRows.length === 0) {
            // self.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_NoSelectItem"));
            self.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), 'Please Select the product first.');
            // No items selected. Please select an item first.
            return false;
        } 
        
        const baseProdId = selectedRows[0].ProductId;
        const otherIds   = selectedRows.filter(row => row.ProductId != baseProdId);
        if(otherIds.length > 0) {
            self.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_SelectedDiffSpecs"));
            // Items with different main sepcs have been selected together. Accessories can only be added for products with the same main spec.
            return false;
        } 

        return true;
    },

    formatPrice: function(value) {
        if (!value) return '';
    
        // 쉼표 제거 후 숫자로 변환
        const cleaned = String(value).replace(/,/g, '').trim();
        const numberValue = parseFloat(cleaned);
    
        if (isNaN(numberValue)) return '';
    
        // 쉼표 포함한 통화 스타일로 변환
        return numberValue.toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    } 
})