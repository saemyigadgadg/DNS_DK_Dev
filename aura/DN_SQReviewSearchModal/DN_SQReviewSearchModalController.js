({
    searchInit : function(component, event, helper) {
        component.set('v.isLoading', false);
        try {
            // Apex Call
            helper.apexCall(component, event, helper, 'searchSQReviewInit', {
    
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);
    
                var dataRow = r;
    
                component.set('v.isDealer', r);
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# searchSQReview error : ' + error.message);
            });
    
            window.setTimeout(
                $A.getCallback(function() {
                    var inputCmp = component.find("inputKeyword");
                    if (inputCmp) {
                        inputCmp.focus();
                    }
                }), 400
            );
            
        } catch (error) {
            console.log('error', error.message);
            
        }
    },

    handleClickSearch : function(component, event, helper) {
        try {
            component.set('v.isLoading', true);
            // Apex Call
            helper.searchSQReview(component, event, helper);
        } catch (error) {
            console.log('handleClickSearch Error : ' + error);
        }
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            helper.searchSQReview(component, event, helper);
        }
    },

    handleRowSelection : function(component, event, helper) {
        const selectedRows = component.get("v.selectedRows");
        const rowIndex = event.getSource().get("v.value");
        const rowData = component.get("v.searchDataList")[rowIndex];
    
        if (!rowData) {
            console.error('Row data is undefined for index:', rowIndex);
            return;
        }
    
        if (event.getSource().get("v.checked")) {
            selectedRows.push(rowData);
        } else {
            const indexToRemove = selectedRows.findIndex(row => row.sqTitle === rowData.sqTitle);
            if (indexToRemove > -1) {
                selectedRows.splice(indexToRemove, 1);
            }
        }
        
        component.set("v.selectedRows", selectedRows);
    },

    handleClickClose : function(component, event, helper) {
        var modalEvent = component.getEvent('modalEvent');
        modalEvent.setParams({
            "modalName"     : 'DN_SQReviewSearchModal',
            "actionName"    : 'CloseReviewSearch',
            "message"       : 'CloseReviewSearch'
        });
        modalEvent.fire();
    },
})