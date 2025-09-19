/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-16
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2024-11-13   yeongdeok.seo@sbtglobal.com   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { label } from 'c/commonUtils';
import { loadScript } from 'lightning/platformResourceLoader';
import getInit from '@salesforce/apex/DN_FieldDefectManagmentController.getInit';
import saveTicket from '@salesforce/apex/DN_FieldDefectManagmentController.saveTicket';
import getIF007 from '@salesforce/apex/DN_FieldDefectManagmentController.getIF007';
import getIF033 from '@salesforce/apex/DN_FieldDefectManagmentController.getIF033';
import getIF008 from '@salesforce/apex/DN_FieldDefectManagmentController.getIF008';

import getListviewModalInit from '@salesforce/apex/DN_FieldDefectManagmentController.getListviewModalInit';
import searchData from '@salesforce/apex/DN_FieldDefectManagmentController.searchData';
import searchData2 from '@salesforce/apex/DN_FieldDefectManagmentController.searchData2';

import DNS_FDM_ListviewValidation  from '@salesforce/label/c.DNS_FDM_ListviewValidation';

import XLSX from '@salesforce/resourceUrl/ExcelJS';

export default class DN_FieldDefectManagment extends LightningElement {
    cLabel = label;
    @api recordId;
    @track ticketRecord = {};
    @track readMode = true;
    @track sectionColumns = ['fieldSection', 'OrderSection', 'CSSection', 'CooperationSection', 'DispatchSection', 'PendingSection'];

    @track oneData = [];
    @track twoData = [];
    isLoading = false;
    severityPicklist = [];
    urgencyPicklist = [];
    defectPicklist = [];
    technicalReviewPicklist = [];
    pendingProcessPicklist = [];
    @track editObject = {};
    partStateList = [];
    ServiceOrderNumberList = [];

    // listview Modal
    isListview = false;
    isListviewLoading = false;
    listviewStart = '';
    listviewEnd = '';
    listviewCompleOption = [
        { label : '전체', value : ''},
        { label : '종결', value : '종결'},
        { label : '미결', value : '미결'}
    ];
    listviewCompleValue = '';
    listviewOrderNumber = '';
    listviewTicketCompleOption = [
        { label : '전체', value : ''},
        { label : '종결', value : '종결'},
        { label : '미결', value : '미결'}
    ];
    listviewTicketCompleValue = '';
    listviewPenddingOption = [];
    listviewPenddingvalue = '';
    listviewWorkcenterOption = [];
    listviewWorkcenterValue = '';
    listviewTopWorkcenterOption = [];
    listviewTopWorkcenterValue = '';
    listviewInstDefectOption = [
        { label : '전체', value : ''},
        { label : 'Y', value : 'Y'},
        { label : 'N', value : 'N'}
    ];
    listviewInstDefectValue = '';
    listviewTechnicalReviewOption = [
        { label : '전체', value : ''},
        { label : 'Y', value : 'Y'},
        { label : 'N', value : 'N'}
    ];
    listviewTechnicalReviewValue = '';
    listviewWarrantyOption = [
        { label : '전체', value : ''},
        { label : '콜센터', value : 'Call Center(Representative)'},
        { label : '딜러포탈', value : 'Dealer portal'}
    ];
    listviewWarrantyValue = '';
    @track listviewData = [];

