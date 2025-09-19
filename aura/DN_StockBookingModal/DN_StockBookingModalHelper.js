({
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    toast: function (type, mmg) {
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    searchModel: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set("v.excelData", null);

        try {
            let keyword = component.get('v.keyword') || '';
            let stockList = component.get('v.stockList') || [];
            let selectedFilter = component.get('v.selectedFilter') || '';

            if (keyword === '') {
                component.set('v.searchList', stockList.slice());
            } else {
                let fieldsToSearch = selectedFilter === 'all' 
                    ? ['DNSA_MODEL', 'VBELN_ST', 'SERIAL_NUMBER'] 
                    : [selectedFilter || 'DNSA_MODEL'];

                let filteredList = stockList.filter(function(item) {
                    return fieldsToSearch.some(function(key) {
                        let value = item[key] || '';
                        return value.toLowerCase().indexOf(keyword.toLowerCase()) !== -1;
                    });
                });
                component.set("v.searchList", filteredList);
                console.log("🚀 ~ filteredList: " + JSON.stringify(filteredList));

                var excelData = helper.convertExcelData(filteredList);
                component.set("v.excelData", excelData);
            }
        } catch (error) {
            console.log('searchModel Error : ' + error.message);
        } finally {
            component.set('v.isLoading', false);
        }
    },

    processSearchData: function(data, userId) {
        const processedData = [];
        data.forEach(row => {
            const formattedRow = Object.assign({}, row);
            if (formattedRow.LIST_PRICE !== undefined) {
                formattedRow.LIST_PRICE = this.formatCurrency(formattedRow.LIST_PRICE);
            }
            if (formattedRow.ADJUSTED_LIST !== undefined) {
                formattedRow.ADJUSTED_LIST = this.formatCurrency(formattedRow.ADJUSTED_LIST);
            }
            if (formattedRow.OPEN_NOTES !== undefined) {
                var replacedNotes = formattedRow.OPEN_NOTES.replace(/#\$/g, '\r\n');
                formattedRow.OPEN_NOTES = replacedNotes;
            }

            let cssClass = '';
            if (formattedRow.crm1 === userId) {
                cssClass = 'bg-green';
            } else if (formattedRow.crm2 === userId) {
                cssClass = 'bg-yellow';
            } else if (formattedRow.crm3 === userId) {
                cssClass = 'bg-pink';
            } else {
                cssClass = 'no';
            }
            formattedRow.cssClass = cssClass;
            processedData.push(formattedRow);
        });
        
        return processedData;
    },

    formatCurrency: function(value) {
        if (value === undefined || value === null) {
            return '';
        }
        return new Intl.NumberFormat('en-US', { 
            style: 'decimal', 
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(value);
    },

    convertExcelData: function (inventoryList) {
        return inventoryList.map(function (item) {
            return {
                "DNSA Model": item.DNSA_MODEL,
                "Stock Order Number": item.VBELN_ST,
                "Open Notes": item.OPEN_NOTES,
                "Serial Number": item.SERIAL_NUMBER,
                "List Price": item.LIST_PRICE,
                "Adjusted Lis": item.ADJUSTED_LIST,
                "Extra Disc": item.PERCENT_OFF,
                "Inventory Status": item.INVENTORY_STS,
                "Location": item.LOCATION,
                "NC": item.NC,
                "MC TC": item.MC_TC,
                "Order Status": item.ORDER_STS,
                "Port": item.PORT,
                "ETA Date": item.ETA_DATE,
                "Dept": item.DEPT,
                "Base Code": item.BASE_CODE,
                "More": item.SQTXT,
            };
        });
    },

    updateSortIcon: function(component, fieldName, sortDirection) {
        let icons = component.find('table').getElement().querySelectorAll('lightning-icon');
        for (let icon of icons) {
            let th = icon.closest('th');
            if (th && th.getAttribute('data-field') === fieldName) {
                icon.setAttribute('iconName', 
                    sortDirection === 'asc' ? 'utility:chevronup' : 'utility:chevrondown');
            } else if (th) {
                icon.setAttribute('iconName', 'utility:chevrondown');
            }
        }
    }
})