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
        self.apexCall(component, event, self, 'getReviewInitDatas', {
            recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('Review', r);
            
            component.set('v.userFilter', r.getUserFilter);
            component.set('v.isRndManager', r.checkRndManager);
            component.set('v.salesUser', r.getSalesUser);
            component.set('v.ReviewOwner', r.getReviewOwner);
            component.set('v.isReviewOwner', r.checkReviewOwner);
            component.set('v.checkDNSAProfile', r.checkDNSAProfile);
            if(r.initDatas != null) {
                const processedReviewList = r.getSQTitleList.map(title => r.initDatas[title]);
                console.log("🚀 ~ .then ~ processedReviewList:" + JSON.stringify(processedReviewList));
                processedReviewList.forEach(group => {
                    // group[0]의 KRWcost__c 포맷팅 (0이거나 null 체크)
                    group[0].formattedKRWcost = group[0].KRWcost__c != null && group[0].KRWcost__c !== 0 
                        ? self.formatNumber(group[0].KRWcost__c) 
                        : '0';

                    //재료비 추가_250811
                    group[0].formattedKRWMaterial_Cost = group[0].Material_Cost__c != null && group[0].Material_Cost__c !== 0 
                        ? self.formatNumber(group[0].Material_Cost__c) 
                        : '0';
                    //조립비 추가_250811
                    group[0].formattedKRWAssembly_Cost = group[0].Assembly_Cost__c != null && group[0].Assembly_Cost__c !== 0 
                        ? self.formatNumber(group[0].Assembly_Cost__c) 
                        : '0';

                    // group[1]이 있는지 확인하고 포맷팅
                    group[1] = group[1] || {}; // group[1] 없으면 빈 객체로 초기화
                    group[1].formattedKRWcost = group[1].KRWcost__c != null && group[1].KRWcost__c !== 0 
                        ? self.formatNumber(group[1].KRWcost__c) 
                        : '0';
                    //재료비 추가_250811
                    group[1].formattedKRWMaterial_Cost = group[1].Material_Cost__c != null && group[1].Material_Cost__c !== 0 
                        ? self.formatNumber(group[1].Material_Cost__c) 
                        : '0';
                    //조립비 추가_250811
                    group[1].formattedKRWAssembly_Cost = group[1].Assembly_Cost__c != null && group[1].Assembly_Cost__c !== 0 
                        ? self.formatNumber(group[1].Assembly_Cost__c) 
                        : '0';

                    // 소계 계산 (group[1] 없거나 KRWcost__c 없는 경우 0으로 처리)
                    let totalCost = (group[0].KRWcost__c || 0) + (group[1].KRWcost__c || 0);
                    group.totalFormattedKRWcost = totalCost !== 0 
                        ? self.formatNumber(totalCost) 
                        : '0';

                    //지료비 합_250811
                    let totalMaterialCost = (group[0].Material_Cost__c || 0) + (group[1].Material_Cost__c || 0);
                    group.formattedKRWMaterial_Cost = totalMaterialCost !== 0 
                        ? self.formatNumber(totalMaterialCost) 
                        : '0';
                    //조립비 합_250711
                    let totalAssemblyCost = (group[0].Assembly_Cost__c || 0) + (group[1].Assembly_Cost__c || 0);
                    group.formattedKRWAssembly_Cost = totalAssemblyCost !== 0 
                        ? self.formatNumber(totalAssemblyCost) 
                        : '0';
                });
                component.set("v.processedReviewList", processedReviewList);
            }
            
            
            if(r.getReviewRichText.ReviewRichValue__c != null) {
                component.set('v.richTextContent', r.getReviewRichText.ReviewRichValue__c),
                component.set('v.isEditable', false);
            }

            component.set('v.currentStage', r.getReviewCurrentStage);
            component.set('v.isWorker', r.checkWorker);
            component.set('v.checkJisajang', r.checkJisajang);
            component.set('v.isLoading', false);
            component.set('v.isRichLoading', false);
        }))
        .catch(function(error) {
            console.log('# getReviewInitDatas error : ' + error.message);
        });
    },

    handleEdit : function(component, event, recordId) {
        component.set('v.reviewId', recordId);
        component.set('v.isClickEdit', true);
    },

    handleSkip : function(component, event, recordId) {
        component.set('v.isLoading', true);
        var self = this;
        // Apex Call
        self.apexCall(component, event, self, 'setSQReviewComments', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            if(r == 'Success') {
                self.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_SUCCESSSKIP"));
                self.init(component, event);
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            }
            
            component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# getReviewInitDatas error : ' + error.message);
        });
    },

    handleReject : function(component, event, recordId) {
        component.set('v.reviewId', recordId);
        component.set('v.isReject', true);
    },

    handleClear : function(component, event, recordId) {
        component.set('v.isLoading', true);
        var self = this;

        var dataRecordId;
        var elements = document.querySelectorAll('.group');
        elements.forEach(function(element) {
            if(element.getAttribute('data-record-id').includes(recordId)) {
                dataRecordId = element.getAttribute('data-record-id');
            }
        });
        const [recordId1, recordId2] = dataRecordId.split('-');

        // Apex Call
        self.apexCall(component, event, self, 'clearSQReview', {
            recordId1 : recordId1,
            recordId2 : recordId2
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'Success') {
                self.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_DELETEREVIEW"));
                self.init(component, event);
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            }
            
            component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# getReviewInitDatas error : ' + error.message);
        });
    },

    handleRequest : function(component, event, recordId) {
        component.set('v.isLoading', true);
        var self = this;

        // Apex Call
        self.apexCall(component, event, self, 'reRequestSQReview', {
            recordId1 : recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'Success') {
                self.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_REREQUEST"));
                self.init(component, event);
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            }
            
            component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# getReviewInitDatas error : ' + error.message);
        });
    },

    handleComplete : function(component, event, recordId) {
        component.set('v.isLoading', true);
        var self = this;

        // Apex Call
        self.apexCall(component, event, self, 'setComplete', {
            recordId : recordId
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            
            if(r == 'Success') {
                self.toast('Success', $A.get("$Label.c.DNS_REVIEW_T_REREQUEST"));
                self.init(component, event);
            } else {
                self.toast('Error', $A.get("$Label.c.DNS_ACC_T_ADMIN"));
            }
            
            component.set('v.isLoading', false);
            $A.get('e.force:refreshView').fire();
        }))
        .catch(function(error) {
            console.log('# getReviewInitDatas error : ' + error.message);
        });
    },

    processSearchData: function(dataList) {
        return dataList.map(row => this.formatRowData(row));
    },
    
    formatRowData: function(data) {
        const processedData = [];
        data.forEach(row => {
            const formattedRow = Object.assign({}, row);
            if (formattedRow.KRWcost__c !== undefined) {
                formattedRow._rawKRWcost = parseFloat(formattedRow.KRWcost__c.replace(/,/g, '')) || 0; 
                formattedRow.KRWcost__c = this.formatCurrency(formattedRow.KRWcost__c);
            }
            processedData.push(formattedRow);
        });
        return processedData;
    },
    
    formatCurrency: function(value) {
        return new Intl.NumberFormat('en-US', {
            style: 'decimal',
            minimumFractionDigits: 0,
        }).format(Number(value));
    },

    formatNumber: function(number) {
        if (number == null || isNaN(number)) return '';
        return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }
})