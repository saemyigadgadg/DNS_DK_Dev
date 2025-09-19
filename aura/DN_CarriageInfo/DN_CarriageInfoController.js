/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-05-13
 * @last modified by  : yeongju.yun
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-07-02   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        var action = component.get("c.fetchInit");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, response => {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnVal = response.getReturnValue();
                console.log('returnVal ::: ', JSON.stringify(returnVal, null, 2));
                
                if(!returnVal || returnVal == null) {
                    component.set('v.isLoading', false);
                    console.log('1');
                    
                } else if(returnVal.O_RETURN.TYPE == 'S') {
                    const rowData = returnVal.T_OUTPUT;
                    component.set("v.carriageInfoList", rowData);
                    console.log(JSON.stringify(rowData, null, 2));
                } else {
                    if(returnVal.O_RETURN.MESSAGE != 'Data not found.') {
                        helper.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), returnVal.O_RETURN.MESSAGE);
                    }
                }
            } else {
                helper.handleError('doInit', response.getError());
            }

            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    // 테이블 세로 스크롤 동기화
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

})