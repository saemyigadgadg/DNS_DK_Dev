({
    doInit : function(component, event, helper) {
        var today = new Date();
        var browserTimeZoneOffset = new Date().getTimezoneOffset();

        today.setMinutes(today.getMinutes() - browserTimeZoneOffset);

        component.set("v.startDate",    today.toISOString().slice(0, 10));
        component.set("v.endDate",      today.toISOString().slice(0, 10));
        console.log('startDate : ', component.get('v.startDate'));
        console.log('endDate : ', component.get('v.endDate'));
    },

    handleSearch : function(component, event, helper) {
        component.set('v.isLoading', true);

        var sampleList = [
            {
                'status'            : 'TEST', 
                'plant'             : 'TEST', 
                'certUpLoad'        : 'TEST', 
                'invoiceNo'         : 'TEST001', 
                'employeeName'      : '홍길동',
                'amount'            : '120000', 
                'curr'              : 'KRW', 
                'qty'               : '2', 
                'unit1'             : 'TEST', 
                'grossWeight'       : 'TEST',  
                'unit2'             : 'TEST',
                'downloadStatus'    : 'TEST', 
                'bond'              : 'TEST', 
                'noDraft'           : 'TEST', 
                'soldToParty'       : 'TEST', 
                'etd'               : 'TEST',
                'legalAction'       : 'TEST', 
                'declarationDate'   : '2024-05-05', 
                'vendor'            : 'TEST', 
                'cbm'               : 'TEST', 
                'unit3'             : 'TEST', 
                'certNo'            : 'TEST0101'
            }
        ];

        var resultList = [];
        for (let i = 0; i < 280; i++) {
            sampleList.forEach(element => {
                resultList.push(element);
            });
        }

        component.set('v.resultList',   resultList);
        component.set('v.isSearched',   true);

        // paging을 위한 로직 
        try {
            var dividePageCount = component.get('v.dividePageCount'); // Page당 보여주고 싶은 갯수
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

            component.set('v.pageAllCountList',     pageAllCountList);      // 2중배열 형태로 페이지 나열을 위한 List [[0 ~ 9], [10 ~ 19], ... , [나머지]]
            component.set('v.pageCountList',        pageAllCountList[0]);   // 페이지 나열을 위한 List
            component.set('v.pageList',             pageList);              // 2중배열의 형태로 [[1Page의 20개], [2Page의 20개], ... , [마지막 Page의 ?개]]
            component.set('v.allResultCount',       resultList.length);     // 인터페이스로 가지고 온 총 갯수
            component.set('v.resultList',           resultList);            // 인터페이스로 가지고 온 전체 List
            component.set('v.totalPage',            totalPage);             // 인터페이스로 가지고 온 List의 총 Page 갯수
            component.set('v.pagingResultList',     pageList[0]);           // 1Page에서 보여줄 iteration할 List

        } catch (error) {
            console.log('Paging Error', error);
        }
        component.set('v.isLoading',    false);
    },

    handleSelect : function(component, event, helper) {
        var checkbox        = component.find('checkbox');
        var resultList      = component.get('v.resultList');
        var selectedList    = [];

        for (var i = 0; i < checkbox.length; i++) {
            if (checkbox[i].get("v.checked")) {
                selectedList.push(resultList[i]);
            }
        }
        component.set('v.selectedList', selectedList);
        console.log('selectedList ::: ' + JSON.stringify(component.get('v.selectedList')));
    },

    handleSelectAll : function(component, evnet, helper) {
        var checkboxes  = component.find('checkbox');
        var isChecked   = component.find('headerCheckbox').get('v.checked');
        var resultList  = component.get('v.resultList');
        var pList       = [];
        
        if (isChecked == true) {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox, index) {
                    checkbox.set('v.checked', isChecked);
                    pList.push(resultList[index]);
                });
            } else {
                checkboxes.set('v.checked', isChecked);
                pList.push(0);
            }
        } else {
            if (Array.isArray(checkboxes)) {
                checkboxes.forEach(function (checkbox) {
                    checkbox.set('v.checked', isChecked);
                });
            } else {
                checkboxes.set('v.checked', isChecked);
            }
            pList = [];
        }
        component.set('v.selectedList', pList);
        console.log('selectedList ::: ' + JSON.stringify(component.get('v.selectedList')));
    },

    handleChangeUploadRadio : function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        console.log('handleChangeUploadRadio ', selectedValue);

        component.set('v.uploadRadiovalue', selectedValue);
    },

    handleChangeCertRadio : function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        console.log('handleChangeCertRadio ', selectedValue);

        component.set('v.certRadiovalue', selectedValue);
    },

    handleClickUpload : function(component, event, helper) {
        var isTrue = component.get('v.isClickUpload');
        component.set('v.isClickUpload', !isTrue);
    },

    handleCompEvent: function (component, event, helper) {
        var modalName   = event.getParam("modalName");
        var action      = event.getParam("actionName");
        var message     = event.getParam("message");

        if(modalName == 'DN_CustomsClearancePlantModal') {
            if(action == 'handleClickRow') component.set('v.plant', message);
        }
    },

    handleShipDocInvoiceModal : function (component, event, helper) {
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_CustomsClearanceShipDocInvoiceModal",
            {},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ShipDocInvoiceModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        component.set("v.isLoading", false);
    },

    handlePlantModal : function (component, event, helper) {
        component.set("v.isLoading", true);
        $A.createComponent("c:DN_CustomsClearancePlantModal",
            {},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("PlantModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
        component.set("v.isLoading", false);
    },

    handleChangePage: function (component, event, helper) {
        try {
            var pageCountListIndex  = component.get('v.pageCountListIndex');    // pageCountList의 Index
            var pageAllCountList    = component.get('v.pageAllCountList');      // 2중 배열
            var changePage          = Number(event.target.value);               // 바뀔 Page번호
            var name                = event.target.name;                        // 바뀔 Page번호
            var pageList            = component.get('v.pageList');              // 2중 배열

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
    
    handleScroll : function(component, event, helper) {          
        var table2 = event.target; 
        var scrollY = table2.scrollTop; 
        var table1 = component.find('leftTableDiv').getElement(); 
        table1.scrollTo({top:scrollY, left:0, behavior:'auto'}); 
    },
})