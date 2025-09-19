/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : youjin.shim@sbtglobal.com 
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-10-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        component.set("v.isLoaded", true);

        let today           = new Date();
        let year            = today.getFullYear();
        let month           = today.getMonth()+1;
        let billingMonth    = year + '-' + month;
        component.set("v.boardMonth",       billingMonth);
        component.set("v.searchBoardMonth", billingMonth);
        //pickListValue
        helper.fetchBoardList(component, event, helper);
        component.set('v.isLoaded', false);
    },

    handleSearch : function(component, event, helper) {
        component.set("v.isLoaded", true);
        component.set('v.searchBoardMonth', component.get('v.boardMonth'));
        helper.fetchBoardList(component, event, helper);
        component.set("v.isLoaded", false);
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

})