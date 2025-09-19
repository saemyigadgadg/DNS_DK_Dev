/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-08-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-08-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    storageBinModalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    handleSearch: function (component, event, helper) {
        let searchKey='';
        let loc1 = component.get('v.loc1');
        let loc2 = component.get('v.loc2');
        let loc3 = component.get('v.loc3');
        let loc4 = component.get('v.loc4');
        let loc5 = component.get('v.loc5');
        let loc6 = component.get('v.loc6');
        if(loc1) { searchKey += loc1; }
        if(loc2) { searchKey += `-${loc2}`; }
        if(loc3) { searchKey += `-${loc3}`; }
        if(loc4) { searchKey += `-${loc4}`; }
        if(loc5) { searchKey += `-${loc5}`; }
        if(loc6) { searchKey += `-${loc6}`; }
        console.log(searchKey + ' < ==searchKey');
        helper.apexCall(component,event,helper, 'getLocationList', {
            search : searchKey
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            component.set('v.storageBinModalList',r);
            if(r.length == 0) {
                helper.toast('success', '검색되는 데이터가 없습니다.');    
            }
            console.log(JSON.stringify(result), ' ::::result');
        })).catch(function(error) {
            helper.toast('error', error[0].message);
        }).finally(function () {
            // 모든 호출 완료 후 로딩 상태 해제
            component.set('v.isLoading', false);
        });
    },

    handleCheckboxChange: function (component, event, helper) {
        var index = event.currentTarget.name;
        console.log('index::', index);
        var data = component.get('v.storageBinModalList');
        var selectedRow = data[index];
        component.set('v.selectedBin', selectedRow);
        selectedRow.parentCmp = component.get('v.parentCmp')
        console.log(component.get('v.parentCmp'),' 1111');
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : "DN_searchStorageBinModal",
            "actionName" : "Close",
            "message" :  selectedRow
        });
        cmpEvent.fire();
        helper.closeModal(component);
    },
})