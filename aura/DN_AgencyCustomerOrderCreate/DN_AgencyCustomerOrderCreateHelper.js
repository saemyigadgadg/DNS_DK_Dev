({
    gfnDoInit: function (component, event) {
        let partsList = component.get("v.partsList");
        let num = 0;
        
        if (partsList.length > 0) {
            let lastSeq  = partsList[partsList.length - 1].itemSeq; 
            lastSeq = lastSeq.slice(0, -1) + '0';
            num = Number(lastSeq/10);
        }
        //Default Order Item
        let newPartList = this.gfnDefaultPartList(component, 10, num);
        partsList = partsList.concat(newPartList);

        component.set("v.partsList", partsList);
        
        let self = this;
        let isSourceQuote = this.gfnIsSourceByQuote(component);
        let isSourceOrder = this.gfnIsSourceByOrder(component);
        this.apexCall(component, event, this, 'init', {
            sourceId: component.get('v.sourceId')
        })
        .then($A.getCallback(function(result) {

            let { r, state } = result;
            console.log('doInit.r : ',  r);
            console.log('doInit.state : ',  state);
            if(r.status.code === 200 ) {
                
                if(isSourceQuote || isSourceOrder) {
                    self.gfnSetCustomerInfo(component, r.order.customer, r.order.customerCode , r.order.customerName);
                    if(!component.get('v.cloneId')) {
                        //추가오더 생성이 아닐경우만
                        r.order.itemList.forEach((orderitem,idx)=>{
                            orderitem.itemSeq = self.gfnPadStart( ((idx+1) * 10), 6, '0');
                            orderitem.isSelected = false;
                            orderitem.replaceSize = 1;
                            orderitem.isRendered = true;
                        });
                        new Promise((resolve) => {
                            component.set("v.partsList", r.order.itemList);
                            
                            resolve();
                        }).then($A.getCallback(function(result) {
                            if(r.order.itemList.length > 0 ) {
                                if(!component.get('v.isEditMode')) {
                                    //수정이 아닌경우 Simulation
                                    //MATNR
                                    let partsListSet = r.order.itemList.filter(part => part.partName).map(part => ({ 
                                        MATNR: part.partName 
                                    }));
                                    console.log(JSON.stringify(partsListSet),' doInit ::: partsListSet')
                                    self.setInputValue(component, partsListSet, 'productCode');
                                    self.gfnShowLoading(component);
                                    self.gfnSimulation(component, event);
                                }else {
                                    //수정인 경우 Total 값만
                                    self.gfnTotalDisCountCalculation(component, r.order.itemList);
                                }
                            }
                        }));
                    } else {
                        //추가 오더 생성 id = null
                        if(r.customerInfo) {
                            if(r.customerInfo.length > 0 && r.customerInfo[0].DiscountRate__c) {
                                self.gfnSetDiscountRate(component, r.customerInfo[0].DiscountRate__c);
                            }
                        }
                        r.order.id = undefined;
                        r.order.seq = undefined;
                        r.order.orderType = 'S';
                    }

                    
                    // self.gfnOrderPriceCalculation(component);
                }
                
                component.set('v.orderHeaderInfo', r.order);
            }
            self.gfnStopLoading(component, 1000);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            self.gfnStopLoading(component, 1000);
        });

       

    },

    gfnSimulation : function(component, event) {
        return new Promise((resolve, reject) => {
        
            console.log(`${component.getName()}.gfnSimulation`);
            let self = this;
            
            let partList = component.get('v.partsList');
            let inputCmpAll  = component.find('productCode');
            if (Array.isArray(inputCmpAll)) {
                for(let i=0; i<inputCmpAll.length; i++) {
                    partList[i].partName = inputCmpAll[i].getInputValue();
                    // console.log(inputCmpAll[i].getInputValue(),' ::: inputCmpAll[i].getInputValue()');
                    
                }
            } else {
                partList[0].partName = inputCmpAll.getInputValue();
                console.log(inputCmpAll.getInputValue(), ' test111');
            }


            partList = component.get('v.partsList').filter((part)=> part.itemSeq.slice(-1) == '0');
            let partCodeList = partList.filter((part)=> part.partName).map((part)=>
                part.partName
            );

            let checkedPartDiscount = {};
            component.get('v.partsList').filter(part => part.replacingPartName && !part.disabled).map((checkedPart)=>{
                checkedPartDiscount[checkedPart.partName] = checkedPart.discountRate;
            });

            console.log(`partCodeList : ${JSON.stringify(partCodeList)}`);

            // if(partCodeList.length === 0) {
            //     this.toast('warning', ' 품목이 없습니다. 품목을 등록해주세요. ');
            //     return ;
            // }

            // if(partList.filter((part)=> part.partName).some((part)=> !part.quantity)) {
            //     this.toast('warning', ' 품목의 수량을 등록해주세요. ');
            //     return;
            // }

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
                        console.log(partDetails,' ::: partDetailspartDetails');
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
                                    part.avaiableQuantity = detail.avaiableQuantity;
                                    part.currentStockQuantity = detail.currentStockQuantity;
                                    part.unit = detail.unit;
                                    part.salesUnit = detail.salesUnit;
                                    part.customerPrice = detail.customerPrice;
                                    part.isRendered = true;
                                    if(checkedPartDiscount[part.partName] || checkedPartDiscount[part.partName] === 0 || checkedPartDiscount[part.partName] === '0') {
                                        part.discountRate = checkedPartDiscount[part.partName];
                                    }

                                    if(!part.discountPrice) part.discountPrice = detail.customerPrice;

                                    part.replaceSize = replaceSize;
                                    part = self.gfnCalcuateDiscountRate(part);
                                    part = self.gfnCalcuateDiscountAmount(part);
                                }else {
                                    part.check = false;
                                    part.disabled = true;
                                    detail.isRendered = true;
                                    detail.itemSeq = self.gfnPadStart((Number(part.itemSeq) + detailIdx), 6, '0');
                                    detail.quantity = part.quantity;
                                    if(!detail.discountPrice) detail.discountPrice = detail.customerPrice;
                                    detail.discountRate = part.discountRate;
                                    // detail.avaiableQuantity = detail.avaiableQuantity;
                                    // detail.currentStockQuantity = detail.currentStockQuantity;
                                    detail.replaceSize = -1;
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
                    var itemList = [];
                    var isSimulationCheck = false;
                    partList.forEach(element => {
                        if(element.discountPrice > 0) {
                            element.isSimulation = true;
                        } else {
                            if (element.replacingPartName == '' || element.replacingPartName == undefined) {
                                if (element.partName !== '' || element.partName !== undefined) {
                                    itemList.push(element.partName);
                                    isSimulationCheck = true;
                                }
                            }
                            element.isSimulation = false;
                        }

                    });
                    if (isSimulationCheck) {
                        itemList = itemList.filter(Boolean);
                        if (itemList.length > 0) {
                            self.toast('warning', JSON.stringify(itemList) + ' 존재하지 않는 품번입니다.');
                        }
                    }
                    
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
                    console.log(JSON.stringify(r),' error 500');
                    reject();
                    self.toast('warning', '오류가 발생하였습니다. 관리자한테 문의해주세요. ');
                }
                
                self.gfnStopLoading(component, 1000);
            })).catch(function(error) {
                console.log('# addError error : ' + error.message);
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
            
            if(!parts.partName) {
                parts.quantity = '';
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
        if(!discountRate) discountRate = 0;

        if ( parts.customerPrice) {
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

    gfnCustomerPriceValidatoin : function(component, event) {
        let isValid = true;
        let partList = component.get('v.partsList').filter((orderItem)=>orderItem.partName && !orderItem.disabled);

        partList.forEach((part)=>{
            if(!part.customerPrice) 
                isValid = false;
        });

        return isValid;
    },

    gfnOrderQuantityValidatoin : function(component, event) {
        let isValid = true;
        let partList = component.get('v.partsList').filter((orderItem)=>orderItem.partName && !orderItem.disabled);

        partList.forEach((part)=>{
            if(part.giQuantity > part.quantity) 
                isValid = false;
        });

        return isValid;
    },

    gfnSaveOrder : function(component, event, method) {
        let self = this;
        let order = this.gfnMeregeOrderAndItem(component);

        this.apexCall(component, event, this, method , {
            order
        })
        .then($A.getCallback(function(result) {

            let { r, state } = result;
            console.log(`${method}.r : `,  r);
            console.log(`${method}.state : `,  state);
            if(r.status.code === 200 ) {
                let {orderId} = r;

                let pageRef = {
                    "type": "standard__recordPage",
                    "attributes": {
                        "recordId": orderId,
                        "objectApiName": "DealerOrder__c",
                        "actionName": "view"
                    }
                };

                self.navigationTo(component, pageRef);
                component.set('v.isSave', false);
                
            }
            self.gfnStopLoading(component, 1500);
            
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            self.gfnStopLoading(component, 1000);
            component.set('v.isSave', false);
        });
    },

    gfnDeleteOrderItems : function(component, event) {
        let self = this;
        let orderItems = component.get('v.partsList').filter((orderItem)=>orderItem.isSelected);
                                    
        if(orderItems.length < 1) {
            this.showMyToast('Error', '항목을 선택해주세요.');
            this.gfnStopLoading(component, 1000);
            return;
        }

        let isNonDeletable = orderItems.some(orderItem=> orderItem.giQuantity);
        if(isNonDeletable) {
            this.showMyToast('Error', '선택한 주문 품목에 출하된 품목이 있습니다.');
            this.gfnStopLoading(component, 1000);
            return;
        }
        orderItems = orderItems.map((orderItem)=> self.gfnConvertByOrderItem(orderItem));
        
        this.apexCall(component, event, this, 'deleteOrderItems' , {
            orderItems
        })
        .then($A.getCallback(function(result) {

            let { r, state } = result;
            console.log('deleteOrderItems.r : ',  r);
            console.log('deleteOrderItems.state : ',  state);
            if(r.status.code === 200 ) {
                let {order} = r;

                if(!order) {
                    self.showMyToast('Error', '삭제 중에 오류가 발생하였습니다. 관리자에게 문의부탁드립니다.');
                    return;
                }

                if(order.Delete__c == 'N')
                    location.replace(location.href);
                else 
                    self.gfnMoveCustomPage(component, 'CustomerOrderManagement__c');

                // let {orderId} = r;

                // let pageRef = {
                //     "type": "standard__recordPage",
                //     "attributes": {
                //         "recordId": orderId,
                //         "objectApiName": "DealerOrder__c",
                //         "actionName": "view"
                //     }
                // };

                // self.navigationTo(component, pageRef);
                
            }
            self.gfnStopLoading(component, 1000);
            
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            self.gfnStopLoading(component, 1000);
        });
    },

    gfnGetAvailiablePartList : function(component) {
        let orderItemList = component.get('v.partsList');
        orderItemList = orderItemList.filter((orderItem)=>orderItem.partName && !orderItem.disabled);
        return orderItemList;
    },

    gfnMeregeOrderAndItem : function(component) {
        let self = this;
        let order = component.get('v.orderHeaderInfo');
        order.customerCode = component.get('v.customerCode');
        order.customer = component.get('v.customer');
        console.log(` order.customerName: ${order.customerName} ` );
        console.log(` customerName: ${component.get('v.customerName')} ` );
        let orderItemList = component.get('v.partsList');
        orderItemList = orderItemList.filter((orderItem)=>orderItem.partName && !orderItem.disabled);

        order.itemList = orderItemList.map((orderItem)=> self.gfnConvertByOrderItem(orderItem));

        console.log(JSON.stringify(order.itemList));
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
            machineName         :orderItem.machineName,
            equipment           :orderItem.equipment
        };  

        if(orderItem.itemId)  orderItemWrapper.itemId   =  orderItem.itemId;
        if(orderItem.orderId) orderItemWrapper.orderId  =  orderItem.orderId;

        return orderItemWrapper;
    },

    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },

    createComponentHelper: function (component, componentName, containerName, params) {
        $A.createComponent(componentName, 
            params, 
            function (content, status, errorMessage) {
            if (status === "SUCCESS") {
                var container = component.find(containerName);
                container.set("v.body", content);
            } else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.");
            } else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
    },

    getUrlParameter : function(paramName) {
        var url = window.location.href;
        var params = new URL(url).searchParams;
        return params.get(paramName);
    },

    gfnIsSourceByQuote : function(component) {
        let pageRef = component.get('v.pageReference');
        console.log('isSourceByQuote' , JSON.stringify(pageRef));

        if(!pageRef) {
            let quoteId = this.getUrlParameter('c__quote');
            if(quoteId) {
                component.set('v.sourceId', quoteId)
                return true;
            }
        }
        
        if(pageRef && pageRef.state.c__quote) {
            component.set('v.sourceId', pageRef.state.c__quote);
            return true;
        }    
        return false;
    },

    gfnIsSourceByOrder : function(component) {
        let pageRef = component.get('v.pageReference');
        console.log('gfnIsSourceByOrder' , JSON.stringify(pageRef));

        if(!pageRef) {
            let orderId = this.getUrlParameter('c__editorder');
            if(orderId) {
                component.set('v.sourceId', orderId)
                component.set('v.isEditMode', true);
                return true;
            }

            orderId = this.getUrlParameter('c__clone');
            if(orderId) {
                component.set('v.cloneId', orderId);
                component.set('v.sourceId', orderId);
                return true;
            }
        }
        
        if(pageRef && pageRef.state.c__editorder) {
            component.set('v.sourceId', pageRef.state.c__editorder);
            component.set('v.isEditMode', true);
            return true;
        }    
        return false;
    },

    gfnSetCustomerInfo : function(component, customer, customerCode, customerName) {
        if(customerCode == '9999999999') {
            //일반 고객
            component.set('v.customerCode', customerCode);
            component.set('v.customer', undefined);
        }else {
            //대리점 고객
            component.set('v.customerCode', undefined);
            component.set('v.customer', customer);
        }
        component.set('v.customerName', customerName);
    },
    
    gfnSetDiscountRate : function(component, discountRate) {
        let targetDiscount = discountRate || 0.0
        component.set('v.discountRate', targetDiscount);
        let partList = component.get('v.partsList');
        partList.forEach(part=>{
            part.discountRate = targetDiscount
            part = this.gfnCalcuateDiscountRate(part);
            part = this.gfnCalcuateDiscountAmount(part);
        });
        
        component.set('v.partsList', partList);
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

    gfnMoveCustomPage : function(component, pageName, state, replace) {
        let pageRef = {
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            },
            state
        };

        this.navigationTo(component, pageRef, replace);
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
                "discountRate": 0.0,
                "isSelected":false,
                "isRendered":true,
                discountRate
            };
            partsList.push(part);
        }

        return partsList;
    },

    gfnHandleKeyPress : function(component, event) {
        if (event.which === 13){
            this.gfnSimulationExecute(component);
        }    
    },

    gfnSimulationExecute : function(component, event) {
        // return new Promise((resolve, reject) => {
            this.gfnShowLoading(component);
            let isValid = true;
            let customerName = component.get('v.customerName');            

            if (customerName == null || customerName.trim() == '') {
                this.showMyToast('Error', '고객사명을 먼저 입력 바랍니다.');
                this.createComponentHelper(component, "c:DN_AgencyCustomerListModal", "AgencyCustomerListModal", {
                    'type' : 'All'
                });
                isValid = false;
                this.gfnStopLoading(component, 1000);
                return;
            }

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
        
                }else if(part.itemSeq.slice(-1) == '0') {
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
                component.set('v.isSave', false);
                return;
            }

            let partsList = allPartList.filter(part=>part.partName);

            let existPartsList = [];
            let existOrderQty = [];
            let orderQtyField = component.find('orderQtyId');
            if(orderQtyField && !Array.isArray(orderQtyField)) {
                orderQtyField = [orderQtyField];
            }

            let partsNoField = component.find('partNoId');
            if(partsNoField && !Array.isArray(partsNoField)) {
                partsNoField = [partsNoField];
            }
                        
            for (let i = 0; i < partsList.length; i++) {
                let partInfo = partsList[i];
                if (partInfo.partName) {
                    existPartsList.push(partInfo.partName);
                    if (!partInfo.quantity || String(partInfo.quantity).trim() == '') {
                        // Focus
                        let partQtyCmp;
                        if(Array.isArray(orderQtyField)) {
                            partQtyCmp = orderQtyField.find(orderQty=> orderQty.get('v.accesskey') == partInfo.itemSeq);
                        }

                        if (partQtyCmp) {
                            partQtyCmp.focus();
                            this.showMyToast('Error', '주문수량을 입력하십시오');
                            isValid = false;
                            break;
                        }
                    }
                }

                if (partInfo.quantity) {
                    existOrderQty.push(partInfo.quantity);
                    if (!partInfo.partName || String(partInfo.partName).trim() == '') {
                        // Focus
                        let partNoCmp;
                        if(Array.isArray(partsNoField)) {
                            partNoCmp = partsNoField.find(orderQty=> orderQty.get('v.accesskey') == partInfo.itemSeq);
                        }

                        if (partNoCmp) {
                            partNoCmp.focus();
                            helper.showMyToast('Error', '품번을 입력하세요.');
                            isValid = false;
                            break;
                        }

                        // if (partsNoField) {
                        //     partsNoField[i].focus();
                        // }
                        // helper.showMyToast('Error', '품번을 입력하세요.');
                        // isValid = false;
                        // break;
                    }
                }            
            }

            if(!isValid) {
                this.gfnStopLoading(component, 1000);
                return ;
            }

            if (existPartsList.length == 0 && existOrderQty.length == 0) {
                this.showMyToast('Error', 'You should input the material info.');
                this.gfnStopLoading(component, 1000);
                return ;
            }
            

            this.gfnSimulation(component, event);
        //});    
        
    }

    
})