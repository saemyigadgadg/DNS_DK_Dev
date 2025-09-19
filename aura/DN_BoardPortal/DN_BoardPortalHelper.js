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

    fetchBoardList : function( component, event, helper ){
        let that = this;

        console.log('param', JSON.stringify({
            category            : component.get('v.searchCategory'),
            title               : component.get('v.searchSubject'),
            keyword             : component.get('v.searchKeyword'),
            searchBoardMonth    : component.get('v.searchBoardMonth'),
            recordType          : component.get('v.recordType')})
        );
        
        that.apexCall(component, event, helper, 'getBoardList', {
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
                // component.set('v.pickListValue', r.picklistValues);
                // component.set('v.searchCategory', r.picklistValues[0].value);
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

})