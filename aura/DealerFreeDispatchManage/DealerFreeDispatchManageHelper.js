/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-28-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-06-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    // 쿼리 설정
    setQuery : function(component) { 
        component.set('v.whereCondition',{});
    },

    setFilterChange : function(component, message) {
        let param =message.message;
       
        let getWhere = component.get('v.whereCondition');
        // console.log(JSON.stringify(getWhere), ' < ==getWhere');
        
        if(param.field =="ReadDeleteHistory") {
            component.set('v.partsList',[]);
        }
        if(getWhere.field == param.field) {
            getWhere.field = param.value;
        } else {
            getWhere[param.field] = param.value;
        }
        //T00:00:00.000+0000
        // console.log(JSON.stringify(getWhere), ' < ==getWhere');
        component.set('v.whereCondition',getWhere);
        // console.log(JSON.stringify(component.get('v.whereCondition')), ' >< testet');
    },

    // 목록 조회
    getDataList : function(component, event) {
        let self = this;
        component.set('v.isLoading', true);
        let headerName = component.get('v.whereCondition').ReadDeleteHistory == true ? '대리점 무상부품 관리 Return History': '대리점 무상부품 관리';
        component.set('v.headerType', headerName);
        component.set('v.partsList',[]);
        component.set('v.selectList',[]);
        let afterSaveList = component.get('v.afterSave');
        // console.log(afterSaveList,'<<< afterSaveList');
        this.apexCall(component,event,this, 'getDataList', {
            whereCondition : component.get('v.whereCondition')
        })
        .then($A.getCallback(function(result) {
            component.set('v.isOpen', false);
            let { r } = result;

            if(r.returnList.length > 0 ) {
                component.set('v.partsList',r.returnList);
                component.set('v.pageInfo', r.pageInfo);
                component.set('v.whereConditionInfinite', component.get('v.whereCondition'));
                if(afterSaveList.length == 0){
                    self.toast('success', ' 검색이 완료되었습니다.');
                }
                
                if(afterSaveList.length > 0){
                    let sel = component.get('v.afterSave')[0];
                    let myObjects = component.get('v.partsList');
                    
                    for (var i = 0; i < myObjects.length; i++) {
                        let checkbox = component.find('checkbox');
                        checkbox[i].set('v.disabled', true);
                        if (myObjects[i].order === sel.order) {
                            if(myObjects[i].item === sel.item) {
                                if (Array.isArray(checkbox)) {
                                    checkbox[i].set("v.checked", true);
                                } else {
                                    checkbox.set("v.checked", true);
                                }
                                component.set('v.selectList', myObjects[i]);
                                checkbox[i].set('v.disabled', false);
                            } 
                        }
                    }
                    let actionD = component.get("c.toggleDetail");
                    actionD.setCallback(this, function(responseD) {
                        var stateD = responseD.getState();
                        if (stateD === "SUCCESS") {
                            // console.log(stateD);
                        } else if (stateD === "ERROR") {
                            // console.log(stateD);
                        }
                    });
                    $A.enqueueAction(actionD); 
                    component.set('v.afterSave',[]);
                    //self.toast('success', ' 검색이 완료되었습니다.');
                }
            
            } else {
                self.toast('error', ' 검색결과가 없습니다.');
                component.set('v.whereConditionInfinite', {});
                component.set('v.pageInfo', {});
            }
           // console.log(JSON.stringify(result.r), ' ::: result.r');
            
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },

   
    getDetailList : function(component, event) {
        let self = this;
        let list = component.get('v.selectList');
        // console.log(JSON.stringify(list[0]));
       
        component.set('v.serviceOrder',[]);
        component.set('v.notification',[]);
        component.set('v.domesticClaim',[]);

        if(component.get('v.whereCondition').ReadDeleteHistory) {
            list[0].historyYN = 'Y';
        }
        
        self.apexCall(component,event,this, 'getDetailList', {
            search : list[0] //component.get('v.selectList')[0]
        })
        .then($A.getCallback(function(result) {
            // console.log(JSON.stringify(result.r), ' ::: result.r');
            //item,order
            if(result.r.type =='' || result.r.type =='S') {
                self.toast('success', ' 검색이 완료되었습니다.');
                // 2025 04 08 서일태 수정 선택한 무상부품의 디테일 정보만 보이도록 수정
                let selected = list[0];
                let serviceOrder = result.r.serviceOrder.filter(item => (item.order+'_'+item.item) == (selected.order +'_'+selected.item));
                let notification = result.r.notification.filter(item => item.item == selected.item);
                let domesticClaim = result.r.domesticClaim.filter(item => (item.order+'_'+item.item) == (selected.order +'_'+selected.item));

                component.set('v.serviceOrder', serviceOrder);
                component.set('v.notification', notification);
                component.set('v.domesticClaim', domesticClaim);
                component.set('v.isOpen', true);
            } else {
                self.toast('error', ' 검색결과가 없습니다.');
                component.set('v.isOpen', false); 
            }
            //console.log(JSON.stringify(result.r), ' ::: result.r');
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },

    // Return 
    addReturn : function(component, event) {
        let self = this;
        self.openConfirm(`반품처리 하시겠습니까?`, 'default', 'headerless')
            .then($A.getCallback(function(result) {
                if(result) {
                    // console.log(JSON.stringify(component.get('v.selectList')[0]),' :: test1111');
                    let notiItemNumber;
                    let domesticItemNumber;
                    let notification = component.get('v.notification')
                    notification.forEach(noti=>{
                        if(noti.isSelected) {
                            notiItemNumber = noti.item;
                        }
                    });
                    let domesticClaim =  component.get('v.domesticClaim');
                    domesticClaim.forEach(domestic=>{
                        if(domestic.isSelected) {
                            domesticItemNumber = domestic.item;
                        }
                    });
                    
                    component.set('v.isLoading', true);
                    self.apexCall(component,event,this, 'addReturn', {
                        pat : component.get('v.selectList')[0],
                        notiItemNumber,
                        domesticItemNumber
                    })
                    .then($A.getCallback(function(result) {
                        // console.log(JSON.stringify(result.r), ' ::: result.return');
                        if(result.r.msg=='S') {
                            self.toast('success', ' 반품처리되었습니다.');
                            self.getDataList(component, event);
                        } else {
                            self.toast('success', ' 반품 처리가 실패하였습니다.');
                        }
                    })).catch(function(error) {
                        console.log('# addError error : ' + error.message);
                    }).finally(function () {
                        // 모든 호출 완료 후 로딩 상태 해제
                        component.set('v.isLoading', false);
                    });
                }
            }))
            .catch(error => {
                console.error("Error during confirmation:", error);
            });
        
        
    },


    // self.apexCall(component,event,this, 'partition', {
                    //     pat : component.get('v.selectList')[0]
                    // })
                    // .then($A.getCallback(function(result) {
                    //     self.toast('success', ' 수량이 분할되었습니다.');
                    //     self.getDataList(component, event);
                        
                    // })).catch(function(error) {
                    //     console.log('# addError error : ' + error.message);
                    // }).finally(function () {
                    //     // 모든 호출 완료 후 로딩 상태 해제
                    //     component.set('v.isLoading', false);
                    // });


    // partition 
    partition : function(component, event) {
        let self = this;
        //component.set('v.isLoading', true);
        self.openConfirm(`수량분할 하시겠습니까?`, 'default', 'headerless')
            .then($A.getCallback(function(result) {
                if(result) {
                    component.set('v.isQty', true);
                    // component.set('v.isLoading', true);     
                }
            }))
            .catch(error => {
                console.error("Error during confirmation:", error);
            });
    },

   partitionInsert : function(component, event) {
        let self = this;
        let qty = component.get('v.partition1');
        let copy = component.get('v.partition2');
        let selectRow = component.get('v.selectList')[0];
        if(qty == 0 || copy == 0) {
            self.toast('error', ' 수량 분할 시 0으로 분할 할 수 없습니다.');
            return;
        }
        // console.log(qty + copy, ' < ;;;qty + copy');
        // console.log(selectRow.reqQty,' ::: selectRow.reqQty');
        let valQty =(parseInt(qty) + parseInt(copy)) - selectRow.reqQty
        if(valQty !=0) {
            if( valQty > 0) {
                self.toast('error', ' Required Qty의 수량보다 분할 수량이 많을 수 없습니다.');
                return;
            } else {
                self.toast('error', ' Partition 1,2 수량이 Required Qty보다 적을 수 없습니다.');
                return;
            }
        }
        
        component.set('v.isLoading', true);    
        self.apexCall(component, event, this, 'partitionCheck', {
            pat : component.get('v.selectList')[0],
            qty : qty,
            copyQty : copy
        }).then($A.getCallback(function(result) {
            if(result.r.isPassCrmDml) {
                self.apexCall(component,event,this, 'partition', {
                    pat : component.get('v.selectList')[0],
                    qty : qty,
                    copyQty : copy
                })
                .then($A.getCallback(function(result) {
                    // console.log(JSON.stringify(result.r), ' ::: result.return');
                    if(result.r.msg =='S') {
                        self.toast('success', ' 수량이 분할되었습니다.');
                        component.set('v.afterSave',result.r.returnOrder);
                        // console.log(JSON.stringify(component.get('v.afterSave'), ' ::: afterSave'));
                        component.set('v.isQty', false);
                        component.set('v.partition1',0);
                        component.set('v.partition2',0);
                        self.getDataList(component, event);
                    } else {
                        let errorMsg = '수량 분할에 실패하였습니다. ' + result.r.ifErrorMsg;
                        self.toast('error', errorMsg);
                    }
                    
                })).catch(function(error) {
                    console.log('# addError error : ' + error.message);
                    self.toast('error', '수량 분할시에 에러가 발생하였습니다. 관리자에게 문의 부탁드립니다.');
                }).finally(function () {
                    // 모든 호출 완료 후 로딩 상태 해제
                    component.set('v.isLoading', false);
                });
            }else {
                component.set('v.isLoading', false); 
                self.toast('error', result.r.errorMsg);
            }
        }));
        
   },

   handleSelect: function(component, event) {
    let current = event.getSource();//.get("v.value"); //let check = event.getSource().get("v.checked");
        let select = component.get('v.selectList');
        let allData = component.get('v.partsList');
        let checkbox = component.find('checkbox');
       
        if(current.get("v.checked")) {
            component.set('v.selectList', allData[current.get('v.name')]);
            if(allData.length>1){
                checkbox.forEach(function (checkbox, index) {
                    if(index != current.get('v.name')) {
                        checkbox.set('v.disabled', true);
                    }
                });
            }
        } else {
            if(allData.length>1){
                component.set('v.selectList', []);
                checkbox.forEach(function (checkbox, index) {
                    checkbox.set('v.disabled', false);
                });
            }
            component.set('v.isOpen', false);
          
        }
    },

    updateTableHeight: function (component, isOpen) {
        var tableWrap = document.querySelector(".body .top-table .table-wrap");
        if (tableWrap) {
            var isSmallScreen = window.matchMedia("(max-width: 1800px)").matches;

            if (isOpen) {
                tableWrap.style.height = isSmallScreen ? "calc(100vh - 35rem)" : "calc(100vh - 45rem)";
            } else {
                tableWrap.style.height = isSmallScreen ? "calc(100vh - 30rem)" : "calc(100vh - 33rem)";
            }
        }
    },

    loadMoreItems: function (component, callback) {
        console.log('loadMoreItems');
        let self = this;
        let partList = component.get('v.partsList');


        if(partList.length > 2000) {
            console.log('2000 Limit');
            callback();
            return;
        }

        if(partList.length == 0) {
            console.log('Not Infinite ');
            callback();
            return ;
        }

        let pageInfo = component.get('v.pageInfo');
        if(pageInfo.endIdx > partList.length) {
            callback();
            return;
        }

        component.set('v.isLoading', true);
        pageInfo.nextPage = pageInfo.currentPage + 1;
        this.apexCall(component, null,this, 'getDataList', {
            whereCondition : component.get('v.whereConditionInfinite'),
            pageInfo
        })
        .then($A.getCallback(function(result) {
            let { r } = result;

            if(r.returnList.length > 0 ) {
                
                partList = partList.concat(r.returnList);
                component.set('v.partsList', partList);
                component.set('v.pageInfo', r.pageInfo);
            }

            // component.set('v.isOpen', false);
            // if(result.r.length > 0 ) {
               
                // component.set('v.partsList',result.r);
                // if(afterSaveList.length == 0){
                //     self.toast('success', ' 검색이 완료되었습니다.');
                // }
                
                // if(afterSaveList.length > 0){
                    // let sel = component.get('v.afterSave')[0];
                    // let myObjects = component.get('v.partsList');
                    
                    // for (var i = 0; i < myObjects.length; i++) {
                    //     let checkbox = component.find('checkbox');
                    //     checkbox[i].set('v.disabled', true);
                    //     if (myObjects[i].order === sel.order) {
                    //         if(myObjects[i].item === sel.item) {
                    //             if (Array.isArray(checkbox)) {
                    //                 checkbox[i].set("v.checked", true);
                    //             } else {
                    //                 checkbox.set("v.checked", true);
                    //             }
                    //             component.set('v.selectList', myObjects[i]);
                    //             checkbox[i].set('v.disabled', false);
                    //         } 
                    //     }
                    // }
                    // let actionD = component.get("c.toggleDetail");
                    // actionD.setCallback(this, function(responseD) {
                    //     var stateD = responseD.getState();
                    //     if (stateD === "SUCCESS") {
                    //         // console.log(stateD);
                    //     } else if (stateD === "ERROR") {
                    //         // console.log(stateD);
                    //     }
                    // });
                    // $A.enqueueAction(actionD); 
                    // component.set('v.afterSave',[]);
                    //self.toast('success', ' 검색이 완료되었습니다.');
                // }
            
            // } else {
                // self.toast('error', ' 검색결과가 없습니다.');
            // }
            
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
            if (typeof callback === 'function') callback();
        });
    }
    
})