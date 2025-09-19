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
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    init : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.isRichLoading', true);
        var self = this;
        
        // Apex Call
        this.apexCall(component, event, helper, 'getSQInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            var dataRow = r.getSQInitDatas;

            dataRow.forEach(row => {
                if (row.Description) {
                    row.Description = row.Description.replace(/<\/p>/g, '\n');
                    row.Description = row.Description.replace(/<.*?>/g, '');
                }
                if (row.SalesComments) {
                    // Replace <br> with newline
                    row.SalesComments = row.SalesComments.replace(/<br\s*\/?>/g, '\n');
                
                    // Replace </p> with newline
                    row.SalesComments = row.SalesComments.replace(/<\/p>/g, '\n');
                
                    // Remove any other HTML tags
                    row.SalesComments = row.SalesComments.replace(/<.*?>/g, '');
                }

                if (row.SQComments) {
                    // Replace <br> with newline
                    row.SQComments = row.SQComments.replace(/<br\s*\/?>/g, '\n');
                
                    // Replace </p> with newline
                    row.SQComments = row.SQComments.replace(/<\/p>/g, '\n');
                
                    // Remove any other HTML tags
                    row.SQComments = row.SQComments.replace(/<.*?>/g, '');
                }
            });
            const formattedData = self.processSearchData(dataRow);
            component.set('v.dataRows', formattedData);
            component.set('v.size', '(' + dataRow.length + ')');

            if(r.getSQRichText.SQRichValue__c != null) {
                component.set('v.richTextContent', r.getSQRichText.SQRichValue__c),
                component.set('v.isEditable', false);
            }

            component.set('v.isDNSA', r.checkRecordType);
            component.set('v.userFilter', r.getUserFilter);
            component.set('v.salesUser', r.getSalesUser);
            component.set('v.checkProfile', r.checkProfile);
            component.set('v.currentStage', r.getSQCurrentStage);
            component.set('v.isWorker', r.checkWorker);
            component.set('v.checkDNSAProfile', r.checkDNSAProfile);
            component.set('v.checkJisajang', r.checkJisajang);
            component.set('v.isLoading', false);
            component.set('v.isRichLoading', false);
        }))
        .catch(function(error) {
            console.log('# handleNext error : ' + error.message);
        });
    },

    handleEdit: function(component, event, recordId) {
        component.set('v.rowId', recordId);
        component.set('v.isEditSQ', true);
        // var pageReference = {
        //     type: 'standard__recordPage',
        //     attributes: {
        //         recordId: recordId,
        //         objectApiName: 'SQ__c',
        //         actionName: 'edit'
        //     }
        // };
    
        // var navService = component.find("navService");
        // navService.navigate(pageReference);
    },

    handleDelete: function(component, event, recordId) {
        var self = this;
        // Apex Call
        this.apexCall(component, event, this, 'deleteSQ', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            if(r == 'success') {
                self.toast('Success', $A.get("$Label.c.DNS_SQ_T_DELETESQ"));
                self.init(component, event, self);
            } else if(r == 'goSqlj') {
                self.toast('Error', $A.get("$Label.c.DNS_SQ_T_GOQLI"));
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            }

            component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# handleNext error : ' + error.message);
        });
    },

    processSearchData: function(data) {
        const processedData = [];
        data.forEach(row => {
            const formattedRow = Object.assign({}, row);
            if (formattedRow.Price !== undefined) {
                formattedRow.Price = this.formatCurrency(formattedRow.Price);
            }
            if (formattedRow.Cost !== undefined) {
                formattedRow.Cost = this.formatCurrency(formattedRow.Cost);
            }
            if (formattedRow.dnsPrice !== undefined) {
                formattedRow.dnsPrice = this.formatCurrency(formattedRow.dnsPrice);
            }
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
            minimumFractionDigits: 0 
        }).format(value);
    },
})