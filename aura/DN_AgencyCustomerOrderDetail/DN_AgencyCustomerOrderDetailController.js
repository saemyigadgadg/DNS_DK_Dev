/**
 * @author            : Jun-Yeong Choi
 * @Description       : 
 * @last modified on  : 12-27-2024
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        // window.addEventListener('popstate', $A.getCallback(function(event) {
        //     window.sessionStorage.setItem('isBack','true');
        //     // 추가 동작 가능
        // }));
        helper.gfnDoinit(component,event);
    },

    selectAll: function (component, event, helper) {
        let isChecked = component.find("headerCheckbox").get("v.checked");
        let partsList = component.get('v.orderDetailList');

        partsList.forEach(part=>{
            if(!part.isComplete)
                part.isSelected = isChecked;
        });
        component.set('v.orderDetailList', partsList);
        // 모든 체크박스의 상태를 변경합니다.
        // if (isChecked == true) {
        //     if (Array.isArray(checkboxes)) {
        //         checkboxes.forEach(function (checkbox, index) {
        //             checkbox.set("v.checked", isChecked);
        //         });
        //     } else {
        //         checkboxes.set("v.checked", isChecked);
        //     }
        // } else {
        //     if (Array.isArray(checkboxes)) {
        //         checkboxes.forEach(function (checkbox) {
        //             checkbox.set("v.checked", isChecked);
        //         });
        //     } else {
        //         checkboxes.set("v.checked", isChecked);
        //     }
        // }
        // component.set('v.selectedOrder', plist);
        // var selectedOrder = component.get('v.selectedOrder');
        // console.log('selectedOrd:', JSON.stringify(selectedOrder));
    },

    orderDetailCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    // 출고 페이지로 이동
    moveGoodsIssueConfrim : function (component, event, helper) {
        let selectedOrder = helper.gfnSelectedOrderItem(component);
        if (selectedOrder.length < 1) {
            helper.showMyToast('Error', '항목을 선택하세요.');
        } else {
            component.set('v.confirmModal', true);
            component.set('v.confirmGi', true);
        }
    },

    // 본사 오더 페이지로 이동 확인
    moveDNOrdeConfrim : function (component, event, helper) {
        let selectedOrder = helper.gfnSelectedOrderItem(component);
        if (selectedOrder.length < 1) {
            helper.showMyToast('Error', '항목을 선택하세요.');
        } else {
            component.set('v.confirmModal', true);
            component.set('v.confirmDn', true);
        }
    },

    // 타 대리점 주문 페이지로 이동 확인
    moveDealerOrderConfrim : function (component, event, helper) {
        let selectedOrder = helper.gfnSelectedOrderItem(component);
        if (selectedOrder.length < 1) {
            helper.showMyToast('Error', '항목을 선택해주세요.');
        } else {
            component.set('v.confirmModal', true);
            component.set('v.confirmOtherDealer', true);
        }
    },

    // 오더 수정 페이지로 이동
    editOrder: function (component, event, helper) {
        let selectedOrder = helper.gfnSelectedOrderItem(component);
        if (selectedOrder.length < 1) {
            component.set('v.confirmModal', true);
            component.set('v.editOrder', true);    
            component.set('v.editMessage', '주문서를 변경하시겠습니까?');
        } else {
            helper.showMyToast('Error', '체크 박스에 체크를 모두 해제해주세요.')
        }
    },

    // 출고 페이지로 이동 취소
    cancelGi: function (component, event, helper) {
        component.set('v.confirmGi', false);
        component.set('v.confirmModal', false);
    },

    // 출고 페이지 페이지로 이동
    moveGi: function (component, event, helper) {
        let selectedItemList = helper.gfnSelectedOrderItem(component).map((orderItem)=>orderItem.itemId);
        helper.gfnMoveCustomPage(component, 'OrderShipment__c', {
            c__dealerorderItems: selectedItemList.join(),
            c__isAll : true
        });
    },

    // 본사 오더 페이지로 이동 취소
    cancelDnOrder: function (component, event, helper) {
        component.set('v.confirmDn', false);
        component.set('v.confirmModal', false);
    },

    // 본사 오더 생성 페이지로 이동
    moveDnOrder: function (component, event, helper) {
        let selectedItemList = helper.gfnSelectedOrderItem(component).map((orderItem)=>orderItem.partName);
        let selectedItemQty = helper.gfnSelectedOrderItem(component).map((orderItem)=>orderItem.quantity);
        console.log(JSON.stringify(selectedItemList),' ::: selectedItemList');
        console.log(JSON.stringify(component.get('v.orderDetailList')) ,' test111');
        helper.gfnMoveCustomPage(component, 'custom_dns_order_create__c', {
            c__parts: selectedItemList.join(),
            c_QTY : selectedItemQty.join(),
        });
    },

    // 타 대리점 주문 페이지로 이동 취소
    cancelOtherDealer: function (component, event, helper) {
        component.set('v.confirmOtherDealer', false);
        component.set('v.confirmModal', false);
    },

    // 타 대리점 주문 페이지로 이동
    moveOtherDealer: function (component, event, helper) {
        let selectedItemList = helper.gfnSelectedOrderItem(component).map((orderItem)=>orderItem.itemId);
        helper.gfnMoveCustomPage(component, 'CreateAnotherAgencyPurchase__c', {
            c__dealerorderItems: selectedItemList.join()
        });
    },

    // 수정 페이지로 이동 취소
    cancelEditOrder: function (component, event, helper) {
        component.set('v.editOrder', false);
        component.set('v.confirmModal', false);
    },

    // 수정 페이지로 이동
    moveEditOrder: function(component, event, helper) {
        var orderDetailList = component.get('v.orderDetailList');

        var orderDetailListString = JSON.stringify(orderDetailList);

        var navService = component.find("navService");
        var pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: 'CustomerOrderCreate__c'
            },
            state: {
                orderDetailList: orderDetailListString,
                orderId: 'abc123'
            }
        };
        // component.set("v.pageReference", pageReference);
        var defaultUrl = "#";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set("v.url", url ? url : defaultUrl);
            }), $A.getCallback(function(error) {
                component.set("v.url", defaultUrl);
            }));

        event.preventDefault();
        navService.navigate(pageReference);
    },
    
    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        table1.scrollTo({ top: scrollY, left: 0, behavior: 'auto' });
    },
})