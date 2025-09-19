({
    // 대리점 자재 종합 조회 검색
    handleSearch : function(component, event, helper, type) {
        let self = this;
        //console.log(' handleSearch!!!');
        //console.log(component.get('v.isPartVal'),' testet111');
        let errorMSG = component.get('v.errorMSG');
        let partNumber = component.get('v.inputPart');
        console.log(partNumber,' :: partNumber');
        // let inputCmpAll  = component.find('productCode');
        // partNumber = inputCmpAll.getInputValue();
        
        if(partNumber =='') {
            errorMSG = '부품번호를 입력해주세요';
            component.set('v.ifData', null) //performance //dealerStock
            component.set('v.performance', null);
            component.set('v.dealerStock', {});
            component.set('v.prodByPlant',null)
            component.set('v.mpps', null);
            component.set('v.mppsData', null);
            component.set('v.otherDealerStockList',[]);
            component.set('v.isEnter', false);
        }
        //console.log(errorMSG,'::errorMSG');
        if(errorMSG !='') {
            self.toast('ERROR', errorMSG);
            component.set('v.isLoading', false);
            component.set('v.errorMSG','');
            //$A.get('e.force:refreshView').fire();
            component.set('v.ifData', null) //performance //dealerStock
            component.set('v.performance', null);
            component.set('v.dealerStock', {});
            component.set('v.prodByPlant',null)
            component.set('v.mpps', null);
            component.set('v.mppsData', null);
            component.set('v.otherDealerStockList',[]);
        } else {
            if(type !='preview') {
                //if(component.get('v.isInit')) {
                    //setTimeout(() => {
                        history.pushState({query: partNumber}, '', location.href);    
                    //}, 1000);
                //}
            }

            component.set('v.isLoading', true);
            self.apexCall(component, event, helper, 'getStock', {
                productCode : partNumber
            })
            .then($A.getCallback(function(result) {
                
                //이전검색기록 저장
                                
                
                
                let r = result.r;
                
                component.set('v.saveDealerStock', {});
                component.set('v.ifData', {});
                //console.log(r.dealerStockInfo,' :: r.dealerStockInfo');
                if(r.dealerStockInfo.Id !=null) {
                    r.dealerStockInfo.CurrentStockQuantity__c = Number(r.dealerStockInfo.CurrentStockQuantity__c);
                    r.dealerStockInfo.AvailableQuantity__c = Number(r.dealerStockInfo.AvailableQuantity__c);
                    r.dealerStockInfo.OrderRequiredQuantity__c = Number(r.dealerStockInfo.OrderRequiredQuantity__c);
                    r.dealerStockInfo.WarrantyRequiredQuantity__c = Number(r.dealerStockInfo.WarrantyRequiredQuantity__c);
                    component.set('v.dealerStock', r.dealerStockInfo);
                } else {
                    component.set('v.dealerStock', {
                        CurrentStockQuantity__c : 0,
                        AvailableQuantity__c : 0,
                        OrderRequiredQuantity__c : 0,
                        WarrantyRequiredQuantity__c : 0
                    });
                }
                if(r.isMpps !=null) {
                    r.dealerMPPS.reOrderPoint = Number(r.dealerMPPS.reOrderPoint);
                    r.dealerMPPS.maximumStock = Number(r.dealerMPPS.maximumStock);
                    r.dealerMPPS.roundingValue = Number(r.dealerMPPS.roundingValue);
                    r.dealerMPPS.minimumLotSize = Number(r.dealerMPPS.minimumLotSize);
                } 
                //r.dealerStockInfo.BlockQuantity__c = Number(r.dealerStockInfo.BlockQuantity__c);
                
                component.set('v.prodByPlant',r.prodByPlant);
                component.set('v.mpps', r.isMpps);
                component.set('v.mppsData', r.dealerMPPS);
                let other = [];
                r['otherDealerStockList'].forEach(element => {
                    if(element.AvailableQuantity__c > 0) {
                        other.push(element);
                    }
                });
                // 타대리점 재고 정보
                component.set('v.otherDealerStockList',other);
                // 인터페이스 정보 - 단건이므로 0번째
                
                if(r.ifRes.D_DETAIL.length > 0) {
                    r.ifRes.D_DETAIL[0].AVAIL_QTY = r.ifRes.D_DETAIL[0].AVAIL_QTY ==null ? 0 : Number(r.ifRes.D_DETAIL[0].AVAIL_QTY);
                    r.ifRes.D_DETAIL[0].AVAIL_QTY2 = r.ifRes.D_DETAIL[0].AVAIL_QTY2 ==null ? 0 : Number(r.ifRes.D_DETAIL[0].AVAIL_QTY2);
                    r.ifRes.D_DETAIL[0].NETPR = Number(r.ifRes.D_DETAIL[0].NETPR).toLocaleString() +' ';
                    r.ifRes.D_DETAIL[0].NETPR  += r.ifRes.D_DETAIL[0].CURRENCY2 ==''? 'KRW' : r.ifRes.D_DETAIL[0].CURRENCY2;
                    component.set('v.ifData',r.ifRes.D_DETAIL[0]);
                    //console.log(JSON.stringify(r.ifRes.D_DETAIL),' ::: r.ifRes.D_DETAIL');
                }
                if(r.performance !=null) {
                    r.performance.dnsPurchaseQTY = Number(r.performance.dnsPurchaseQTY);
                    r.performance.otherDealerPurchaseQTY = Number(r.performance.otherDealerPurchaseQTY);
                    r.performance.totalPerformance = Number(r.performance.totalPerformance);
                    r.performance.yearPurchasePerformance = Number(r.performance.yearPurchasePerformance);
                }
                
                // 실적 정보
                component.set('v.performance', r.performance);
                
                //대체품 정보
                self.apexCall(component, event, helper, 'replacingPart', {
                    productCode : partNumber
                })
                .then($A.getCallback(function(result) {
                    //console.log(JSON.stringify(result), ' ::대체품 정보');
                    {}
                    component.set('v.replacePartsList', result.r.ET_CROSS);
                    component.set('v.isInit', true);
                    component.set('v.isLoading', false);
                }))
                .catch(function(error) {
                    //console.log(JSON.stringify(error),' < ===error');
                    if(error.length > 0) {
                        self.toast('ERROR', error[0].message);
                        component.set('v.ifData', null) //performance //dealerStock
                        component.set('v.performance', null);
                        component.set('v.dealerStock', {});
                        component.set('v.prodByPlant',null)
                        component.set('v.mpps', null);
                        component.set('v.mppsData', null);
                        component.set('v.otherDealerStockList',[]);
                    } else {
                        self.toast('ERROR', 'An error occurred, please contact your administrator.');
                    }
                    component.set('v.isLoading', false);
                })
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                //console.log(JSON.stringify(error),' < ===error');
                if(error.length > 0) {
                    self.toast('ERROR', error[0].message);
                    component.set('v.ifData', null) //performance //dealerStock
                    component.set('v.performance', null);
                    component.set('v.dealerStock', {});
                    component.set('v.prodByPlant',null)
                    component.set('v.mpps', null);
                    component.set('v.mppsData', null);
                    component.set('v.otherDealerStockList',[]);
                } else {
                    self.toast('ERROR', 'An error occurred, please contact your administrator.');
                }
                component.set('v.isLoading', false);
                component.set('v.isEnter', false);
            }).finally(function () {
                // 브라우저 자동 완성에 검색한 값을 저장하기 위해 form을 직접 그린 후 임의로 제출
                // 화면에서는 보이지 않도록 하기 위해 스타일도 설정
                const form = document.createElement("form");
                form.action = "javascript:void(0);";
                form.method = "POST";
                form.id="hiddenForm";
                form.style.position = "absolute";
                form.style.width = "1px";
                form.style.height = "1px";
                form.style.overflow = "hidden";
                form.style.whiteSpace = "nowrap";
                form.style.border = "0";
                form.style.padding = "0";
                form.style.margin = "-1px";
                const input = document.createElement("input");
                input.type = "text";
                input.name = "partCode";
                input.value = component.get('v.inputPart');
                input.autocomplete = "on";
                form.appendChild(input);
                const targetDiv = document.getElementById("autoCompleteTarget");
                targetDiv.appendChild(form);
                form.requestSubmit();
                
                setTimeout(() => {
                    targetDiv.removeChild(form);
                    component.set('v.isEnter', false);   
                }, 1000);
                
            });
        }
        
    },
})