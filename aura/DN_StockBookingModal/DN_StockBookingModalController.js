({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set("v.excelData", null);
        
        // Apex Call
        helper.apexCall(component, event, helper, 'getStockList', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r.flag == 'success') {
                const formattedData = helper.processSearchData(r.data, r.userId);
                component.set('v.isPortal', r.isPortal);
                component.set('v.stockList', formattedData);
                component.set('v.searchList', formattedData);

                var excelData = helper.convertExcelData(r.data);
                component.set("v.excelData", excelData);
                component.set('v.userId', r.userId);
                
                component.set('v.isLoading', false);
            } else if(r.flag = 'qliList') {
                helper.toast('Error', r.msg);
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
            } else if(r.flag = 'isOrder') {
                helper.toast('Error', 'An Order already exists.');
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
            } else {
                helper.toast('Error', r.msg);
                component.set('v.isLoading', false);
                component.find('overlayLib').notifyClose();
                $A.get('e.force:refreshView').fire();
            }

        }))
        .catch(function(error) {
            console.log('# getStockList error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleClickBooking : function(component, event, helper) {
        component.set('v.isLoading', true);
        const rowIndex = event.getSource().get('v.value');
        const rowData = component.get('v.searchList')[rowIndex];
        console.log('rowData', rowData);
        console.log('rowData.VBELN_ST', rowData.VBELN_ST);
        

        // Apex Call
        helper.apexCall(component, event, helper, 'insertQuoteLineItem', {
            product : rowData.BASE_CODE,
            recordId : component.get('v.recordId'),
            VBELN_ST : rowData.VBELN_ST,
            SQTXT : rowData.SQTXT
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);

            if(r == 'Success') {
                helper.toast('Success', 'Success');
            } else if(r == 'none') {
                helper.toast('Error', 'No Product');
            } else if(r == 'error') {
                helper.toast('Error', 'Error');
            } else {
                helper.toast('Error', r);
            }
            component.find('overlayLib').notifyClose();
            $A.get('e.force:refreshView').fire();
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            console.log('# insertQuoteLineItem error : ' + error.message);
        });
        
    },

    handleClickSearch : function(component, event, helper) {
        helper.searchModel(component, event, helper);
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            helper.searchModel(component, event, helper);
        }
    },

    handleClickClose : function(component, event, helper) {
        component.find('overlayLib').notifyClose();
        $A.get('e.force:refreshView').fire();
    },

    openDescriptionModal : function(component, event, helper) {
        const rowIndex = event.getSource().get('v.value');
        const rowData = component.get('v.stockList')[rowIndex];

        component.set('v.sqText', rowData.SQTXT);
        component.set('v.isDescriptionModalOpen', true);
    },

    handleFilterChange: function(component, event, helper) {
        var selectedFilter = event.getSource().get('v.value');
        component.set('v.selectedFilter', selectedFilter);
        console.log('Selected Filter:', selectedFilter);
    },

    handleSort: function(component, event, helper) {
        console.log('handleSort start');
        let icon = event.getSource();
        let fieldName = icon.getElement().closest('th').getAttribute('data-field');
        console.log("🚀 ~ fieldName:", fieldName);
        
        let sortDirection = component.get('v.sortDirection');
        let currentSortBy = component.get('v.sortBy');
        
        if (currentSortBy === fieldName) {
            sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            sortDirection = 'asc';
        }
        
        component.set('v.sortBy', fieldName);
        component.set('v.sortDirection', sortDirection);
        
        let data = component.get('v.searchList');
        data.sort(function(a, b) {
            let val1 = a[fieldName] ? a[fieldName].toString().toLowerCase() : '';
            let val2 = b[fieldName] ? b[fieldName].toString().toLowerCase() : '';
            
            if (sortDirection === 'asc') {
                return val1 > val2 ? 1 : val1 < val2 ? -1 : 0;
            } else {
                return val1 < val2 ? 1 : val1 > val2 ? -1 : 0;
            }
        });
        
        component.set('v.searchList', data);
        helper.updateSortIcon(component, fieldName, sortDirection);
    },

    handleModalEvent : function(component, event, helper) {
        console.log('handleModalEvent');
        var actionName = event.getParam('actionName');
        var message = event.getParam('message');

        if(message == 'CancelDescriptionModal') {
            component.set('v.sqText', '');
            component.set('v.isDescriptionModalOpen', false);
        } else if(message == 'CancelNoteModal') {
            component.set('v.noteText', '');
            component.set('v.isNoteModalOpen', false);
        }
        
    }
})