    connectedCallback(){
        this.isLoading = true;
        var fieldApiNames = ['Severity__c', 'Urgency__c','InstallationDefect__c', 'SkillCheck__c', 'Pendingprocessing__c'];
        try {
            getInit({
                ticketId: this.recordId,
                fieldApiNames: fieldApiNames
            }).then(result1 => {
    
                console.log('result1 ::: ' + JSON.stringify(result1));
    
                var ticketInfo = result1.getTicketInfo;
                
                var editInfo = {...ticketInfo};
                this.ticketRecord = ticketInfo;
                this.editObject = editInfo;
                console.log('editObject ::: ', this.editObject);
                this.severityPicklist = result1.Severity__c;
                this.urgencyPicklist = result1.Urgency__c;
                this.defectPicklist = result1.InstallationDefect__c;
                this.technicalReviewPicklist = result1.SkillCheck__c;
                this.pendingProcessPicklist = result1.Pendingprocessing__c;
                this.ServiceOrderNumberList = ticketInfo.notiNumList;

                console.log('this.ServiceOrderNumberList ::: ' + this.ServiceOrderNumberList);

                if (this.ServiceOrderNumberList.length > 0) {
    
                    console.log('this.ServiceOrderNumberList.length ::: ' + this.ServiceOrderNumberList.length);
    
                    for (let i = 0; i < this.ServiceOrderNumberList.length; i++) {
                        var valueList = [];
                        getIF007({
                            notiNum : this.ServiceOrderNumberList[i]
                        }).then(result007 => {
                            console.log('result007-' + i + ' ::: ', JSON.stringify(result007));
                            if (result007.O_RETURN.TYPE == 'S') {
                                var partList = result007.T_O_LIST;
                                partList.forEach(part => {
                                    var obj = {
                                        MATNR : part.MATNR,
                                        MAKTX : part.MAKTX,
                                        KWMENG : part.KWMENG,
                                        PRETD : part.PRETD,
                                        QDATU : part.QDATU,
                                        MATNR_TXT : part.MATNR_TXT,
                                        SOLDTO : part.NAME4
                                    };
                                    this.twoData.push(obj);
                                    switch (part.MATNR_TXT) {
                                        case '확보중':
                                            var stateObj = {
                                                MATNR_TXT : part.MATNR_TXT,
                                                QDATU : part.QDATU,
                                                value : 1,
                                            };
                                            valueList.push(stateObj);
                                            break;
                                        case '재고보유':
                                            var stateObj = {
                                                MATNR_TXT : part.MATNR_TXT,
                                                QDATU : part.QDATU,
                                                value : 2,
                                            };
                                            valueList.push(stateObj);
                                            break;
                                        case '포장완료':
                                            var stateObj = {
                                                MATNR_TXT : part.MATNR_TXT,
                                                QDATU : part.QDATU,
                                                value : 3,
                                            };
                                            valueList.push(stateObj);
                                            break;
                                        case '배송완료':
                                            var stateObj = {
                                                MATNR_TXT : part.MATNR_TXT,
                                                QDATU : part.QDATU,
                                                value : 4,
                                            };
                                            valueList.push(stateObj);
                                            break;
                                    }
                                });
                            }
                        }).catch(error => {
                            console.log('Error007-' + i + ' ::: ', error.message);
                            this.isLoading = false;

                        }).finally(() => {
                            this.partStateList = [...valueList];
                        });
    
                        getIF033({
                            notiNum : this.ServiceOrderNumberList[i]
                        }).then(result033 => {
                            console.log('result033-' + i + ' ::: ', JSON.stringify(result033));
                            if (result033.O_RETURN.TYPE == 'S') {
                                var partList033 = result033.T_O_LIST;
                                console.log('partList033? ::: ', partList033);
    
                                getIF008({
                                    notiNum : this.ServiceOrderNumberList[i]
                                }).then(result008 => {
                                    console.log('result008-' + i + ' ::: ', JSON.stringify(result008));
                                    var saDateMap = ticketInfo.saDateMap[this.ServiceOrderNumberList[i]];
                                    partList033.forEach(part033 => {
                                        console.log('part033? ::: ', part033);
                                        var cDate = ticketInfo.partsCreatedDateMap[this.ServiceOrderNumberList[i] + '!' + part033.QMSEQ];
                                        var part008 = result008[part033.QMNUM + '!' + part033.QMSEQ];
                                        var obj033 = {
                                            MATNR : part033.MATNR,
                                            MAKTX : part033.MAKTX,
                                            MENGE : part033.MENGE,
                                            REQDAT : cDate,
                                            MATNR_TXT : part033.MATNR_TXT,
                                            APPROVAL : '승인',
                                            DAREG : part008.DAREG,
                                            DAYYN : part008.DAYYN,
                                            SDATE : saDateMap['sDate'],
                                            ODATE : saDateMap['oDate']
                                        };
                                        console.log('obj033? ::: ', JSON.stringify(obj033));
                                        this.oneData.push(obj033);
                                    });
    
                                }).catch(error => {
                                    console.log('Error008-' + i + ' ::: ', error.message);
                                }).finally(() => {
                                    console.log('this.partStateList ::: ', JSON.stringify(this.partStateList));
                                    // var minState = Math.min(...this.partStateList);
                                    if (this.partStateList.length > 0) {
                                        var minState = this.partStateList.reduce((prev, value) => {
                                            return prev.value <= value.value ? prev : value;
                                        });
                                        console.log('minState ::: ', JSON.stringify(minState));
                                        this.ticketRecord.partState = minState.MATNR_TXT;
                                        this.ticketRecord.supplyDate = minState.QDATU;
                                    }
                                    this.isLoading = false;
                                });
                                
                            } else {
                                this.isLoading = false;
                            }
                        }).catch(error => {
                            console.log('Error0033-' + i + ' ::: ', error.message);
                            this.isLoading = false;
                        }).finally(() => {
                            this.isLoading = false;
                        });
                    }
    
                } else {
                    this.isLoading = false;
                }

            }).catch(error => {
                console.log('error1 내역 ::: ' + JSON.stringify(error));
            })

            loadScript(this, XLSX + '/unpkg/exceljs.min.js')
            .then(() => {
                console.log('ExcelJS loaded successfully');
            }).catch(() => {
                console.log('ExcelJS loaded Fail');
            });
        } catch (error) {
            console.log('Error ::: ', error.message);
        }
    }

    handleClickEditIcon() {
        console.log('Before ::: ', this.readMode);
        this.readMode = !this.readMode;
        console.log('After ::: ', this.readMode);

    }
    handleChange(event) {
        var name = event.target.name;
        var value = event.target.value;
        this.editObject[name] = value;
        if (name == 'pendingProcessing') {
            var label = this.pendingProcessPicklist.find(item => item.value == value).label;
            this.editObject[name + 'Label'] = label;
            console.log('label ::: ', label);
        }
        console.log('name ::: ', name);
        console.log('value ::: ', value);
        console.log('editObject ::: ', JSON.stringify(this.editObject));
    }

    handleChangeChecked(event) {
        var name = event.target.name;
        var checked = event.target.checked;
        this.editObject[name] = checked;
        console.log('name ::: ', name);
        console.log('checkedValue ::: ', checked);
        console.log('editObject ::: ', JSON.stringify(this.editObject));
    }

    handleClickCancelButton() {
        console.log('Origin ::: ', JSON.stringify(this.ticketRecord));
        console.log('Edit ::: ', JSON.stringify(this.editObject));
        this.editObject = {...this.ticketRecord};
        this.readMode = !this.readMode;
    }

