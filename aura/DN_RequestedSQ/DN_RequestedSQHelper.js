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
        var self = this;
        component.set('v.isLoading', true);
        component.set('v.isRichLoading', true);
        // Apex Call
        this.apexCall(component, event, helper, 'getRelatedListInit', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('r', r);
            var dataRow = r.getInitDatas;

            dataRow.forEach(row => {
                if (row.Description) {
                    row.Description = row.Description.replace(/<\/p>/g, '\n');
                    row.Description = row.Description.replace(/<.*?>/g, '');
                }
            });
            const formattedData = self.processSearchData(dataRow);

            component.set('v.dataRows', formattedData);
            component.set('v.size', '(' + dataRow.length + ')');
            
            if(r.getRichTextValue.richValue__c != null) {
                component.set('v.richTextContent', r.getRichTextValue.richValue__c),
                component.set('v.isEditable', false);
            }
            console.log('r.getInitDatas.IsRefineComplete ::: ', r.getInitDatas.IsRefineComplete);
            
            component.set('v.IsRefineComplete', r.getInitDatas.IsRefineComplete);
            component.set('v.currentStage', r.getCurrentStage);
            component.set('v.userFilter', r.getUserFilter);
            component.set('v.isOwnerDealer', r.getDealerOwner);
            component.set('v.isRepresentative', r.getBranchRepresentative);
            component.set('v.isSQ', r.getSQdata);
            component.set('v.isWorker', r.checkWorker);
            component.set('v.checkPreAuth', r.checkPreAuth);
            component.set('v.checkGlobal', r.checkGlobal);
            component.set('v.isQuoteLineItem', r.checkQuoteLineItems);
            component.set('v.isDNSASalesTeam', r.checkDNSASalesTeam);
            component.set('v.isReqSend', r.isReqSend);
            component.set('v.checkJisajang', r.checkJisajang);
            component.set('v.checkRnd', r.checkRnd);
            component.set('v.isLoading', false);
            component.set('v.isRichLoading', false);
            component.set('v.sqProduct', r.sqProduct);
        }))
        .catch(function(error) {
            console.log('# handleNext error : ' + error.message);
        });
    },

    handleRefine : function(component, event, helper, recordId) {
        component.set('v.rowId', recordId);
        component.set('v.isRefine', true);
        // Apex Call
        this.apexCall(component, event, helper, 'updateRefineComplete', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {
            component.set('v.IsRefineComplete', r);
            component.set('v.rowId', recordId);
            component.set('v.isRefine', true);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# sendCompleteNotiAndEmail error : ' + error.message);
        });
    },

    handleComplete : function(component, event, helper, recordId) {
        // component.set('v.isLoading', true);
        var self = this;
        // Apex Call
        this.apexCall(component, event, helper, 'sendCompleteNotiAndEmail', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            if(r == 'success') {
                component.set('v.IsRefineComplete', true);
                self.toast('Success', $A.get("$Label.c.DNS_SQR_T_COMPLETETOAST"));
                // self.init(component, event, helper);
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            }

            // component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# sendCompleteNotiAndEmail error : ' + error.message);
        });
    },

    handleEdit : function(component, event, recordId) {
        try {
            component.set('v.rowId', recordId);
            component.set('v.isEditClick2', true);
        } catch (error) {
            console.log('# handleEdit error : ', error.message);
            
        }
    },

    handleDelete: function(component, event, helper, recordId) {
        var self = this;
        // Apex Call
        this.apexCall(component, event, helper, 'deleteRequestedSQ', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            if(r == 'success') {
                self.toast('Success', 'The Requested SQ was deleted.');
                // self.init(component, event, helper);
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