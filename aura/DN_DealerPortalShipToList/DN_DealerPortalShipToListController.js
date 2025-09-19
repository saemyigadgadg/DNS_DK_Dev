/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 01-15-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-12-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        console.log('!!!!!!!!!!!!!!!');
        let isDealerPortal = false;
        component.set('v.shipToCss', {
            'sldsCard':'',
            'topCard':'',
            'tableWrap':'',
            'table01':'',
            'checkBox':'',
            'checkBoxCenter':'',
            'center':'',
            'sldsIcon':'',

        });
        component.set('v.shipToList', []);
        component.set('v.deleted', []);
        let cssSetting = component.get('v.shipToCss');
        
        var url = window.location.pathname;
        console.log(url,' <url');
        // 딜러포탈 고객 상세 화면
        if(url.includes('dealercustomer')) {
            url = url.substring(url.indexOf('dealercustomer'), url.length-1);
            url = url.replace('dealercustomer/', '');
            url = url.trim();
            console.log(url,' ><===url');
            let records = url.split('/');
            console.log(JSON.stringify(records),' < ==records');
            if(records.length > 0) {
                component.set('v.recordId', records[0]);
            }
            
            isDealerPortal = true;
        }
        // 딜러포탈 고객 생성 화면
        if(url.includes('CustomerManagementCreate')) {
            isDealerPortal = true;
        }

        //css 설정 / isDealerPortal = true면 딜러포탈, false면 CRM
        if(isDealerPortal) {
            cssSetting.topCard = 'top-card ship-list-card';
            cssSetting.sldsCard = 'slds-card';
            // cssSetting.cardHeader = 'card-header';
            cssSetting.headerWrap = 'header-wrap';
            cssSetting.buttonWrap = 'button-wrap';
            cssSetting.sldsButton = 'slds-button slds-button_neutral';
            cssSetting.tableWrap = 'table-wrap';
            cssSetting.table01 ='table-01 left-table';
            cssSetting.checkBox = 'check-box';
            cssSetting.checkBoxCenter = 'check-box center';
            cssSetting.center = 'center';
            console.log(cssSetting.sldsTruncateInputWrap,' ::: cssSetting.sldsTruncateInputWrap');
            cssSetting.sldsIcon = 'slds-icon_container slds-icon-utility-search slds-input__icon slds-input__icon_right iconheight';
        } else {
            cssSetting.sldsCard = 'slds-card crm-card';
        }
        component.set('v.shipToCss',cssSetting);
        helper.init(component);
    },
    //추가
    handleAdd : function(component, event, helper) {
        console.log('handleAdd')
        let shipToSet = component.get("v.shipToList");
        shipToSet.push({ 
            id : ``, 
            street : '', 
            postalCode : '', 
            city : '',
            detailInfo : '',
            sggNm : '',
            roadAddr : ''
        });
        component.set('v.shipToList',shipToSet);
    },
    //삭제
    handleMin : function(component, event, helper) {
        let shipToSet = component.get("v.shipToList");
        let selected = component.get('v.selected');
        let deleted = shipToSet.filter((_, index) => selected.includes(index));
        let deletedSet =[];
        shipToSet = shipToSet.filter((_, index) => !selected.includes(index));
        deleted.forEach(element => {
            if(element.id !='') {
                console.log(element.id,' :::element.id');
                deletedSet.push(element.id);
            }
        });
        setTimeout(() => {
            component.set('v.shipToList',shipToSet);
            component.set('v.deleted', deletedSet);
            component.set('v.selected',[]);    
        }, 0);
        
        console.log(deletedSet,' ::: deletedSet');

        //삭제 후 header 체크 해제
        let headerCheckbox = component.find("headerCheckbox");
        if (headerCheckbox) {
            headerCheckbox.set("v.checked", false);
        }
        console.log(deletedSet,' :: deletedSet');
        if(deletedSet.length > 0) {
            console.log(JSON.stringify(deletedSet),' :: deletedSet');
            helper.handleSave(component, '삭제되었습니다.');
        }
    },

    //header 체크시 모든 체크박스 선택
    selectAll: function (component, event, helper) {
        let checkboxes = component.find("checkbox");
        let isChecked = component.find("headerCheckbox").get("v.checked");
        let selectedIndices = [];

        if (Array.isArray(checkboxes)) {
            checkboxes.forEach(function (checkbox, index) {
                console.log(checkbox.get('v.disabled'), ' disabled');
                if (isChecked) {
                    if(!checkbox.get('v.disabled')) {
                        checkbox.set("v.checked", isChecked);
                        selectedIndices.push(index);
                    }
                } else {
                    checkbox.set("v.checked", isChecked);
                    selectedIndices = [];
                }
            });
        } else {
            if (isChecked) {
                if(!checkboxes.get('v.disabled')) {
                    selectedIndices.push(0);
                    checkboxes.set("v.checked", isChecked);
                }
            } else {
                checkboxes.set("v.checked", isChecked);
                selectedIndices = [];
            }
        }

        component.set("v.selected", selectedIndices); 
    },

    handleCheck : function(component, event, helper) {
        let check = event.getSource().get("v.checked");;
        let row = event.getSource().get("v.name");
        let rowId = event.getSource().get("v.id");
        let selected = component.get('v.selected');
        let deleted = component.get('v.deleted');
        
        if(check) {
            selected.push(row);
            deleted.push(rowId);
        } else {
            if(rowId !='') {
                console.log(rowId,' ::: rowId');
                //deleted.splice(deleted.indexof(rowId), 1);
                deleted = deleted.filter(item => item !=rowId);
                console.log(deleted,' ::: deleted');
            } 
            if(selected.length > 0) {
                console.log(row,' ::: row');
                selected.splice(parseInt(row), 1);
            }
        }
        component.set("v.selected", selected);
        component.set("v.deleted", deleted);
    },

    handleCompEvent: function (component, event, helper) {
        try {
            console.log('test111111');
            let selectIndx = component.get('v.openJusoIndex');
            let shipToList =  component.get('v.shipToList');
            let shipTo = {};
            let message = event.getParam('message');
            if(shipToList[selectIndx].id !=undefined) {
                shipTo.id = shipToList[selectIndx].id;
            }
            shipTo.roadAddr = message.selectedResult.roadAddrPart1;    
            shipTo.street = message.selectedResult.roadAddrPart1 + '\n' +message.detailedAddress;
            shipTo.postalCode = message.selectedResult.zipNo;
            shipTo.sggNm = message.selectedResult.siNm + ' ' + message.selectedResult.sggNm;
            shipTo.city = message.selectedResult.siNm;
            shipTo.detailInfo = message.selectedResult.roadAddrPart2 +' '+ message.detailedAddress;
            shipToList[selectIndx] = shipTo;
            component.set('v.shipToList', shipToList);
        } catch (error) {
           
        }
        
    },
    // 주소모달
    openJuso : function(component, event, helper) {
        component.set('v.openJusoIndex', event.getSource().get("v.accesskey"));       
        component.set("v.isAddress", true);
    },
    // 저장
    handleSave : function(component, event, helper) {
        helper.handleSave(component, '저장되었습니다.');
    },
    handleClose : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get('e.force:refreshView').fire();
    }
    
   
    
})