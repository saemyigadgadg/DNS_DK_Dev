/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-15
 * @last modified by  : KyongyunJung@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-06-2024   youjin.shim@sbtglobal.com   Initial Version
 * 1.1   12-02-2024   Daewook.KIM                 doSearch 
**/
({
    doInit : function(component, event, helper) {
        // 날짜 초기값 셋팅
        let eDay      = new Date();
        let sDay      = new Date();
        sDay.setDate(1);

        let endDate   = helper.dayCount(eDay);
        let startDate = helper.dayCount(sDay);

        component.set('v.endDate', endDate);
        component.set('v.startDate', startDate);

        // 사용자 정보 셋팅
        var action = component.get('c.GetUserInfo');
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === 'SUCCESS') {
                console.log('!! 부품 오더 조회 시작 !!');
                var dealerInfo = response.getReturnValue();            
                component.set('v.dealerInfo', dealerInfo); 
                
                if(dealerInfo.userProfile == 'DNSA CS Parts_Partner'){
                    component.set('v.isDNSA',true);
                    component.set('v.orderType', 'YDOR');
                }
                console.log('오더 조회 유저 정보 :: ' + JSON.stringify(component.get('v.dealerInfo'), null, 4));

                // 생성 후 조회로 돌아와 검색할 때 사용되는 로직 = partOrderNo 값 확인
                const partOrderNo = localStorage.getItem('partOrderNo');
                if (partOrderNo) {
                    console.log('오더 생성시 실행되는 로직.')
                    component.set('v.partOrderNo', partOrderNo);
                    localStorage.removeItem('partOrderNo');

                    // doSearch 호출
                    var search = component.get('c.doSearch');
                    $A.enqueueAction(search);
                }
                
            }else if(status === 'ERROR') {
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message) {
                    console.log('실패 사유: ' + errors[0].message);
                }else {
                    console.log('알수없는 오류가 발생했습니다.');
                }
            }
        })
        $A.enqueueAction(action);

    },

    // 속성 이름과 값 매칭
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },
    
    // 오더 생성 화면 이동 버튼
    doOrderCreate : function (component, event, helper) {
        component.set('v.isLoading', true);
        const navOrderCreate = component.find("navOrderCreate");
        const page = {
            type: "standard__webPage",
            attributes: {
                // url: "/order-create",
                url: "/partners/s/order-create",
            }
        };
        navOrderCreate.navigate(page);
        component.set('v.isLoading', false);
    },

    // 오더 조회 기능
    doSearch : function(component, event, helper) {
        var searchType = component.get('v.isType');
        console.log('searchType :: ' +searchType);

        component.set('v.isLoading', true);

        var dealerInfo       = component.get('v.dealerInfo')        // 유저정보 
        , partOrderNo        = component.get('v.partOrderNo')       // 주문번호
        , customerOrderNo    = component.get('v.CustomerOrderNo')   // 고객주문번호
        , orderType          = component.get('v.orderType')         // 주문유형
        , startDate          = component.get('v.startDate')         // 시작 기간
        , endDate            = component.get('v.endDate');          // 종료 기간
        var result = helper.dayCounter(startDate, endDate);

        // 날짜 조건
        if (result > 180) {
            helper.toast('WARNING',  $A.get("{!$Label.c.ORI_E_MSG_1}")); //검색 기간은 180일을 초과할 수 없습니다.
            component.set('v.isLoading', false);
            return ;
        } else if (result < 0) { 
            helper.toast('WARNING', $A.get("{!$Label.c.ORI_E_MSG_2}")); //종료 일자가 시작 일자보다 빠를 수 없습니다.
            component.set('v.isLoading', false);
            return ;
        }

        var purchaseOrderTerm = {
            dealerInfo      : dealerInfo,
            partOrderNo     : partOrderNo,
            customerOrderNo : customerOrderNo,
            orderType       : orderType,
            startDate       : startDate,
            endDate         : endDate,
        };

        helper.apexCall(component, 'GetPurchaseOrderList', {poTerm : purchaseOrderTerm})
        .then($A.getCallback(function(result){
            let response = result.r;
            if(response.oiList.length > 0) {
                component.set('v.isSearched', true);
                component.set('v.partOrderRecords', response.oiList);
                component.set("v.totalItemQuantity", response.totalItemsQuantity);
                component.set("v.totalItemsAmount" , response.totalItemsAmount);
            } else {
                helper.toast('SUCCESS',$A.get("{!$Label.c.service_msg_validation_011}")); //검색 결과를 찾을 수 없습니다.
                component.set('v.partOrderRecords', []);
                component.set("v.totalItemQuantity", 0);
                component.set("v.totalItemsAmount" , 0);
            }
            component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            if(errors && errors[0] && errors[0].message) {
                console.log('errors :: ' + errors[0].message);
            }else {
                console.log('errors :: errors???');
            }
        }))
    },

    // Order Detail Information Modal (오더 상세 모달)
    detailModal: function(component, event, helper) {
        console.log('주문번호 상세창!!');
        component.set('v.isLoading', true);

        var clickedElement = event.currentTarget;
        var partOrderNo = clickedElement.getAttribute("data-partOrderNo"); // 선택한 (부품)주문번호
            
        console.log('partOrderNo :: 오더 조회 :: '+JSON.stringify(partOrderNo,null,4))

        $A.createComponent("c:DN_PurchaseOrderDetail",
            {
                "partOrderNo" : partOrderNo,
                "Type"        : 'OrderInquiry'
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    component.set('v.isLoading', false);
                    var container = component.find("PurchaseOrderDetail");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );             
    },

    // 이벤트 모달에서 검색 값 가져오기(받을 값은 없지만)
    handleCompEvent: function(component, event, helper) {
        var modalName = event.getParam("modalName");
        var message   = event.getParam("message");

        component.set('v.partOrderNo', message)
    },
})