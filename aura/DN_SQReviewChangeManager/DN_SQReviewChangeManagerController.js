({
    searchInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        window.setTimeout(
            $A.getCallback(function() {
                var inputCmp = component.find("inputKeyword");
                if (inputCmp) {
                    inputCmp.focus();
                }
            }), 400
        );

        // Apex Call
        helper.apexCall(component, event, helper, 'searchManagerInit', {
            
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            
            component.set('v.searchDataList', r);
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# searchSQReview error : ' + error.message);
        });        
    },

    handleClickSearch : function(component, event, helper) {
        try {
            // Apex Call
            helper.searchManager(component, event, helper);
        } catch (error) {
            console.log('handleClickSearch Error : ' + error);
        }
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            helper.searchManager(component, event, helper);
        }
    },

    handleRowSelection : function(component, event, helper) {
        try {
            const selectedRows = component.get('v.selectedRows');
            const rowIndex = event.getSource().get('v.value');
            const rowData = component.get('v.searchDataList')[rowIndex];
        
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
        } catch (error) {
            console.log('# handleRowSelection error : ', error);
        }
    },

    handleClickClose : function(component, event, helper) {
        helper.closeModal(component);
    },

    handleClickApply : function(component, event, helper) {
        component.set('v.isLoading', true);

        // Apex Call
        helper.apexCall(component, event, helper, 'setChangeReviewManager', {
            reviewId : component.get('v.reviewId'),
            selectedRows : component.get('v.selectedRows')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            
            if(r == 'Success') {
                helper.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_SUCCESSCHANGE"));
                // helper.init(component, event);
                helper.closeModal(component);
                $A.get('e.force:refreshView').fire();
            } else {
                helper.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# searchSQReview error : ' + error.message);
        });   
    }
})