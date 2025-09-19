/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 2025-01-15
 * @last modified by  : yuhyun.park@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2025-01-15   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    close: function (component) {
        component.find("overlayLib").notifyClose();
    }

    , toast: function (type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title
            , type: type
            , message: message
            , duration: 3000
            , mode: 'dismissible'
        });
        toastEvent.fire();
    }

    , reverseSpinner: function (component) {
        component.set('v.isLoading', !component.get('v.isLoading'));
    }

    , filterTableData: function (component, searchTerm) {
        const allData = component.get("v.defaultData"); // 원본 데이터
        const filteredData = allData.filter(item => {
            return (
                item.kit.toLowerCase().includes(searchTerm.toLowerCase()) ||
                item.description.toLowerCase().includes(searchTerm.toLowerCase())
            );
        });
        component.set("v.tableData", filteredData);
    }

     , setColumns : function(component) {

        const tableColumns = [
            {type: 'button-icon', typeAttributes: {iconName: 'utility:add', name: 'add', variant: 'bare'}, initialWidth: 50}
            , {label : 'Kit',         fieldName : 'kit',         wrapText: true,  initialWidth: 180}
            , {label : 'Description', fieldName : 'description', wrapText: true}
            , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 100}
            // , {label : 'Price',       fieldName : 'price',       type : 'number'}
        ];

        const selTableColumns = [
            {type: 'button-icon', typeAttributes: {iconName: 'utility:dash', name: 'remove', variant: 'bare'}, initialWidth: 50}
            , {label : 'Kit',         fieldName : 'kit',         wrapText: true,  initialWidth: 160}
            , {label : 'Description', fieldName : 'description', wrapText: true}
            , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 100, editable: true}
            // , {label : 'Price',       fieldName : 'price',       type : 'number', initialWidth: 120}
        ];

        component.set('v.tableColumns',    tableColumns);
        component.set('v.selTableColumns', selTableColumns);
    }

    , handleError: function (methodName, errorMsg) {
        var msg = errorMsg;
        if (typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
        if (msg.message) { msg = msg.message; }

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        this.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
    }

    , changeTableData: function (component, category) {
        const categoryOptionData = component.get('v.categoryOptionData');
        const tableData = categoryOptionData.filter(data => data.category == category);

        component.set('v.tableData', tableData);
    }
})