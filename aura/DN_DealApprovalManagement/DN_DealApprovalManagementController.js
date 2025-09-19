/**
 * @author            : Jun-Yeong Choi
 * @description       : 
 * @last modified on  : 01-10-2025
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   2024-06-18   junyeong.choi@sbtglobal.com   Initial Version
**/
({
    doInit : function (component, event, helper) {
        helper.gfnDoinit(component, event);
    },

    selectAll : function(component, event, helper) {
        let checked = event.getSource().get('v.checked');
        let partsList = component.get('v.partsList');
        partsList.forEach(part=>{
            part.isSelected = checked;
        });
        component.set('v.partsList', partsList);
    },

    approval : function(component, event, helper) {
        helper.gfnApproval(component, event);
    },

    reject : function(component, event, helper) {
        helper.gfnReject(component,event);
    },

    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        var table1 = component.find('leftTableDiv').getElement();
        // x축 스크롤 값을 유지
        var scrollX = table1.scrollLeft;
        table1.scrollTo({ top: scrollY, left: scrollX, behavior: 'auto' });
    },

})