/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 05-28-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-31-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({

    doInit: function (component, event, helper) {
        //디폴트 쿼리 설정
        helper.setQuery(component);

        window.addEventListener("resize", $A.getCallback(function () {
            helper.updateTableHeight(component, component.get("v.isOpen"));
        }));
    },

    // handleScroll: function (component, event, helper) {
    //     var table2 = event.target;
    //     var scrollY = table2.scrollTop;
    //     var table1 = component.find('leftTableDiv').getElement();
        
    //     let now = Date.now();
    //     let lastCall = component.get("v._lastScrollCall") || 0;

    //     // 300ms마다만 실행되게 throttle
    //     if (now - lastCall < 300) {
    //         return;
    //     }

    //     component.set("v._lastScrollCall", now);

    //     setTimeout(() => {
        	
    //         if( (table2.scrollTop + table2.clientHeight) >= table2.scrollHeight) {
    //         	helper.loadMoreItems(component);
    //     	}    
    //     }, 300); // 300ms 정도 지연
        
    //     // if(table2.scrollTop >= (table2.scrollHeight - 20)) {
    //     //     helper.loadMoreItems(component);
    //     // }
    //     // if (table2.scrollTop + table2.clientHeight >= table2.scrollHeight - 20) {
    //     //     helper.loadMoreItems(component);
    //     // }

    //     // x축 스크롤 값을 유지
    //     var scrollX = table1.scrollLeft;
    //     table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });

    // },

    handleScroll: function (component, event, helper) {
        const table2 = event.target;
        const scrollY = table2.scrollTop;
    
        const table1 = component.find('leftTableDiv').getElement();
        table1.scrollTop = scrollY;
        let pervious =  component.get('v._prevScrollY') || 0;
        if(table1.scrollTop !== pervious) {
            const now = Date.now();
            const lastCall = component.get("v._lastScrollCall") || 0;
            const isLoading = component.get("v.isLoading") || false;
        
            if (now - lastCall >= 300 && !isLoading) {
                const nearBottom = (table2.scrollTop + table2.clientHeight) >= (table2.scrollHeight - 50);
        
                if (nearBottom) {
                    component.set("v._lastScrollCall", now);
                    component.set("v.isLoading", true);
        
                    helper.loadMoreItems(component, () => {
                        component.set("v.isLoading", false);
                    });
                }
            }
        }
        
    }
    ,
    

    toggleDetail: function (component, event, helper) {
        if (component.get('v.selectList').length > 0) {
            var isOpen = !component.get("v.isOpen");
            component.set("v.isOpen", isOpen);
            helper.updateTableHeight(component, isOpen);

            if (isOpen) {
                helper.getDetailList(component);
            }
        } else {
            helper.toast('error', '오더를 선택해주세요.');
        }
    },

    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            // console.log(" setSubscriptionLMC");
            // console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach':
                    helper.getDataList(component);
                    break;
                default:
                    break;
            }  
        }
    },
    // 체크박스 선택
    // handleSelect: function (component, event, helper) {
    //     console.log(event);
    //     let current = event.getSource();//.get("v.value"); //let check = event.getSource().get("v.checked");
    //     let select = component.get('v.selectList');
    //     let allData = component.get('v.partsList');
    //     let checkbox = component.find('checkbox');
       
    //     if(current.get("v.checked")) {
    //         component.set('v.selectList', allData[current.get('v.name')]);
    //         if(allData.length>1){
    //             checkbox.forEach(function (checkbox, index) {
    //                 if(index != current.get('v.name')) {
    //                     checkbox.set('v.disabled', true);
    //                 }
    //             });
    //         }
    //     } else {
    //         if(allData.length>1){
    //             component.set('v.selectList', []);
    //             checkbox.forEach(function (checkbox, index) {
    //                 checkbox.set('v.disabled', false);
    //             });
    //         }
    //         component.set('v.isOpen', false);
          
    //     }
    // },

    handleSelect: function (component, event, helper) {
        let current = event.getSource(); 
        let allData = component.get('v.partsList');
        let buttons = component.find('selectButton'); 
        let selectedIndex = current.get('v.name');
        let currentIcon = current.get('v.iconName'); 
    
        // 모든 버튼을 초기화
        if (Array.isArray(buttons)) {
            buttons.forEach(button => {
                button.set('v.iconName', "utility:record"); 
                button.set('v.variant', "");
            });
        } else {
            buttons.set('v.iconName', "utility:record");
            buttons.set('v.variant', "");
        }
    
        // 선택된 항목에 대한 처리
        if (currentIcon === "utility:record") { 
            component.set('v.selectList', allData[selectedIndex]);
            current.set('v.iconName', "utility:check"); 
            current.set('v.variant', "brand"); 
        } else {
            component.set('v.selectList', []);
            current.set('v.iconName', "utility:record");
            current.set('v.variant', "");
        }
    
        // 선택한 행에 class 넣기
        let rows = component.find('table-row');
        rows.forEach((row, index) => {
            let rowElement = row.getElement();  
            let cells = rowElement.getElementsByTagName('td'); 
            
            if (index === selectedIndex) {
                for (let cell of cells) {
                    $A.util.addClass(cell, 'choice');
                    $A.util.removeClass(cell, 'non-choice');
                }
            } else {
                for (let cell of cells) {
                    $A.util.addClass(cell, 'non-choice');
                    $A.util.removeClass(cell, 'choice');
                }
            }
        });
    
        //오른쪽 테이블에도 동일하게 넣기
        let rightRows = component.find('rightTableRow');
        rightRows.forEach((row, index) => {
            let rowElement = row.getElement(); 
            let cells = rowElement.getElementsByTagName('td'); 
    
            if (index === selectedIndex) {
                for (let cell of cells) {
                    $A.util.addClass(cell, 'choice');
                    $A.util.removeClass(cell, 'non-choice');
                }
            } else {
                for (let cell of cells) {
                    $A.util.addClass(cell, 'non-choice');
                    $A.util.removeClass(cell, 'choice');
                }
            }
        });
    
        // isOpen이 true이면 getDetailList 다시 실행
        if (component.get("v.isOpen")) {
            helper.getDetailList(component);
        }
    },
    
    
    
    

    handleReturn: function (component, event, helper) {
        let self = this;
        let isDetail = component.get('v.isOpen');
        if(!isDetail) {
            helper.toast('error', 'Detail을 확인 후 반품처리 해주세요.');
            return;
        }
        let seleted = component.get('v.selectList');
        // console.log('handleReturn');
        let serviceLength = component.get('v.serviceOrder');
        let notiLength    = component.get('v.notification');
        let claimLength   = component.get('v.domesticClaim');
     
        // console.log(JSON.stringify(component.get('v.selectList')),' test');

        if( seleted[0].status=='3') {
            helper.toast('error', '상태가 삭제 경우 반품이 불가능합니다.');
            return;
        }
        if(seleted[0].status=='5') {
            helper.toast('error', '상태가 정산완료인 경우 반품이 불가능합니다.');
            return;
        }
        // console.log('dddd');
        if(!(serviceLength.length > 0 && notiLength.length > 0)){
            helper.toast('error', '반품이 불가능합니다.');
            return;
        }
        // console.log('dddxxxd');
        if(serviceLength.length > 0){
            // console.log('serviceOrder');
            let so = component.find('ServiceOrder');
            let soChecked;
            
            if(Array.isArray(so)) {
                soChecked = so.some(order => order.get('v.checked') === true); 
            }else {
                soChecked = so.get('v.checked')
            }

            if (!soChecked) {
                helper.toast('error', 'Service Order Component를 선택해주세요.');
                return;
            }
        }
        // console.log('ddssssdxxxd');
        if(notiLength.length > 0){
            let noti = component.find('Notification');
            let notiChecked;
            if(Array.isArray(noti)) {
                notiChecked = noti.some(notiL => notiL.get('v.checked') === true); 
            }else {
                notiChecked = noti.get('v.checked');
            }

            if(!notiChecked) {
                helper.toast('error', 'Notification Parts Info를 선택해주세요.');
                return;
            }
        }
        // console.log('cccc');
        if(claimLength.length > 0){
            let doClaim = component.find('DomesticClaim');
            let doChecked;
            if(Array.isArray(doClaim)) {
                doChecked = doClaim.some(doL => doL.get('v.checked') === true); 
            }else {
                doChecked = doClaim.get('v.checked');
            }
            if(!doChecked) {    
                helper.toast('error', 'Domestic Claim Parts Use History를 선택해주세요.');
                return;
            }
        }
        
        helper.addReturn(component, event);
        
    },

    handlePartition: function (component, event, helper) {
        
        let self = this;
        let isDetail = component.get('v.isOpen');
        if(!isDetail) {
            helper.toast('error', 'Detail을 확인 후 수량분할 처리해주세요.');
            return;
        }

        let seleted = component.get('v.selectList');
        // console.log(JSON.stringify(component.get('v.selectList')),' test');
       
        let serviceLength = component.get('v.serviceOrder');
        let notiLength    = component.get('v.notification');
        let claimLength   = component.get('v.domesticClaim');
        
        if( seleted[0].reqQty==1) {
            helper.toast('error', 'Req.Qty 개수가 1개 이하는 분할이 불가합니다.');
            return;
        }
        if( seleted[0].status=='3') {
            helper.toast('error', '상태가 삭제 경우 수량분할이 불가능합니다.');
            return;
        }
        if(seleted[0].status=='5') {
            helper.toast('error', '상태가 정산완료인 경우 수량분할이 불가능합니다.');
            return;
        }
        
        if(!(serviceLength.length > 0 && notiLength.length > 0 && claimLength.length > 0)){
            helper.toast('error', '수량분할이 불가능합니다.');
            return;
        }
       
        if(serviceLength.length > 0){
            let serviceOrder  = component.find('ServiceOrder').get('v.checked');
            if(!serviceOrder) {
                helper.toast('error', 'Service Order Component를 선택해주세요.');
                return;
            }
        }

        if(notiLength.length > 0){
            let notification  = component.find('Notification').get('v.checked');
            if(!notification) {
                helper.toast('error', 'Notification Parts Info를 선택해주세요.');
                return;
            }
        }

        if(claimLength.length > 0){
            let domesticClaim = component.find('DomesticClaim').get('v.checked');
            if(!domesticClaim) {    
                helper.toast('error', ' Domestic Claim Parts Use History를 선택해주세요.');
                return;
            }
        }
       
        helper.partition(component, event);
    },

    // 수량분할 모달 닫기
    qtyModalCancel: function (component, event, helper) {
        component.set('v.isQty', false);
        component.set('v.partition1',0);
        component.set('v.partition2',0);
    },

    //수량 분할
    partitionInsert : function (component, event, helper) {
        let partition1 = component.get('v.partition1');
        let partition2 = component.get('v.partition2');
        let reqQty = component.get('v.selectList');//[0].reqQty
        if(reqQty <= partition1 || reqQty <= partition2 || partition2 <=0 || partition1 <=0) {
            helper.toast('error', '분할 수량이 올바르지 않습니다.');
            return;
        }
       
        helper.partitionInsert(component, event);
    },

    // 음수 입력 불가 및 분할 시 수량계산산
    handleChage : function(component, event, helper){
        let value = event.getSource().get("v.value");
        value = value.replace(/[^0-9]/g, ''); 

        let reqQty = component.get('v.selectList');//[0].reqQty
        component.set('v.partition1',value);
        let partitionSet = Number(reqQty[0].reqQty) - Number(component.get('v.partition1'));
        console.log(partitionSet,' :: partitionSet');
        
        component.set('v.partition2',partitionSet);
        console.log(component.get('v.partition2'));
    },
   
})