/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-02-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-02-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    gfnDoinit : function(component, event) {
        console.log(`${component.getName()}.gfnDoinit`);
        let self = this;
        let sourceId = this.getUrlParameter('c__dealerorderItems');
        if(!sourceId) sourceId = this.getUrlParameter('c__editorder');
        console.log(`sourceId : ${sourceId}`);

        let partsList = component.get("v.partsList");
        let num = 0;
        if (partsList.length > 0) {
            num = partsList[partsList.length - 1].hangNumber;
        }
        for (var i = 0; i < 10; i++) {
            var num2 = num + ((i + 1) * 10);
            var str = num2 + '';
            var objSelectItem = {
                "hangNumber": num2,
                "itemSeq": str.padStart(6, '0'),
                "partName": "",
                "replacingPartName": "",
                "replaceSize":1,
                "check": false,
                "quantity": "",
                "discountRate": 0.0,
                "isSelected":false,
            };
            partsList.push(Object.assign({}, objSelectItem));
        }
        component.set("v.partsList", partsList);

        let sourceIdList = [];
        
        if(sourceId) {
            sourceIdList = sourceId.split(',');
            
            this.apexCall(component, event, this, 'init', {sourceIdList}).then($A.getCallback(function(result){
                let { r, state } = result;
                console.log(`gfnDoinit.r : `,  r);
                console.log(`gfnDoinit.state : `,  state);
                if(r.status.code === 200 ) {

                    if(r.order.itemList.length > 0) {
                        r.order.itemList.forEach((orderItem, idx)=>{
                            orderItem.itemSeq = String((idx + 1) * 10 ).padStart(6, '0');
                            orderItem.replaceSize = 1;
                        });
                        new Promise((resolve) => {
                            component.set("v.partsList", r.order.itemList);
                            
                            resolve();
                        }).then($A.getCallback(function(result) {
                            
                            //MATNR
                            let partsListSet = r.order.itemList.filter(part => part.partName).map(part => ({ 
                                MATNR: part.partName 
                            }));
                            console.log(JSON.stringify(partsListSet),' doInit ::: partsListSet')
                            self.setInputValue(component, partsListSet, 'productCode');
                            if(result.sObjectTypeName !== 'DealerOrderItem__c') {
                                self.gfnShowLoading(component);
                                self.gfnSimulation(component, event, true);
                            }
                            
                        }));
                        // component.set('v.partsList', r.order.itemList);
                        // self.gfnSimulation(component, event, true);
                    }
    
                }else {
                    self.toast('Error', ' 관리자에게 문의 부탁드립니다.');
                }
            }));
        } 
        // PO List Review를 통한경우
        else if(self.getUrlParameter('c_Material') !=null) {
            component.set("v.partsList",[]);
            let partsList = [];
            let num = 0;
            let materialList = self.getUrlParameter('c_Material').split(',');
            let qtyList = self.getUrlParameter('c_QTY').split(',');
            let dealer = self.getUrlParameter('c_daler').split(',');
            let dealerCode = self.getUrlParameter('c_code').split(',');
            let dealerName = self.getUrlParameter('c_name').split(',');
            if (partsList.length > 0) {
                num = partsList[partsList.length - 1].hangNumber;
            }
            for(let i=0; i<materialList.length; i++) {
                var num2 = num + ((i + 1) * 10);
                var str = num2 + '';
                var objSelectItem = {
                    "hangNumber": num2,
                    "itemSeq": str.padStart(6, '0'),
                    "partName": materialList[i],
                    "replacingPartName": "",
                    "replaceSize":1,
                    "check": false,
                    "quantity": qtyList[i],
                    "discountRate": 0.0,
                    "isSelected":false,
                    "dealer" : dealer[i],
                    "dealerCode" : dealerCode[i],
                    "dealerName" : dealerName[i]
                };
                partsList.push(Object.assign({}, objSelectItem));
            }
            new Promise((resolve) => {
                component.set("v.partsList", partsList);
                
                resolve();
            }).then($A.getCallback(function(result) {
                
                //MATNR
                let partsListSet = partsList.filter(part => part.partName).map(part => ({ 
                    MATNR: part.partName 
                }));
                console.log(JSON.stringify(partsListSet),' doInit ::: partsListSet')
                self.setInputValue(component, partsListSet, 'productCode');
                self.gfnSimulation(component, event, true);
                
            }));  
        }
        
    }

    ,gfnSaveOrder : function(component, event, method) {
        let self = this;
        this.gfnShowLoading(component);
        let order = this.gfnMeregeOrderAndItem(component);
        if(!order) {
            this.gfnStopLoading(component, 500);
            return;
        }

        //Validation : 오더헤더 혹은 오더품목의 대리점(고객)이 미존재할 경우
        let isValid = true;
        if(!order.customer) {
            isValid = order.itemList.every(orderItem=> orderItem.dealer);
        }
        if(!isValid) {
            this.gfnStopLoading(component, 500);
            this.toast('Error', '대리점을 입력해주세요.');
            return ;
        }

        if(order.itemList.length == 0 ) {
            this.gfnStopLoading(component, 500);
            this.toast('Error', '주문 품목을 입력해주세요.');
            return ;
        }


        isValid = order.itemList.every(orderItem=> orderItem.quantity);
        if(!isValid) {
            this.gfnStopLoading(component, 500);
            this.toast('Error', '품목중에 요청수량 0 이 존재합니다. 변경 부탁드립니다.');
            return ;
        }

        let isValidDiscountPrice = true;
        order.itemList.forEach(item=>{
            if(!item.salesUnit) 
                isValid = false;

            if(item.discountPrice === 0 || item.discountPrice === '0')
                isValidDiscountPrice = false;
        });
        
        if(!isValid) {
            this.gfnStopLoading(component, 500);
            this.toast('Error', 'Simulation 을 돌려주세요.');
            return ;
        }

        if(!isValidDiscountPrice) {
            this.gfnStopLoading(component, 500);
            this.toast('Error', '품목중에 할인판매가가 0 이 존재합니다. 삭제 및 변경 부탁드립니다.');
            return ;
        }


        //Order Split
        let orderList = this.gfnOrderSplit(order);

        this.apexCall(component, event, this, method , {
            orderList
        })
        .then($A.getCallback(function(result) {

            let { r, state } = result;
            console.log(`${method}.r : `,  r);
            console.log(`${method}.state : `,  state);
            if(r.status.code === 200 ) {
                
                let insertSize = r.orderList.length;
                let pageRef;
                if(insertSize == 1) {
                    pageRef = self.gfnGetStandardPagerRef(r.orderList[0].Id, 'DealerPurchaseOrder__c', 'view');
                    self.navigationTo(component, pageRef);   
                    return ;
                }

                pageRef = self.gfnGetCommunityCustomPageRef('PurchaseManagement__c');
                self.navigationTo(component, pageRef);   
                
            }else {
                self.toast('Error', '구매요청 생성중에 문제가 발생하였습니다. 관리자에게 문의 부탁드립니다.');
            }
            self.gfnStopLoading(component, 500);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            self.gfnStopLoading(component, 1000);
        });
    },

    //품목별로 구매요청 대리점이 다른 경우 주문 분할
    gfnOrderSplit : function(order) {
        let orders = [];

        let orderItemByDealer = {};
        // let prevDealer;
        order.itemList.forEach((orderItem, itemIdx)=>{
            if(!orderItemByDealer[orderItem.dealer]) orderItemByDealer[orderItem.dealer] = [];
            orderItemByDealer[orderItem.dealer].push(orderItem);
            // if(itemIdx != 0 && prevDealer != orderItem.dealer) {
                
            // }
            // prevDealer = orderItem.dealer;
        });
        let keyList = Object.keys(orderItemByDealer);
        let splitSize = keyList.length;
        if(splitSize > 1) {
            order.customer = undefined;
            order.customerName = undefined;
        }

        for(let key in orderItemByDealer) {
            let dealerOrder = JSON.parse(JSON.stringify(order));
            dealerOrder.itemList = orderItemByDealer[key];
            dealerOrder.customer = dealerOrder.itemList[0].dealer; //주문품목의 Dealer 는 요청 대리점으로 Customer 에 들어가야함
            dealerOrder.customerName = undefined;
            orders.push(dealerOrder);
        }

        return orders;
    },

    clearField: function (component, event, helper, fieldName, warningMessage) {
        let index = event.getSource().get('v.accesskey'); 
        let partsList = component.get('v.partsList');
    
        if (!partsList || !partsList[index][fieldName]) { 
            helper.toast('WARNING', warningMessage);
            return;
        }
    
        partsList[index][fieldName] = ''; 
        component.set('v.partsList', partsList);
    },

    gfnSetDealerOrderItem: function(component, dealerName, dealerId, dealerCode) {
        let partList = component.get('v.partsList')
        partList.forEach((part) => {
            part.dealer = dealerId;
            part.dealerName = dealerName;
            part.dealerCode = dealerCode;
        });
        component.set('v.partsList', partList);
    },
    gfnSimulationValidation : function(component, partList) {
        let isValid = true;
        let isNotMappingDealer = false;
        let isHeaderDealerByPass = partList.some((part)=> {
            if(part.partName && !part.dealerName) isNotMappingDealer = true;
            if(part.dealerName) return true;
        });

        let headerParams = component.get('v.headerParams');
        //대리점 선택 필수 유효성 검사
        if(!isHeaderDealerByPass) {
            if(!headerParams['CustomerName__c']) {
                this.toast('Error', '대리점을 입력해주세요.');
                isValid = false;
                return isValid;
            }
        }

        if(isNotMappingDealer) {
            this.toast('Error', '품목에 대리점이 선택되지 않은 항목이 존재합니다. 제거해야 Simulation 기능을 사용할 수 있습니다.');
            isValid = false;
            return isValid;
        }
        return isValid;
    },

    gfnSimulation : function(component, event, isValidByPass) {
        return new Promise((resolve, reject) => {
            console.log(`${component.getName()}.gfnSimulation2`);
            let self = this;
            this.gfnShowLoading(component);
            let allPartList = component.get('v.partsList');
            let inputCmpAll  = component.find('productCode');
            if (Array.isArray(inputCmpAll)) {
                for(let i=0; i<inputCmpAll.length; i++) {
                    allPartList[i].partName = inputCmpAll[i].getInputValue();
                    console.log(inputCmpAll[i].getInputValue(),' ::: inputCmpAll[i].getInputValue()');
                    
                }
            } else {
                allPartList[0].partName = inputCmpAll.getInputValue();
                console.log(inputCmpAll.getInputValue(), ' test111');
            }


            let partCount = {};
            allPartList.forEach(part=>{
                if(part.itemSeq.slice(-1) == '0') {
                    if(part.partName) {
                        if(partCount[part.partName]) partCount[part.partName] += 1;
                        else partCount[part.partName] = 1;
                    }
        
                }else if(part.itemSeq.slice(-1) == '1') {
                    if(part.replacingPartName && part.partName != part.replacingPartName) {
                        if(partCount[part.replacingPartName]) partCount[part.replacingPartName] += 1;
                        else partCount[part.replacingPartName] = 1;
                    }
                }
            });

            let isDuplicate = Object.values(partCount).some(count=>count>1);
            if(isDuplicate) {
                this.toast('warning', 'Duplicate Part Order No!');
                this.gfnStopLoading(component);
                return;
            }


            let partList = allPartList.filter((part)=> part.itemSeq.slice(-1) == '0');
            let isValid = true;
            if(!isValidByPass) isValid = this.gfnSimulationValidation(component, partList);
            
            if(!isValid) {
                this.gfnStopLoading(component, 1000);
                return;
            }

            let dealerNameForOrder = component.get('v.dealerNameForOrder');
            let dealerForOrder = component.get('v.dealerForOrder');
            let dealerCodeForOrder = component.get('v.dealerCodeForOrder');

            let partCodeList = [];
            let partDealerMap = {};
            partList.forEach((part)=> {
                if(part.partName && dealerForOrder) {
                    part.dealer = dealerForOrder;
                    part.dealerCode = dealerCodeForOrder;
                    part.dealerName = dealerNameForOrder;
                }

                if(part.dealerCode && part.partName) {
                    partDealerMap[part.partName] = part.dealerCode;
                    // partCodeList.push(part.partName);
                }

                if(!part.partName) {
                    part.dealer = part.dealerCode = part.dealerName = '';
                }else {
                    partCodeList.push(part.partName);
                }
            });

            console.log('partDealerMap :: ', JSON.stringify(partDealerMap));
            
            if(partCodeList.length === 0) {
                this.toast('warning', ' 품목이 없습니다. 품목을 등록해주세요. ');
                this.gfnStopLoading(component, 1000);
                return ;
            }

            if(partList.filter((part)=> part.partName).some((part)=> !part.quantity)) {
                this.toast('warning', ' 품목의 수량을 등록해주세요. ');
                this.gfnStopLoading(component, 1000);
                return;
            }

            

            this.apexCall(component,event,this, 'doSimulation', {partCodeList, partDealerMap}).then($A.getCallback(function(result) {

                let { r, state } = result;

                console.log('r : ',  r);
                console.log('state : ',  state);
                if(r.status.code === 200 ) {
                    let { partDetailsMap, customerCodeGradeMap, purchasingGradeMap } = r ;

                    let replacingParts = [];
                    
                    partList.forEach((part, partIdx)=>{
                        let partDetails = partDetailsMap[part.partName];
                            if(partDetails && Array.isArray(partDetails)) {
                                let replaceSize = partDetails.length;
                                partDetails.forEach((detail, detailIdx)=> {
                                    if(detailIdx == 0) { //detail.replacingPartName === part.partName
                                        
                                        part.part = detail.part;
                                        part.partName = detail.partName;
                                        part.partDetails = detail.partDetails;
                                        part.replacingPart        = detail.replacingPart;
                                        part.replacingPartName    = detail.replacingPartName;
                                        part.replacingPartDetails = detail.replacingPartDetails;
                                        part.avaiableQuantity     = detail.avaiableQuantity;
                                        part.currentStockQuantity = detail.currentStockQuantity;
                                        part.unit = detail.unit;
                                        part.salesUnit = detail.salesUnit;
                                        // //타 대리점 재고 조회로 값이 있으면 미설정
                                        // if(!part.customerPrice) 
                                        // if(!part.discountPrice) 
                                        part.customerPrice = detail.customerPrice;
                                        part.discountPrice = detail.customerPrice;
                                        if(customerCodeGradeMap[part.dealerCode]) {
                                            let customerCode = customerCodeGradeMap[part.dealerCode];
                                            if(purchasingGradeMap[customerCode]) {
                                                part.discountRate = purchasingGradeMap[customerCode];
                                            }
                                        }

                                        part.replaceSize = replaceSize;
                                        part = self.gfnCalcuateDiscountRate(part);
                                        part = self.gfnCalcuateDiscountAmount(part);
                                    }else {
                                        part.disabled = true;
                                        detail.itemSeq = self.gfnPadStart((Number(part.itemSeq) + detailIdx), 6, '0');
                                        detail.quantity = part.quantity;
                                        if(!detail.discountPrice) detail.discountPrice = detail.customerPrice;
                                        // detail.discountRate = part.discountRate;
                                        detail.replaceSize = -1;
                                        detail.dealer = part.dealer;
                                        detail.dealerName = part.dealerName;
                                        if(part.discountRate) detail.discountRate = part.discountRate;
                                        
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
                        self.gfnTotalDisCountCalculation(component, partList);    
                        resolve();
                    }).then($A.getCallback(function(result) {
                        //MATNR
                        let partsListSet = partList.filter(part => part.partName).map(part => ({ 
                            MATNR: part.partName 
                        }));
                        console.log(JSON.stringify(partsListSet),' ::: partsListSet')
                        self.setInputValue(component, partsListSet, 'productCode');
                    }));
                    resolve();
                    
                }

                if(r.status.code === 500 ) {
                    reject();
                    self.toast('warning', '오류가 발생하였습니다. 관리자한테 문의해주세요. ');
                }
                
                self.gfnStopLoading(component, 1000);
            })).catch(function(error) {
                console.log('# addError error : ' + error.message);
                reject();
                self.gfnStopLoading(component, 1000);
            });
        });
        
    },

    gfnOrderPriceCalculation : function(component, event) {
        console.log(component.getName() + '.gfnOrderPriceCalculation');
        let self = this;
        const partsList = component.get("v.partsList");
        const updatedPartsList = partsList.map(parts => {
            //수량이 없을 때
            if (!parts.discountRate && !parts.quantity) {
                parts.discountRate = '';
                parts.quantity = '';
                parts.discountPrice = '';
                parts.discountAmount = '';
            } else {
                parts = self.gfnCalcuateDiscountRate(parts);
            }
            parts = self.gfnCalcuateDiscountAmount(parts);

            return parts;
        });

        component.set("v.partsList", updatedPartsList);
        this.gfnTotalDisCountCalculation(component, updatedPartsList);
    },
    

    gfnTotalDisCountCalculation : function(component, partsList)     {
        //마지막에 총 합계 계산
        const partList = partsList.filter(parts => !parts.disabled);
        const totalDiscountAmount = partList.reduce((total, parts) => {
            return total + (parts.discountAmount || 0);
        }, 0);

        component.set('v.totalDiscountAmount', totalDiscountAmount.toLocaleString('ko-KR'));
    
        const totalDiscount = partList.reduce((total, parts) => {
            return total + (parts.discountPrice || 0);
        }, 0);

        component.set('v.totalDiscount', totalDiscount.toLocaleString('ko-KR'));
    },

    gfnCalcuateDiscountRate : function(parts) {
        // 할인율이 적용
        let discountRate =  parts.discountRate;
        if(!discountRate) parts.discountRate = discountRate = 0;

        if (parts.customerPrice) {
            parts.discountPrice = parseFloat(parts.customerPrice) * (1 - parseFloat(discountRate) / 100);
            parts.discountPrice = Math.floor(parts.discountPrice / 10) * 10;
        }

        return parts;
    },

    gfnCalcuateDiscountAmount : function(parts) {
        //할인 판매 금액 계산
        let discountPrice = parts.discountPrice;
        if(!discountPrice) discountPrice = 0;
        if (parts.quantity) {
            parts.discountAmount = parts.quantity * parts.discountPrice; 
        }

        return parts;
    },

    //유효성 검사
    gfnValidationForOrder : function(component) {
        let isValid = true;
        let headerParams = component.get('v.headerParams');
        let requiredParams = component.get('v.requiredParams');

        let self = this;
        requiredParams.map((requiredParam)=> {
            if(!headerParams[requiredParam.fieldApiName]) {
                self.toast('error', `필수 항목을 입력해주세요.`);
                isValid = false;
            }
        });
        return isValid;
    },

    gfnMeregeOrderAndItem : function(component) {
        let self = this;
        if(!this.gfnValidationForOrder(component)) {
            //주문 헤더 필수값 유효성 검사
            return;
        }

        let order = this.gfnConvertByOrder(component);
        let orderItemList = component.get('v.partsList');
        orderItemList = orderItemList.filter((orderItem)=>orderItem.partName && !orderItem.disabled);

        order.itemList = orderItemList.map((orderItem)=> self.gfnConvertByOrderItem(orderItem));

        console.log(JSON.stringify(order.itemList));
        return order;
    },

    gfnConvertByOrder : function(component) {
        let headerParams = component.get('v.headerParams');
        let order = {};
        for(let key in headerParams) {
            //요청할 대리점
            if(key == 'CustomerName__c') {
                order['customer'] = headerParams[key];
            }else if(key == 'shipTo') {
                //배송처

                if(headerParams[key] == '9999999999') {
                    //직접입력
                    order['customerShipTo'] = undefined;
                    order['customerShipToCode'] = headerParams[key];
                    order['shipToName'] = component.get('v.shipToName');
                    order['postalCode'] =  component.get('v.postalCode');
                    order['city'] =  component.get('v.city');
                    order['street'] =  component.get('v.street');
                    order['customerName'] = component.get('v.customerName');
                    order['representative'] =  component.get('v.representative');
                    order['phone']=  component.get('v.phone');

                }else {
                    order['customerShipTo'] = headerParams[key];
                    order['postalCode'] =  component.get('v.postalCode');
                    order['city'] =  component.get('v.city');
                    order['street'] =  component.get('v.street');
                    order['shipToName'] = component.get('v.shipToName');
                    order['customerName'] = component.get('v.customerName');
                    order['representative'] =  component.get('v.representative');
                    order['phone']=  component.get('v.phone');
                }
            }else if(key == 'priority') {
                if(headerParams[key] == 'G') order[key] = undefined; //일반
                else order[key] = headerParams[key]; //긴급
            }
            else {
                order[key] = headerParams[key];
            }
            
            
        }
        return order;
    },

    gfnConvertByOrderItem : function(orderItem) {
        //'{"hangNumber":10,"itemSeq":"000010","partName":"DNM4000-F0MF-0-U10","replacingPartName":"","quantity":"1","discountRate":"10","avaiableQuantity":"2","salesUnit":"3"}'
        let orderItemWrapper = {
            itemSeq             :orderItem.itemSeq,
            part                :orderItem.part,
            partName            :orderItem.partName,
            replacingPart       :orderItem.replacingPart,
            replacingPartName   :orderItem.replacingPartName,
            unit                :orderItem.unit,
            salesUnit           :Number(orderItem.salesUnit),
            quantity            :Number(orderItem.quantity),
            customerPrice       :Number(orderItem.customerPrice),
            discountRate        :Number(orderItem.discountRate),
            discountPrice       :Number(orderItem.discountPrice),
            discountAmount      :Number(orderItem.discountAmount),
            currentStockQuantity:Number(orderItem.currentStockQuantity),
            machineName         :orderItem.machineName,
            equipment           :orderItem.equipment,
            dealer              :orderItem.dealer,
            dealerName          :orderItem.dealerName
        };  

        if(orderItem.itemId)  orderItemWrapper.itemId   =  orderItem.itemId;
        if(orderItem.orderId) orderItemWrapper.orderId  =  orderItem.orderId;

        return orderItemWrapper;
    },

    gfnHandleKeyPress : function(component, event) {
        if (event.which === 13){
            this.gfnSimulation(component);
        }    
    },

    gfnResetPart : function(part , isNotDealerReset) {
        part.part              = undefined;
        part.partName          = undefined;        
        part.partDetails       = undefined;
        part.replacingPart     = undefined;
        part.replacingPartName = undefined;
        part.replacingPartDetails = undefined;
        part.unit              = undefined;
        part.salesUnit         = undefined;
        part.quantity          = undefined;
        part.customerPrice     = undefined;
        // part.discountRate      = undefined;
        part.discountPrice     = undefined;
        part.discountAmount    = undefined;
        // part.machineName       = undefined;
        // part.equipment         = undefined;
        if(!isNotDealerReset) part.dealer            = undefined;
        if(!isNotDealerReset) part.dealerName        = undefined;
        part.currentStockQuantity = undefined;
        return part;
    },

    gfnStopLoading: function(component, millSecond) {
        console.log(` gfnStopLoading : ${millSecond}`);
        setTimeout(()=>{
            component.set('v.isLoading', false);
        }, millSecond);
    },

    gfnShowLoading: function(component, millSecond) {
        setTimeout(()=>{
            component.set('v.isLoading', true);
        }, millSecond);
    },
})