    handleClickSaveButton() {
        this.isLoading = true;

        console.log('saveData ::: ', JSON.stringify(this.editObject));

        var processCheck = true;

        if (this.ticketRecord.workOrderCount > 0 && this.editObject.pendingProcessing == 'Closing') {
            processCheck = confirm(this.ticketRecord.workOrderCount +  '건의 오더가 발행된 Ticket입니다. 종결처리를 하시겠습니까?');
        }

        if (processCheck) {
            saveTicket({
                recordId: this.recordId,
                saveObject: JSON.stringify(this.editObject)
            }).then(result => {
                console.log('result :::', result);
                if (result.isSuccess) {
    
                    this.editObject.csMemberId = result.updateTicket.csMemberId;
                    this.editObject.csMemberName = result.updateTicket.csMemberName;
                    this.editObject.cooperationTeam = result.updateTicket.cooperationTeam;
                    this.editObject.cooperationPerson = result.updateTicket.cooperationPerson;
                    this.editObject.cooperationDate = result.updateTicket.cooperationDate;
                    this.editObject.urgencyEquip = result.updateTicket.urgencyEquip;
                    this.editObject.technicalReview = result.updateTicket.technicalReview;
                    this.editObject.complaint = result.updateTicket.complaint;
                    this.editObject.pendingProcessing = result.updateTicket.pendingProcessing;
                    this.editObject.pendingProcessingLabel = result.updateTicket.pendingProcessingLabel;
                    this.editObject.pendingProcessingDetail = result.updateTicket.pendingProcessingDetail;
                    this.editObject.countermeasure = result.updateTicket.countermeasure;
    
                    this.ticketRecord = {...this.editObject};
                    console.log('새로운 ticketRecord ::: ' + JSON.stringify(this.ticketRecord));
                    this.showToast('success', result.message, 'success');
                    this.readMode = !this.readMode;
                    this.isLoading = false;
                } else {
                    console.log('error ::: ' + result.message);
                    console.log('error 내역 ::: ' + JSON.stringify(error));
                    this.showToast('error', result.message, 'error');
                    this.isLoading = false;
                }
            }).catch(error => {
                console.log('error 내역 ::: ' + JSON.stringify(error));
            });
        } else {
            this.isLoading = false;
        }
            

    }

    handleClickListview() {
        
        this.isListview = !this.isListview;
        if (this.isListview) {
            this.isListviewLoading = true;
            // console.log('isListview true 🍿');
            var today = new Date();
            this.listviewStart = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + today.getDate();
            this.listviewEnd = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + today.getDate();
            getListviewModalInit({

            }).then(result => {
                console.log('result ::: ', result);
                this.listviewPenddingOption = result.getListviewPicklist;
                this.listviewWorkcenterOption = result.getListviewWorkcenters.workcenterOption;
                this.listviewTopWorkcenterOption = result.getListviewWorkcenters.topWorkcenterOption;
            }).catch(error => {
                console.log('error ::: ', error.message);
            }).finally(() => {
                this.isListviewLoading = false;
            });
        } else {
            this.listviewCompleValue = '';
            this.listviewOrderNumber = '';
            this.listviewTicketCompleValue = '';
            this.listviewPenddingvalue = '';
            this.listviewWorkcenterValue = '';
            this.listviewInstDefectValue = '';
            this.listviewTechnicalReviewValue = '';
            this.listviewWarrantyValue = '';
            this.listviewTopWorkcenterValue = '';
            this.listviewData = [];
        }
    }

    changeListviewStartDate(event) {
        var value = event.target.value;
        this.listviewStart = value;
        console.log('Start ::: ', this.listviewStart);
    }

    changeListviewEndDate(event) {
        var value = event.target.value;
        this.listviewEnd = value;
        console.log('End ::: ', this.listviewEnd);
    }

    changeListviewComple(event) {
        var value = event.target.value;
        this.listviewCompleValue = value;
        console.log('listviewCompleValue ::: ', this.listviewCompleValue);
    }
    
    changeListviewOrderNumber(event) {
        var value = event.target.value;
        this.listviewOrderNumber = value;
        console.log('listviewOrderNumber ::: ', this.listviewOrderNumber);
    }

    changelistviewTicketComple(event) {
        var value = event.target.value;
        this.listviewTicketCompleValue = value;
        console.log('listviewTicketCompleValue ::: ', this.listviewTicketCompleValue);
    }

    changeListviewPendding(event) {
        var value = event.target.value;
        this.listviewPenddingvalue = value;
        console.log('listviewPenddingvalue ::: ', this.listviewPenddingvalue);
    }

    changeListviewWorkcenter(event) {
        var value = event.target.value;
        this.listviewWorkcenterValue = value;
        this.listviewTopWorkcenterValue = '';
        console.log('listviewWorkcenterValue ::: ', this.listviewWorkcenterValue);
    }

    changeListviewTopWorkcenter(event) {
        var value = event.target.value;
        this.listviewTopWorkcenterValue = value;
        this.listviewWorkcenterValue = '';
        console.log('listviewTopWorkcenterValue ::: ', this.listviewTopWorkcenterValue);
    }

    changeListviewInstDefect(event) {
        var value = event.target.value;
        this.listviewInstDefectValue = value;
        console.log('listviewInstDefectValue ::: ', this.listviewInstDefectValue);
    }

