/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 02-24-2025
 * @last modified by  : Chungwoo Lee
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-29-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
	// init
	doInit: function (component, event, helper) {
		console.log(component.get('v.isBranch'), ' ===111');
		component.set("v.isCheck",component.get('v.isBranch'));
		
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
				{'label' : '교육/회의', 'value' : 'Training/Meeting'},
				{'label' : '자체유상', 'value' : 'Own payment'},
			]);
		}
		// 날짜 기본값 오늘날짜
		let today = new Date();
        let yyyy = today.getFullYear();
        let mm = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        let dd = String(today.getDate()).padStart(2, '0');
		let formattedDate = `${yyyy}-${mm}-${dd}`;
		component.find('startDate').set('v.value',formattedDate);
		component.find('endDate').set('v.value',formattedDate);
	},

	closeModal: function (component, event, helper) {
        helper.closeModal(component);
    },
	
	handleCreate: function (component, event, helper) {
		let resourceId = component.find("resourceId");
		// 필드 목록
		let type = component.find("type");
		let description = component.find("description");
		let startDate = component.find("startDate");
		let endDate = component.find("endDate");
		let startTime = component.find("startTime");
		let endTime = component.find("endTime");
		let errorMessage = '';
		if(resourceId.get("v.value") ==null || resourceId.get("v.value") =='') {
			resourceId.focus();
			errorMessage +='작업자';
		}
		if(startDate.get("v.value") ==null || startDate.get("v.value") =='') {
			startDate.focus();
			if(errorMessage !='') {
				errorMessage += ', 시작 날짜';
			} else {
				errorMessage += '시작 날짜';
			}
		}
		if(startTime.get('v.value') ==null || startTime.get('v.value') =='') {
			startTime.focus();
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
		if(endTime.get('v.value') ==null || endTime.get('v.value') =='') {
			endTime.focus();
			if(errorMessage !='') {
				errorMessage += ', 종료 시간';
			} else {
				errorMessage += '종료 시간';
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
			let button = component.find("createBtn");
			button.focus();
			button.getElement().blur();
			helper.toast('ERROR', errorMessage + ' 필수값이 누락되었습니다.');
			return;
		}
		


		let resSet ={};
		let check = component.get('v.isCheck');
		console.log(check,' < ===check');
		if(check) {
			
			// 직영인 경우 장비번호,고객사
			let equipmentText = component.find("equipment");
			console.log('testetetetet');
			let accountNameText = component.find("accountName");
			

			resSet = {
				'resourceId': resourceId.get("v.value"),
				'type': type.get("v.value"),
				'description': description.get("v.value"),
				'startDate': startDate.get("v.value") +'T'+startTime.get('v.value')+'Z',
				'endDate': endDate.get("v.value") + 'T'+endTime.get('v.value')+'Z',
				'equipment' : equipmentText.get("v.value"),
				'accountName' : accountNameText.get("v.value"),
			};
			console.log('testetetetet');
		} else {
			console.log('testetetetet');
			let machineName = component.find("machineName");
			let equipmentText = component.find("equipmentText");
			let accountNameText = component.find("accountNameText");
			let accountAddress = component.find("accountAddress");	
			resSet = {
				'resourceId': resourceId.get("v.value"),
				'type': type.get("v.value"),
				'description': description.get("v.value"),
				'startDate': startDate.get("v.value") +'T'+startTime.get('v.value')+'Z',
				'endDate': endDate.get("v.value")+'T'+ endTime.get('v.value')+'Z',
				'machineName' : machineName.get("v.value"),
				'equipmentText' : equipmentText.get("v.value"),
				'accountNameText' : accountNameText.get("v.value"),
				'accountAddress' : accountAddress.get("v.value"),
			};
		}
		console.log(JSON.stringify(resSet), ' < ==resSet');
		
		helper.apexCall(component, event, helper, 'resourceAbsenceInsert', {
			res : resSet,
			isWorck : component.get('v.isBranch')
		})
		.then($A.getCallback(function(result) {
			let r = result.r;
			let msg = r;
			var cmpEvent = component.getEvent("cmpEvent");
			cmpEvent.setParams({
				"modalName" : "DN_ResourceAbsenceCreate",
				"actionName" : "Close",
				"message" : msg
			});
			cmpEvent.fire();
			helper.closeModal(component);
		}))
		.catch(function(error) {
			console.log(JSON.stringify(error), ' < =====error');
			
			helper.toast('ERROR', error[0].message);
			// console.log('# search Error : ' + error.message);
		});
		
	},

	// 시간 설정
	handleTimeChange: function (component, event, helper) {
		let isMorning = component.get('v.isMorning');
		let isAfter = component.get('v.isAfter');
		let isNight = component.get('v.isNight');
		
		let startTime = '';
		let endTIme = '';
		// 오전,오후,야간
		if(isMorning && isAfter && isNight) { 
			startTime = '09:00:00.000';	 //T05:12:00.000Z 
			endTIme = '21:00:00.000';	
		}
		// 오전, 야간
		if(isMorning && !isAfter && isNight) {
			component.set('v.isAfter', true);
			startTime = '09:00:00.000';	 //T05:12:00.000Z 
			endTIme = '21:00:00.000';	
		}
		// 오전, 오후
		if(isMorning && isAfter && !isNight) { 
			startTime = '09:00:00.000';	
			endTIme = '17:00:00.000';	
		}
		// 오후, 야간
		if(!isMorning && isAfter && isNight) { 
			startTime = '13:00:00.000';	
			endTIme = '21:00:00.000';	
		}
		//오전
		if(isMorning && !isAfter && !isNight) { 
			startTime = '09:00:00.000';	
			endTIme = '12:00:00.000';	
		}
		//오후
		if(!isMorning && isAfter && !isNight) { 
			startTime = '13:00:00.000';	
			endTIme = '17:00:00.000';	
		}
		//야간
		if(!isMorning && !isAfter && isNight) { 
			startTime = '18:00:00.000';	
			endTIme = '21:00:00.000';	
		}
		//!오전,!오후,!야간
		if(!isMorning && !isAfter && !isNight) { 
			component.find('startTime').set('v.value','');	
			component.find('endTime').set('v.value','');	
			return;
		}
		component.find('startTime').set('v.value',startTime);	
		component.find('endTime').set('v.value',endTIme);	
	},
	// 시작일자,종료일자
	handleDateChage: function (component, event, helper) {
		console.log(event.getSource().get("v.value"), ' < ===111'); //T00:00:00.000Z //T03:00:00.000Z
		//T15:30:00.000Z
	},

})