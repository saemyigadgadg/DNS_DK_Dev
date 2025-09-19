/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-20
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-07-22   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        
        var recordId = component.get('v.recordId') == '' ? component.get('v.ticketId') : component.get('v.recordId');

        if (component.get('v.recordId') == '') {
            component.set('v.objectName', 'Ticket');
        } else {
            component.set('v.objectName', 'Service Order');
        }

        // console.log('recordId', recordId);
        // console.log('objectName', component.get('v.objectName'));
        helper.apexCall(component, event, helper, 'getInit', {
            recordId : recordId
        }).then($A.getCallback(function(result) {

            let r = result.r;
            // console.log('r', JSON.stringify(r));
            if (!r.isSuccess) {
                helper.toast(r.message, 'Error', 'error');
            }

            component.set('v.accAddress', r.getFirstCenterLocation.accAddress);

            var paramObject = {
                'type' : 'init',
                'centerLat' : Number(r.getFirstCenterLocation.lat),
                'centerLng' : Number(r.getFirstCenterLocation.lng),
                'equipment' : r.getFirstCenterLocation,
                'technician' : {},
                'distance' : '20'
            };

            // component.set('v.searchAddress', r.getFirstCenterLocation.selectAddress);
            component.set('v.srList', r.getFirstCenterLocation.srList);
            component.set('v.srHistoryList', r.getDispatchedHistory);
            component.set('v.affiliationOptions', r.getWorkCenterList);
            component.set('v.workStatusOptions', r.getResourceAbsenceType);
            // component.get('v.distanceFilterTranslate');
            var distanceFilterOptions = [
                {'label' : '5km', 'value' : '5'},
                {'label' : '10km', 'value' : '10'},
                {'label' : '15km', 'value' : '15'},
                {'label' : '20km', 'value' : '20'},
                {'label' : '30km', 'value' : '30'},
                {'label' : '50km', 'value' : '50'},
                {'label' : component.get('v.distanceFilterTranslate'), 'value' : '0'}
            ];
            component.set('v.distanceFilterOptions', distanceFilterOptions);
            
            helper.loadKakaoMap(component, paramObject);

        })).catch(function(error) {
            console.log('Error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    closeLocationModal: function(component, event, helper) {
        helper.closeModal(component);
    },

    handleKeyupSearch: function(component, event, helper) {
        if(event.keyCode === 13) {
            console.log(component.get('v.searchAddress'));
            helper.searchAddressInfo(component, event, helper);
        }

    },

    handleKeyupSearch2: function(component, event, helper) {
        if(event.keyCode === 13) {
            console.log('event.keyCode', event.keyCode);
        }
    },

    searchAddressInfo: function (component, event, helper) {

        helper.searchAddressInfo(component, event, helper);
        
    },

    selectAddress: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.srHistoryList', []);
        component.set('v.srList', []);
        var index = event.target.name;
        var addressList = component.get('v.addressList');
        var paramObject = component.get('v.paramObject');
        var selectAddress = addressList[index].roadAddrPart1;

        helper.apexCall(component, event, helper, 'getSelectAddressEquipment', {
            selectAddress : selectAddress
        }).then($A.getCallback(function(result) {

            var r = result.r;

            // console.log('r.getAddressEquipment.lat ::: ', r.getAddressEquipment.lat);
            // console.log('r.getAddressEquipment.lng ::: ', r.getAddressEquipment.lng);
            if (r.getAddressEquipment.lat == null || r.getAddressEquipment.lng == null) {
                helper.toast('카카오지도에서 가져올 수 없는 주소입니다.', 'Error', 'error');
                component.set('v.isLoading', false);
            } else {
                paramObject.centerLat = Number(r.getAddressEquipment.lat);
                paramObject.centerLng = Number(r.getAddressEquipment.lng);
                paramObject.equipment = r.getAddressEquipment;
                paramObject.type = 'addressClick';
                paramObject.distance = '20';
    
                helper.loadKakaoMap(component, paramObject);
            }

        })).catch(function(error) {
            console.log('Error : ' + error.message);              
        });

    },

    searchTechnicians: function (component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.searchDitance', false);
        component.set('v.selectTechnicianIndex', null);
        component.set('v.drList', []);
        component.set('v.nrList', []);
        component.set('v.currentSortLabel', '');
        component.set('v.currentSortAuraId', '');
        component.set('v.technicianList', []);

        var affiliation = component.get('v.affiliation');
        var workStatus = component.get('v.workStatus');
        var resourceName = component.get('v.resourceName');
        var paramObject = component.get('v.paramObject');
        
        paramObject.technician = {};
        paramObject.type = '';
        paramObject.centerLat = paramObject.equipment.lat;
        paramObject.centerLng = paramObject.equipment.lng;

        var DNS_RTC_SearchName = $A.get('$Label.c.DNS_RTC_SearchName');
        var DNS_RTC_NoReault = $A.get('$Label.c.DNS_RTC_NoReault');

        if (resourceName == null && resourceName == '') {
            helper.toast(DNS_RTC_SearchName, 'Error', 'error');
            component.set('v.isLoading', false);
        } else {
            helper.apexCall(component, event, helper, 'getSearchTechnicians', {
                affiliation : affiliation,
                workStatus : workStatus,
                resourceName : resourceName
            }).then($A.getCallback(function(result) {
    
                let r = result.r;
                var technicianList = r.getTechnicians;
    
                var resultList = [];

                if (technicianList.length > 0) {
    
                    var chunkList = helper.chunkArray(technicianList, 30);

                    chunkList.forEach(techList => {
                        helper.apexCall(component, event, helper, 'getAddressRegioncodes', {
                            resourceList : techList
                        }).then(result2 => {
                            var r2 = result2.r;
                            resultList = [...resultList, r2];
                            // console.log('resultList ::: ', JSON.stringify(resultList.flat()));
                            // console.log('resultList.length ::: ', resultList.length);
    
                        }).catch(error => {
                            console.log('Error2 : ' + JSON.stringify(error));
                        }).finally(() => {
                            if (technicianList.length == resultList.flat().length) {
                                component.set('v.technicianList', resultList.flat());
                                component.set('v.defaultTechnicianList', resultList.flat());
                    
                                helper.loadKakaoMap(component, paramObject);
                            }
                        });
                    });

                    // component.set('v.technicianList', technicianList);
                    // component.set('v.defaultTechnicianList', technicianList);
    
                    // helper.loadKakaoMap(component, paramObject);
                } else {
                    helper.toast(DNS_RTC_NoReault, 'Error', 'error');
                    helper.loadKakaoMap(component, paramObject);
                }
                
    
            })).catch(function(error) {
                console.log('Error : ' + error.message);
            });
        }

    },

    handleChangeTechnicianLoc: function(component, event, helper) {
        component.set('v.isLoading', true);
        try {
            var selectTechnicianIndex = component.get('v.selectTechnicianIndex');
            var index = event.currentTarget.dataset.record;
            var currentSeclectId = document.getElementById('technician' + index);
            var selectId = document.getElementById('technician' + selectTechnicianIndex);

            
            if (selectTechnicianIndex != null && selectTechnicianIndex != index) {
                selectId.classList.remove('clicked');
            } 
            
            component.set('v.selectTechnicianIndex', index);

            // TR AddClass
            currentSeclectId.classList.toggle('clicked');

            var technicianList = component.get('v.technicianList');
            var paramObject = component.get('v.paramObject');
            if (technicianList[index].location != '') {
                paramObject.centerLat = technicianList[index].lat;
                paramObject.centerLng = technicianList[index].lng;
                paramObject.technician = technicianList[index];
                paramObject.type = 'technicianClick';
        
                helper.loadKakaoMap(component, paramObject);
            } else {
                component.set('v.isLoading', false);
            }
            
        } catch (error) {
            console.log('Error : ' + error.message);
        }

    },

    handleCheckboxChange: function (component, event, helper) {
        try {
            var checkbox = component.find('checkbox');
            var checkbox2 = event.getSource();
            var name = event.target.name;
            var technicianIndex;
            var index;
            var technicianList = [];
            // console.log('checkbox ::: ', JSON.stringify(checkbox));
            // console.log('checkbox2 ::: ', JSON.stringify(checkbox2));
            // console.log('name ::: ', name);
            if (Array.isArray(checkbox)) {
                checkbox.forEach((element, i) =>{
                    if (element.getGlobalId() == checkbox2.getGlobalId()) {
                        // console.log('index', i);
                        index = i;
                    } else {
                        element.set('v.checked', false);
                    }
                })
                if (checkbox[index].get('v.checked')) {
                    if (name.includes('dr')) {
                        technicianIndex = Number(name.split('?')[1]);
                        technicianList = component.get('v.drList');
                    } else if (name.includes('srH')) {
                        technicianIndex = Number(name.split('?')[1]);
                        technicianList = component.get('v.srHistoryList');
                    } else if (name.includes('technician')) {
                        technicianIndex = Number(name.split('?')[1]);
                        technicianList = component.get('v.technicianList');
                    }
                    component.set('v.technicianId', technicianList[technicianIndex].id);
                    component.set('v.workcenterId', technicianList[technicianIndex].workcenterId);
                } else {
        
                    component.set('v.technicianId', '');
                    component.set('v.workcenterId', '');
        
                }
            } else {

                if (checkbox.get('v.checked')) {
                    if (name.includes('dr')) {
                        technicianIndex = Number(name.split('?')[1]);
                        technicianList = component.get('v.drList');
                    } else if (name.includes('srH')) {
                        technicianIndex = Number(name.split('?')[1]);
                        technicianList = component.get('v.srHistoryList');
                    } else if (name.includes('technician')) {
                        technicianIndex = Number(name.split('?')[1]);
                        technicianList = component.get('v.technicianList');
                    }
                    component.set('v.technicianId', technicianList[technicianIndex].id);
                    component.set('v.workcenterId', technicianList[technicianIndex].workcenterId);
                } else {
        
                    component.set('v.technicianId', '');
                    component.set('v.workcenterId', '');
        
                }
            }
        } catch (error) {
            console.log('Error : ' + error.message);
        }

    },

    searchDistanceButton: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.searchDitance', true);
        component.set('v.selectTechnicianIndex', null);
        component.set('v.checkIndex', null);
        var distance = component.get('v.distanceFilter');
        var paramObject = component.get('v.paramObject');


        component.set('v.currentSortLabel', '');
        component.set('v.currentSortAuraId', '');
        component.set('v.technicianList', []);

        helper.apexCall(component, event, helper, 'getDistanceTechnicians', {
            distance : distance,
            equipLat : paramObject.equipment.lat,
            equipLng : paramObject.equipment.lng
        }).then($A.getCallback(function(result) {
            var r = result.r;
            var technicianList = r.getTechniciansInDistance.technicianList;
            var drList = r.getTechniciansInDistance.drList;
            var nrList = r.getTechniciansInDistance.nrList;

            component.set('v.drList', drList);
            component.set('v.nrList', nrList);

            paramObject.centerLat = paramObject.equipment.lat;
            paramObject.centerLng = paramObject.equipment.lng;
            paramObject.distance = distance;
            paramObject.technician = {};
            paramObject.type = '';

            var resultList = [];

            // console.log('technicianList.length ::: ', technicianList.length);

            if (technicianList.length > 0) {

                var chunkList = helper.chunkArray(technicianList, 30);

                chunkList.forEach(techList => {
                    helper.apexCall(component, event, helper, 'getAddressRegioncodes', {
                        resourceList : techList
                    }).then(result2 => {
                        var r2 = result2.r;
                        resultList = [...resultList, r2];
                        // console.log('resultList ::: ', JSON.stringify(resultList.flat()));
                        // console.log('resultList.length ::: ', resultList.length);

                    }).catch(error => {
                        console.log('Error2 : ' + JSON.stringify(error));
                    }).finally(() => {
                        if (technicianList.length == resultList.flat().length) {
                            component.set('v.technicianList', resultList.flat());
                            component.set('v.defaultTechnicianList', resultList.flat());
                
                            helper.loadKakaoMap(component, paramObject);
                        }
                    });
                });

            } else {
                component.set('v.technicianList', technicianList);
                component.set('v.defaultTechnicianList', technicianList);
    
                helper.loadKakaoMap(component, paramObject);
            }

        })).catch(function(error) {
            console.log('Error1 : ' + JSON.stringify(error));
        });
    },

    technicianListSorting: function(component, event, helper) {
        var technicianList = component.get('v.technicianList');
        if (technicianList.length > 0) {
            var saveLabel = component.get('v.currentSortLabel');
            var saveAuraId = component.get('v.currentSortAuraId');
    
            var label = event.currentTarget.dataset.label;
            var auraId = event.currentTarget.dataset.id;
    
            // console.log('saveLabel ::: ', saveLabel);
            // console.log('label ::: ', label);
            // console.log('saveAuraId ::: ', saveAuraId);
            // console.log('auraId ::: ', auraId);

            // var test = component.find(auraId);
            // var test2 = event.currentTarget;
            // console.log('test ::: ', test);
            // console.log('test2 ::: ', test2);
            
            if (saveAuraId != '' && saveAuraId != auraId) {
                var typeBoolean = component.get('v.searchDitance');
                if (typeBoolean) {
                    component.find(saveAuraId + 'True').getElements()[0].innerText = saveLabel;
                } else {
                    component.find(saveAuraId).getElements()[0].innerText = saveLabel;
                }
            }
    
            var sortType = component.get('v.technicianListSortType');
    
            if (saveLabel != label) {
                sortType = 0;
            }
    
            sortType += 1;
    
            if (sortType > 2) {
                sortType = 0;
            }
    
            switch (sortType) {
                case 0:
                    event.currentTarget.innerText = label
                    break;
    
                case 1:
                    event.currentTarget.innerText = label + ' ▴';
                    break;
                
                case 2:
                    event.currentTarget.innerText = label + ' ▾';
                    break;
    
            }
    
            // console.log('sortType ::: ', sortType);
            component.set('v.currentSortAuraId', auraId);
            component.set('v.currentSortLabel', label);
            component.set('v.technicianListSortType', sortType);

            if (sortType > 0) {
                helper.sortingList(component, event, helper, auraId, sortType);
            } else {
                var defaultTechnicianList = component.get('v.defaultTechnicianList');
                component.set('v.technicianList', defaultTechnicianList);
            }
        }
    },

    handleClick: function (component, event, helper) {
        component.set('v.isLoading', true);
        var technicianId = component.get('v.technicianId');
        var workcenterId = component.get('v.workcenterId');
        var recordId = component.get('v.recordId') == '' ? component.get('v.ticketId') : component.get('v.recordId');

        if (technicianId == '') {
            helper.toast('서비스요원을 선택하지 않았습니다.', 'Error', 'error');
            component.set('v.isLoading', false);
        } else {
            // console.log('technicianId ::: ', technicianId);

            helper.apexCall(component, event, helper, 'getObjectType', {
                recordId : recordId
            }).then(result => {
                var r = result.r;
                if (r == 'Case') {
                    // publish event
                    const compEvent = component.getEvent("cmpEvent");
                    compEvent.setParams({
                        "modalName": 'DN_ResourceTrackingComponent',
                        "actionName": 'Select',
                        "message": {
                            'technicianId' : technicianId,
                            'workcenterId' : workcenterId
                        }
                    });
        
                    compEvent.fire();
                    component.set('v.isLoading', false);
                    helper.closeModal(component);
                } else {
                    helper.apexCall(component, event, helper, 'updateServiceOrder', {
                        recordId : recordId,
                        technicianId : technicianId,
                        workcenterId : workcenterId
                    }).then(result2 => {
                        var r = result2.r;
                        if (r.isSuccess) {
                            window.location.reload();
                        } else {
                            helper.toast(r.message, 'Update Fail', 'error');
                            component.set('v.isLoading', false);
                        }
                    }).catch(error => {
                        console.log('Error ::: ', error.message);
                    });
                }
            });

        }
    },

    // Excel
    handleScriptsLoaded: function (component, event, helper) {
        console.log('Excel Test');
    },
    
    // handleScriptsLoaded2: function (component, event, helper) {
    //     console.log('FileSaver Test');
    // },

    downloadExcel: function(component, event, helper) {
        try {
            var searchDitance = component.get('v.searchDitance');
            const technicianList = component.get('v.technicianList');

            if (technicianList.length > 0) {

                var date = new Date();
                var year = date.getFullYear();
                var month = date.getMonth() + 1;
                var day = date.getDate();
                var yobi = date.getDay();
                var hour = date.getHours();
                var minute = date.getMinutes();
                var second = String(date.getSeconds()).padStart(2, '0');
                var half = '오전';

                switch (yobi) {
                    case 0:
                        yobi = '일';
                        break;
                    case 1:
                        yobi = '월';
                        break;
                        case 2:
                        yobi = '화';
                        break;
                    case 3:
                        yobi = '수';
                        break;
                    case 4:
                        yobi = '목';
                        break;
                    case 5:
                        yobi = '금';
                        break;
                    case 6:
                        yobi = '토';
                        break;
                }

                if (hour > 12) {
                    hour = hour - 12;
                    half = '오후';
                }

                var printDate = '출력일 (' + year + '년 ' + month + '월 ' + day + '일 ' + yobi + '요일' + ' ' + half + ' ' + hour + ':' + minute + ':' + second + ')';

                const workbook = new ExcelJS.Workbook();
                const worksheet = workbook.addWorksheet('sheet1');

                const headerStyle = {
                    font: {
                        name: '돋움',
                        size: 9,
                        color: { argb: "2f435c" }
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "dbe2ea" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: {
                        top: { style: 'thin', color: { argb: '657584' } },
                        bottom: { style: 'thin', color: { argb: '657584' } },
                        left: { style: 'thin', color: { argb: '657584' } },
                        right: { style: 'thin', color: { argb: '657584' } }
                    }
                };

                const colStyles = {
                    font: {
                        name: '돋움',
                        size: 9,
                        color: { argb: "2f435c" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };
    
                const locationStyles = {
                    font: {
                        name: '돋움',
                        size: 9,
                        color: { argb: "2f435c" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "left"
                    },
                    border: headerStyle.border
                };
    
                const nameStyles = {
                    font: {
                        name: '돋움',
                        color: { argb: "0a0aff" },
                        size: 9
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };    
                
                const statusStyles = {
                    font: {
                        name: '돋움',
                        color: { argb: "2f435c" },
                        size: 9
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "ffff80" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    },
                    border: headerStyle.border
                };

                const mergeStyle = {
                    font: {
                        name: '맑은 고딕',
                        color: { argb: "000000" },
                        size: 15,
                        bold: false
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "F3F3F3" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "center"
                    }
                };

                const finishMergeStyle = {
                    font: {
                        name: '맑은 고딕',
                        color: { argb: "646464" },
                        size: 10,
                        bold: false
                    },
                    fill: {
                        type: 'pattern',
                        pattern: 'solid',
                        fgColor: { argb: "dcdcdc" }
                    },
                    alignment: {
                        vertical: "middle",
                        horizontal: "right"
                    }
                };
        
        
                // 1행 빈줄
                worksheet.addRow([]);
    
                // 제목 추가
                worksheet.addRow(['서비스요원 정보']);
        
                // 3행 빈줄
                worksheet.addRow([]);

                if (searchDitance) {

                    // 헤더 추가
                    const header = ['관할지사', '서비스W/C', '이름', '현재위치', '거리(km)', '업무상태', '핸드폰 번호'];
                    const headerRow = worksheet.addRow(header);
        
                    headerRow.eachCell((cell) => {
                        cell.style = headerStyle;
                    });
        
                    // 데이터 추가
                    technicianList.forEach(technician => {
                        const dataRow = worksheet.addRow([
                            technician.topWorkcenter,
                            technician.workcenter,
                            technician.name,
                            technician.location,
                            technician.distance,
                            technician.status,
                            technician.phone
                        ]);
                        dataRow.getCell(1).style = colStyles;
                        dataRow.getCell(2).style = colStyles;
                        dataRow.getCell(3).style = nameStyles;
                        dataRow.getCell(4).style = locationStyles;
                        dataRow.getCell(5).style = colStyles;
                        dataRow.getCell(6).style = statusStyles;
                        dataRow.getCell(7).style = colStyles;
                    });
    
                    worksheet.addRow([]);
                    worksheet.addRow([
                        printDate
                    ]);
        
                    // 셀 병합
                    var finishRowIndex = technicianList.length + 6;
                    var startMerge = 'A' + finishRowIndex;
                    var finishMerge = 'A' + finishRowIndex + ':G' + finishRowIndex;
    
                    worksheet.mergeCells('A2:G2');
                    worksheet.mergeCells(finishMerge);
                    const mergedCell = worksheet.getCell('A2');
                    const finishMergedCell = worksheet.getCell(startMerge);
                    mergedCell.style = mergeStyle;
                    finishMergedCell.style = finishMergeStyle;
            
                    // 행 높이 설정
                    worksheet.getRow(2).height = 40; // 제목 행
                    worksheet.getRow(4).height = 20;
                    for (let i = 5; i < technicianList.length + 5; i++) {
                        worksheet.getRow(i).height = 17; // 데이터 행
                    }
                    worksheet.getRow(technicianList.length + 6).height = 20; // 마지막 날짜
    
            
                    // 열 너비 설정
                    worksheet.getColumn(1).width = 18;
                    worksheet.getColumn(2).width = 18;
                    worksheet.getColumn(3).width = 12;
                    worksheet.getColumn(4).width = 30;
                    worksheet.getColumn(5).width = 10;
                    worksheet.getColumn(6).width = 12;
                    worksheet.getColumn(7).width = 22;

                } else {
                    // 헤더 추가
                    const header = ['관할지사', '서비스W/C', '이름', '현재위치', '업무상태', '핸드폰 번호'];
                    const headerRow = worksheet.addRow(header);
        
                    headerRow.eachCell((cell) => {
                        cell.style = headerStyle;
                    });

                    // 데이터 추가
                    technicianList.forEach(technician => {
                        const dataRow = worksheet.addRow([
                            technician.topWorkcenter,
                            technician.workcenter,
                            technician.name,
                            technician.location,
                            technician.status,
                            technician.phone
                        ]);
                        dataRow.getCell(1).style = colStyles;
                        dataRow.getCell(2).style = colStyles;
                        dataRow.getCell(3).style = nameStyles;
                        dataRow.getCell(4).style = locationStyles;
                        dataRow.getCell(5).style = statusStyles;
                        dataRow.getCell(6).style = colStyles;
                    });
    
                    worksheet.addRow([]);
                    worksheet.addRow([
                        printDate
                    ]);
        
                    // 셀 병합
                    var finishRowIndex = technicianList.length + 6;
                    var startMerge = 'A' + finishRowIndex;
                    var finishMerge = 'A' + finishRowIndex + ':F' + finishRowIndex;
    
                    worksheet.mergeCells('A2:F2');
                    worksheet.mergeCells(finishMerge);
                    const mergedCell = worksheet.getCell('A2');
                    const finishMergedCell = worksheet.getCell(startMerge);
                    mergedCell.style = mergeStyle;
                    finishMergedCell.style = finishMergeStyle;
            
                    // 행 높이 설정
                    worksheet.getRow(2).height = 40; // 제목 행
                    worksheet.getRow(4).height = 20;
                    for (let i = 5; i < technicianList.length + 5; i++) {
                        worksheet.getRow(i).height = 17; // 데이터 행
                    }
                    worksheet.getRow(technicianList.length + 6).height = 20; // 마지막 날짜
            
                    // 열 너비 설정
                    worksheet.getColumn(1).width = 18;
                    worksheet.getColumn(2).width = 18;
                    worksheet.getColumn(3).width = 12;
                    worksheet.getColumn(4).width = 30;
                    worksheet.getColumn(5).width = 11;
                    worksheet.getColumn(6).width = 17;
            
                }

                // 고정 행 설정
                worksheet.views = [
                    { state: 'frozen', xSplit: 0, ySplit: 4, topLeftCell: 'A5', activeCell: 'A5' }
                ];
        
                // 파일 생성
                workbook.xlsx.writeBuffer().then((buffer) => {
                    // const blob = new Blob([buffer], { type: 'application/octet-stream' });
                    // FileSaver.saveAs(blob, 'example.xlsx');
                    const blob = new Blob([buffer], { type: 'application/octet-stream' });
                    const link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = `${new Date().toISOString().slice(0, 10).replace(/-/g, '')}서비스요원.xlsx`;
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                });
            }
        } catch (error) {
            console.log('에러 내역 알려주세요 ::: ' + error);
            console.log('에러 내역 알려주세요 ::: ' + error.message);
        }

    },
    
})