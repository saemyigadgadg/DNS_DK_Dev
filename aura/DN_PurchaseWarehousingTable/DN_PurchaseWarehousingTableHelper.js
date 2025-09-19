({
    // 쿼리 설정
    setQuery : function(component) { 
        let strQuery = [];
        let userInfo = component.get('v.currentUserInfo');
        component.set('v.whereCondition',{});
    },

    setFilterChange : function(component, message) {
        let param =message.message;
       
        let getWhere = component.get('v.whereCondition');
        //console.log(JSON.stringify(getWhere), ' < ==getWhere');
        if(getWhere.field == param.field) {
            getWhere.field = param.value;
        } else {
            getWhere[param.field] = param.value;
        }
        //T00:00:00.000+0000
        //console.log(JSON.stringify(getWhere), ' < ==getWhere');
        component.set('v.whereCondition',getWhere);
        // console.log(JSON.stringify(component.get('v.whereCondition')), ' >< testet');
    },
    // 전체 호출
    getDataListAll : function(component, event) {
        let self = this;
        const today = new Date();
        const year = today.getFullYear();
        const month = (today.getMonth() + 1).toString().padStart(2, '0');
        const day = today.getDate().toString().padStart(2, '0');
        const dateString = year + '-' + month + '-' + day;
        component.set('v.printDate', dateString);
        // 엑셀데이터 설정
        let excelData = [];
        let dataSet =[];
        component.set('v.selectedProducts',[]);
        component.set('v.orderList', []);
        return new Promise((resolve, reject) => {
            component.set('v.isLoading', true);
            self.apexCall(component,event,this, `getDNSLIst`, {
                whereCondition : component.get('v.whereCondition')
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                    if(r.length > 0) {
                        r.forEach(element => {
                            element.printDate = dateString;
                            excelData.push({
                                '구매주문번호' : element.orderNumber,
                                '구매처' : element.buyerName,
                                '부품번호' : element.partNumber,
                                '품명': element.partName,
                                '창고재고' : element.stockQuantity,
                                '입고가능수량' : element.gRPossibleQuantity,
                                '기입고수량' : element.gRTemporaryQuantity,
                                '반품수량' : element.gRReturnQuantity,
                                '입고수량' : element.gRQuantity,
                                '송장번호' : element.text1 || '',
                                '저장위치' : element.stockLocation || '',
                                '주문일자' : element.orderDate,
                                '출고일자' : element.gIdate 
                            });
                        });
                    }
                return r;
            })).then($A.getCallback(function(result) {
                //console.log('test111');
            	
				dataSet = result;
                //console.log(dataSet);
            	self.apexCall(component,event,this, `getDealerPurOrder`, {
                    whereCondition : component.get('v.whereCondition')
                })
                .then($A.getCallback(function(res) {
                    
                    component.set('v.selectedProducts', []);
                    let { r, state } = res;
                    if(r.length > 0) {
                        // 출력일자 설정
                        r.forEach(element => {
                            element.printDate = dateString;
                            excelData.push({
                                '구매주문번호' : element.orderNumber,
                                '구매처' : element.buyerName,
                                '부품번호' : element.partNumber,
                                '품명': element.partName,
                                '창고재고' : element.stockQuantity,
                                '입고가능수량' : element.gRPossibleQuantity,
                                '기입고수량' : element.gRTemporaryQuantity,
                                '반품수량' : element.gRReturnQuantity,
                                '입고수량' : element.gRQuantity,
                                '송장번호' : element.text1 || '',
                                '저장위치' : element.stockLocation || '',
                                '주문일자' : element.orderDate,
                                '출고일자' : element.gIdate 
                            });
                            dataSet.push(element);
                        });
                        
                        //ataSet.concat(r);
                        //console.log(dataSet,' :: dataSet');
                    }
                    if(dataSet.length > 0) {
                        dataSet = self.setSorting(dataSet);
                   		component.set('v.orderList', dataSet);
                     	component.set('v.excelData',excelData);
        				component.set('v.excelName','구매입고');   
                    }
                   
                    resolve();
                })).catch(function(error) {
                    reject(error);
                    console.log('# addError error : ' + error.message);
                })
            })).catch(function(error) {
                reject(error);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                // 모든 호출 완료 후 로딩 상태 해제
                component.set('v.isLoading', false);
            });
        });             
    },

    // 목록 조회
    getDataList : function(component, event, apexMethod) {        
        let self = this;
        return new Promise((resolve, reject) => {
            component.set('v.isLoading', true);
            component.set('v.selectedProducts',[]);
            
            this.apexCall(component,event,this, `${apexMethod}`, {
                whereCondition : component.get('v.whereCondition')
            })
            .then($A.getCallback(function(result) {
                let { r, state } = result;
                component.set('v.selectedProducts', []);
                component.set('v.orderList', []);
                let dataSet = [];
                //console.log('r : ',  r);
                //console.log('state : ',  state);
                //console.log(JSON.stringify(r), ' < ==rrr');
                // 출력일자 설정
                const today = new Date();
                const year = today.getFullYear();
                const month = (today.getMonth() + 1).toString().padStart(2, '0');
                const day = today.getDate().toString().padStart(2, '0');
                const dateString = year + '-' + month + '-' + day;
                component.set('v.printDate', dateString);
                // 엑셀데이터 설정
                let excelData = [];
                r.forEach(element => {
                    element.printDate = dateString;
                    excelData.push({
                        '구매주문번호' : element.orderNumber,
                        '구매처' : element.buyerName,
                        '부품번호' : element.partNumber,
                        '품명': element.partName,
                        '창고재고' : element.stockQuantity,
                        '입고가능수량' : element.gRPossibleQuantity,
                        '기입고수량' : element.gRTemporaryQuantity,
                        '반품수량' : element.gRReturnQuantity,
                        '입고수량' : element.gRQuantity,
                        '송장번호' : element.text1 || '',
                        '저장위치' : element.stockLocation || '',
                        '주문일자' : element.orderDate,
                        '출고일자' : element.gIdate 
                    });
                });
                dataSet = self.setSorting(r);
                component.set('v.orderList', r);
                component.set('v.excelData',excelData);
                component.set('v.excelName','구매입고');
                resolve();
            })).catch(function(error) {
                reject(error);
                console.log('# addError error : ' + error.message);
            }).finally(function () {
                // 모든 호출 완료 후 로딩 상태 해제
                component.set('v.isLoading', false);
            });
        });        
    },

    //입고처리
    insertGR: function(component, event) {
        component.set('v.isLoading', true);
        let selectedProducts = component.get('v.selectedProducts');
        //console.log(JSON.stringify(selectedProducts),' :: selectedProducts')
        let self = this;
        let goodsReceiptList = [];
        let dnsIds =[];
        let agencyIds =[];
        if(selectedProducts.length > 0 ) {
            selectedProducts.forEach(element => {
                
                let orderType = element.orderType == 'DNS'? '2' : '1';
                let dataSet = {
                    inventoryChange : 'S',
                    part : element.partId,
                    location : element.stockLocationId,
                    stockId : element.stockId,
                    quantity : element.gRQuantity,
                    gRPossibleQuantity : element.gRPossibleQuantity,
                    unit : element.unit,
                    currenc : 'KRW',
                    type : orderType
                }
                if(element.orderType == 'DNS') {
                    dataSet.purchaseOrderItem = element.id;
                    dnsIds.push(element.id);
                } else {
                    dataSet.dealerPurchaseOrderItem = element.id;
                    agencyIds.push(element.id);
                }
                goodsReceiptList.push(dataSet);
            });
            //console.log(JSON.stringify(goodsReceiptList),' < ==goodsReceiptList');
            //console.log(JSON.stringify(agencyIds),' < ==agencyIds');
            //console.log(JSON.stringify(dnsIds),' < ==dnsIds');
            
            this.apexCall(component,event,this, 'insertGRList', {
                goodsReceiptList : goodsReceiptList,
                dnsIds : dnsIds,
                agencyIds : agencyIds
            })
            .then($A.getCallback(function(result) {
                component.find("headerCheckbox").set('v.checked', false);
                component.set('v.selectedProducts',[]);
                component.set('v.orderList',[]);
                let { r, state } = result;
                let res = result.r;
                //console.log(JSON.stringify(res), ' ><resultresultresultresult');
                let headerData = [{
                    '대리점명': r.agencyName,
                    '참고문서번호' : r.doc,
                    '생성일자': r.createdDate,
                    '생성시각' : r.createdTime
                }];
                let exceldata = [];
                let index =1;
                res.returnGRList.forEach(element => {
                    let location = element.Location__c == undefined ? '' : element.Location__r.FM_Loc__c;
                    let docNumber = '';
                    if(element.PurchaseOrderItem__c !=null ) {
                        docNumber = element.PurchaseOrderItem__r.PurchaseOrder__r.PartOrderNo__c;
                    } else {
                        docNumber =element.DealerPurchaseOrderItem__r.DealerPurchaseOrder__r.OrderNumber__c;
                    }
                    exceldata.push({
                        '순번' : index,
                        '종류':'구매입고',
                        '문서번호' : docNumber,
                        '품번' : element.Part__r.ProductCode || '',
                        '품명' : element.Part__r.FM_MaterialDetails__c || '',
                        '수량' : element.Quantity__c || 0,
                        '재고위치' : location,
                        '창고재고' : res.stockMap[element.Part__r.ProductCode].CurrentStockQuantity__c || 0
                    });
                    index ++;
                });
                component.set('v.excelName',`${headerData[0]['참고문서번호']}_구매입고증`);
                component.set('v.headerData',headerData);
                component.set('v.excelGRData',exceldata);
            })).then($A.getCallback(function(result) {
                self.handleGIGRDocumentExcel(component);
                let searchType = component.get('v.whereCondition');
                if(searchType.orderType == 'All') {
                    self.getDataListAll(component,event);
                } else {
                    if(searchType.orderType == 'DNS') {
                        self.getDataList(component,event,'getDNSLIst');
                    } else {
                        self.getDataList(component,event,'getDealerPurOrder');
                    }
                }
                self.toast('success', '입고완료되었습니다.');
            }))
            .catch(function(error) {
                console.log('# addError error : ' + error.message);
                self.toast('error', `${error[0].message}`);
                component.set('v.isLoading', false);
            });
        } else {
            this.toast('error', '입고처리할 항목을 선택해주세요.');
            component.set('v.isLoading', false);
        }
    },
    
    handleOutput: function(component, event) {
        let self = this;
        let selectedProducts = component.get('v.selectedProducts');
        

        let recordIds = '';
        let qty = [];
        let printDate = [];
        //let printDate = component.get('v.printDate');
        //printDate = printDate.substring(0,10);

        for(let i=0;i<selectedProducts.length; i++) {
            recordIds += selectedProducts[i].id+',';
            //console.log(selectedProducts[i].gRQuantity,' < ==1111');
            // qty += selectedProducts[i].gRQuantity + ':';
            qty.push(selectedProducts[i].gRQuantity);
            printDate.push(selectedProducts[i].printDate);
            
        }
        recordIds = recordIds.substring(0,recordIds.length-1);
        let qtys = qty.join(',')
        let printDateSet = printDate.join(',');
        //console.log(JSON.stringify(selectedProducts),'<==selectedProducts');
        if(selectedProducts.length > 0) {
            //gRQuantity
            component.set('v.openUrl', `/s/DealerPortalPrintView?c_record=${recordIds}&c_qty=${qtys}&c_printDate=${printDateSet}&c_type=입고`);
            self.handleprint(component);
        } else {
            self.toast('error', '출력할 항목을 선택해주세요.');
        }
        
    },
    setSorting : function(data) {
        data.sort((a, b) => {
            const aOrder = a.orderNumber || "";
            const bOrder = b.orderNumber || "";
    
            const aPrefix = parseInt(aOrder.charAt(0), 10);
            const bPrefix = parseInt(bOrder.charAt(0), 10);
    
            const isAInRange = aPrefix >= 2 && aPrefix <= 3;
            const isBInRange = bPrefix >= 2 && bPrefix <= 3;
    
            if (isAInRange && isBInRange) {
                return aOrder.localeCompare(bOrder); // ASC for 2~3번대
            }
    
            return bOrder.localeCompare(aOrder); // DESC for others
        });
        return data;
    }


})