({
    close : function(component) {
        component.find("overlayLib").notifyClose();
    }

    , toast: function (type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title      : title
            , type     : type
            , message  : message
            , duration : 3000
            , mode     : 'dismissible'
        });
        toastEvent.fire();
    }

    , reverseSpinner: function(component){
        component.set('v.isLoading', !component.get('v.isLoading'));
    }

    , setColumns : function(component) {

        const isDomestic = component.get('v.checkDomestic');
        let tableColumns, selTableColumns = [];

        if(isDomestic) {
            
            tableColumns = [
                {type: 'button-icon', typeAttributes: {iconName: 'utility:add', name: 'add', variant: 'bare'}, initialWidth: 50}
                , {label : 'Kit',         fieldName : 'kit',         wrapText: true,  initialWidth: 180}
                , {label : 'Description', fieldName : 'description', wrapText: true}
                , {label : 'Details',     fieldName : 'details', wrapText: true}
                , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 100}
            ];

            selTableColumns = [
                {type: 'button-icon', typeAttributes: {iconName: 'utility:dash', name: 'remove', variant: 'bare'}, initialWidth: 50}
                , {label : 'Kit',         fieldName : 'kit',         wrapText: true,  initialWidth: 160}
                , {label : 'Description', fieldName : 'description', wrapText: true}
                , {label : 'Details',     fieldName : 'details', wrapText: true}
                , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 100, editable: true}
            ];
        } else {

            tableColumns = [
                {type: 'button-icon', typeAttributes: {iconName: 'utility:add', name: 'add', variant: 'bare'}, initialWidth: 50}
                , {label : 'Kit',         fieldName : 'kit',         wrapText: true,  initialWidth: 180}
                , {label : 'Description', fieldName : 'description', wrapText: true}
                , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 100}
            ];
    
            selTableColumns = [
                {type: 'button-icon', typeAttributes: {iconName: 'utility:dash', name: 'remove', variant: 'bare'}, initialWidth: 50}
                , {label : 'Kit',         fieldName : 'kit',         wrapText: true,  initialWidth: 160}
                , {label : 'Description', fieldName : 'description', wrapText: true}
                , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 100, editable: true}
            ];
        }

        component.set('v.tableColumns',    tableColumns);
        component.set('v.selTableColumns', selTableColumns);
    }

    , handleError : function(methodName, errorMsg) {
        var msg = errorMsg;
        if(typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
        if(msg.message) { msg = msg.message; }

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        this.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
    }

    , changeTableData : function(component, category) {
        const categoryOptionData = component.get('v.categoryOptionData');
        const tableData          = categoryOptionData.filter(data => data.category == category);
        
        component.set('v.tableData', tableData);
    }
})