/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-10-2025   youjin.shim@sbtglobal.com   Initial Version
**/
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

    fetchBoardList: function(component, event, helper, params) {

        let that = this;

        console.log('param', JSON.stringify({
            category            : component.get('v.searchCategory'),
            title               : component.get('v.searchSubject'),
            keyword             : component.get('v.searchKeyword'),
            searchBoardMonth    : component.get('v.searchBoardMonth'),
            recordType          : component.get('v.recordType')})
        );
        
        that.apexCall(component, event, helper, 'getBoardListwithCs', {
            category            : component.get('v.searchCategory'),
            title               : component.get('v.searchSubject'),
            keyword             : component.get('v.searchKeyword'),
            searchBoardMonth    : component.get('v.searchBoardMonth'),
            recordType          : component.get('v.recordType')
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log(r);
            
            if(r.flag == 'success') {
                component.set('v.recordTypeId', r.recordTypeId);
                console.log(component.get('v.recordTypeId'), ' rec!!!');
                var resultList  = [];
                // New인지 아닌지 구분 변수
                const todaySet = new Date();
                const msInADay = 24 * 60 * 60 * 1000;
                const daySet = new Date(todaySet.getTime() - parseInt(7) * msInADay);
                const dateOnlySet = daySet.toISOString().split('T')[0];
                const todayOnlySet = todaySet.toISOString().split('T')[0];
                r.boardList.forEach(element => {
                    if(element.PostingDate__c >=dateOnlySet && todayOnlySet >= element.PostingDate__c) {
                        element.isNew = true;
                    } else {
                        element.isNew = false;
                    }
                });
                console.log(JSON.stringify(r.boardList), ' < ===testetet');
                resultList      = r.boardList;

                try {
                    var dividePageCount = component.get('v.dividePageCount');
                    var totalPage       = Math.ceil(resultList.length / dividePageCount);

                    var pageList            = [];
                    var pageAllCountList    = [];
                    var pageCountList       = [];

                    for (let i = 0; i < totalPage; i++) {
                        if (pageCountList.length == 10) {
                            pageAllCountList.push(pageCountList);
                            pageCountList = [];
                        }
                        pageCountList.push(i);

                        var objList = resultList.slice(i * dividePageCount, (i + 1) * dividePageCount);
                        pageList.push(objList);
                    }
                    pageAllCountList.push(pageCountList);

                    component.set('v.pageAllCountList',     pageAllCountList);
                    component.set('v.pageCountList',        pageAllCountList[0]);
                    component.set('v.pageList',             pageList);
                    component.set('v.allResultCount',       resultList.length);
                    component.set('v.boardList',            resultList);
                    component.set('v.totalPage',            totalPage);
                    component.set('v.pagingResultList',     pageList[0]);


                } catch (error) {
                    console.log('Paging Error', JSON.stringify(error));
                }
            } else {
                that.toast('ERROR', 'An error occurred, please contact your administrator.');
            }
        }))
        .catch(function(error) {
            console.log('# fetchBoardList error : ' + error.message);
        });
    },

    saveQnA : function(component, event, helper, params) {
        let that = this;

        let noticeTarget = '';
        let profileName = component.get('v.currentProfileName'); 
        if (profileName === 'DNS CS Service_Partner') {
            noticeTarget = profileName;
        }

        console.log('param', JSON.stringify({
            title            : component.get('v.qnaTitle'),
            question         : component.get('v.qnaQuestion'),
            noticeTarget     : noticeTarget
        })
        );
        
        that.apexCall(component, event, helper, 'saveQnA', {
            title             : component.get('v.qnaTitle'),
            question          : component.get('v.qnaQuestion'),
            noticeTarget      : noticeTarget
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log(r);
            
            if(r.flag == 'success') {
                component.set('v.recordTypeId', r.recordId);
                console.log(component.get('v.recordTypeId'), ' rec!!!');
                
                that.toast('SUCCESS', 'Q&A has been saved successfully.');

                component.set('v.qnaTitle', '');
                component.set('v.qnaQuestion', '');
                
                $A.get('e.force:refreshView').fire();

                component.set('v.addQnAModal', false);

                helper.fetchBoardList(component, event, helper);
            } else {
                that.toast('ERROR', r.msg || 'An error occurred, please contact your administrator.');
            }
        }))
        .catch(function(error) {
            console.log('# saveQnA error : ' + error.message);
            that.toast('ERROR', 'An unexpected error occurred. Please try again.');
        });
    }
})