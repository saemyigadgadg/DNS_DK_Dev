/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-13-2024
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-13-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    gfnSave : function(component, event) {
        console.log(component.getName() + '.gfnSave');
        let headerParams = component.get('v.headerParams');
        console.log(JSON.stringify(headerParams));
        // customerCode : 9999999999 일반고객일경우
        if(!this.gfnValidationCheckRequiredFields(component, headerParams)) {
            this.toast('warning', '필수 값을 입력해주세요.');
            component.set('v.isSpinner', false);
            return;
        }

        let quoteItemList = component.get('v.partsList').filter((part)=> part.partName && !part.disabled);

        if(!this.gfnValidationCheckQuoteItems(quoteItemList)) {
            this.toast('warning', 'Parts 를 입력해주세요. ');
            component.set('v.isSpinner', false);
            return;
        }

        // if(!quoteItemList.every(part=>part.discountPrice)) {
        //     this.toast('Warning', 'Simualtion 을 진행하지 않은 품목이 존재합니다.');
        //     component.set('v.isSpinner', false);
        //     return;
        // }
        
        for(let i=0; i<quoteItemList.length; i++) {
            if(!quoteItemList[i].isSimulation) {
                this.toast('Warning', 'Simualtion 을 진행하지 않은 품목이 존재합니다.');
                component.set('v.isSpinner', false);
                return;
            }

            if(!quoteItemList[i].quantity) {
                this.toast('Warning', '수량을 확인해 주세요.');
                component.set('v.isSpinner', false);
                return;
            }
        }

    
        let self = this;
        let params = {'quote' : this.gfnConvertByQuote(headerParams)};

        let itemList = [];
        itemList = quoteItemList.map((quoteItem)=> this.gfnConvertByQuoteItem(quoteItem));
        params.quote.itemList = itemList;
        

        this.apexCall(component,event,this, 'doSave', params).then($A.getCallback(function(result) {

            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {
                // component.set('v.customerList', r.agencyCustomerList);
                
                let pageRef = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId":r.quoteId,
                        "objectApiName": "DealerQuote__c",
                        "actionName": "view"
                    }
                };

                self.navigationTo(component, pageRef);
                self.gfnStopLoading(component, 1000);
            }
            if(r.status.code === 500 ) {
                self.toast('warning', '저장 중에 오류가 발생하였습니다. 관리자한테 문의해주세요. ');
            }
            component.set('v.isSpinner', false);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            component.set('v.isSpinner', false);
        });
    
    },

    gfnSimulation : function(component, event) {
        let self = this;
        let partList = component.get('v.partsList');
        let inputCmpAll  = component.find('productCode');
        if (Array.isArray(inputCmpAll)) {
            for(let i=0; i<inputCmpAll.length; i++) {
                partList[i].partName = inputCmpAll[i].getInputValue();
            }
        } else {
            partList[0].partName = inputCmpAll.getInputValue();
            console.log(inputCmpAll.getInputValue(), ' test111');
        }

        partList = partList.filter((part)=> part.itemSeq.slice(-1) == '0');
        
        let partCodeList = partList.filter((part)=> part.partName).map((part)=>
            part.partName
        );

        console.log(`partCodeList : ${JSON.stringify(partCodeList)}`);

        if(partCodeList.length === 0) {
            this.toast('warning', ' 품목이 없습니다. 품목을 등록해주세요. ');
            this.gfnStopLoading(component, 500);
            return ;
        }

        if(partList.filter((part)=> part.partName).some((part)=> !part.quantity)) {
            this.toast('warning', ' 품목의 수량을 등록해주세요. ');
            this.gfnStopLoading(component, 500);
            return;
        }

        let newPartList = partList.filter((part)=> part.partName && part.quantity);
        if(newPartList.length < 10) {
            newPartList = newPartList.concat(this.gfnDefaultPartList(component, 10, newPartList.length-1));
        }
        partList = newPartList;
        
        this.apexCall(component,event,this, 'doSimulation', {partCodeList}).then($A.getCallback(function(result) {

            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {
                let { partDetailsMap } = r ;

                let replacingParts = [];
                
                partList.forEach((part, partIdx)=>{
                    let seq = ((partIdx + 1) * 10);
                    part.itemSeq = String(seq).padStart(6, '0');

                    let partDetails = partDetailsMap[part.partName];
                    if(partDetails && Array.isArray(partDetails)) {
                        let replaceSize = partDetails.length;
                        partDetails.forEach((detail, detailIdx)=> {
                            if(detailIdx == 0) { //detail.replacingPartName === part.partName
                                part.part = detail.part;
                                part.partName = detail.partName;
                                part.partDetails = detail.partDetails;
                                part.replacingPart = detail.replacingPart;
                                part.replacingPartName = detail.replacingPartName;
                                part.replacingPartDetails = detail.replacingPartDetails;
                                part.unit = detail.unit;
                                part.customerPrice = detail.customerPrice;
                                part.discountPrice = detail.customerPrice;
                                part.replaceSize = replaceSize;
                                part.isRendered = true;
                                part = self.gfnCalcuateDiscountRate(part);
                                part = self.gfnCalcuateDiscountAmount(part);
                            }else {
                                part.disabled = true;
                                detail.itemSeq = self.gfnPadStart((Number(part.itemSeq) + detailIdx), 6, '0');
                                detail.quantity = part.quantity;
                                detail.discountRate = part.discountRate;
                                detail.discountPrice = detail.customerPrice;
                                detail.replaceSize = -1;
                                detail.isRendered = true;
                                detail = self.gfnCalcuateDiscountRate(detail);
                                detail = self.gfnCalcuateDiscountAmount(detail);
                                replacingParts.push({
                                    partIdx,
                                    detail
                                });
                            }
                        });
                        
                    }
                });

                console.log(JSON.stringify(replacingParts));

                for(let lastIdx = replacingParts.length-1; lastIdx >= 0; lastIdx--) {
                    let { partIdx, detail } = replacingParts[lastIdx];
                    partList.splice(partIdx+1, 0, detail);
                }
                partList.forEach(element => {
                    if(element.discountPrice > 0) {
                        element.isSimulation = true;
                    } else {
                        element.isSimulation = false;
                    }
                });

                console.log('추가완료 Part : ', JSON.stringify(partList));
                
                new Promise((resolve) => {
                    component.set('v.partsList', []);
                    component.set('v.partsList', partList);
                    self.gfnTotalQuotePriceCalculation(component, partList);
                    resolve();
                }).then($A.getCallback(function(result) {
                    //MATNR
                    let partsListSet = partList.filter(part => part.partName).map(part => ({ 
                        MATNR: part.partName 
                    }));
                    console.log(JSON.stringify(partsListSet),' ::: partsListSet')
                    self.setInputValue(component, partsListSet, 'productCode');
                })); 
            }

            if(r.status.code === 500 ) {
                self.toast('warning', '오류가 발생하였습니다. 관리자한테 문의해주세요. ');
            }
            
            self.gfnStopLoading(component, 1000);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            self.gfnStopLoading(component, 1000);
        });
    },

    gfnQuotePriceCalculation : function(component, event) {
        
        let self = this;
        const partsList = component.get("v.partsList");
        const updatedPartsList = partsList.map(parts => {
            //수량이 없을 때

            if(parts.partName) {
                if (!parts.discountRate && !parts.quantity) {
                    parts.discountRate = 0;
                    parts.quantity = 0;
                    parts.discountPrice = '';
                    parts.discountAmount = '';
                } else {
                    if(!parts.discountRate) {
                        parts.discountRate = 0;
                    }
                    parts = self.gfnCalcuateDiscountRate(parts);
                }
                parts = self.gfnCalcuateDiscountAmount(parts);
            }


            return parts;
        });

        component.set("v.partsList", updatedPartsList);
        this.gfnTotalQuotePriceCalculation(component, updatedPartsList);
    },

    gfnTotalQuotePriceCalculation : function(component, partsList)     {
        //마지막에 총 합계 계산
        const partList = partsList.filter(parts => !parts.disabled);
        const quoteTotal = partList.reduce((total, parts) => {
            return total + (parts.discountAmount || 0);
        }, 0);
    
        component.set("v.quoteTotal", quoteTotal);
    },

    gfnCalcuateDiscountRate : function(parts) {
        // 할인율이 적용
        let discountRate =  parts.discountRate;
        if(!discountRate) discountRate = 0;

        if (parts.customerPrice) {
            parts.discountPrice = parseFloat(parts.customerPrice) * (1 - parseFloat(discountRate) / 100);
            parts.discountPrice = Math.floor(parts.discountPrice / 10) * 10;
        } else {
            parts.discountPrice = 0;
        }

        return parts;
    },

    gfnCalcuateDiscountAmount : function(parts) {
        //할인 판매 금액 계산
        let discountPrice = parts.discountPrice;
        if (discountPrice && (parts.quantity || parts.quantity == 0)) {
            if((discountPrice === 0 || discountPrice === '0')) discountPrice = 0;
            parts.discountAmount = parts.quantity * parts.discountPrice; 
        }

        return parts;
    },

    gfnValidationCheckRequiredFields : function(component, params) {
        console.log(component.getName() + '.gfnValidationCheckRequiredFields');
        let isValid = true;
        let requiredParams = component.get('v.requiredParams');
        if(!!!params) params = {};
        
        if(!Array.isArray(requiredParams)) return false;

        isValid = requiredParams.every((required)=> (!!params[required.fieldApiName]));

        return isValid;
    },

    gfnValidationCheckQuoteItems : function(quoteItemList) {
        console.log('.gfnValidationCheckQuoteItems');
        let isValid = true;

        if(quoteItemList.length == 0) isValid = false;

        return isValid;
    },

    gfnConvertByQuote : function(quote) {
        let quoteWrapper = {
            machineName  : quote.Type ,
            equipment    : quote.SerialNumber ,
            description  : quote.Description
        };

        if('9999999999' === quote.CustomerName__c) quoteWrapper.customerCode = quote.CustomerName__c;
        else quoteWrapper.customer = quote.CustomerName__c

        return quoteWrapper;
    },

    gfnConvertByQuoteItem : function(quoteItem) {
        let quoteItemWrapper = {
            itemSeq             :quoteItem.itemSeq,
            part                :quoteItem.part,
            replacingPart       :quoteItem.replacingPart,
            unit                :quoteItem.unit,
            quantity            :Number(quoteItem.quantity),
            customerPrice       :Number(quoteItem.customerPrice),
            discountRate        :Number(quoteItem.discountRate),
            discountPrice       :Number(quoteItem.discountPrice),
        };

        return quoteItemWrapper;
    },

    gfnSetDiscountRate : function(component, discountRate) {
        component.set('v.discountRate', discountRate);
        let partList = component.get('v.partsList');
        partList.forEach(part=>{
            part.discountRate = discountRate || 0;
            part = this.gfnCalcuateDiscountRate(part);
            part = this.gfnCalcuateDiscountAmount(part);
        });
        this.gfnTotalQuotePriceCalculation(component, partList);
        component.set('v.partsList', partList);
    },

    gfnDefaultPartList : function(component, size, startIdx=0) {
        let partsList = [];
        let discountRate = component.get('v.discountRate');
        for (let i = startIdx; i < (size+startIdx); i++) {
            let seq = ((i + 1) * 10);
            let part = {
                "itemSeq": String(seq).padStart(6, '0'),
                "partName": "",
                "replacingPartName": "",
                "replaceSize":1,
                "check": false,
                "quantity": "",
                "isSelected":false,
                "isRendered":true,
                discountRate
            };
            partsList.push(part);
        }

        return partsList;
    },

    gfnStopLoading: function(component, millSecond) {
        console.log(` gfnStopLoading : ${millSecond}`);
        setTimeout(()=>{
            component.set('v.isSpinner', false);
        }, millSecond);
    },

    gfnShowLoading: function(component, millSecond) {
        setTimeout(()=>{
            component.set('v.isSpinner', true);
        }, millSecond);
    },

    gfnHandleKeyPress : function(component, event) {
        if (event.which === 13){
            this.gfnShowLoading(component);
            this.gfnSimulation(component);
        }    
    },
})