    changeListviewTechnicalReview(event) {
        var value = event.target.value;
        this.listviewTechnicalReviewValue = value;
        console.log('listviewTechnicalReviewValue ::: ', this.listviewTechnicalReviewValue);
    }

    changeListviewWarranty(event) {
        var value = event.target.value;
        this.listviewWarrantyValue = value;
        console.log('listviewWarrantyValue ::: ', this.listviewWarrantyValue);
    }

    listviewSearch() {
        // console.log('listviewStart ::: ', this.listviewStart);
        // console.log('listviewEnd ::: ', this.listviewEnd);
        // console.log('listviewCompleValue ::: ', this.listviewCompleValue);
        // console.log('listviewOrderNumber ::: ', this.listviewOrderNumber);
        // console.log('listviewPenddingvalue ::: ', this.listviewPenddingvalue);
        // console.log('listviewWorkcenterValue ::: ', this.listviewWorkcenterValue);
        // console.log('listviewTopWorkcenterValue ::: ', this.listviewTopWorkcenterValue);
        // console.log('listviewInstDefectValue ::: ', this.listviewInstDefectValue);
        // console.log('listviewTechnicalReviewValue ::: ', this.listviewTechnicalReviewValue);
        // console.log('listviewWarrantyValue ::: ', this.listviewWarrantyValue);
        // console.log('listviewTicketCompleValue ::: ', this.listviewTicketCompleValue);

        this.isListviewLoading = true;
        var startDT = new Date(this.listviewStart);
        var endDT = new Date(this.listviewEnd);

        var validationCheck = true;

        if (startDT.setMonth(startDT.getMonth() + 6) < endDT) {
            if (this.listviewCompleValue == '' &&
                this.listviewOrderNumber == '' &&
                this.listviewPenddingvalue == '' &&
                this.listviewWorkcenterValue == '' &&
                this.listviewTopWorkcenterValue == '' &&
                this.listviewInstDefectValue == '' &&
                this.listviewTechnicalReviewValue == '' &&
                this.listviewWarrantyValue == '' &&
                this.listviewTicketCompleValue == ''
            ) {
                validationCheck = false;
            }
        }

        if (validationCheck) {

            var filterObject = {
                listviewStart : this.listviewStart,
                listviewEnd : this.listviewEnd,
                listviewCompleValue : this.listviewCompleValue,
                listviewOrderNumber : this.listviewOrderNumber,
                listviewPenddingvalue : this.listviewPenddingvalue,
                listviewWorkcenterValue : this.listviewWorkcenterValue,
                listviewTopWorkcenterValue : this.listviewTopWorkcenterValue,
                listviewInstDefectValue : this.listviewInstDefectValue,
                listviewTechnicalReviewValue : this.listviewTechnicalReviewValue,
                listviewWarrantyValue : this.listviewWarrantyValue,
                listviewTicketCompleValue : this.listviewTicketCompleValue
            };
    
            // console.log('JSON.stringify(filterObject) ', JSON.stringify(filterObject));
    
            searchData({
                jsonString : JSON.stringify(filterObject)
            }).then(result => {
    
                console.log('result ::: ', JSON.stringify(result));
                // console.log('orderList.length ::: ', result.length);
    
                var resultList = [];
    
                if (result.length > 0) {
    
                    var chunkList = this.chunkArray(result, 500);
                    // console.log('chunkList ::: ', JSON.stringify(chunkList));
                    chunkList.forEach(orders => {
                        searchData2({
                            orderList : orders,
                        }).then(result2 => {
                            console.log('result2 ::: ', JSON.stringify(result2));
                            if (result2.isSuccess) {
    
                                resultList = [...resultList, result2.resultList];
    
                                // this.listviewData = result2.resultList;
                                
                            } else {
                                this.showToast('Error', result.message, 'error');
                            }
                            
                        }).catch(error2 => {
                            console.log('error2 ::: ', error2);
                        }).finally(() => {
                            if (result.length == resultList.flat().length) {
                                var listviewResultList = resultList.flat();
                                listviewResultList.sort(function(a, b) {
                                    let val1 = a['createdDate'];
                                    let val2 = b['createdDate'];
    
                                    return val1 < val2 ? 1 : val1 > val2 ? -1 : 0;
    
                                });
    
                                this.listviewData = listviewResultList;
                                this.isListviewLoading = false;
                            }
                        });
                    })
    
                } else {
                    // this.showToast('Error', result.message, 'error');
                    this.listviewData = resultList;
                    this.isListviewLoading = false;
                }
            }).catch(error => {
                console.log('error ::: ', JSON.stringify(error));
                this.isListviewLoading = false;
            })
            // .finally(() => {
            //     this.isListviewLoading = false;
            // });
        } else {
            this.showToast('error', DNS_FDM_ListviewValidation, 'error');
            this.isListviewLoading = false;
        }

    }

    chunkArray(orderList, size) {
        const result = [];
        for (let i = 0; i < orderList.length; i += size) {
          result.push(orderList.slice(i, i + size));
        }
        return result;
    }

