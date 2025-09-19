/**
 * @description       : (포탈) 부품 정보 > 부품 기본 정보 조회
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 2025-09-10
 * @last modified by  : jiyoung.p@dncompany.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-18-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        console.log('** 사용자 정보 조회 **');

        var action = component.get('c.GetUserInfo');
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === 'SUCCESS') {
                console.log('>> 성공');
                var userResult = response.getReturnValue();
                console.log('---------------------');
                console.log(userResult);
                console.log('---------------------');
                if(userResult.userProfile == 'DNS CS Parts_Partner') {
                    component.set('v.isProfile', true);
                    component.set('v.isCSUser', true);
                    component.set('v.isDNS', true);
                }
                if(userResult.userProfile == 'DNSA CS Parts_Partner') {
                    component.set('v.isCSUser', true);
                }
                component.set('v.userInfo', userResult);

            }else if(status === 'ERROR') {
                console.log('>> 실패');
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message) {
                    console.error('실패 사유: ' + errors[0].message);
                }else {
                    console.error('알수없는 오류가 발생했습니다.');
                }
            }
        })
        $A.enqueueAction(action);
    },

    

    // 검색 버튼
    doSearch : function (component, event, helper) {
        console.log('** 부품 정보 조회 **');
        component.set('v.isLoading', true);
        let userInfo = component.get('v.userInfo');
        var partNo = component.get('v.productNumber');
        partNo = partNo ? partNo.replace(/\s+/g, '') : '';
        var partNo = partNo.trim();

        if (partNo === '' || partNo === undefined || partNo === null) {
            helper.toast('WARNING', $A.get("$Label.c.BPI_E_MSG_1"));// 부품 번호를 입력해 주세요.
            component.set('v.isLoading', false);
            return;
        }
        else {
            var listNo = [partNo];
            helper.apexCall(component, 'SearchPartNo', {pn : listNo})
            .then($A.getCallback(function(result) {
                let response = result.r;
                console.log('product2 result >> ' + JSON.stringify(response,null,4));

                if(response.length == 0) {
                    component.set('v.partInfo', '');
                    component.set('v.replaceName', '');
                    component.set('v.rePartInfo','');
                    component.set('v.partsStock',[]);
                    return Promise.reject({type:'NO_PRODUCT', message: $A.get("$Label.c.BPI_E_MSG_2")});//등록된 제품이 아닙니다.'}); 
                }

                var partName = response[0].Name;
                return helper.apexCall(component, 'SeachPart', {partNo : partName, userInfo : userInfo})
            }))
            .then($A.getCallback(function(result) {
                console.log('>> 성공');
                let response = result.r;
                console.log('response >>>> ' +JSON.stringify(response,null,4))
                let message = response.message.split('.')[0];
                if(message == 'No data found'){
                    component.set('v.partInfo', '');
                    component.set('v.replaceName', '');
                    component.set('v.rePartInfo','');
                    component.set('v.partsStock',[]);
                    return Promise.reject({type:'NO_DATA', message:$A.get("$Label.c.BPI_E_MSG_3")}); //'검색결과가 없습니다.'});
                }
                response.partBasicInfo.stockQuantity = Number(response.partBasicInfo.stockQuantity);
                response.partBasicInfo.stockQuantity2 = Number(response.partBasicInfo.stockQuantity2);

                console.log('response.partBasicInfo > ' + JSON.stringify(response.partBasicInfo,null,4))
                let partInfo = response.partBasicInfo;
                partInfo.consumerPrice = parseInt(partInfo.consumerPrice).toLocaleString()+' '+partInfo.pbiCurrency;
                partInfo.unitPrice = parseInt(partInfo.unitPrice).toLocaleString()+' '+partInfo.pbiCurrency;

                component.set('v.partInfo', response.partBasicInfo);
                var rePartInfo = response.replacementInfo;

                rePartInfo.forEach(e => {
                    e.avilQty = Number(e.avilQty);
                    e.avilQty2 = Number(e.avilQty2);
                })

                component.set('v.rePartInfo', rePartInfo);    
                return helper.apexCall(component, 'SeachPart2', {partNo : partNo, userInfo : userInfo});
            }))
            .then($A.getCallback(function(result) {
                console.log('>> 대체품 정보');
                let response = result.r;
                console.log('대체품 정보 확인 >>> ' +JSON.stringify(response,null,4));
                component.set('v.replacementList', response);
                let reName = helper.getNextValue(component, response, partNo);
                console.log('reName ::: ' +reName);
                if(reName != null && reName != '') {
                    component.set('v.isReplace', true)
                }
                else {
                    component.set('v.isReplace', false)
                }
                component.set('v.replaceName', reName);

                return helper.apexCall(component, 'GetCurrentStock', {dli : userInfo, ptn : partNo});
            }))
            .then($A.getCallback(function(result){
                let response = result.r;
                let partInfo = component.get('v.partInfo'); 

                console.log('response >> 여기 '+JSON.stringify(response,null,4))

                if(response == null) {
                    component.set('v.partInfo', '');
                    component.set('v.partsStock', '');
                    component.set('v.isReplace', false);

    
                    component.set('v.rePartInfo', '');
                    component.set('v.replaceName', '');
                    component.set('v.replacementList', '');
                    
                    // component.set('v.isReplace', false);
                    helper.toast('INFO', $A.get("$Label.c.BPI_E_MSG_4"));//'CRM Product에 적재되지 않은 부품 입니다.');
                    component.set('v.isLoading', false);
                    return;
                }
                console.log('>> 타 대리점 부품 재고 >> '+JSON.stringify(response,null,4));
                
                let other = [];
                response.forEach(e=> {
                    if(Number(e.AvailableQuantity__c) > 0) {
                        if(e.Dealer__r) {
                            e.name = e.Dealer__r.Name;
                        }else {
                            e.name = '';
                        }
                        e.partQty = e.AvailableQuantity__c;
                        other.push(e);
                    }
                })
                console.log('other >> ' +JSON.stringify(other,null,4))
                response.forEach(e=> {
                    if(userInfo.accountName == e.name) {
                        partInfo.note = e.Note__c;
                    }
                })

                response = response.filter(function(e) {
                    return e.Dealer__r;
                });

                console.log('partInfo >> ' +JSON.stringify(partInfo,null,4));
                component.set('v.partInfo', partInfo);
                component.set('v.partsStock', other);
                component.set('v.isLoading', false);
            }))
            .catch($A.getCallback(function(errors) {
                component.set('v.isLoading', false);
                if(errors.type == 'NO_DATA') {
                    helper.toast('INFO', errors.message);
                }else if(errors.type == 'NO_PRODUCT') {
                    helper.toast('INFO', errors.message);
                }else{
                    helper.toast('ERROR', $A.get("$Label.c.BPI_E_MSG_5"));//'반복되는 경우 관리자에게 문의 바랍니다.');
                    console.error('errors :: ' +JSON.stringify(errors,null,4));
                }
            }))            
        }
    },

    // 부품번호 Modal 띄우기
    openSearchProductNumber : function(component, event, helper) {

        $A.createComponent("c:DN_SearchProductNumber",
            {
                'type' : '부품번호'
            },
            function(content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("SearchProductNumber");
                    container.set("v.body", content);
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

    // 부품번호 지우기
    clearProductNumber: function (component, event, helper) {
        let productNumber = component.get("v.productNumber");
        if (!productNumber) {
            helper.toast("WARNING", $A.get("$Label.c.BPI_E_MSG_6"));//"저장된 부품번호 값이 없습니다."); // 기종 값이 없을 때 알림
            return;
        }
        component.set("v.productNumber", null);
        // component.set('v.partInfo', null);
        // component.set('v.rePartInfo', null);
        // component.set('v.replaceName', null);
        // component.set('v.replacementList', null);
        // component.set('v.partsStock', null);
        // component.set('v.isReplace', false);
        
    },

    //대체품 모달
    openreplacementList : function (component, event, helper) {
        var partNumber = component.get('v.productNumber');
        var replacementList = component.get('v.replacementList');

        if(replacementList == null) {
            helper.toast('INFO', $A.get("$Label.c.BPI_E_MSG_7"));//'대체품 정보가 없습니다.');
            return;
        } else {
            $A.createComponent("c:DN_SearchProductNumber",
                {
                    'type' : '대체품',
                    'partNumber' : partNumber,
                    'replacementList' : replacementList
                },
                function(content, status, errorMessage) {
                    if (status === "SUCCESS") {
                        var container = component.find("SearchProductNumber");
                        container.set("v.body", content);
                    }else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        }
    },

    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam("modalName");
        var message = event.getParam("message");
        
        if (modalName == 'DN_SearchProductNumber') {
            component.set('v.productNumber', message.ProductCode);
        }
    },

    // 엔터 검색
    handleKeyPress: function (component, event, helper) {
        console.log('엔터 키 입장')

        let productNo = component.get('v.productNumber');
        console.log('productNo>>'+productNo);
        console.log('event >> ' +event.keyCode);

        if(event.keyCode === 13) {
            if( productNo == null || productNo.trim() == '' ) {
                helper.toast('INFO',$A.get("$Label.c.BPI_E_MSG_1"));//'부품번호를 입력해주세요.');
            } else {
                let search = component.get('c.doSearch');
                $A.enqueueAction(search);
            }
        }
    },

    handleUpperCase: function (component, event, helper) {
        let inputCmp = event.getSource(); 
        let value = inputCmp.get("v.value");
        
        console.log('inputCmp >> '+inputCmp);
        console.log('value >> '+value);
    
        if (value) {
            inputCmp.set("v.value", value.toUpperCase());
        }
    },

    // 값 입력 후 커서 제외하면 작동 25.04.14 일단 만들어 둠.
    inputEnd: function(component, event, helper) {
        // let check = component.get('c.partsCheck');
        // $A.enqueueAction(check);
    },
    
    // 값 입력 후 커서 제외하면 작동 25.04.14 일단 만들어 둠.
    partsCheck : function(component, evetn, helper ){
        let partNo = component.get('v.productNumber');

        if(partNo.trim() == null || partNo.trim() == '') {
            console.log('그냥 클릭한 건 제외')
            return;
        }

        let partList = [partNo];

        helper.apexCall(component, 'CheckProduct', {psl : partList})
        .then($A.getCallback(function(result) {
            let status = result.r;
            console.log('status >>> ' + JSON.stringify(status,null,4));

            let matchedList = status.filter(e => e.ProductCode != null);
            console.log('matchedList >>> ' + JSON.stringify(matchedList,null,4));

            component.set('v.matchedList', matchedList);

            if(matchedList.length == 0) {
                component.set('v.productNumber','');
                helper.toast('INFO',$A.get("$Label.c.BPI_E_MSG_8"));//'부품 번호를 확인해 주세요.');
            }
        }))
        .catch($A.getCallback(function(errors) {
            component.set('v.isLoading', false);
            if(errors.type == 'NO_DATA') {
                helper.toast('INFO', errors.message);
            }else{
                helper.toast('ERROR', $A.get("$Label.c.BPI_E_MSG_5"));//'반복되는 경우 관리자에게 문의 바랍니다.');
                console.log('error>> ' + JSON.stringify(errors,null,4));
            }
        }))  
    },
})