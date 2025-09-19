/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-10-2025
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-10-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        helper.gfnDoinit(component, event);
    },

    selectAll : function(component, event, helper) {
        let checked = event.getSource().get('v.checked');
        let partList = component.get('v.partsList');
        partList.forEach(part=>{
            if(!part.isDisabledChange)
                part.isSelected = checked;
        });
        component.set('v.partsList', partList);
    },

    downloadExcel : function(component, event, helper) {
        let partList = component.get('v.partsList');
        console.log(JSON.stringify(partList),' ::: partList');
        let header = helper.gfnExcelHeader();
        let excelData = partList.map(part=> {
            let excelData = {};
            Object.keys(header).forEach(key=>{
                if(part[key] || part[key] === 0 || part[key] === '0') {
                    excelData[header[key]] = part[key];
                }
            });
            return excelData;
        });
        component.set('v.excelName', 'Order_History');
        component.set('v.excelData', excelData);
        helper.handleExcel(component);
        
    },

    updateRequest : function(component, event, helper) {
        helper.gfnUpdateRequest(component, event);
    },

    deleteRequest : function(component, event, helper) {
        helper.gfnDeleteRequest(component, event);
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