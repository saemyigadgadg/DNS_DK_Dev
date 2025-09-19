/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-06-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-15-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({  

    init: function(component, event, helper) {
        helper.getUrlParams(component);
        window.setTimeout(
            $A.getCallback(function() {
                var machineName = component.get('v.machineName');
                var assetName = component.get('v.assetName');
    
                // machineName과 assetName이 있을 때만 doSearch 실행
                if (machineName && assetName) {
                    helper.doSearch(component, event, helper);
                }
            }), 500
        );
    },
    
    // 기종모달
    openModelModal: function (component, event, helper) {
        component.set("v.isLoading", true);

        var type = '기종';
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

        var type = '장비번호';
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

    // 기종 지우기
    clearMachine: function (component, event, helper) {
        let machineName = component.get("v.machineName");
        if (!machineName) {
            helper.toast("WARNING", "저장된 기종 값이 없습니다."); // 기종 값이 없을 때 알림
            return;
        }
        component.set("v.machineName", "");
        component.set("v.assetName", "");
    },
    
    //장비번호 지우기
    clearAsset : function (component, event, helper) {
        let assetName = component.get("v.assetName");
        if (!assetName) {
            helper.toast("WARNING", "저장된 장비번호 값이 없습니다."); // 장비번호 값이 없을 때 알림
            return;
        }
        component.set("v.assetName", "");
    },


    // 모달 이벤트 핸들러
    handleCompEvent :function (component, event, helper) {
        let modalName = event.getParam("modalName");
        let actionName = event.getParam("actionName");
        let message = event.getParam("message");
        console.log(JSON.stringify(message),'<===message');
        if (modalName == 'DN_customerSearchModal') {
            component.set('v.customerInfo', message);
        } else if(modalName == 'DN_dealerModal') {
            component.set('v.workCenterInfo', message);
        } else if (modalName == 'MachineModal') {
            component.set("v.machineName", message.label);
            component.set('v.assetName', "");
            component.set('v.assetData', "");
        } else if(modalName == 'SerialModal') {
            component.set("v.assetName", message.label);
            component.set("v.machineName", message.machineName);
            
            let assetId = message.value;

            if (!assetId) {
                helper.toast('WARNING', 'Please select unit information.');
                return;
            }        
            // helper.apexCall(component, event, helper, 'searchByAssetName', { assetId })
            // .then($A.getCallback(function(result) {
            //     let r = result.r;
            //     console.log('response ::: ', JSON.stringify(r, null, 2));
        
            //     if(r.flag == 'success' && r.assetData != null) {
            //         // helper.toast('SUCCESS', 'Request creation was successful');
            //         component.set('v.assetData', r.assetData);
            //     } else {
            //         helper.toast('WARNING', 'An error occurred, please contact your administrator.');
            //     }
            // }))
            // .catch(function(error) {
            //     helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            //     console.log('# requestcustomerId error : ' + error.message);
            //     component.set('v.isLoading', false);
            // });
        }
        
        if (actionName === 'Close') {
            helper.closeModal(component);
        }
    },

    // 검색
    doSearch : function(component, event, helper) {
        console.log('---------search---------')
        var machineName = component.get('v.machineName'); // 기종
        var assetName = component.get('v.assetName');
        var isLoading = component.get("v.isLoading");

        // 기종 미선택시 경고문
        if (machineName == null || machineName == '') {
            helper.toast('WARNING', '기종을 선택해 주세요.');
            return ;
        }
        // 호기 미선택시 경고문
        if (assetName == null || assetName == '') {
            helper.toast('WARNING', '장비번호를 선택해 주세요.');
            return ;
        }

        component.set("v.isLoading", true)
        console.log("isLoading", isLoading);

        helper.apexCall(component, event, helper, 'getShippingInstructionInfo', {
            machineName : machineName,
            assetName : assetName,
        })
        .then($A.getCallback(function(result) {
            // no data
            let oReturn = result.r.O_RETURN;
            if(oReturn.TYPE =='E') {
                helper.toast('ERROR', oReturn.MESSAGE);
                component.set('v.equipment',{});
                component.set('v.isLoading', false);
                return;
            } else {
                // 출하지시서 Info
                component.set('v.equipment',result.r);
            }
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

})