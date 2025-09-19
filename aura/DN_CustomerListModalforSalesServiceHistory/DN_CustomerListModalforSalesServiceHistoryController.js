/**
 * @author            : Yu-Hyun Park
 * @description       : 
 * @last modified on  : 01-08-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   2024-06-12   yuhyun.park@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {

        var customerTypes = component.get("v.customerTypes");
        var listViewOptions = component.get("v.listViewOptions");

        customerTypes = [
            {'label' : '전체', 'value' : '전체'},
            {'label' : '실고객', 'value' : '실고객'},
            {'label' : '잠재고객', 'value' : '잠재고객'}
        ]

        listViewOptions = [
            {'label' : '5', 'value' : '5'},
            {'label' : '10', 'value' : '10'},
            {'label' : '15', 'value' : '15'}

            // {'label' : '15', 'value' : '15'},
            // {'label' : '10', 'value' : '30'},
            // {'label' : '45', 'value' : '45'}
        ]

        component.set("v.customerTypes", customerTypes);
        component.set("v.listViewOptions", listViewOptions);

    },

    closeModal : function(component, event, helper) {
        helper.closeModal(component);
    },

    //모달에서 고객 선택 시, 값 전달
    sendCustomerInfo : function(component, event, helper) {

        var customerCode = component.get("v.customerCode");


        // 클릭한 행의 index 찾기
        var index = event.currentTarget.getAttribute('data-index');
        var customerList = component.get('v.customerList');
        var customer = customerList[index];
        var message = customer;

        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "modalName" : 'DN_CustomerListModalforSalesServiceHistory',
            "actionName" : customerCode,
            "message" : message,
        });
        console.log('messagetest ::: ', message);
        
        cmpEvent.fire();
        helper.closeModal(component);
    },

    doSearch : function(component, event, helper) {
        let searchData = {
            accountName     : component.get("v.companyName").trim(),
            representative  : component.get("v.representative").trim(),
            address         : component.get("v.addressName").trim(),
        };

        component.set("v.isLoading", true);
        helper.apexCall(component, event, helper, 'searchCustomer', { searchData : searchData })
        .then($A.getCallback(function(result) {
            let r = result.r;
            console.log('response ::: ', JSON.stringify(r, null, 2));
            console.log('queryString ::: ', JSON.stringify(r.queryString, null, 2));
    
            if(r.flag === 'success') {
                helper.toast('SUCCESS', 'Search success');
                component.set('v.customerList', r.accountList);
                helper.paginateResults(component, r.accountList); 
                component.set("v.isLoading", false);
            } else if(r.flag === 'warning') {
                helper.toast('WARNING', 'This is not a customer that exists.');
                component.set('v.customerList', []);
                helper.paginateResults(component, []); 
                component.set("v.isLoading", false);
            }
            component.set('v.isLoading', false);
        }))
        .catch(function(error) {
            helper.toast('ERROR', 'An error occurred, please contact your administrator.');
            console.log('# Service Progress error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    handleChangePage: function (component, event, helper) {
        let pageCountListIndex = component.get('v.pageCountListIndex'); 
        let pageAllCountList = component.get('v.pageAllCountList'); 
        let pageList = component.get('v.pageList'); 
        let currentPage = component.get('v.currentPage'); 
        let name = event.target.name; 
    
        let changePage;
    
        if (name === 'first') {
            changePage = 1;
            pageCountListIndex = 0;
        } else if (name === 'previous') {
            if (currentPage > 1) {
                changePage = currentPage - 1;
                if (changePage < pageAllCountList[pageCountListIndex][0] + 1) {
                    pageCountListIndex = Math.max(0, pageCountListIndex - 1);
                }
            } else {
                return; 
            }
        } else if (name === 'next') {
            if (currentPage < pageList.length) {
                changePage = currentPage + 1;
                if (changePage > pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1) {
                    pageCountListIndex = Math.min(pageAllCountList.length - 1, pageCountListIndex + 1);
                }
            } else {
                return; 
            }
        } else if (name === 'last') {
            changePage = pageList.length;
            pageCountListIndex = pageAllCountList.length - 1;
        } else {
            changePage = Number(event.target.value); 
        }
    
        component.set('v.currentPage', changePage); 
        component.set('v.pageCountList', pageAllCountList[pageCountListIndex]); 
        component.set('v.pageCountListIndex', pageCountListIndex); 
        component.set('v.customerList', pageList[changePage - 1]); 
    },
    
    

    // doSearch : function(component, event, helper) {
    //     let searchData = {
    //         accountName     : component.get("v.companyName"),
    //         representative  : component.get("v.representative"),
    //         address         : component.get("v.addressName"),
    //     };
        
    //     // Validation 등 조건 로직 추가해야함
    //     // if (!searchData) {
    //     //     component.set('v.isLoading', false); 
    //     //     return;
    //     // }

    //     helper.apexCall(component, event, helper, 'searchCustomer', { searchData : searchData })
    //     .then($A.getCallback(function(result) {
    //         let r = result.r;
    //         console.log('response ::: ', JSON.stringify(r, null, 2));
    
    //         if(r.flag == 'success') {
    //             helper.toast('SUCCESS', 'Search success');
    //             component.set('v.customerList',r.accountList);
    //         } else if(r.flag == 'warning') {
    //             helper.toast('WARNING', 'This is not a customer that exists.');
    //             component.set('v.customerList',[]);
    //         }
    //         component.set('v.isLoading', false);
    //     }))
    //     .catch(function(error) {
    //         helper.toast('ERROR', 'An error occurred, please contact your administrator.');
    //         console.log('# Service Progress error : ' + error.message);
    //         component.set('v.isLoading', false);
    //     });
        
    //     // Paging
    //     var dividePageCount = component.get("v.listViewOption");
    //     var totalPage = Math.ceil(customerList.length / dividePageCount);
    //     // var pageCount = Math.floor(customerList.length / dividePageCount);
        
    //     var pageList = [];
    //     var pageAllCountList = [];
    //     var pageCountList = [];

    //     for (let i = 0; i < totalPage; i++) {
    //         if(pageCountList.length == 10){
    //             pageAllCountList.push(pageCountList);
    //             pageCountList = [];
    //         }
    //         pageCountList.push(i);
    //         var objList = customerList.slice(i * dividePageCount, (i + 1) * dividePageCount);
    //         pageList.push(objList);

    //     }
    //     pageAllCountList.push(pageCountList);

    //     component.set('v.pageAllCountList', pageAllCountList); // 2중배열 형태로 페이지 나열을 위한 List [[0 ~ 9], [10 ~ 19], ... , [나머지]]
    //     component.set('v.pageCountList', pageAllCountList[0]); // 페이지 나열을 위한 List
    //     component.set('v.pageList', pageList); // 2중배열의 형태로 [[1Page의 20개], [2Page의 20개], ... , [마지막 Page의 ?개]]

    //     component.set('v.allResultCount', customerList.length); // 인터페이스로 가지고 온 총 갯수
    //     component.set('v.totalPage', totalPage); // 인터페이스로 가지고 온 List의 총 Page 갯수
    //     component.set('v.customerList', pageList[0]); // 1Page에서 보여줄 iteration할 List
    // },
    
    // handleChangePage: function (component, event, helper) {
    //     var pageCountListIndex = component.get('v.pageCountListIndex'); // pageCountList의 Index
    //     var pageAllCountList = component.get('v.pageAllCountList'); // 2중 배열
    //     var changePage = Number(event.target.value); // 바뀔 Page번호
    //     var name = event.target.name; // 바뀔 Page번호       
    //     var pageList = component.get('v.pageList'); // 2중 배열

    //     if (name == 'first') {
    //         changePage = 1;
    //         pageCountListIndex = 0;
    //     } else if (name == 'previous') {
    //         pageCountListIndex--;
    //         if (pageCountListIndex < 0) {
    //             pageCountListIndex = 0;
    //             changePage = pageAllCountList[pageCountListIndex][0] + 1;
    //         } else {
    //             changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
    //         }
    //     } else if (name == 'next') {
    //         pageCountListIndex++;
    //         if (pageCountListIndex >= pageAllCountList.length) {
    //             pageCountListIndex = pageAllCountList.length - 1;
    //             changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
    //         } else {
    //             changePage = pageAllCountList[pageCountListIndex][0] + 1;
    //         }
    //     } else if (name == 'last') {
    //         changePage = pageList.length;
    //         pageCountListIndex = pageAllCountList.length - 1;
    //     }

    //     component.set('v.currentPage', changePage); // 바뀔 Page번호
    //     component.set('v.pageCountList', pageAllCountList[pageCountListIndex]); // 바뀔 pageCountList
    //     component.set('v.pageCountListIndex', pageCountListIndex); // 바뀔 pageCountList의 Index
    //     component.set('v.customerList', pageList[changePage - 1]); // 바뀔 Page에 해당하는 iteration할 List 
    // },


})