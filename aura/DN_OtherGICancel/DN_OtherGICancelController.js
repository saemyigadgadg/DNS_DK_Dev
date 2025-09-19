/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2024-06-11
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-10   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        //디폴트 쿼리 설정
        helper.setQuery(component);

        let giType = [
            { 'label': '기타출고', 'value': '기타출고' }
        ]
        component.set("v.giType", giType);
    },
    // 메세지 채널을 통해 모달이벤트 수신 / 필터CMP,데이터테이블CMP
    setSubscriptionLMC : function(component, message, helper) {
        let params = message._params;
        // console.log(params.uuid, ' < ====params.uuid');
        // console.log(component.get("v.uuid"), ' < ====cmp uuid');
        if(params.uuid == component.get("v.uuid")) { // CustomModal,CustomPage 등등 추후 필요 시 조건 식 추가
            console.log(" setSubscriptionLMC");
            console.log(JSON.stringify(params), ' < ==params');
            switch (params.type) {
                case 'filterChange':
                    helper.setFilterChange(component,params);
                    break;
                case 'defaultFilter':
                    helper.setFilterChange(component,params);
                    break;
                case 'Seach': // 취소목록 검색
                    helper.getDataQuery(component,params.type);
                    break;
                case 'Save': // 출고 취소
                    let selectedGIs = component.get('v.selectedGIs');
                    if(selectedGIs.length == 0) {
                        helper.toast('error', '출고 취소할 항목을 선택해주세요');
                        break;
                    }
                    helper.cancelGI(component);
                    break;
                default:
                    break;
            }  
        }
    },


    doSearch: function (component, event, helper) {
        component.set("v.isLoading", true);
        var isSearched = component.get("v.isSearched");
        var giList = component.get("v.giList");


        component.set("v.isSearched", isSearched);
        component.set("v.giList", giList);
        component.set("v.isLoading", false);
    },

    // 전체 선택/해제
    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox");
        var isChecked = component.find("headerCheckbox").get("v.checked");
        var plist = [];
        let allData = component.get('v.giList');
        console.log(isChecked,' ::: isChecked');

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    console.log(index,' :::ALL index');
                    checkbox.set("v.checked", isChecked);
                    plist.push(allData[index]);
                });
            } else { 
                checkboxes.set("v.checked", isChecked);
                plist = allData;
            }
        } else {
            console.log(isChecked, ' else :: isChecked');
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    console.log(index,' :::ALL index');
                    checkbox.set("v.checked", isChecked);
                    
                });
            } else {
                checkboxes.set("v.checked", isChecked);
            }
            plist = [];
        }
        component.set('v.selectedGIs', plist);
        let seleted = component.get('v.selectedGIs');
        console.log('selectedGIs:', JSON.stringify(seleted));
    },

    // 개별 체크변경
    handleCheckboxChange: function (component, event, helper) {
        let check = event.getSource().get('v.checked');
        let index = event.getSource().get('v.name');
        console.log(index,' < ===index');
        let allData = component.get('v.giList');
        let seletedList = component.get('v.selectedGIs');
        if(check) {
            seletedList.push(allData[index]);
        } else {
            seletedList = seletedList.filter(item => item !== allData[index]);
        }
        console.log(JSON.stringify(seletedList), ' ::::selectedGIs');
        component.set('v.selectedGIs', seletedList);
    },

    handeQTYChange : function(component, event, helper) {
        let value = event.getSource().get('v.value');
        let index = event.getSource().get("v.accesskey");
        let giList = component.get('v.giList');
        if(/[^0-9]/.test(value)) {
            value = 0;
        } else {
            value = Number(value);
        }
        giList[index].cancelRequestQty = value;
        component.set('v.giList', giList);
    },

})