    downloadPendingExcel() {
        this.isListviewLoading = true;
        try {
            const workbook = new ExcelJS.Workbook();
            const worksheet = workbook.addWorksheet('sheet1');
    
            var startDate = this.listviewStart;
            var endDate = this.listviewEnd;
            var dataList = this.listviewData;

            var date = new Date();
            var year = date.getFullYear();
            var month = date.getMonth() + 1;
            var day = date.getDate();
            var yobi = date.getDay();
            var hour = date.getHours();
            var minute = String(date.getMinutes()).padStart(2, '0');
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

            // 1행 빈줄
            worksheet.addRow([]);
    
            // 제목 추가
            worksheet.addRow(['진행사항관리 리스트 ' + startDate + ' ~ ' + endDate]);
    
            // 3행 빈줄
            worksheet.addRow([]);
    
            const header1 = [
                'Ticket 상태',
                '긴급/독촉',
                '재발생',
                '심각도',
                '긴급도',
                '경과일',
                '지사',
                '서비스W/C',
                '판매자',
                '설치자',
                '접수번호',
                '업체명',
                '기종',
                '호기',
                '제어장치',
                '출하일',
                '설치완료일',
                '접수일',
                '상담원',
                '출동일',
                '예약상태',
                '종결미결원인',
                '고장내용(상담)',
                '수리내용',
                '향후대응방안',
                '출동계획',
                '',
                '미결하자관리',
                '',
                '',
                '',
                'CS',
                '',
                '협조부서',
                '',
                '',
                '부품',
                '',
                '수리',
                '',
                '장비기준 오더현황',
                '',
                '',
                '',
                '',
                '',
                '설치W/C',
                '공동작업자'
            ];
    
            const header2 = [
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '출동자',
                '출동예정일',
                '상태',
                '미결사유',
                '고객불만',
                '출동횟수',
                '담당자',
                '처리기한',
                '팀',
                '담당자',
                '처리기한',
                '상태',
                '공급예정일/출고일자',
                '담당자',
                '수리요청일',
                '설치경과일',
                '전체오더건수',
                '오더건수(30일)',
                '오더건수(90일)',
                '오더평균',
                '긴급대응장비'
            ];
    
            const headerStyle = {
                font: {
                    name: '돋움',
                    size: 11,
                    color: { argb: "2f435c" },
                    bold: true
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

            var colStyles = {
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

            var leftColStyles = {
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

            var yellowColStyles = {
                font: {
                    name: '돋움',
                    size: 9,
                    color: { argb: "2f435c" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "center"
                },
                fill: {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: "ffff66" }
                },
                border: headerStyle.border
            };

            var leftYellowColStyles = {
                font: {
                    name: '돋움',
                    size: 9,
                    color: { argb: "2f435c" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "left"
                },
                fill: {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: "ffff66" }
                },
                border: headerStyle.border
            };

            var redColStyles = {
                font: {
                    name: '돋움',
                    size: 9,
                    color: { argb: "2f435c" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "center"
                },
                fill: {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: "ff9999" }
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
    
            // 헤더 추가
            const header1Row = worksheet.addRow(header1);
            const header2Row = worksheet.addRow(header2);
    
            header1Row.eachCell((cell) => {
                cell.style = headerStyle;
            });
            header2Row.eachCell((cell) => {
                cell.style = headerStyle;
            });

            // 데이터 추가
            dataList.forEach(data => {
                const dataRow = worksheet.addRow([
                    data.ticketStatus,
                    data.urgencyNY,
                    data.reGenerateNY,
                    data.severity,
                    data.urgency,
                    data.elapsedDate,
                    data.topWorkcenterName,
                    data.workcenterName,
                    data.dealerName,
                    data.installer,
                    data.ticketNumber,
                    data.srWC,
                    data.assetModelName,
                    data.assetName,
                    data.assetNcType,
                    data.assetStartUpDate,
                    data.installFinishDate,
                    data.createdDate,
                    data.ownerName,
                    data.lastDispatchDate,
                    data.reservationNY,
                    data.pendingProcessing,
                    data.receptionDetail,
                    data.ticketDetail,
                    data.countermeasure,
                    data.srName,
                    data.repairRequestDate,
                    data.orderStatus,
                    data.pendingStatus,
                    data.complaint,
                    data.dispatchedCount,
                    data.csMemberName,
                    data.csDueDate,
                    data.cooperationTeam,
                    data.cooperationPerson,
                    data.cooperationDate,
                    data.partState,
                    data.supplyDate,
                    data.orderSrName,
                    data.repairDate,
                    data.assetInstElapsedDate,
                    data.allOrderCount,
                    data.orderCount30,
                    data.orderCount90,
                    parseFloat(data.orderAverage).toFixed(2),
                    data.urgencyEquip,
                    data.assetInstallWC,
                    data.collaboWorkerName
                ]);

                for (let i = 1; i < 49; i++) {
                    if (data.isYellow) {
                        if (i == 20) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = yellowColStyles;
                            }
                        } else if (i == 27) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = yellowColStyles;
                            }
                        } else if (i == 23) {
                            dataRow.getCell(i).style = leftYellowColStyles;
                        } else if (i == 24) {
                            dataRow.getCell(i).style = leftYellowColStyles;
                        } else {
                            dataRow.getCell(i).style = yellowColStyles;
                        }
                    } else {
                        if (i == 20) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = colStyles;
                            }
                        } else if (i == 27) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = colStyles;
                            }
                        } else if (i == 23) {
                            dataRow.getCell(i).style = leftColStyles;
                        } else if (i == 24) {
                            dataRow.getCell(i).style = leftColStyles;
                        } else {
                            dataRow.getCell(i).style = colStyles;
                        }
                    }
                }

            });

