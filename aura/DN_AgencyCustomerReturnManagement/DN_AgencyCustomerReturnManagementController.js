/**
 * @author            : Jun-Yeong Choi
 * @Description       : 
 * @last modified on  : 2024-06-10
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-03   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {

    },

    // // 고객사명 모달 열기
    // openCustomerList: function (component, event, helper) {
    //     component.set("v.isLoading", true);
    //     $A.createComponent("c:DN_AgencyCustomerListModal",
    //         {},
    //         function (content, status, errorMessage) {
    //             if (status === "SUCCESS") {
    //                 var container = component.find("AgencyCustomerListModal");
    //                 container.set("v.body", content);
    //             } else if (status === "INCOMPLETE") {
    //                 console.log("No response from server or client is offline.")
    //             } else if (status === "ERROR") {
    //                 console.log("Error: " + errorMessage);
    //             }
    //         });
    //     component.set("v.isLoading", false);
    // },

    // //품번 멀티 등록(복사붙여넣기)
    // openCopy: function (component, event, helper) {
    //     $A.createComponent("c:DN_DemandAdjPerAgencyPopupResMultiPart",{},
    //         function (content, status, errorMessage) {
    //             if (status === "SUCCESS") {
    //                 console.log('팝업창');
    //                 var container = component.find("RegisterMultiPartsModal");
    //                 container.set("v.body", content);
    //             } else if (status === "INCOMPLETE") {
    //                 console.log("No response from server or client is offline.")
    //             } else if (status === "ERROR") {
    //                 console.log("Error: " + errorMessage);
    //             }
    //         }
    //     );
    // },

    selectAll: function (component, event, helper) {
        let checkboxes = component.find("checkbox");
        let isChecked = component.find("headerCheckbox").get("v.checked");

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked == true) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
        } else {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set("v.checked", isChecked);
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
        }
    },

    // 이벤트 Catch : 고객사명 모달
    // handleCompEvent: function (component, event, helper) {
    //     var modalName = event.getParam("modalName");
    //     console.log('modalName::', modalName);
    //     var action = event.getParam("action");
    //     var message = event.getParam("message");
    //     console.log('message::', message);

    //     if (modalName == 'DN_AgencyCustomerListModal' && message != '일반고객') {
    //         component.set('v.customerName', message.customerName);

    //     } else if (message == '일반고객') {
    //         component.set('v.customerName', message);
    //     } else if(modalName =='DN_DemandAdjPerAgencyPopupResMultiPart' ) {
    //         console.log(JSON.stringify(message), ' 123121313');
    //         let partsList ="";
    //         message.forEach(element => {
    //             partsList += element +',';
    //         });
    //         component.set("v.partNubmer", partsList);
    //         //message   
    //     }
    // },

    // returnOrderDelete: function (component, event, helper) {
    //     var selectedOrder = component.get('v.selectedOrder');
    //     if(selectedOrder.length < 1) {
    //         helper.showMyToast('Error', '삭제할 데이터를 선택해주십시오.');
    //     } else {
    //         component.set('v.confirmModal', true);
    //         var countOrder = selectedOrder.length;
    //         console.log('countOrder::', countOrder);
    //         component.set('v.countOrder', countOrder);
    //     }
    // },

    cancelDelete: function (component, event, helper) {
        component.set('v.confirmModal', false);
    },

    confirmDelete: function (component, event, helper) {
        helper.gfnDeleteReturnOrder(component, event);
        // component.set('v.confirmModal', false);
        // helper.showMyToast('Success', '삭제되었습니다.');
    },


    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(`${component.getName()}.setSubscriptionLMC`);
            console.log(JSON.stringify(message));
           
            switch (params.cmpName) {
                case 'dN_DealerPortalFilter':
                    if(params.type ==='filterChange' || params.type === 'defaultFilter') {
                        let headerParams = component.get('v.headerParams');
                        if(!!!headerParams) headerParams = {};

                        console.log('type : filterChange');
                        let isArray = Array.isArray(params.message);
                        
                        if(isArray) {
                            [...params.message].forEach((headerParam)=>{
                                headerParams[headerParam.field] = headerParam.value;
                            });

                        }else {
                            headerParams[params.message.field] = params.message.value;
                        }
                        component.set('v.headerParams', headerParams);
                    }
                    break;
                    
                case 'dN_DealerPortalButton':
                    if(params.type === 'Seach') {
                        console.log('Seach');
                        helper.gfnSearchReturnOrder(component, null, 'Search');
                    }else if(params.type === 'Delete') {
                        console.log('type : Delete');

                        let returnOrderList = component.get('v.returnOrderList').filter((returnOrder)=> returnOrder.isSelected);

                        if(returnOrderList.length < 1) {
                            helper.toast('Error', '선택된 품목이 없습니다.')
                            return ;
                        }

                        component.set('v.countOrder', returnOrderList.length);
                        component.set('v.confirmModal', true);
                        // helper.gfnDeleteReturnOrder(component, null);
                    }
                    break;
                
                case 'dN_DealerPortalQueryPage':
                    console.log('dN_DealerPortalQueryPage');
                    console.log(JSON.stringify(params), ' msg');
                    component.set('v.nextPage',    params.message.nextpage);
                    component.set('v.currentPage', params.message.currentPage);
                    // helper.gfnSearchReturnRequestOrder(component, null, 'PageChange');
                    break;  
            }
        }
    },

})