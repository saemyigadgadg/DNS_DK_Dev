/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-04-13
 * @last modified by  : chungwoo.lee@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-08-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({

    doInit : function (component, event, helper) {
        helper.apexCall(component, event, helper, 'getLoginUserInfo', {
        })
        .then($A.getCallback(function(result) {
            console.log(JSON.stringify(result),' < ===responseData');
            component.set('v.WorkCenter', {
                Name : result.r.workerInfo.Service_Territory__r.Name,
                CustomerCode : result.r.workerInfo.Service_Territory__r.WCCode__c,
                Plant : result.r.workerInfo.RelatedRecord.Plant__c
            })
            // CustomerCode : result.r.workerInfo.RelatedRecord.Account.CustomerCode__c,
            const todaySet = new Date();
            const msInADay = 24 * 60 * 60 * 1000;
            const firstDayOfMonth = new Date(Date.UTC(todaySet.getFullYear(), todaySet.getMonth(), 1));
            console.log(firstDayOfMonth,' < ==firstDayOfMonth');
            console.log(firstDayOfMonth.toISOString(),' < ==firstDayOfMonthtoISOString()');
            component.find('Start').set('v.value', firstDayOfMonth.toISOString());
            component.find('End').set('v.value',todaySet.toISOString());
        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
        });
    },

    //검색
    doSearch : function (component, event, helper) {
        
        
         // 두 날짜의 차이를 계산 (밀리초 단위)
        const diffInMilliseconds = Math.abs(new Date(component.get('v.startDate')) - new Date(component.get('v.endDate')));
     

        // 밀리초를 연도로 변환
        const diffInYears = diffInMilliseconds / (1000 * 60 * 60 * 24 * 365);
        // 1년 이상인지 확인
        if (diffInYears >= 1) {
            helper.toast("WARNING", "조회기간은 365일 제한입니다."); 
            return;
        } 
        let workCenter = component.get('v.WorkCenter');
        
        console.log(workCenter.CustomerCode,' < ==customerCode');
        
        let searchSet = {
            I_AUART : component.get('v.orderValue'), // CSO2 고정
            I_EQUNR : component.get('v.machineName'), //기종
            I_SERNR : component.get('v.assetName'),  // 장비번호 //I_TYPBZ : '', //호기(장버번호)
            I_RPDAT_F : component.get('v.startDate'), //조회일자
            I_RPDAT_T : component.get('v.endDate'), //조회일자자
            I_AUFNR_F : component.get('v.orderNumStart'), // 오더번호
            I_AUFNR_T : component.get('v.orderNumEnd'), // 오더번호
            I_ARBPL_F : workCenter.CustomerCode, // CRM에 데이터 없어보여서 고정
            I_ARBPL_T : workCenter.CustomerCode,// CRM에 데이터 없어보여서 고정
            I_VBELN_F : component.get('v.partsOrderStart'), // 부품오더더
            I_VBELN_T : component.get('v.partsOrderEnd'), // 부품 오더
            WERKS : workCenter.Plant
            
        };
        console.log(JSON.stringify(searchSet), ' < ===searchSet');

        component.set('v.isLoading', true);
        
        helper.apexCall(component, event, helper, 'getPartsIssuanceStatus', {
            search : searchSet
        })
        .then($A.getCallback(function(result) {
            //component.set('v.orderList', result.r.T_TAB);
            //component.set('v.excelList');
            let orderList = [];
            let excelList = [];
            if(result.r.T_TAB.length > 0 ) {

                console.log(JSON.stringify(result), ' < ====result ');
                
                result.r.T_TAB.forEach(element => {
                    element.AUFNR = element.AUFNR.substring(3,element.AUFNR.length);
                    element.QMNUM = element.QMNUM.substring(3,element.QMNUM.length);
                    element.KWMENG = parseInt(element.KWMENG);
                    element.LFIMG = parseInt(element.LFIMG)
                    element.REQTY = parseInt(element.REQTY)
                    // 출하지시 데이터 설정
                    if(element.VBELN_ST == 'X') {
                        element.VBELN_ST = 'Completely processed';
                        element.VBELN_ST_Icon = 'icon-green';
                    } else {
                        element.VBELN_ST ='';
                        element.VBELN_ST_Icon = 'icon-red';
                    }
                    //출고 데이터 설정
                    if(element.WBSTA_ST =='A') {
                        element.WBSTA_ST= 'Not yet processed';
                        element.WBSTA_ST_Icon = 'icon-red';
                    } else if(element.WBSTA_ST =='B') {
                        element.WBSTA_ST = 'Partially processed.';
                        element.WBSTA_ST_Icon = 'icon-orange';
                    } else if(element.WBSTA_ST =='C') {
                        element.WBSTA_ST = 'Completely processed.';
                        element.WBSTA_ST_Icon = 'icon-green';
                    } else {
                        element.WBSTA_ST ='';
                        element.WBSTA_ST_Icon = 'icon-gray';
                    }

                    //재고보유 현황 설정
                    if(element.CALBASE =='In Stock') {
                        element.CALBASE = '재고보유';
                    } else {
                        element.CALBASE = '업체제공 납기일';
                    }
                    let data = {
                        '오더번호' : element.AUFNR,
                        '접수번호': element.QMNUM,
                        '부품 오더': element.VBELN,//부품오더
                        '생성일자': element.AUDAT,
                        '항목' : element.POSNR,
                        '품목' : element.MATNR,
                        '내역' : element.MAKTX,
                        '수량' : element.KWMENG,
                        '단위' : element.MEINS,
                        '공급 가능 일자' :element.PRETD,
                        '산출 근거' : element.CALBASE,
                        '출고 수량' : element.LFIMG,
                        '잔여량' : element.REQTY,
                        '출하지시' : element.VBELN_ST,
                        '출고' :element.WBSTA_ST,
                        '실 출고일' : element.WADAT,
                    }
                    excelList.push(data);
                    
                });
                helper.toast("SUCCESS", "조회되었습니다.");
                component.set('v.orderList', result.r.T_TAB);
                component.set('v.excelList', excelList);
                console.log(JSON.stringify(excelList), ' < ==excelList');
            } else {
                helper.toast("WARNING", "해당 검색에 조회건이 없습니다."); // 데이터가 없을시
                component.set('v.orderList', []);
                component.set('v.isLoading', false);
                return;
            
            }
            
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
           console.log(error + ' <M ===error');
           component.set('v.isLoading', false);
        });
    },


    // 기종모달
    openModelModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        // 해당 컴포넌트에서 row 정보 필요시 사용.
        // var rowIndex = event.getSource().get('v.accesskey');
        // component.set('v.selectedModelIndex', Number(rowIndex));

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
        
        // 해당 컴포넌트에서 row 정보 필요시 사용.
        // var rowIndex = event.getSource().get('v.accesskey');
        // component.set('v.selectedModelIndex', Number(rowIndex));

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

    //스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },
})