({
    init : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        if (pageReference) {
            //InboundCall로 고객조회하는 경우
            var state = pageReference.state; 
            console.log('state', state);
            component.set('v.contactId',state.c__contactId);
            component.set('v.taskId',state.c__taskId);
            component.set('v.uId',state.c__uid);
            helper.searchContact(component);
        }
    },
    //입력한 정보를 기반으로 장비목록 조회
    handleSearch : function(component, event, helper) {
        var accountKey = component.get('v.accountKey');
        var assetTerm = component.get('v.assetTerm');

        //조건 입력 없이 검색하면 조건 입력 ErrorMsg 발생
        if($A.util.isEmpty(accountKey) && $A.util.isEmpty(assetTerm)){
            helper.toast(component, $A.get("$Label.c.DNS_M_EnterSearchCondition") , 'ERROR', 'Error');
            return null;
        }
        
        //장비정보 입력은 최소4글자
        if(!$A.util.isEmpty(assetTerm) && assetTerm.length<4){
            helper.toast(component, '장비정보는 4글자 이상 입력해주세요.' , 'ERROR', 'Error');
            return null;
        }

        //배열형태면 String으로 변환
        if (Array.isArray(accountKey)) {
            accountKey = accountKey.toString();
        }

        var keyJson = {
            accountKey : accountKey,
            assetTerm : assetTerm,
        }
        var keyData = JSON.stringify(keyJson);
        

        component.set('v.isSpinner', true);
        helper.apex(component, "getSearchResult", {
            keyData : keyData
        })
        .then(function(result){
            console.log('getSearchResult',result);
            if(result.isSuccess){
                if(result.returnList.length > 0){
                    // console.log('@@ result.returnList : ' + JSON.stringify(result.returnList));
                    component.set('v.searchList', result.returnList);
                    component.set('v.isSpinner', false);
                }else{
                    helper.toast(component, result.msg, 'INFO', 'Info');//조회된 장비X Msg
                    component.set('v.searchList', []);
                    component.set('v.isSpinner', false);
                }
        }
        });      
    },
    //장비 체크박스 하나만 선택
    handleCheck : function(component, event, helper) {
        var isChecked = event.getParam('checked');
        if(isChecked){
            component.set('v.equipmentId', event.target.name);
            console.log('equipmentId', event.target.name);
            var chekcbox = document.querySelectorAll('.checkbox');
            [...chekcbox].forEach(ch => {
                if(ch !== event.target){
                    ch.checked = false;
                }
            });
        }
    },
    //Footer의 Cancel Btn 클릭시, Tab 닫기
    handleCancel : function(component, event, helper) {
        helper.closeTab(component);
    },
    //선택한 장비로 등록된 Ticket 목록 조회
    handleNext : function(component, event, helper){
        //====더블클릭 방지=====
        let lastClickedTime = component.get("v.lastClickedTime");
        let currentTime = new Date().getTime();
        if (lastClickedTime && (currentTime - lastClickedTime) < 1000) {
            console.log("Double-click detected! Ignored.");
            return;
        }
        component.set("v.lastClickedTime", currentTime);
        //====더블클릭 방지=====

        var isNext = false;
        var chekcbox = document.querySelectorAll('.checkbox');
        [...chekcbox].forEach(ch =>{
            if(ch.checked){
                isNext = true;
            }       
        });

        //검색조건 저장
        var searchCondition = {
            accountKey : component.get('v.accountKey'),
            assetTerm : component.get('v.assetTerm'),
        }
        component.set('v.searchCondition',searchCondition);
        
        if(isNext){
            component.set('v.isSpinner', true);

            var keyJson = {
                assetId : component.get('v.equipmentId'),
                taskId : component.get('v.taskId'),
                caller : component.get('v.contactId'),
                recType : component.get('v.recType'),
                uId : component.get('v.uId'),
            }
            
            //선택된 장비정보로 Ticket 목록 조회
            helper.apex(component, "getTicketList", {
                keyData : JSON.stringify(keyJson)
            })
            .then(function(result){
                console.log('getTicketList',result);
                if(result.isNew){
                    helper.toast(component, result.msg, 'SUCCESS', 'Success');
                    //Ticket이 없는 경우 새로 생성
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                        helper.toast(component, result.msg, 'SUCCESS', 'Success');
                        helper.openTab(component, workspaceAPI, result.returnList[0].Id);
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                }else if((result.isSuccess == true) && (result.isNew == false)){
                    component.set('v.ticketList', result.returnList);
                    component.set('v.accountKey', result.returnList[0].AccountId);
                    component.set('v.assetKey', result.returnList[0].AssetId);
                    component.set('v.isSpinner', false);
                    component.set('v.isNext', true);
                }else{
                    console.log('error', result.errMessage);
                    helper.toast(component, 'Error :'+result.msg, 'ERROR', 'Error');
                    component.set('v.isSpinner', false);
                }
            });     
        }else{
            helper.toast(component, $A.get("$Label.c.DNS_M_SelectOption"), 'ERROR', 'Error');
        }
    },
    //장비 더블클릭시, 해당 장비와 관련된 Ticket 목록 화면으로 이동
    handleDoubleClick : function(component, event, helper){
        var selectedItem = event.currentTarget;       
        console.log('data id', selectedItem.dataset.id);
        component.set('v.equipmentId', selectedItem.dataset.id);

        var chekcbox = document.querySelectorAll('.checkbox');
        [...chekcbox].forEach(ch => {
            if(ch.name == selectedItem.dataset.id){
                ch.checked = true;
            }else{
                ch.checked = false;
            }
        });

        var searchCondition = {
            accountKey : component.get('v.accountKey'),
            assetKey : component.get('v.assetKey'),
            assetTerm : component.get('v.assetTerm'),
            phoneKey : component.get('v.phoneKey'),
            contactKey : component.get('v.contactKey'),
        }
        component.set('v.searchCondition',searchCondition);
        
        component.set('v.isSpinner', true);
        var keyJson = {
            assetId : component.get('v.equipmentId'),
            taskId : component.get('v.taskId'),
            caller : component.get('v.contactId'),
            recType : component.get('v.recType'),
            uId : component.get('v.uId'),
        }
        console.log(JSON.stringify(keyJson));
        
        //선택된 장비정보로 Ticket 목록 조회
        helper.apex(component, "getTicketList", {
            keyData : JSON.stringify(keyJson)
        })
        .then(function(result){
            console.log('getTicketList',result);
            if(result.isNew){
                //Ticket이 없는 경우 새로 생성
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                    helper.toast(component, result.msg, 'SUCCESS', 'Success');
                    helper.openTab(component, workspaceAPI, result.returnList[0].Id);
                })
                .catch(function(error) {
                    console.log(error);
                });
                
            }else if((result.isSuccess == true) && (result.isNew == false)){
                //기존 Ticket이 있으면 Ticket 목록 출력
                component.set('v.ticketList', result.returnList);
                component.set('v.accountKey', result.returnList[0].AccountId);
                component.set('v.assetKey', result.returnList[0].AssetId);
                component.set('v.isSpinner', false);
                component.set('v.isNext', true);
            }else{
                console.log('error', result.errMessage);
                helper.toast(component, 'Error :'+result.msg, 'ERROR', 'Error');
                component.set('v.isSpinner', false);
            }
        }); 
    },
    //Ticket 목록에서 Ticket 선택
    hadleTicket : function(component, event, helper){
        var isChecked = event.getParam('checked');
        if(isChecked){
            component.set('v.ticketId', event.target.name);
            var chekcbox = document.querySelectorAll('.ticketbox');
            [...chekcbox].forEach(ch => {
                if(ch !== event.target){
                    ch.checked = false;
                }
            });
        }
    },
    //선택한 Ticket 상세화면으로 이동 & Task 연결
    handleSelect : function(component, event, helper){
        console.log('handleSelect');
        helper.preventDbClick(component);//더블클릭 방지
        
        var isNext = false;
        var chekcbox = document.querySelectorAll('.ticketbox');
        [...chekcbox].forEach(ch =>{
            if(ch.checked){
                isNext = true;
            }       
        });
        
        if(isNext){
            component.set('v.isSpinner', true);
            console.log('ticketId', component.get('v.ticketId'));
            console.log('taskId', component.get('v.taskId'));
            //선택한 Ticket 상세화면으로 이동
            helper.apex(component, "viewSelectedTicket", {
                ticketId : component.get('v.ticketId'),
                taskId : component.get('v.taskId'),
                uId : component.get('v.uId'),
                contactKey : component.get('v.contactKey')
            })
            .then(function(result){
                console.log('viewSelectedTicket',result);
                if(result.isSuccess){
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                        helper.openTab(component, workspaceAPI, result.returnValue);
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                }else{
                    console.log(result.errMessage);
                    helper.toast(component, 'ERROR', 'ERROR', 'Error');
                    component.set('v.isSpinner', false);
                }
            });     
        }else{
            helper.toast(component, $A.get("$Label.c.DNS_M_SelectOption"), 'ERROR', 'Error');
        }
    },
    //선택한 Ticket 더블클릭 시 상세화면으로 이동
    handleTicketDoubleClick : function(component, event, helper){
        var selectedItem = event.currentTarget;       
        console.log('data id', selectedItem.dataset.id);
        component.set('v.ticketId', selectedItem.dataset.id);


        var chekcbox = document.querySelectorAll('.ticketbox');
        [...chekcbox].forEach(ch => {
            if(ch.name == selectedItem.dataset.id){
                ch.checked = true;
            }else{
                ch.checked = false;
            }
        });

        component.set('v.isSpinner', true);
        helper.apex(component, "viewSelectedTicket", {
            ticketId : component.get('v.ticketId'),
            taskId : component.get('v.taskId'),
            uId : component.get('v.uId'),
            contactKey : component.get('v.contactKey')
        })
        .then(function(result){
            console.log('viewSelectedTicket',result);
            if(result.isSuccess){
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                    helper.openTab(component, workspaceAPI, result.returnValue);
                })
                .catch(function(error) {
                    console.log(error);
                });
            }else{
                console.log(result.errMessage);
                helper.toast(component, 'ERROR', 'ERROR', 'Error');
                component.set('v.isSpinner', false);
            }
        });
    },
    //새로운 Ticket 생성
    handleCreate : function(component, event, helper){
        //더블클릭 방지
        helper.preventDbClick(component);//더블클릭 방지

        var keyJson = {
            accountKey : component.get('v.accountKey'),
            assetKey : component.get('v.assetKey'),
            contactKey : component.get('v.contactKey'), 
            taskId : component.get('v.taskId'), 
            caller : component.get('v.contactId'), 
            recType : component.get('v.recType'), 
            uId : component.get('v.uId')
        }
        var keyData = JSON.stringify(keyJson);
        console.log('keyData',keyData);

        component.set('v.isSpinner', true);

        helper.apex(component, "getNewTicket", {
            keyData : keyData
        })
        .then(function(result){
            console.log('createNewTicket', result);
            if(result.isSuccess){
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                    helper.openTab(component, workspaceAPI, result.returnValue);
                })
                .catch(function(error) {
                    console.log(error);
                });
            }else{
                console.log(result.errMessage);
                helper.toast(component, 'ERROR', 'ERROR', 'Error');
                component.set('v.isSpinner', false);
            }
        }); 
    },
    //Ticekt목록에서 장비조회화면으로 이동
    handlePrevious : function(component, event, helper){
        component.set('v.isSpinner', true);
        component.set('v.isNext', false);
        console.log(component.get('v.equipmentId'));
        console.log('searchCondition',component.get('v.searchCondition'));

        var interval = setInterval(function() {
            var chekcbox = document.querySelectorAll('.checkbox');
            if(chekcbox){
                [...chekcbox].forEach(ch => {
                    if (ch.name == component.get('v.equipmentId')) {
                        ch.checked = true;
                    }
                });

                var searchCondition = component.get('v.searchCondition');
                component.set('v.accountKey', searchCondition.accountKey);
                component.set('v.assetKey', searchCondition.assetKey);
                component.set('v.phoneKey', searchCondition.phoneKey);
                component.set('v.contactKey', searchCondition.contactKey);
                component.set('v.isSpinner', false);
                clearInterval(interval);
            }
        }, 100);
    },

    //장비정보 조회조건 Like로 변경
    handleAsset : function(component, event, helper){
        console.log('Asset 입력한 내용 ', event.target.value);
        console.log('assetTerm',component.get('v.assetTerm'));
    },
    handleContact : function(component, event, helper){
        console.log('asdf',event.getParam('value'));
        if(event.getParam('value').length != 0){
            console.log('Contact 입력한 내용 ', event.getParam('value')[0]);
            component.set('v.contactKey',event.getParam('value')[0]);
        }else{
            console.log('contactKey',component.set('v.contactKey', ''));
        }        
    },

    //Contact Modal 창 닫기
    handleModalCancel : function(component, evnet, helper){
        component.set('v.isContact', false);
    },

    //ContactList에서 Contact 선택
    handleContactChb : function(component, event, helper){
        var isChecked = event.getParam('checked');
        if(isChecked){
            component.set('v.contactKey', event.target.name);
            console.log('contactKey', event.target.name);
            var chekcbox = document.querySelectorAll('.contactbox');
            [...chekcbox].forEach(ch => {
                if(ch !== event.target){
                    ch.checked = false;
                }
            });
        }
    },

    //ContactList에서 Contact 선택
    doubleClickContact : function(component, event, helper){
        var selectedItem = event.currentTarget;      
        var chekcbox = document.querySelectorAll('.contactbox');
        [...chekcbox].forEach(ch => {
            if(ch.name == selectedItem.dataset.id){
                ch.checked = true;
                component.set('v.contactKey', selectedItem.dataset.id);
            }else{
                ch.checked = false;
            }
        });
        helper.getAssetInfo(component, selectedItem.dataset.id);
        component.set('v.isContact', false);
    },

    //선택한 Contact ContactKey에 넣기
    selectContact : function(component, event, helper){
        console.log('contactKey', component.get('v.contactKey'));
        var contact = component.get('v.contactKey');
        if(!$A.util.isEmpty(contact)){
            helper.getAssetInfo(component, contact);
            component.set('v.isContact', false);
        }else{
            helper.toast(component, 'ERROR', '연락처를 선택해주세요.', 'Error');
        }
    },

    //sort 
    doSort: function (component, event, helper) {
        component.set('v.isSpinner', true);
        var fieldName = event.currentTarget.dataset.fieldname; // 클릭한 필드 이름 가져오기
        var sortDirection = component.get("v.sortDirection");
        var searchList = component.get("v.searchList");

        console.log('fieldName ::: ',fieldName);
        console.log('sortDirection ::: ',sortDirection);

        // 현재 정렬 방향을 반전시킴
        sortDirection = sortDirection === "asc" ? "desc" : "asc";
        component.set("v.sortDirection", sortDirection);
        component.set("v.sortedBy", fieldName);

        // 정렬 수행
        searchList.sort(function (a, b) {
            var valA = a[fieldName] ? a[fieldName].toString().toLowerCase() : "";
            var valB = b[fieldName] ? b[fieldName].toString().toLowerCase() : "";

            if (sortDirection === "asc") {
                return valA > valB ? 1 : -1;
            } else {
                return valA < valB ? 1 : -1;
            }
        });

        // 정렬된 리스트 업데이트
        component.set("v.searchList", searchList);
        component.set('v.isSpinner', false);
    }
})