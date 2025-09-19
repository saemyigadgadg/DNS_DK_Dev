/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-28-2025
 * @last modified by  : daewook.kim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-05-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        // 날짜 초기값 셋팅
        let eDay      = new Date();
        let sDay      = new Date();
        sDay.setDate(eDay.getDate() - 90);

        let endDate   = helper.dayCount(eDay);
        let startDate = helper.dayCount(sDay);

        component.set('v.endDate', endDate);
        component.set('v.startDate', startDate);        
        
        // 사용자 정보 셋팅
        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            let response = result.r;
            component.set('v.dealerInfo', response);

            // 생성 후 조회 로직
            const caseNumber = localStorage.getItem('caseNo');

            if (caseNumber) {
                console.log('납품후교육 생성 후 실행되는 로직.');
                component.set('v.caseNo', caseNumber);
                localStorage.removeItem('caseNo');

                // doSearch 호출
                var search = component.get('c.doSearch');
                $A.enqueueAction(search);
            }
        }))            
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.log('에러 발생 사유 :: ' + errors[0].message);
            } else {
                console.log('에러 발생 사유 :: 알 수 없음');
            }
        }))
    },

    // 납품 후 교육 조회
    doSearch : function(component, event, helper) {
        component.set("v.isLoading", true);
        
        var dealerInfo = component.get('v.dealerInfo');
        var erpPSONo = component.get('v.erpPSONo');
        var accId    = component.get('v.accId');
        var machineName = component.get('v.machineName');
        var assetName = component.get('v.assetName');
        var caseNo = component.get('v.caseNo');
        var startDate = component.get('v.startDate');
        var endDate = component.get('v.endDate');

        helper.apexCall(component, 'GetTicketInfo', {
            dealerInfo : dealerInfo,
            erpPSONo : erpPSONo,
            accId    : accId,
            caseNo   : caseNo,
            machineName : machineName,
            assetName : assetName,
            startDate : new Date(startDate).toISOString(),
            endDate   : new Date(new Date(endDate).setDate(new Date(endDate).getDate() + 1)).toISOString()

        })
        .then($A.getCallback(function(result) {
            component.set("v.isLoading", false);
            let response = result.r;
            console.log('response :: ' + JSON.stringify(response,null,4));
            component.set('v.isSearched', true);
            if (response.length == 0) {
                helper.toast('SUCCESS', '검색결과가 없습니다.');
                component.set('v.ticketList', '');
                return
            } else {
                var ticketList = helper.processResponse(component, response);
                console.log('ticketList :: ' +JSON.stringify(ticketList,null,4))
                component.set('v.ticketList', ticketList);
            }
        }))
        .catch($A.getCallback(function(errors) {
            component.set("v.isLoading", false);
            if(errors && errors[0] && errors[0].message) {
                helper.toast('ERROR','반복되면 관리자에게 문의 부탁 드립니다.')
                console.log('에러메세지 :: '+errors[0].message);
            }else {
                console.log('errors :: ?????');
            }

        }))
    },    

    // 납품 후 교육 생성 열기 
    // 기존코드
    /*createTraining : function (component, event, helper) {
        component.set('v.isLoading', true);
        const navTrainingCreate = component.find("navTrainingCreate");
        const page = {
            type: "standard__webPage",
            attributes: {
                url: "/post-delivery-training-request",
            }
        };
        navTrainingCreate.navigate(page);
        component.set('v.isLoading', false);
    },*/


    // 납품 후 교육 생성 열기 (메인오그/딜러포탈 모두 적용)
    createTraining : function(component, event, helper) {
        component.set('v.isLoading', true);
        const navService = component.find("navTrainingCreate");
        const path = window.location.pathname;

    // 1) 메인 오그 (Lightning Experience)
        if (!path.includes('/s/')) {
            navService.navigate({
                type: 'standard__navItemPage',
                attributes: {
                    apiName: 'DN_postDeliveryTrainingRequest'
                }
            });
        }
    // 2) 딜러포탈 (Experience Cloud)
        else {
            navService.navigate({
                type: 'standard__webPage',
                attributes: {
                    url: '/post-delivery-training-request'
                }
            });
        }
         component.set('v.isLoading', false);
    },

    //납품 후 교육 조회
    searchTraining : function (component, event, helper) {
        const element = event.currentTarget;
        console.log("element", element);
        element.classList.add("visited");

        const caseNumber = event.target.dataset.case;
        localStorage.setItem('caseNo', caseNumber);

        /* 기존 코드
        const url = `post-delivery-training-search?orderNumber=${caseNumber}`;
        window.open(url, "_blank");
        */


        // 딜러포탈 / 메인오그 분기
        const path = window.location.pathname;
        
        if (!path.includes('/s/')) {
            component.find('navTrainingList').navigate({
                type: 'standard__navItemPage',
                attributes: { apiName: 'DN_postDeliveryTrainingSearch' },
                state: { c__orderNumber: caseNumber }
               });
        } else {
                const url = `post-delivery-training-search?orderNumber=${caseNumber}`;
                window.open(url, "_blank");
        }

    },

    //수주번호 모달 열기
    openOrderListModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        let eduTicket = true;
        var dealerInfo = component.get('v.dealerInfo');

        console.log('dealerInfo :: ' + JSON.stringify(dealerInfo,null,4));
    
        $A.createComponent("c:DN_OrderListModalforServiceHistoryResult",
                {'eduTicket'  : eduTicket,
                  'dealerInfo' : dealerInfo
                },
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
            var container = component.find("OrderListModal");
            container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);

    },

    // 기종모달
    openModelModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        // var rowIndex = event.getSource().get('v.accesskey');
        var type = '기종';
        // component.set('v.selectedModelIndex', Number(rowIndex));
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 장비번호 모달 
    openSerialNumberModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        let machineName = component.get("v.machineName");
        // var rowIndex = event.getSource().get('v.accesskey');
        var type = '장비번호';
        // component.set('v.selectedModelIndex', Number(rowIndex));
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type,
                'MachineName' : machineName
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    //고객 모달 열기
    openCustomerListModal : function(component, event, helper){
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_CustomerListModalforSalesServiceHistory",
                {},
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
            var container = component.find("CustomerListModal");
            container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);
    },

    // 모달
    handleCompEvent : function(component, event, helper) {
        var modalName = event.getParam("modalName");
        var actionName = event.getParam("actionName");
        var message = event.getParam("message");
        console.log("modalName", modalName);
        console.log("message", JSON.stringify(message));
        if (modalName == 'DN_CustomerListModalforSalesServiceHistory') {
            component.set('v.customerInfo', message);
            component.set('v.accName', message.Name);
            component.set('v.accId', message.Id);
        } else if (modalName == 'DN_OrderListModalforServiceHistoryResult') {
            // 수주번호 검색 결과.
            component.set('v.erpPSONo', message.psoNumber);
        } else if (modalName == 'MachineModal') {
            // 기종 검색 결과.
            component.set("v.machineName", message.label);
            component.set('v.assetName', "");
            component.set('v.assetData', "");
        } else if (modalName == 'SerialModal') {
            // 장비번호 검색 결과.
            component.set("v.machineName", message.machineName);
            component.set("v.assetName", message.label);
        } 
    },

    // 오더번호 지우기
    clearOrderNo: function (component, event, helper) {
        let erpPSONo = component.get("v.erpPSONo");
        if (!erpPSONo) {
            helper.toast("WARNING", "저장된 오더번호 값이 없습니다."); // 오더번호 값이 없을 때 알림
            return;
        }
        component.set("v.erpPSONo", "");
        component.set('v.ticketList','');
    },

    // 기종 지우기
    clearMachine: function (component, event, helper) {
        let machineName = component.get("v.machineName");
        if (!machineName) {
            helper.toast("WARNING", "저장된 기종 값이 없습니다."); // 기종 값이 없을 때 알림
            return;
        }
        component.set("v.machineName", "");
        component.set('v.ticketList','');
    },

    //장비번호 지우기
    clearAsset : function (component, event, helper) {
        let assetName = component.get("v.assetName");
        if (!assetName) {
            helper.toast("WARNING", "저장된 장비번호 값이 없습니다."); // 장비번호 값이 없을 때 알림
            return;
        }
        component.set("v.assetName", "");
        component.set('v.ticketList','');
    },

    //고객사명 지우기
    clearCustomerName : function (component, event, helper) {
        let customerCode = component.get("v.accName");
        if (!customerCode) {
            helper.toast("WARNING", "저장된 고객사명 값이 없습니다."); // 고객코드 값이 없을 때 알림
            return;
        }
        // let customerInfo = component.get("v.customerInfo");
        // customerInfo.CustomerCode__c = "";
        component.set("v.accName", "");
        component.set('v.ticketList','');
    },

    
    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        table1.scrollTo({ top: scrollY, left: 0, behavior: 'auto' });
    },

    // 속성 이름과 값 매칭
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },    
})