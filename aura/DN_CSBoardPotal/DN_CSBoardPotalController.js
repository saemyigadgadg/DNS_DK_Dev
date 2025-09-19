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
    doInit : function(component, event, helper) {
        component.set("v.isLoaded", true);
        // 운영 OR 샌드박스 구분
        var baseUrl = window.location.origin;
        if(!baseUrl.includes("--dev.sandbox")) {
            baseUrl += '/s'
        } else {
            baseUrl += '/partners/s'
        }
        component.set("v.baseUrl", baseUrl);
        var currentUrl = window.location.href;

        if (currentUrl.includes('cs-Board-Qna')) {
            component.set("v.isQnA", true);
            // component.set("v.header", "QnA");
        }

        if (currentUrl.includes('cs-Board-Announce')) {
            component.set("v.isAnn", true);
            // component.set("v.header", "공지사항");
        }

        let today           = new Date();
        let year            = today.getFullYear();
        let month           = today.getMonth()+1;
        let billingMonth    = year + '-' + month;
        component.set("v.boardMonth",       billingMonth);
        component.set("v.searchBoardMonth", billingMonth);
        
        helper.fetchBoardList(component, event, helper);

        component.set('v.isLoaded', false);
    },

    handleSearch: function(component, event, helper) {
        component.set("v.isLoaded", true);
        component.set('v.searchBoardMonth', component.get('v.boardMonth'));
        helper.fetchBoardList(component, event, helper);
        component.set("v.isLoaded", false);
        // // 로딩 상태 표시
        // component.set("v.isLoaded", true);
    
        // // 검색 조건 가져오기
        // var searchCategory = component.get('v.searchCategory');
        // var searchSubject = component.get('v.searchSubject');
        // var searchKeyword = component.get('v.searchKeyword');
        // var searchBoardMonth = component.get('v.boardMonth');
        // var recordTypeId = component.get('v.recordTypeId');
    
        // // 검색 조건이 비어있으면, 필터링하지 않고 바로 데이터를 가져오는 방식으로 처리할 수 있음
        // if (!searchCategory || !searchSubject) {
        //     // 검색 조건이 부족하면 알림을 띄울 수 있음
        //     alert('검색 조건을 입력해 주세요.');
        //     component.set("v.isLoaded", false);
        //     return;
        // }
    
        // // 검색 조건으로 서버에서 데이터를 가져오는 함수 호출
        // helper.fetchBoardList(component, event, helper, {
        //     category: searchCategory,
        //     title: searchSubject,
        //     keyword: searchKeyword,
        //     searchBoardMonth: searchBoardMonth,
        //     recordType: recordTypeId
        // });
    },
    

    handleChangeCategory : function(component, event, helper) {
        const selectedValue = event.getParam("value");
        component.set("v.searchCategory", selectedValue);
    },

    handleChangeTitle : function(component, event, helper) {
        var titleValue = event.getSource().get('v.value');
        component.set('v.searchSubject', titleValue);
    },

    handleChangeKeyword : function(component, event, helper) {
        var keyValue = event.getSource().get('v.value');
        component.set('v.searchKeyword', keyValue);
    },

    handleChangeMonth : function(component, event, helper) {
        var monthValue = event.getSource().get('v.value');
        component.set('v.boardMonth', monthValue);
    },

    handleEnterSearch : function(component, event, helper) {
        if(event.keyCode === 13) {
            helper.fetchBoardList(component, event, helper);
        }
    },

    handleChangePage: function (component, event, helper) {
        try {
            var pageCountListIndex  = component.get('v.pageCountListIndex');
            var pageAllCountList    = component.get('v.pageAllCountList');
            var changePage          = Number(event.target.value);
            var name                = event.target.name;
            var pageList            = component.get('v.pageList');

            if (name == 'first') {
                changePage          = 1;
                pageCountListIndex  = 0;
            } else if (name == 'previous') {
                pageCountListIndex--;
                if (pageCountListIndex < 0) {
                    pageCountListIndex  = 0;
                    changePage          = pageAllCountList[pageCountListIndex][0] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                }
            } else if (name == 'next') {
                pageCountListIndex++;
                if (pageCountListIndex >= pageAllCountList.length) {
                    pageCountListIndex  = pageAllCountList.length - 1;
                    changePage          = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][0] + 1;
                }
            } else if (name == 'last') {
                changePage          = pageList.length;
                pageCountListIndex  = pageAllCountList.length - 1;
            }

            component.set('v.currentPage',          changePage);                            // 바뀔 Page번호
            component.set('v.pageCountListIndex',   pageCountListIndex);                    // 바뀔 pageCountList의 Index
            component.set('v.pageCountList',        pageAllCountList[pageCountListIndex]);  // 바뀔 pageCountList
            component.set('v.pagingResultList',     pageList[changePage - 1]);              // 바뀔 Page에 해당하는 iteration할 List

        } catch (error) {
            console.log('handleChangePage Error : ' + JSON.stringify(error));
        }
    },

    addQnA : function (component, event, helper) {
        component.set('v.addQnAModal', true);
    }, 

    closeModal : function(component) {
        component.set('v.addQnAModal', false);
    },

    handleAdd : function (component, event, helper) {
        component.set("v.isLoaded", true);
        helper.saveQnA(component, event, helper);
        component.set("v.isLoaded", false);
    }

})