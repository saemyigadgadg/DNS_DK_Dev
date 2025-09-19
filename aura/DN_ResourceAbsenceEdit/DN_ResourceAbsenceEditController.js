/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-24-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   01-31-2025   youjin.shim@sbtglobal.com   Initial Version
**/
({
	
	// init
	doInit: function (component, event, helper) {
		
		let isCheck = component.get('v.isBranch');
		console.log(component.get('v.typeValue'));
		
		console.log(isCheck ,' < ==isCheck');

		
		if(component.get('v.isBranch')) {
			component.set('v.typeList', [
				{'label' : '전체','value' : 'None'},
				{'label' : '휴가', 'value' : 'Leave'},
				{'label' : '영업/기술', 'value' : 'Sales/Technical'},
				{'label' : '교육/회의', 'value' : 'Training/Meeting'},
			]);
		} else {
			component.set('v.typeList', [
				{'label' : '전체','value' : 'None'},
				{'label' : '휴가', 'value' : 'Leave'},
				{'label' : '교육/회의', 'value' : 'Sales/Technical'},
				{'label' : '자체유상', 'value' : 'Own payment'},
			]);
		}
		let data = component.get('v.typeList');
		const item = data.find(entry => entry.label === component.get('v.typeValue'));
		component.set('v.typeValue',item.value);
		setTimeout(() => {
			component.find('fieldSet').forEach(function(f) {            
				console.log('test111');
				f.reset();
				
			});
		}, 500);
	},
	//수정
	handleEdit : function(component, event, helper) {
		console.log(component.get("v.isDisabled"));
		component.set("v.isDisabled", false);
		//$A.get("e.force:refreshView").fire(); 
	},

	//저장
	handleSave : function(component, event, helper) {
		// 필드 목록
		let resourceId = component.find("resourceId");
		let type = component.find("type");
		let description = component.find("description");
		let startDate = component.find("startDate");
		console.log(startDate.get("v.value"),'startDate');
		let endDate = component.find("endDate");
		let errorMessage = '';
		if(resourceId.get("v.value") ==null || resourceId.get("v.value") =='') {
			resourceId.focus();
			errorMessage +='작업자';
		}
		if(startDate.get("v.value") ==null || startDate.get("v.value") =='') {
			startDate.focus();
			if(errorMessage !='') {
				errorMessage += ', 시작 시간';
			} else {
				errorMessage += '시작 시간';
			}
		}
		if(endDate.get("v.value") ==null || endDate.get("v.value")=='' ) {
			endDate.focus();
			if(errorMessage !='') {
				errorMessage += ', 종료 날짜';
			} else {
				errorMessage += '종료 날짜';
			}
		}
		if(type.get("v.value") ==null || type.get("v.value") =='') {
			type.focus();
			if(errorMessage !='') {
				errorMessage += ', 유형';
			} else {
				errorMessage += '유형';
			}
		}
		if(errorMessage !='') {
			let button = component.find("editBtn");
			button.focus();
			button.getElement().blur();
			helper.toast('ERROR', errorMessage + ' 필수값이 누락되었습니다.');
			return;
		}

		let resSet ={};
		if(component.get('v.isBranch')) {
			// 직영인 경우 장비번호,고객사
			let equipmentText = component.find("equipment");
			
			let accountNameText = component.find("accountName");
			

			resSet = {
				'id' : component.get('v.recordId'),
				'resourceId': resourceId.get("v.value"),
				'type': type.get("v.value"),
				'description': description.get("v.value"),
				'startDate': startDate.get("v.value"),
				'endDate': endDate.get("v.value"),
				'equipment' : equipmentText.get("v.value"),
				'accountName' : accountNameText.get("v.value"),
			};
			console.log('test');
		} else {
			let machineName = component.find("machineName");
			let equipmentText = component.find("equipmentText");
			let accountNameText = component.find("accountNameText");
			let accountAddress = component.find("accountAddress");	
			resSet = {
				'id' : component.get('v.recordId'),
				'resourceId': resourceId.get("v.value"),
				'type': type.get("v.value"),
				'description': description.get("v.value"),
				'startDate': startDate.get("v.value"),
				'endDate': endDate.get("v.value"),
				'machineName' : machineName.get("v.value"),
				'equipmentText' : equipmentText.get("v.value"),
				'accountNameText' : accountNameText.get("v.value"),
				'accountAddress' : accountAddress.get("v.value"),
			};
		}

		
		console.log(component.get('v.isWisBranchorkC'), ' < ===1111');
		let isWorck =component.get('v.isBranch');
		console.log(isWorck, ' >< ==isWorck');
		helper.apexCall(component, event, helper, 'resourceAbsenceUpdate', {
			resource : resSet,
			isWorck : isWorck
		})
		.then($A.getCallback(function(result) {
			let r = result.r;
			let msg = r;
			//$A.get('e.force:refreshView').fire();
			var cmpEvent = component.getEvent("cmpEvent");
			cmpEvent.setParams({
				"modalName" : "DN_ResourceAbsenceEdit",
				"actionName" : "Close",
				"message" : msg
			});
			cmpEvent.fire();
			component.find('recordEditForm').submit();
			helper.closeModal(component);
			
		}))
		.catch(function(error) {
			console.log(JSON.stringify(error), ' < =====error');
			helper.toast('ERROR', error[0].message);
			// console.log('# search Error : ' + error.message);
		});
	},
	closeModal: function (component, event, helper) {
        helper.closeModal(component);
    },
	// 시간 설정
	handleTimeChange: function (component, event, helper) {
		let isMorning = component.get('v.isMorning');
		let isAfter = component.get('v.isAfter');
		let isNight = component.get('v.isNight');
		let today = new Date();
        let yyyy = today.getFullYear();
        let mm = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        let dd = String(today.getDate()).padStart(2, '0');
		let formattedDate = `${yyyy}-${mm}-${dd}`;
		let starDateTime = '';
		let endDateTime = '';
		
		// 오전,오후,야간
		if(isMorning && isAfter && isNight) { 
			starDateTime = formattedDate+'T00:00:00.000Z';
			endDateTime = formattedDate+'T12:00:00.000Z';
		}
		// 오전, 야간
		if(isMorning && !isAfter && isNight) { 
			component.set('v.isAfter', true);
			starDateTime = formattedDate+'T00:00:00.000Z';
			endDateTime = formattedDate+'T12:00:00.000Z';
		}

		// 오전, 오후
		if(isMorning && isAfter && !isNight) { 
			starDateTime = formattedDate+'T00:00:00.000Z';
			endDateTime = formattedDate+'T08:00:00.000Z';
		}
		// 오후, 야간
		if(!isMorning && isAfter && isNight) { 
			starDateTime = formattedDate+'T04:00:00.000Z';
			endDateTime = formattedDate+'T12:00:00.000Z';
		}
		
		//오전
		if(isMorning && !isAfter && !isNight) { 
			starDateTime = formattedDate+'T00:00:00.000Z';
			endDateTime = formattedDate+'T03:00:00.000Z';
		}
		//오후
		if(!isMorning && isAfter && !isNight) { 
			starDateTime = formattedDate+'T04:00:00.000Z';
			endDateTime = formattedDate+'T08:00:00.000Z';
		}
		//야간
		if(!isMorning && !isAfter && isNight) { 
			starDateTime = formattedDate+'T09:00:00.000Z';
			endDateTime = formattedDate+'T12:00:00.000Z';
		}
		//!오전,!오후,!야간
		if(!isMorning && !isAfter && !isNight) { 
			starDateTime = formattedDate;	
			endDateTime = formattedDate;	
		}
		component.find('startDate').set('v.value',starDateTime);
		component.find('endDate').set('v.value',endDateTime);
	},
	// 시작일자,종료일자
	handleDateChage: function (component, event, helper) {
		console.log(event.getSource().get("v.value"), ' < ===111'); //T00:00:00.000Z //T03:00:00.000Z
		//T15:30:00.000Z
	},
	handleCreateLoad: function (component, event, helper) {
		console.log(' handleCreateLoad');
		var record = event.getParam("recordUi");
        var fieldNames = Object.keys(record.fields);
		console.log(record, ' record');
		console.log(fieldNames, ' fieldNames');
		// let isload = component.get('v.isload');
		// if(isload) {
		// 	let rec = component.get('v.recordId');
		// 	component.set('v.recordId', '');
		// 	setTimeout(() => {
		// 		component.set('v.recordId', rec);
		// 		component.set('v.isload',false);	
		// 	}, 500);
			
		// }
		// let rec = component.get('v.recordId');
		// if(rec) {
		// 	component.set('v.recordId', '');
		// }
		
	},
	handleSubmit: function(component, event, helper) {
		console.log('서브밋 성공');
		
	},
	
	handleOnSuccess: function (component, event, helper) {
		console.log('성공');
	}
})