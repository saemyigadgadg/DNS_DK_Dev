/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 04-25-2025
 * @last modified by  : Hanyeong Choi
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-18   yuhyun.park@sbtglobal.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
        var self 		= this,
            recordId 	= component.get('v.recordId');            
        var recentlyVersion = true;
        var columns = [];
        component.set('v.quotePrice', $A.get("$Label.c.DNS_M_QuotePriceBTN"));
        component.set('v.selectAccessories', $A.get("$Label.c.DNS_M_QuoteAccessory"));
        component.set('v.selectOptions', $A.get("$Label.c.DNS_M_QuoteOptions"));
        component.set('v.sqReview', $A.get("$Label.c.DNS_M_QuoteSQReview"));
        component.set('v.delete', $A.get("$Label.c.DNS_M_Delete"));
        component.set('v.cancel', $A.get("$Label.c.DNS_M_Cancel"));
        component.set('v.reason', $A.get("$Label.c.DNS_M_RFQRejectReason"));
        component.set('v.reasonPlace', $A.get("$Label.c.DNS_M_RFQRejectReasonPlace"));
        component.set('v.title', $A.get("$Label.c.DNS_M_QuoteDeleteTitle"));
        component.set('v.subtitle', $A.get("$Label.c.DNS_M_QuoteDeleteSubtitle"));
        // console.log('여ㅑ긴가아아 : ' + recordId);
		self.apex(component,"getQuoteLineItemList",{recordId :component.get('v.recordId')})
        .then(function(result){
            console.log('result' , JSON.stringify(result));
            // console.log('recordType : ' + result.recordType);
            component.set('v.isFinal', result.isFinal);
            var size = result.quoteLineItemSize;
            var review = result.Review;
            if(size > 0){
                // var row = result.quoteLineItemWrapperList;
                // for ( var i = 0; i < row.length; i++ ) {
                //     if(row.highLight == 'highLight'){
                //          row[i].highLight='highLight'
                //     }
                // }
                if(result.isPortal && result.recordType == 'Global' && result.role == 'Worker'){
                // if(result.isPortal && result.recordType == 'Korea'){
                    component.set('v.portalGlobal', true);
                }
                component.set('v.size', ' (' + size + ')');
                recentlyVersion = result.quoteLineItemWrapperList[0].recentlyVersion
                component.set('v.recentlyVersion', recentlyVersion);
                // console.log('orderCnt : ' + result.quoteLineItemWrapperList[0].orderCnt);
                if(result.quoteLineItemWrapperList[0].orderCnt != 0){
                    component.set('v.orderCnt', false);
                }
                // console.log('version : ' + recentlyVersion);
                // console.log('prdurl : ' + result.quoteLineItemWrapperList[0].ProductURL);
                var actions;
                if(result.isFinal){//Final Quote인경우 Edit불가
                    actions = [
                        { label: 'Delete', name: 'delete' }
                    ];
                }else{
                    actions = [
                        { label: 'Edit', name: 'Edit' },
                        { label: 'Delete', name: 'delete' }
                    ];
                }
                
                if(recentlyVersion == true){
                    if(result.recordType == 'Korea'){
                        columns = [
                            {
                                label: $A.get("$Label.c.DN_M_Product"), fieldName: 'ProductURL', type: 'url', sortable: true
                                ,cellAttributes: {class: { fieldName: 'highLight' }},
                                typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                            },
                            { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_ProductPrice"), fieldName: 'SalesPrice', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_CVTotal"), fieldName: 'CVTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_AccessoryTotal"), fieldName: 'AccTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_SQTotal"), fieldName: 'SQTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_CVComplete"), fieldName: 'CVComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_AccessoryComplete"), fieldName: 'AccessoryComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_IsOrderCreated"), fieldName: 'IsOrderCreated', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}}
                            // { 
                            //     type: "action"
                            //     ,cellAttributes: {class: { fieldName: 'highLight' }},
                            //     typeAttributes: { rowActions: actions }
                            // }
                        ];
                    }else if (result.recordType == 'Global'){

                        component.set('v.recordType', result.recordType);

                        if(review){
                            component.set('v.review', ' / ' + $A.get("$Label.c.DNS_T_QuoteReviewSubtitle") + ' : ' + review);
                        }else{
                            component.set('v.review', '');
                        }

                        if(result.isPortal){
                            component.set('v.role', result.role);
                            if(result.role == 'Worker'){ //Worker는 가격정보 아무것도 안보이게
                                columns = [
                                    // {
                                    //     label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true,
                                    //     typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                                    // },
                                    {
                                        label: $A.get("$Label.c.DN_M_Product"), fieldName: 'ProductName', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}
                                    },
                                    { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_Warranty"), fieldName: 'Warranty', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_CVComplete"), fieldName: 'CVComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_AccessoryComplete"), fieldName: 'AccessoryComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_IsOrderCreated"), fieldName: 'IsOrderCreated', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}}
                                    // { 
                                    //     type: "action"
                                    //     ,cellAttributes: {class: { fieldName: 'highLight' }},
                                    //     typeAttributes: { rowActions: actions }
                                    // }
                                ];
                            }else if(result.role == 'Manager'){
                                columns = [
                                    {
                                        label: $A.get("$Label.c.DN_M_Product"), fieldName: 'ProductURL', type: 'url', sortable: true
                                        ,cellAttributes: {class: { fieldName: 'highLight' }},
                                        typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                                    },
                                    { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_Warranty"), fieldName: 'Warranty', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_ProductPrice"), fieldName: 'SalesPrice', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_CVTotal"), fieldName: 'CVTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_AccessoryTotal"), fieldName: 'AccTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_SQTotal"), fieldName: 'SQTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: 'DC', fieldName: 'DC', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_AdjustmentPrice"), fieldName: 'AdjustmentPrice', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},

                                    { label: $A.get("$Label.c.DN_M_WarrantyPrice"), fieldName: 'WarrantyPrice', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_SalesPrice"), fieldName: 'DealerPrice', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_CVComplete"), fieldName: 'CVComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_AccessoryComplete"), fieldName: 'AccessoryComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                                    { label: $A.get("$Label.c.DN_M_IsOrderCreated"), fieldName: 'IsOrderCreated', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}}
                                    // { 
                                    //     type: "action",
                                    //     typeAttributes: { rowActions: actions }
                                    // }
                                ];
                            }
                        }else{
                            // console.log('여긴오니?');
                            columns = [
                                {
                                    label: $A.get("$Label.c.DN_M_Product"), fieldName: 'ProductURL', type: 'url', sortable: true,
                                    cellAttributes: {class: { fieldName: 'highLight' }},
                                    typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank'
                                    
                                     }
                                },
                                { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true,
                                    cellAttributes: {class: { fieldName: 'highLight' }}
                                 },
                                { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_Warranty"), fieldName: 'Warranty', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_ProductPrice"), fieldName: 'SalesPrice', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_CVTotal"), fieldName: 'CVTotal', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_AccessoryTotal"), fieldName: 'AccTotal', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_SQTotal"), fieldName: 'SQTotal', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},

                                { label: 'DC', fieldName: 'DC', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                
                                { label: $A.get("$Label.c.DN_M_AdjustmentPrice"), fieldName: 'AdjustmentPrice', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                
                                { label: $A.get("$Label.c.DN_M_WarrantyPrice"), fieldName: 'WarrantyPrice', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_SalesPrice"), fieldName: 'DealerPrice', type: 'text', sortable: true ,
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_CVComplete"), fieldName: 'CVComplete', type:'boolean',
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_AccessoryComplete"), fieldName: 'AccessoryComplete', type:'boolean',
                                    cellAttributes: {class: { fieldName: 'highLight' }}},
                                { label: $A.get("$Label.c.DN_M_IsOrderCreated"), fieldName: 'IsOrderCreated', type:'boolean',
                                    cellAttributes: {class: { fieldName: 'highLight' }}}
                                // { 
                                //     type: "action",
                                //     typeAttributes: { rowActions: actions },
                                //     cellAttributes: {class: { fieldName: 'highLight' }}
                                // }
                            ];
                        }
                        
                    } else if (result.recordType == 'DNSA Commodity'){
                        columns = [
                            {
                                label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true,
                                typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                            },
                            { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true },
                            { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true },
                            { label: 'Sales Price', fieldName: 'SalesPrice', type: 'text', sortable: true },
                            { label: 'Quantity', fieldName: 'Quantity', type: 'text', sortable: true },
                            { label: 'Subtotal', fieldName: 'Subtotal', type: 'text', sortable: true },
                            { label: 'Discount(Percentage)', fieldName: 'Discount', type: 'text', sortable: true },
                            { label: 'Total Price', fieldName: 'TotalPrice', type: 'text', sortable: true },
                            { label: 'Model Name', fieldName: 'ModelName', type: 'text', sortable: true },
                            // { label: 'List Price', fieldName: 'ListPrice', type: 'text', sortable: true },
                            // { label: 'CV Complete', fieldName: 'CVComplete', type:'boolean'},
                            // { label: 'Is Order Created', fieldName: 'IsOrderCreated', type:'boolean'}
                        ];
                    }
                    
                }else{
                    if(result.recordType == 'Korea'){
                        columns = [
                            {
                                label: $A.get("$Label.c.DN_M_Product"), fieldName: 'ProductURL', type: 'url', sortable: true
                                ,cellAttributes: {class: { fieldName: 'highLight' }},
                                typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                            },
                            { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_ProductPrice"), fieldName: 'SalesPrice', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // { label: 'Dealer Price', fieldName: 'DealerPrice', type: 'text', sortable: true },
                            { label: $A.get("$Label.c.DN_M_CVTotal"), fieldName: 'CVTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_AccessoryTotal"), fieldName: 'AccTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_SQTotal"), fieldName: 'SQTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // { label: 'Quantity', fieldName: 'Quantity', type: 'text', sortable: true },
                            // { label: 'Subtotal', fieldName: 'Subtotal', type: 'text', sortable: true },
                            // { label: 'Discount(Percentage)', fieldName: 'Discount', type: 'text', sortable: true },
                            // { label: 'Total Price', fieldName: 'TotalPrice', type: 'text', sortable: true },
                            // { label: 'List Price', fieldName: 'ListPrice', type: 'text', sortable: true },
                            { label: $A.get("$Label.c.DN_M_CVComplete"), fieldName: 'CVComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_AccessoryComplete"), fieldName: 'AccessoryComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_IsOrderCreated"), fieldName: 'IsOrderCreated', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}}
                        ];
                    }else if (result.recordType == 'Global'){
                        columns = [
                            {
                                label: $A.get("$Label.c.DN_M_Product"), fieldName: 'ProductURL', type: 'url', sortable: true
                                ,cellAttributes: {class: { fieldName: 'highLight' }},
                                typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                            },
                            { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_Warranty"), fieldName: 'Warranty', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // { label: 'List Price', fieldName: 'SalesPrice', type: 'text', sortable: true },
                            { label: $A.get("$Label.c.DN_M_SalesPrice"), fieldName: 'DealerPrice', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_AccessoryTotal"), fieldName: 'AccTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_SQTotal"), fieldName: 'SQTotal', type: 'text', sortable: true ,cellAttributes: {class: { fieldName: 'highLight' }}},
                            // { label: 'Quantity', fieldName: 'Quantity', type: 'text', sortable: true },
                            // { label: 'Subtotal', fieldName: 'Subtotal', type: 'text', sortable: true },
                            // { label: 'Discount(Percentage)', fieldName: 'Discount', type: 'text', sortable: true },
                            // { label: 'Total Price', fieldName: 'TotalPrice', type: 'text', sortable: true },
                            // { label: 'List Price', fieldName: 'ListPrice', type: 'text', sortable: true },
                            { label: $A.get("$Label.c.DN_M_CVComplete"), fieldName: 'CVComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_AccessoryComplete"), fieldName: 'AccessoryComplete', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}},
                            { label: $A.get("$Label.c.DN_M_IsOrderCreated"), fieldName: 'IsOrderCreated', type:'boolean',cellAttributes: {class: { fieldName: 'highLight' }}}
                        ];
                    } else if (result.recordType == 'DNSA Commodity'){
                        columns = [
                            {
                                label: 'Product', fieldName: 'ProductURL', type: 'url', sortable: true,
                                typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }
                            },
                            { label: 'RDD', fieldName: 'ExpectedDelivDate', type: 'text', sortable: true },
                            { label: 'ERP Quotation NO', fieldName: 'ERPQutaionNO', type: 'text', sortable: true },
                            { label: 'Sales Price', fieldName: 'SalesPrice', type: 'text', sortable: true },
                            { label: 'Quantity', fieldName: 'Quantity', type: 'text', sortable: true },
                            { label: 'Subtotal', fieldName: 'Subtotal', type: 'text', sortable: true },
                            { label: 'Discount(Percentage)', fieldName: 'Discount', type: 'text', sortable: true },
                            { label: 'Total Price', fieldName: 'TotalPrice', type: 'text', sortable: true },
                            { label: 'Model Name', fieldName: 'ModelName', type: 'text', sortable: true },
                            // { label: 'List Price', fieldName: 'ListPrice', type: 'text', sortable: true },
                            // { label: 'CV Complete', fieldName: 'CVComplete', type:'boolean'},
                            // { label: 'Is Order Created', fieldName: 'IsOrderCreated', type:'boolean'}
                        ];
                    }
                    
                }
                
                component.set('v.columns', columns); 
                component.set('v.quoteLineItemList', result.quoteLineItemWrapperList);

            }           
            
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


    , verifyBtnConditions : function(selectedRows, recordType) {
        const self = this;
        
        
        if (!selectedRows || selectedRows.length === 0) {
            self.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_NoSelectItem"));
            // No items selected. Please select an item first.
            return false;
        } 
        
        const baseProdId = selectedRows[0].ProductId;
        const otherIds   = selectedRows.filter(row => row.ProductId != baseProdId);
        if(otherIds.length > 0 && recordType != 'Global') {
            self.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), $A.get("$Label.c.DNS_M_SelectedDiffSpecs"));
            // Items with different main sepcs have been selected together. Accessories can only be added for products with the same main spec.
            return false;
        } 

        return true;
    }
})