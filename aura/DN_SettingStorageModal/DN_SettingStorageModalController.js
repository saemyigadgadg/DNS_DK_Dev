/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 01-10-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-06-04   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        var parts = component.get('v.parts');
        var type = component.get('v.type');
        //console.log('parts', JSON.stringify(parts));
        //console.log('type', type);
        component.set('v.uuid',self.crypto.randomUUID());
        helper.apexCall(component,event,this, 'getInit', {
        })
        .then($A.getCallback(function(result) {
            let { r, state } = result;
            //console.log(JSON.stringify(r), ' < ==rrr');
            //console.log(r.user[0],' ::: r.user[0]');
            component.set('v.user',null);
            component.set('v.user', r.user[0]);
            let resultList = [];
            resultList = r.locationList;
            component.set('v.totalSize', r.total.length)
            if (type == 'Create') {
                component.set('v.storageList', resultList);
                let newStorageList = [{ 'Loc1__c' : '', 
                    'Loc2__c' : '', 
                    'Loc3__c' : '', 
                    'Loc4__c' : '', 
                    'Loc5__c' : '', 
                    'Loc6__c' : '', 
                    'Description__c' : ''
                }]
                component.set('v.seletedList', []);
                component.set('v.newStorageList', newStorageList);
                
            } else if (type == 'Setting') {
                // paging을 위한 로직
                try {
                    var dividePageCount = component.get('v.dividePageCount'); // Page당 보여주고 싶은 갯수
                    var totalPage = Math.ceil(resultList.length / dividePageCount);
        
                    var pageList = [];
                    var pageAllCountList = [];
                    var pageCountList = [];
        
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
        
                    component.set('v.pageAllCountList', pageAllCountList); // 2중배열 형태로 페이지 나열을 위한 List [[0 ~ 9], [10 ~ 19], ... , [나머지]]
                    component.set('v.pageCountList', pageAllCountList[0]); // 페이지 나열을 위한 List
                    component.set('v.pageList', pageList); // 2중배열의 형태로 [[1Page의 20개], [2Page의 20개], ... , [마지막 Page의 ?개]]
                    component.set('v.allResultCount', resultList.length); // 인터페이스로 가지고 온 총 갯수
                    component.set('v.totalPage', totalPage); // 인터페이스로 가지고 온 List의 총 Page 갯수
                    component.set('v.storageList', pageList[0]); // 1Page에서 보여줄 iteration할 List
                    //console.log(pageList[0],' ::: pageList[0]');
                } catch (error) {
                    console.log('Error', error);
                }
            }
            component.set('v.isLoading', false);
        })).catch(function(error) {
            component.set('v.isLoading', false);
            console.log('# addError error : ' + error.message);
        });



        
    },

    handleChangePage: function (component, event, helper) {
        // 페이지 이동
        try {
            var pageCountListIndex = component.get('v.pageCountListIndex'); // pageCountList의 Index
            var pageAllCountList = component.get('v.pageAllCountList'); // 2중 배열
            var changePage = event.target.value; // 바뀔 Page번호
            var name = event.target.name; // 바뀔 Page번호
            var pageList = component.get('v.pageList'); // 2중 배열
            //console.log('pageCountListIndex', pageCountListIndex);
            //console.log('pageAllCountList.length', pageAllCountList.length);
            //console.log('changePage', changePage);
            if (name == 'first') {
                changePage = 1;
                pageCountListIndex = 0;
            } else if (name == 'previous') {
                pageCountListIndex--;
                if (pageCountListIndex < 0) {
                    pageCountListIndex = 0;
                    changePage = pageAllCountList[pageCountListIndex][0] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                }
            } else if (name == 'next') {
                pageCountListIndex++;
                if (pageCountListIndex >= pageAllCountList.length) {
                    pageCountListIndex = pageAllCountList.length - 1;
                    changePage = pageAllCountList[pageCountListIndex][pageAllCountList[pageCountListIndex].length - 1] + 1;
                } else {
                    changePage = pageAllCountList[pageCountListIndex][0] + 1;
                }
            } else if (name == 'last') {
                changePage = pageList.length;
                pageCountListIndex = pageAllCountList.length - 1;
            }

            component.set('v.currentPage', Number(changePage)); // 바뀔 Page번호
            component.set('v.pageCountListIndex', pageCountListIndex); // 바뀔 pageCountList의 Index
            component.set('v.pageCountList', pageAllCountList[pageCountListIndex]); // 바뀔 pageCountList
            component.set('v.storageList', pageList[changePage - 1]); // 바뀔 Page에 해당하는 iteration할 List

        } catch (error) {
            console.log('Error', error);
        }

    },

    settingStorageModalCancel: function (component, event, helper) {
        helper.closeModal(component);
    },

    addNewStorageRow: function (component, event, helper) {
        var newStorageList = component.get('v.newStorageList');

        var newStorage = {
            'Loc1__c' : '', 
            'Loc2__c' : '', 
            'Loc3__c' : '', 
            'Loc4__c' : '', 
            'Loc5__c' : '', 
            'Loc6__c' : '', 
            'Description__c' : ''
        };

        newStorageList.push(newStorage);
        component.set('v.newStorageList', newStorageList);
    },

    deleteNewStorageRow: function (component, event, helper) {
        var rowIndex = event.getSource().get('v.accesskey');
        var newStorageList = component.get("v.newStorageList");
        newStorageList.splice(rowIndex, 1);
        //console.log(JSON.stringify(newStorageList),' :: newStorageList');
        component.set('v.newStorageList', newStorageList);
        //seletedList
        let seletedSet = [];
        let selected = component.find('seletedList');
        selected.forEach( (element,index) => {
            if(element.get('v.checked')) {
                ///console.log(index, ' index ::');
                if(newStorageList[index] !=null) {
                    seletedSet.push(newStorageList[index]);
                }
                
            }
        });
        //console.log(JSON.stringify(seletedSet),' :: seletedSet');
        component.set("v.seletedList", seletedSet); 
    },

    deleteStorageRow: function (component, event, helper) {
        let rowIndex = event.currentTarget.accessKey;
        rowIndex = parseInt(rowIndex, 10);
        let storageList = component.get("v.storageList");
        //컨핌창
        
        helper.openConfirm('저장 위치를 삭제하시겠습니까?', 'default', 'headerless')
        .then($A.getCallback(function(result) {
            if(result) {
                // true -> 처리 로직 구현
                component.set('v.isLoading', true);
                helper.apexCall(component,event,this, 'deleteLocation', {
                    recordId : storageList[rowIndex].Id
                }).then($A.getCallback(function(result) {
                    let modalEvent = component.getEvent('cmpEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_SettingStorageModal',
                        "actionName"    : 'Create',
                        "message"       : {'parentCmp' : 'DN_DealerPortalDisplay'}
                    });
                    modalEvent.fire();
                    var action = component.get('c.doInit');
                    $A.enqueueAction(action);
                })).catch(function(error) {
                    console.log('# addError error : ' + error.message);
                });
            }
        }))
        .catch(error => {
            console.error("Error during confirmation:", error);
        });
       
        //storageList.splice(rowIndex, 1);
        
        //component.set("v.storageList", storageList);
    },

    selectAll: function (component, event, helper) {
        var checkboxes = component.find("checkbox2");
        //console.log('checkboxes', JSON.stringify(checkboxes));
        var isChecked = component.find("headerCheckbox2").get("v.checked");
        var checkList = [];

        // 모든 체크박스의 상태를 변경합니다.
        if (isChecked == true) {
            checkboxes.forEach(function (checkbox) {
                checkbox.set("v.checked", isChecked);
            });
            var storageList = component.get('v.storageList');
            ///console.log(storageList);
            storageList.forEach(function (storage) {
                ///console.log(storage);
                checkList.push(storage);
            });
        } else if (isChecked == false) {
            checkboxes.forEach(function (checkbox) {
                checkbox.set("v.checked", isChecked = false);
            })
            checkList = [];
            //console.log('checkList', checkList);
        }
        component.set('v.selectedStorages', checkList);
    },

    checkNewStorageLOC: function (component, event, helper) {
        component.set('v.isModalLoading', true);
        var newStorageList = component.get('v.newStorageList');
        var storageList = component.get('v.storageList');
        var insertStorageList = [];
        var isCheck = true;
        if (newStorageList.length == 0) {
            helper._showToast(component, 'error', 'Error', '저장위치1이 기입되지 않은 Row가 있습니다.');
        } else {
            for (let i = 0; i < newStorageList.length; i++) {
                var storage = newStorageList[i];
                var loc1 = storage.LOC1.split(' ')[0];
                var loc2 = storage.LOC2.split(' ')[0];
                var loc3 = storage.LOC3.split(' ')[0];
                var loc4 = storage.LOC4.split(' ')[0];
                var loc5 = storage.LOC5.split(' ')[0];
                var loc6 = storage.LOC6.split(' ')[0];

                var loc = loc1 + '-' + loc2 + '-' + loc3 + '-' + loc4 + '-' + loc5 + '-' + loc6;

                while (loc.slice(-1) == '-') {
                    loc = loc.slice(0, -1);
                }

                loc = loc.toLocaleUpperCase();
                //console.log('loc', loc);

                if (isCheck) {

                    if (loc.startsWith('-')) {
                        helper._showToast(component, 'error', 'Error', '저장위치1이 기입되지 않은 Row가 있습니다.');
                        break;
                    } else if (loc.includes('--')) {
                        helper._showToast(component, 'error', 'Error', '저장위치는 순차로 기입되어야 합니다.');
                        break;
                    }

                    ///console.log('i', i);

                    for (let j = 0; j < storageList.length; j++) {
                        var checkLoc = storageList[j].LOC;
                        if (checkLoc == loc) {
                            helper._showToast(component, 'error', 'Error', loc + '가 중복됩니다.');
                            isCheck = false;
                            break;
                        }
                        //console.log('j', j);
                    }
                } else {
                    break;
                }

                if (loc != '' && loc != null && isCheck) {
                    storage.LOC = loc;
                    storage.LOC1 = loc1;
                    storage.LOC2 = loc2;
                    storage.LOC3 = loc3;
                    storage.LOC4 = loc4;
                    storage.LOC5 = loc5;
                    storage.LOC6 = loc6;
                    insertStorageList.push(storage);
                }
            }
            storageList.push(...insertStorageList);

            ///console.log(storageList);
            component.set('v.storageList', storageList);
        }

        component.set('v.isModalLoading', false);

    },

    handleChangeNewStorageLOC: function (component, event, helper) {
        let index = event.getSource().get('v.name');
        let allData = component.get('v.newStorageList');
        allData[index].Loc1__c = allData[index].Loc1__c.toUpperCase();
        allData[index].Loc2__c = allData[index].Loc2__c.toUpperCase();
        allData[index].Loc3__c = allData[index].Loc3__c.toUpperCase();
        allData[index].Loc4__c = allData[index].Loc4__c.toUpperCase();
        allData[index].Loc5__c = allData[index].Loc5__c.toUpperCase();
        allData[index].Loc6__c = allData[index].Loc6__c.toUpperCase();
        component.set('v.newStorageList',allData);
    },

    handleCheckboxChange: function (component, event, helper) {
        var checkbox = component.find('checkbox2');
        var index = event.target.name;
        var selectedIndex = component.get('v.selectedIndex');
        if (checkbox[index]) {
            if (selectedIndex == null) {
                component.set('v.selectedIndex', index);
            } else {
                if (index != selectedIndex) {
                    checkbox[selectedIndex].set('v.checked', false);
                    component.set('v.selectedIndex', index);
                }
            }
        }
        var storageList = component.get('v.storageList');
        component.set('v.selectLOC', storageList[index].LOC);

    },

    // handleCheckbox2Change: function (component, event, helper) {
    //     var checkbox = component.find('checkbox2');
    //     var selectedStorages = [];
    //     for (var i = 0; i < checkbox.length; i++) {
    //         if (checkbox[i].get("v.checked")) {
    //             selectedStorages.push(i);
    //         }
    //     }
    //     var isChecked = component.find("headerCheckbox2").get("v.checked");

    //     if (isChecked == true) {
    //         component.find("headerCheckbox2").set("v.checked", false);
    //     }

    //     component.set('v.selectedStorages', selectedStorages);
    // },

    // 설정/변경
    handleSettingButton: function (component, event, helper) {
        var checkbox = component.find('checkbox2');
        var selectedIndex = component.get('v.selectedIndex');
        var storageList = component.get('v.storageList');
        //console.log('selectedIndex', selectedIndex);
        var selectedCheck = selectedIndex != null ? checkbox[selectedIndex].get('v.checked') : false;
        ///console.log('selectedCheck', selectedCheck);
        if (selectedCheck) {
            let storage ='';
            // 검색
            if (selectedIndex == 0) {
                let fmLoc ='';
                fmLoc += component.get('v.settingLOC1') ==''? '' : component.get('v.settingLOC1');
                fmLoc += component.get('v.settingLOC2') ==''? '' : '-'+component.get('v.settingLOC2');
                fmLoc += component.get('v.settingLOC3') ==''? '' : '-'+component.get('v.settingLOC3');
                fmLoc += component.get('v.settingLOC4') ==''? '' : '-'+component.get('v.settingLOC4');
                fmLoc += component.get('v.settingLOC5') ==''? '' : '-'+component.get('v.settingLOC5');
                fmLoc += component.get('v.settingLOC6') ==''? '' : '-'+component.get('v.settingLOC6');
                storage = fmLoc;
                //console.log(fmLoc,' < ---fmLoc');
            } else {
                storage = storageList[selectedIndex - 1].FM_Loc__c;
            }
            // 설정/변경 검색
            helper.apexCall(component,event,this, 'getSettingCheck', {
                fmLoc : storage,
                part : component.get('v.parts').partId,
            })
            .then($A.getCallback(function(result) {
                helper._showToast(component, 'success', 'success', '저장위치가 설정되었습니다.');
                let modalEvent = component.getEvent('modalEvent');
                    modalEvent.setParams({
                        "modalName"     : 'DN_SettingStorageModal',
                        "actionName"    : 'Save',
                        "message"       : 'Save'
                    });
                    modalEvent.fire();
                    helper.closeModal(component);
                //console.log('저장완료')
                // var action = component.get('c.doInit');
                // $A.enqueueAction(action);
                
            })).catch(function(error) {
                helper._showToast(component, 'error', 'Error', error[0].message);
                console.log('# addError error : ' + error.message);
            });
            
        } else {
            helper._showToast(component, 'error', 'Error', '설정/변경할 항목을 선택해주세요.');
        }
    },
    //생성 모두 선택
    selectAllCheck: function (component, event, helper) {
        let selectAllChecked = event.getSource().get("v.checked");
        let checkboxes = component.find("seletedList");

        if (!Array.isArray(checkboxes)) {
            checkboxes = [checkboxes];
        }

        checkboxes.forEach(function (checkbox) {
            checkbox.set("v.checked", selectAllChecked);
        });

        let newStorageList = component.get("v.newStorageList");
        if (selectAllChecked) {
            component.set("v.seletedList", [...newStorageList]); 
        } else {
            component.set("v.seletedList", []); 
        }
    },
    // 생성 선택
    selected: function (component, event, helper) {
        let seleted = event.getSource();
        let allList = component.get('v.newStorageList');
        let index = seleted.get('v.name');
        let seletedList = component.get('v.seletedList');//seletedList //allList[seleted]
        
        if(seleted.get('v.checked')) {
            seletedList.push(allList[index]);
        } else {
            seletedList = seletedList.filter(item => item !== allList[index]);
        }
        component.set('v.seletedList',seletedList);
        
    },
    
    // 생성 버튼
    handleCreateStorage: function (component, event, helper) {
        let newStorageList = component.get('v.seletedList');
        //console.log(JSON.stringify(newStorageList),' < ==newStorageList.length');
        let isCheck = false;
        component.set('v.isModalLoading', true);
        //val
        if(newStorageList.length == 0 ) {
            helper._showToast(component, 'error', 'Error', '설정/변경할 항목을 선택해주세요.'); 
            component.set('v.isModalLoading', false);
        } else {
            newStorageList.forEach(element => {       
                if(element.Loc1__c=='') {
                    helper._showToast(component, 'error', 'Error', '저장위치1에 값을 입력하세요');
                    isCheck = true;
                    component.set('v.isModalLoading', false);
                    return;
                } else{
                    element.Dealer__c = component.get('v.user').AccountId;//component.set('v.user', r.user);
                    component.set('v.isModalLoading', false);
                }
            });
            // // 생성 목록에서 중복확인
            // if (newStorageList.length > 1) {
            //     // 중복 확인을 위한 Set 생성
            //     let uniqueSet = new Set();
            //     let hasDuplicate = false;
            
            //     newStorageList.forEach(element => {
            //         if (uniqueSet.has(element.Loc1__c)) {
            //             hasDuplicate = true;
            //         } else {
            //             uniqueSet.add(element.Loc1__c); // 중복이 아니면 Set에 추가
            //         }
            //     });
            
            //     if (hasDuplicate) {
            //         isCheck = true;
            //         helper._showToast(component, 'error', 'Error', '저장위치 중복값이 있습니다.');
            //         component.set('v.isModalLoading', false);
            //         return;
            //     }
            //     component.set('v.isModalLoading', false);
            // }
            if(!isCheck) {
                // 설정/변경 검색
                helper.apexCall(component,event,this, 'insertLocationCheck', {
                    locList : newStorageList,
                })
                .then($A.getCallback(function(result) {
                    helper.openConfirm('생성가능한 저장위치입니다. 저장 위치를 생성하시겠습니까?', 'default', 'headerless')
                    .then($A.getCallback(function(result) {
                        if(result) {
                            helper.apexCall(component,event,this, 'insertLocation', {
                                locList : newStorageList,
                            })
                            .then($A.getCallback(function(result) {

                            })).catch(function(error) {
                                helper._showToast(component, 'error', 'Error', error[0].message);
                                console.log('# addError error : ' + error.message);
                                component.set('v.isModalLoading', false);
                            });
                            newStorageList = [{ 'Loc1__c' : '', 
                                'Loc2__c' : '', 
                                'Loc3__c' : '', 
                                'Loc4__c' : '', 
                                'Loc5__c' : '', 
                                'Loc6__c' : '', 
                                'Description__c' : ''
                            }]
                            component.set('v.seletedList', []);
                            component.set('v.newStorageList', newStorageList);
                            component.find('CreatedCheckbox').set('v.checked', false);
                            //console.log(component.get('v.newStorageList'),' > 111');
                            let modalEvent = component.getEvent('cmpEvent');
                            modalEvent.setParams({
                                "modalName"     : 'DN_SettingStorageModal',
                                "actionName"    : 'Create',
                                "message"       : {'parentCmp' : 'DN_DealerPortalDisplay'}
                            });
                            modalEvent.fire();
                            var action = component.get('c.doInit');
                            $A.enqueueAction(action);
                            component.set('v.isModalLoading', false);
                        }
                    }))
                    .catch(error => {
                        console.error("Error during confirmation:", error);
                    });
                    
                })).catch(function(error) {
                    helper._showToast(component, 'error', 'Error', error[0].message);
                    console.log('# addError error : ' + error.message);
                    component.set('v.isModalLoading', false);
                });
            }
            
        }        
    },
   
})