            worksheet.addRow([]);
            worksheet.addRow([
                printDate
            ]);
    
            // 셀 병합
            var finishRowIndex = dataList.length + 7;
            var startMerge = 'A' + finishRowIndex;
            var finishMerge = 'A' + finishRowIndex + ':AV' + finishRowIndex;

            worksheet.mergeCells('A2:AV2');
            worksheet.mergeCells('A4:A5');
            worksheet.mergeCells('B4:B5');
            worksheet.mergeCells('C4:C5');
            worksheet.mergeCells('D4:D5');
            worksheet.mergeCells('E4:E5');
            worksheet.mergeCells('F4:F5');
            worksheet.mergeCells('G4:G5');
            worksheet.mergeCells('H4:H5');
            worksheet.mergeCells('I4:I5');
            worksheet.mergeCells('J4:J5');
            worksheet.mergeCells('K4:K5');
            worksheet.mergeCells('L4:L5');
            worksheet.mergeCells('M4:M5');
            worksheet.mergeCells('N4:N5');
            worksheet.mergeCells('O4:O5');
            worksheet.mergeCells('P4:P5');
            worksheet.mergeCells('Q4:Q5');
            worksheet.mergeCells('R4:R5');
            worksheet.mergeCells('S4:S5');
            worksheet.mergeCells('T4:T5');
            worksheet.mergeCells('U4:U5');
            worksheet.mergeCells('V4:V5');
            worksheet.mergeCells('W4:W5');
            worksheet.mergeCells('X4:X5');
            worksheet.mergeCells('Y4:Y5');
            worksheet.mergeCells('Z4:AA4');
            worksheet.mergeCells('AB4:AE4');
            worksheet.mergeCells('AF4:AG4');
            worksheet.mergeCells('AH4:AJ4');
            worksheet.mergeCells('AK4:AL4');
            worksheet.mergeCells('AM4:AN4');
            worksheet.mergeCells('AO4:AT4');
            worksheet.mergeCells('AU4:AU5');
            worksheet.mergeCells('AV4:AV5');
            worksheet.mergeCells(finishMerge);

            const mergedCell = worksheet.getCell('A2');
            const finishMergedCell = worksheet.getCell(startMerge);
            mergedCell.style = mergeStyle;
            finishMergedCell.style = finishMergeStyle;

            // 행 높이 설정
            worksheet.getRow(2).height = 40; // 제목 행
            for (let i = 6; i < dataList.length + 6; i++) {
                worksheet.getRow(i).height = 17; // 데이터 행
            }
            worksheet.getRow(dataList.length + 7).height = 20; // 마지막 날짜

            // 고정 행 설정
            worksheet.views = [
                { state: 'frozen', xSplit: 0, ySplit: 5, topLeftCell: 'A6', activeCell: 'A6' }
            ];

            // 열 너비 설정
            for (let i = 1; i < 49; i++) {
                if (i == 23) {
                    worksheet.getColumn(i).width = 60;
                } else if (i == 24) {
                    worksheet.getColumn(i).width = 40;
                } else if (i == 25) {
                    worksheet.getColumn(i).width = 30;
                } else {
                    worksheet.getColumn(i).width = 12;
                }
            }

            // 열 숨기기
            worksheet.getColumn(3).hidden = true;
            worksheet.getColumn(4).hidden = true;
            worksheet.getColumn(5).hidden = true;
            worksheet.getColumn(7).hidden = true;
            worksheet.getColumn(9).hidden = true;
            worksheet.getColumn(10).hidden = true;
            worksheet.getColumn(15).hidden = true;
            worksheet.getColumn(16).hidden = true;
            worksheet.getColumn(19).hidden = true;
            worksheet.getColumn(21).hidden = true;
            worksheet.getColumn(28).hidden = true;
            worksheet.getColumn(29).hidden = true;
            worksheet.getColumn(30).hidden = true;
            worksheet.getColumn(31).hidden = true;
            worksheet.getColumn(32).hidden = true;
            worksheet.getColumn(33).hidden = true;
            worksheet.getColumn(34).hidden = true;
            worksheet.getColumn(35).hidden = true;
            worksheet.getColumn(36).hidden = true;
            worksheet.getColumn(37).hidden = true;
            worksheet.getColumn(38).hidden = true;
            worksheet.getColumn(39).hidden = true;
            worksheet.getColumn(41).hidden = true;
            worksheet.getColumn(42).hidden = true;
            worksheet.getColumn(43).hidden = true;
            worksheet.getColumn(44).hidden = true;
            worksheet.getColumn(45).hidden = true;
            worksheet.getColumn(46).hidden = true;

            var localDate = new Date();
            // 로컬 시간에 맞는 년, 월, 일 추출
            var year = localDate.getFullYear();
            var month = String(localDate.getMonth() + 1).padStart(2, '0');
            var day = String(localDate.getDate()).padStart(2, '0'); 

            var dateString = year + month + day;

