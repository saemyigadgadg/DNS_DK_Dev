({
    setColumns : function(component, isPortal) {
        const tableColumns = [
            {type: 'button-icon', typeAttributes: {iconName: 'utility:add', name: 'add', variant: 'bare'}, initialWidth: 32}
            , {label : 'Type',         fieldName : 'type',         wrapText: true,  initialWidth: 70}
            , {label : 'Kit',         fieldName : 'key',         wrapText: true,  initialWidth: 170}
            , {label : 'Description', fieldName : 'description', wrapText: true}
            , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 50}
            // , {label : 'Price',         fieldName : 'price',         wrapText: true,  initialWidth: 80}
        ];
        if(!isPortal){
            tableColumns.push({label : 'Price',         fieldName : 'price',         wrapText: true,  initialWidth: 80});
        }
        
        component.set('v.tableColumns',    tableColumns);
    },
    reverseSpinner: function(component){
        component.set('v.isLoading', !component.get('v.isLoading'));
    },
    close : function(component) {
        $A.get('e.force:refreshView').fire();
        component.find("overlayLib").notifyClose();
        $A.get('e.force:refreshView').fire();
    },
    toast: function (type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title      : title
            , type     : type
            , message  : message
            , duration : 3000
            , mode     : 'dismissible'
        });
        toastEvent.fire();
    },
})