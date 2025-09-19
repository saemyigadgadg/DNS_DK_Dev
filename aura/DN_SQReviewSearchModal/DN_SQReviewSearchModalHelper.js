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

    searchSQReview : function(component, event, helper) {
        var self = this;
        try {
            if(component.get('v.keyword') == '' &&component.get('v.productModel') == '') {
                self.toast('ERROR', $A.get("$Label.c.DNS_SQR_T_FILLKEYWORD"));
                component.set('v.isLoading', false);
                return;
            }
            component.set('v.isLoading', true);
            // Apex Call
            self.apexCall(component, event, helper, 'searchSQReview', {
                keyword : component.get('v.keyword'),
                modelName : component.get('v.productModel'),
                recordId : null
            })
            .then($A.getCallback(function(result) {
                let r = result.r;
                console.log('r', r);

                var dataRow = r;

                dataRow.forEach(row => {
                    if (row.descriptionHtml) {
                        row.descriptionHtml = row.descriptionHtml.replace(/<\/p>/g, '\n');
                        row.descriptionHtml = row.descriptionHtml.replace(/<.*?>/g, '');
                    }
                    if (row.commentsHtml) {
                        row.commentsHtml = row.commentsHtml.replace(/<\/p>/g, '\n');
                        row.commentsHtml = row.commentsHtml.replace(/<.*?>/g, '');
                    }
                });

                const formattedData = self.processSearchData(dataRow);
                
                component.set('v.searchDataList', formattedData);
                component.set('v.isLoading', false);
            }))
            .catch(function(error) {
                console.log('# searchSQReview error : ' + error.message);
            });
        } catch (error) {
            console.log('handleClickSearch Error : ' + error);
        }
    },

    processSearchData: function(data) {
        const processedData = [];
        data.forEach(row => {
            const formattedRow = Object.assign({}, row);
            if (formattedRow.krwCost !== undefined) {
                formattedRow.krwCost = this.formatCurrency(formattedRow.krwCost);1
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