            // 파일 생성
            workbook.xlsx.writeBuffer().then((buffer) => {
                // const blob = new Blob([buffer], { type: 'application/octet-stream' });
                // FileSaver.saveAs(blob, 'example.xlsx');
                const blob = new Blob([buffer], { type: 'application/octet-stream' });
                const link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = dateString + ' 진행사항관리.xlsx';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.isListviewLoading = false;
            });
        } catch (error) {
            console.log('에러 내역 알려주세요 ::: ' + error.message);
            this.isListviewLoading = false;
        }

    }

    downloadExcel() {
        this.isListviewLoading = true;
        try {
            const workbook = new ExcelJS.Workbook();
            const worksheet = workbook.addWorksheet('sheet1');
    
            var startDate = this.listviewStart;
            var endDate = this.listviewEnd;
            var dataList = this.listviewData;

            var date = new Date();
            var year = date.getFullYear();
            var month = date.getMonth() + 1;
            var day = date.getDate();
            var yobi = date.getDay();
            var hour = date.getHours();
            var minute = String(date.getMinutes()).padStart(2, '0');
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

            // 1행 빈줄
            worksheet.addRow([]);
    
            // 제목 추가
            worksheet.addRow(['진행사항관리 리스트 ' + startDate + ' ~ ' + endDate]);
    
            // 3행 빈줄
            worksheet.addRow([]);
    
            const header1 = [
                'Ticket 상태',
                '긴급/독촉',
                '재발생',
                '심각도',
                '긴급도',
                '경과일',
                '지사',
                '서비스W/C',
                '판매자',
                '설치자',
                '접수번호',
                '업체명',
                '기종',
                '호기',
                '제어장치',
                '출하일',
                '설치완료일',
                '접수일',
                '상담원',
                '출동일',
                '예약상태',
                '종결미결원인',
                '고장내용(상담)',
                '수리내용',
                '향후대응방안',
                '출동계획',
                '',
                '미결하자관리',
                '',
                '',
                '',
                'CS',
                '',
                '협조부서',
                '',
                '',
                '부품',
                '',
                '수리',
                '',
                '장비기준 오더현황',
                '',
                '',
                '',
                '',
                '',
                '설치W/C',
                '공동작업자'
            ];
    
            const header2 = [
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '출동자',
                '출동예정일',
                '상태',
                '미결사유',
                '고객불만',
                '출동횟수',
                '담당자',
                '처리기한',
                '팀',
                '담당자',
                '처리기한',
                '상태',
                '공급예정일/출고일자',
                '담당자',
                '수리요청일',
                '설치경과일',
                '전체오더건수',
                '오더건수(30일)',
                '오더건수(90일)',
                '오더평균',
                '긴급대응장비'
            ];
    
            const headerStyle = {
                font: {
                    name: '돋움',
                    size: 11,
                    color: { argb: "2f435c" },
                    bold: true
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

            var colStyles = {
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

            var leftColStyles = {
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

            var yellowColStyles = {
                font: {
                    name: '돋움',
                    size: 9,
                    color: { argb: "2f435c" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "center"
                },
                fill: {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: "ffff66" }
                },
                border: headerStyle.border
            };

            var leftYellowColStyles = {
                font: {
                    name: '돋움',
                    size: 9,
                    color: { argb: "2f435c" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "left"
                },
                fill: {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: "ffff66" }
                },
                border: headerStyle.border
            };

            var redColStyles = {
                font: {
                    name: '돋움',
                    size: 9,
                    color: { argb: "2f435c" }
                },
                alignment: {
                    vertical: "middle",
                    horizontal: "center"
                },
                fill: {
                    type: 'pattern',
                    pattern: 'solid',
                    fgColor: { argb: "ff9999" }
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
    
            // 헤더 추가
            const header1Row = worksheet.addRow(header1);
            const header2Row = worksheet.addRow(header2);
    
            header1Row.eachCell((cell) => {
                cell.style = headerStyle;
            });
            header2Row.eachCell((cell) => {
                cell.style = headerStyle;
            });

            // 데이터 추가
            dataList.forEach(data => {
                const dataRow = worksheet.addRow([
                    data.ticketStatus,
                    data.urgencyNY,
                    data.reGenerateNY,
                    data.severity,
                    data.urgency,
                    data.elapsedDate,
                    data.topWorkcenterName,
                    data.workcenterName,
                    data.dealerName,
                    data.installer,
                    data.ticketNumber,
                    data.srWC,
                    data.assetModelName,
                    data.assetName,
                    data.assetNcType,
                    data.assetStartUpDate,
                    data.installFinishDate,
                    data.createdDate,
                    data.ownerName,
                    data.lastDispatchDate,
                    data.reservationNY,
                    data.pendingProcessing,
                    data.receptionDetail,
                    data.ticketDetail,
                    data.countermeasure,
                    data.srName,
                    data.repairRequestDate,
                    data.orderStatus,
                    data.pendingStatus,
                    data.complaint,
                    data.dispatchedCount,
                    data.csMemberName,
                    data.csDueDate,
                    data.cooperationTeam,
                    data.cooperationPerson,
                    data.cooperationDate,
                    data.partState,
                    data.supplyDate,
                    data.orderSrName,
                    data.repairDate,
                    data.assetInstElapsedDate,
                    data.allOrderCount,
                    data.orderCount30,
                    data.orderCount90,
                    parseFloat(data.orderAverage).toFixed(2),
                    data.urgencyEquip,
                    data.assetInstallWC,
                    data.collaboWorkerName
                ]);

                for (let i = 1; i < 49; i++) {
                    if (data.isYellow) {
                        if (i == 20) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = yellowColStyles;
                            }
                        } else if (i == 27) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = yellowColStyles;
                            }
                        } else if (i == 23) {
                            dataRow.getCell(i).style = leftYellowColStyles;
                        } else if (i == 24) {
                            dataRow.getCell(i).style = leftYellowColStyles;
                        } else {
                            dataRow.getCell(i).style = yellowColStyles;
                        }
                    } else {
                        if (i == 20) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = colStyles;
                            }
                        } else if (i == 27) {
                            if (data.isRed) {
                                dataRow.getCell(i).style = redColStyles;
                            } else {
                                dataRow.getCell(i).style = colStyles;
                            }
                        } else if (i == 23) {
                            dataRow.getCell(i).style = leftColStyles;
                        } else if (i == 24) {
                            dataRow.getCell(i).style = leftColStyles;
                        } else {
                            dataRow.getCell(i).style = colStyles;
                        }
                    }
                }

            });

            worksheet.addRow([]);
            worksheet.addRow([
                printDate
            ]);
    
            // 셀 병합
            var finishRowIndex = dataList.length + 7;
            var startMerge = 'A' + finishRowIndex;
            var finishMerge = 'A' + finishRowIndex + ':AV' + finishRowIndex;

            worksheet.mergeCells('A2:AV2');
            worksheet.mergeCells('A4:A5');
            worksheet.mergeCells('B4:B5');
            worksheet.mergeCells('C4:C5');
            worksheet.mergeCells('D4:D5');
            worksheet.mergeCells('E4:E5');
            worksheet.mergeCells('F4:F5');
            worksheet.mergeCells('G4:G5');
            worksheet.mergeCells('H4:H5');
            worksheet.mergeCells('I4:I5');
            worksheet.mergeCells('J4:J5');
            worksheet.mergeCells('K4:K5');
            worksheet.mergeCells('L4:L5');
            worksheet.mergeCells('M4:M5');
            worksheet.mergeCells('N4:N5');
            worksheet.mergeCells('O4:O5');
            worksheet.mergeCells('P4:P5');
            worksheet.mergeCells('Q4:Q5');
            worksheet.mergeCells('R4:R5');
            worksheet.mergeCells('S4:S5');
            worksheet.mergeCells('T4:T5');
            worksheet.mergeCells('U4:U5');
            worksheet.mergeCells('V4:V5');
            worksheet.mergeCells('W4:W5');
            worksheet.mergeCells('X4:X5');
            worksheet.mergeCells('Y4:Y5');
            worksheet.mergeCells('Z4:AA4');
            worksheet.mergeCells('AB4:AE4');
            worksheet.mergeCells('AF4:AG4');
            worksheet.mergeCells('AH4:AJ4');
            worksheet.mergeCells('AK4:AL4');
            worksheet.mergeCells('AM4:AN4');
            worksheet.mergeCells('AO4:AT4');
            worksheet.mergeCells('AU4:AU5');
            worksheet.mergeCells('AV4:AV5');
            worksheet.mergeCells(finishMerge);

            const mergedCell = worksheet.getCell('A2');
            const finishMergedCell = worksheet.getCell(startMerge);
            mergedCell.style = mergeStyle;
            finishMergedCell.style = finishMergeStyle;

            // 행 높이 설정
            worksheet.getRow(2).height = 40; // 제목 행
            for (let i = 6; i < dataList.length + 6; i++) {
                worksheet.getRow(i).height = 17; // 데이터 행
            }
            worksheet.getRow(dataList.length + 7).height = 20; // 마지막 날짜

            // 고정 행 설정
            worksheet.views = [
                { state: 'frozen', xSplit: 0, ySplit: 5, topLeftCell: 'A6', activeCell: 'A6' }
            ];

            // 열 너비 설정
            for (let i = 1; i < 49; i++) {
                if (i == 23) {
                    worksheet.getColumn(i).width = 60;
                } else if (i == 24) {
                    worksheet.getColumn(i).width = 40;
                } else if (i == 25) {
                    worksheet.getColumn(i).width = 30;
                } else {
                    worksheet.getColumn(i).width = 12;
                }
            }

            var localDate = new Date();
            // 로컬 시간에 맞는 년, 월, 일 추출
            var year = localDate.getFullYear();
            var month = String(localDate.getMonth() + 1).padStart(2, '0');
            var day = String(localDate.getDate()).padStart(2, '0'); 

            var dateString = year + month + day;

            // 파일 생성
            workbook.xlsx.writeBuffer().then((buffer) => {
                // const blob = new Blob([buffer], { type: 'application/octet-stream' });
                // FileSaver.saveAs(blob, 'example.xlsx');
                const blob = new Blob([buffer], { type: 'application/octet-stream' });
                const link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = dateString + ' 진행사항관리.xlsx';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.isListviewLoading = false;
            });
        } catch (error) {
            console.log('에러 내역 알려주세요 ::: ' + error.message);
            this.isListviewLoading = false;
        }

    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    // 

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `
            *:has(c-d-n_-field-defect-managment .modal-body) {
                overflow: hidden;
            }
            .slds-tabs_card .slds-card__body {
                margin: 0;
            }
            .field-container .slds-form-element:has(.slds-combobox_container) .slds-form-element__label {
                display: none;
            }
            .field-container .slds-form-element {
                width: 100%;
            }
            .slds-accordion__summary {
                background-color: var(--slds-g-color-neutral-base-95);
                border-radius: 0.25rem;
            }
            .modal-body .input-wrap .slds-form-element {
                width: 100% !important;
            }
            .modal-body .input-wrap .slds-form-element__help {
                display: none;
            }
         `;
        this.template.querySelector('.FieldDefectManagement').appendChild(style);
    }
}