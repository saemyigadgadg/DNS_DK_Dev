({
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

    reverseSpinner: function(component){
        component.set('v.isLoading', !component.get('v.isLoading'));
    },

    setColumns : function(component) {
        const tableColumns = [
            {type: 'button-icon', typeAttributes: {iconName: 'utility:add', name: 'add', variant: 'bare'}, initialWidth: 32}
            , {label : 'Kit',         fieldName : 'kit',         wrapText: true,  initialWidth: 180}
            , {label : 'Description', fieldName : 'description', wrapText: true}
            , {label : 'Qty',         fieldName : 'quantity',    type : 'number', initialWidth: 100}
        ];
        component.set('v.tableColumns',    tableColumns);
    },

    handleError : function(methodName, errorMsg) {
        var self = this;
        var msg = errorMsg;
        if(typeof msg != 'string' && errorMsg.length > 0) { msg = errorMsg[0]; }
        if(msg.message) { msg = msg.message; }

        console.error(methodName + " Error : " + JSON.stringify(msg, null, 2));
        self.toast('error', $A.get("$Label.c.DNS_M_GeneralError"), msg);
        self.reverseSpinner(component);
    },

    changeTableData: function(component, category) {
        var self = this;
        const quoteId = component.get('v.quoteId');
        const selTableData = component.get('v.selTableData') || [];
        const delTableData = component.get('v.delTableData') || [];
        
        var action = component.get("c.selectCategory");
        action.setParams({ category: category, quoteId: quoteId });
    
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const returnVal = response.getReturnValue();
                console.log('Return Value:', returnVal);
                
                const deletedKeys = delTableData
                    .filter(deletedItem => deletedItem.category === category && deletedItem.del === 'D')
                    .map(deletedItem => deletedItem.key);
                console.log("Deleted Keys to Restore:", deletedKeys);
                
                const filteredTableData = returnVal.filter(item => {
                    const isSelected = selTableData.some(selectedItem => selectedItem.key === item.key);
                    const isDeleted = delTableData.some(deletedItem => deletedItem.key === item.key && deletedItem.del === 'D');
                    
                    return !isSelected && (!isDeleted || deletedKeys.includes(item.key));
                });
                console.log("Filtered Table Data:", JSON.stringify(filteredTableData, null, 2));
                
                component.set('v.tableData', filteredTableData);
                self.reverseSpinner(component);
            } else {
                const errors = response.getError();
                console.error('Error fetching data:', errors);
                self.handleError('selectedItems', errors);
            }
        });
        
        $A.enqueueAction(action);
    }
    
    
    
})