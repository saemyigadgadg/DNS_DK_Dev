({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);

        // Apex Call
        helper.apexCall(component, event, helper, 'getQuoteLineItems', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            let qliId = r.qliid;
            component.set('v.originalId', qliId);
            let filteredList = r.quoteLineItemWrapperList.filter(function(item) {
                if(item.Id !== qliId) {
                    console.log('item :', item);
                    return item;
                }
            });
            //let filteredList = r.quoteLineItemWrapperList.filter(item => item.Id !== qliId);
            console.log('filteredList :', filteredList);
            component.set('v.data', filteredList);
            console.log("🚀 ~component.get('v.data') :", component.get('v.data'));

            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getQuoteLineItems error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleRowSelection : function(component, event, helper) {
        try {
            const selectedRows = component.get('v.selectedRows');
            const rowIndex = event.getSource().get('v.value');
            const rowData = component.get('v.data')[rowIndex];
        
            if (!rowData) {
                console.error('Row data is undefined for index:', rowIndex);
                return;
            }
        
            if (event.getSource().get('v.checked')) {
                selectedRows.push(rowData);
                
                const allCheckboxes = component.find("checkbox");
                allCheckboxes.forEach(checkbox => {
                    if (checkbox.get("v.value") !== rowIndex) {
                        checkbox.set("v.disabled", true);
                    }
                });
                
            } else {
                const indexToRemove = selectedRows.findIndex(row => row.id === rowData.id);
                if (indexToRemove > -1) {
                    selectedRows.splice(indexToRemove, 1);
                }
                const allCheckboxes = component.find("checkbox");
                allCheckboxes.forEach(checkbox => {
                    checkbox.set("v.disabled", false);
                });
            }
            component.set('v.selectedRows', selectedRows);
            console.log('test', component.get('v.selectedRows'));
        } catch (error) {
            console.log('# handleRowSelection error : ', error);
        }
    },

    handleClickSave : function(component, event, helper) {
        component.set('v.isLoading', true);
        let record = component.get('v.selectedRows');
        
        // Apex Call
        helper.apexCall(component, event, helper, 'cloneSQQuoteLineItem', {
            recordId : component.get('v.recordId'),
            originalId : component.get('v.originalId'),
            qliId : record[0].Id
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r == 'Success') {
                helper.toast('Success', $A.get("$Label.c.DNS_SQ_CLONE_SUCCESS"));
                $A.get("e.force:closeQuickAction").fire();
            } else {
                helper.toast('Error', $A.get("$Label.c.DNS_SQ_CLONE_FAIL"));
            }


            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# getQuoteLineItems error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleClickClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})