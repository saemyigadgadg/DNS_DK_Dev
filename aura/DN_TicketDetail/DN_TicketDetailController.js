/**
 * @author            : Yeong-Deok Seo
 * @Description       : 
 * @last modified on  : 2025-05-14
 * @last modified by  : yeongdeok.seo@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2025-01-03   yeongdeok.seo@sbtglobal.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
		component.set('v.isLoading', true);
		helper.doInit(component, event, helper);
	},

	editMode : function(component, event, helper) {
		var TicketWrapper = component.get('v.TicketWrapper');

		// console.log('breakdownDatetime ::: ', TicketWrapper.reception.failureDate);
		// console.log('repairRequestDatetime ::: ', TicketWrapper.technical.fixRequestDate);

		component.set('v.selectStatus', TicketWrapper.reception.status);
		component.set('v.selectCloseReason', TicketWrapper.reception.closeReason);
		component.set('v.selectTicketMajor', TicketWrapper.reception.ticketTypeMajor);
		component.set('v.selectTicketMiddle', TicketWrapper.reception.ticketTypeSub);

		component.set('v.isReadMode', false);
	},

	handleStatusChange : function(component, event, helper) {
		try {
			var status = document.getElementById('status');
			var value = status.value;
			component.set('v.selectStatus', value);
			component.set('v.selectCloseReason', '');
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleCloseReasonChange : function(component, event, helper) {
		try {
			var endOfReason = document.getElementById('endOfReason');
			var value = endOfReason.value;
			component.set('v.selectCloseReason', value);
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleTypeMajorChange : function(component, event, helper) {
		try {
			var TicketWrapper = component.get('v.TicketWrapper');
			var ticketType = document.getElementById('ticketType');
			var value = ticketType.value;
			component.set('v.selectTicketMajor', value);
			if (TicketWrapper.ticketRecordType == 'Ticket_DNSA' && value == 'General inquiry') {
				component.set('v.isDNSAGeneral', false);
			} else {
				component.set('v.isDNSAGeneral', true);
			}
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleTypeMiddleChange : function(component, event, helper) {
		try {
			var TicketWrapper = component.get('v.TicketWrapper');
			var ticketMiddleType = document.getElementById('ticketMiddleType');
			var applicationDatetime = document.getElementById('applicationDatetime');
			var breakdownDatetime = document.getElementById('breakdownDatetime');
			var repairRequestDatetime = document.getElementById('repairRequestDatetime');
			var value = ticketMiddleType.value;
			var isUserProfile = component.get('v.isUserProfile');
			// console.log(value);
			component.set('v.selectTicketMiddle', value);

			if (value == 'Failure receipt') {
				if (isUserProfile) {
					component.set('v.failureRquired', false);
				} else {
					component.set('v.failureRquired', true);
				}
			} else {
				component.set('v.failureRquired', false);
			}

			if (value == 'Failure receipt') {
				if (TicketWrapper.reception.failureDate == undefined) {
					breakdownDatetime.value = applicationDatetime.value;
				}
				if (TicketWrapper.technical.fixRequestDate == '') {
					// 2025-01-01T23:58:39.000Z
					var dateValue = new Date(applicationDatetime.value);
					dateValue.setHours(dateValue.getHours() - 8);
					var dateValueString = dateValue.getFullYear() + '-' + String((dateValue.getMonth() + 1)).padStart(2, '0') + '-' + String(dateValue.getDate()).padStart(2, '0') + 'T' + String(dateValue.getHours()).padStart(2,'0') + ':' + String(dateValue.getMinutes()).padStart(2,'0') + ':' + String(dateValue.getSeconds()).padStart(2,'0') + '.000Z';
					repairRequestDatetime.value = dateValueString;
				}
			} else {
				if (TicketWrapper.reception.failureDate == undefined) {
					breakdownDatetime.value = '';
				}
				if (TicketWrapper.technical.fixRequestDate == '') {
					repairRequestDatetime.value = '';
				}				
			}

			if (value == 'Missing Part, Wrong Part') {
				var assetId = document.getElementById('assetId').value;
				helper.apex(component, 'getSelectAssetAccount', {assetId : assetId})
				.then(result => {
					var instWorkcenter = document.getElementById('instWorkcenter');
					var producer = document.getElementById('producer');

					instWorkcenter.value = result.InstWorkCenter__c == null ? '' : result.InstWorkCenter__c;
					producer.value = result.ManufacturerName__c;
				}).catch(error => {
					console.log('Error ::: ', error.message);
				});
			}
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleChangeAsset : function(component, event, helper) {
		try {
			var ticketWrapper = component.get('v.TicketWrapper');
			var assetId = document.getElementById('assetId');
			var accountId = document.getElementById('accountId');
			// var dealerId = document.getElementById('dealerId');
			var value = assetId.value;
			// console.log('value ::: ', value);
			if (value != null && value != '') {
				helper.apex(component, 'getSelectAssetAccount', {assetId : value})
				.then(result => {
					// console.log('result ::: ', result);
					var resultAccountId = result.AccountId == null ? '' : result.AccountId;
					accountId.value = resultAccountId;
					component.set('v.assetAccountId', resultAccountId);
					component.set('v.selectAccountId', resultAccountId);

					if (ticketWrapper.ticketRecordType == 'Ticket_DNSA') {
						var dealerId = document.getElementById('dealerId');
						var resultDealerId = result.SoldTo__c == null ? '' : result.SoldTo__c;
						dealerId.value = resultDealerId;
					}

					if (component.get('v.selectTicketMiddle') == 'Missing Part, Wrong Part') {
						var instWorkcenter = document.getElementById('instWorkcenter');
						var producer = document.getElementById('producer');

						instWorkcenter.value = result.InstWorkCenter__c == null ? '' : result.InstWorkCenter__c;
						producer.value = result.ManufacturerName__c;
					}
				}).catch(error => {
					console.log('Error ::: ', error.message);
				});

				helper.apex(component, 'changeAssetFailureAreaMajor', {assetId : value})
				.then(result => {
					component.set('v.selectedFailureArea', '');
					component.set('v.selectedFailureAreaLabel', '');
					component.set('v.selectedFailureAreaDetail', '');
					component.set('v.selectedFailureAreaDetailLabel', '');
					component.set('v.selectedFailurePhenomenon', '');
					component.set('v.selectedFailurePhenomenonLabel', '');
					component.set('v.isFailureAreaDetail', true);
					component.set('v.isFailurePhenomenon', true);
					component.set('v.majorOptions', result);
					component.set('v.middleOptions', []);
					component.set('v.phenomenonOptions', []);
				});

			}
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleAccountId : function(component, event, helper) {
		var selectAccountId = document.getElementById('accountId').value;
		component.set('v.selectAccountId', selectAccountId);
	},

	handleUrgencyChange : function(component, event, helper) {
		try {
			var isUrgency = document.getElementById('isUrgency');
			var value = isUrgency.value;
			var receptionDetails = document.getElementById('receptionDetails');

			var urgencyCustomLabel = $A.get('$Label.c.DNS_TD_Urgency');

			if (value) {
				receptionDetails.value = '[' + urgencyCustomLabel + ']' + receptionDetails.value;
			} else {
				receptionDetails.value = receptionDetails.value.replace('[' + urgencyCustomLabel + ']', '');
			}
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleReGenerateChange : function(component, event, helper) {
		try {
			// DNS_TD_Urgency, DNS_TD_ReGenerate
			var isReGenerate = document.getElementById('isReGenerate');
			var value = isReGenerate.value;
			var receptionDetails = document.getElementById('receptionDetails');
			var isUrgency = document.getElementById('isUrgency');

			var urgencyCustomLabel = $A.get('$Label.c.DNS_TD_Urgency');
			var reGenerateCustomLabel = $A.get('$Label.c.DNS_TD_ReGenerate');

			if (isUrgency.value) {
				if (value) {
					receptionDetails.value = receptionDetails.value.replace('[' + urgencyCustomLabel + ']','');
					receptionDetails.value = '[' + urgencyCustomLabel + '][' + reGenerateCustomLabel + ']' + receptionDetails.value;
				} else {
					receptionDetails.value = receptionDetails.value.replace('[' + reGenerateCustomLabel + ']', '');
				}
			} else {
				if (value) {
					receptionDetails.value = '[' + reGenerateCustomLabel + ']' + receptionDetails.value;
				} else {
					receptionDetails.value = receptionDetails.value.replace('[' + reGenerateCustomLabel + ']', '');
				}
			}
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleFailureAreaChange : function(component, event, helper) {
		var failureArea = document.getElementById('failureArea');
		var value = failureArea.value;
		var options = component.get('v.majorOptions');
		var selectedOption = options.find(option => option.value === value);
		component.set('v.selectedFailureAreaLabel', selectedOption.label);
		component.set('v.selectedFailureAreaDetail', '');
		component.set('v.selectedFailureAreaDetailLabel', '');
		component.set('v.selectedFailurePhenomenon', '');
		component.set('v.selectedFailurePhenomenonLabel', '');
		component.set('v.isFailureAreaDetail', true);
		component.set('v.isFailurePhenomenon', true);
		component.set('v.middleOptions', []);
		component.set('v.phenomenonOptions', []);
		helper.apex(component, 'getFailureAreaMiddle', {majorValue : value})
		.then(result => {
			component.set('v.middleOptions', result);
			component.set('v.isFailureAreaDetail', false);
		});
	},

	handleFailureAreaDetailChange : function(component, event, helper) {
		var majorValue = component.get('v.selectedFailureArea');
		var failureAreaDetail = document.getElementById('failureAreaDetail');
		var value = failureAreaDetail.value;
		var middelValue = majorValue + value;
		var options = component.get('v.middleOptions');
		var selectedOption = options.find(option => option.value === value);
		component.set('v.selectedFailureAreaDetailLabel', selectedOption.label);
		component.set('v.selectedFailurePhenomenon', '');
		component.set('v.selectedFailurePhenomenonLabel', '');
		component.set('v.isFailurePhenomenon', true);
		component.set('v.phenomenonOptions', []);
		helper.apex(component, 'getFailurePhenomenon2', {middleValue : middelValue})
		.then(result => {
			component.set('v.phenomenonOptions', result);
			component.set('v.isFailurePhenomenon', false);
		});
	},

	handleFailurePhenomenonChange : function(component, event, helper) {
		var failurePhenomenon = document.getElementById('failurePhenomenon');
		var value = failurePhenomenon.value;
		// console.log(value);
		var options = component.get('v.phenomenonOptions');
		var selectedOption = options.find(option => option.value === value);
		component.set('v.selectedFailurePhenomenonLabel', selectedOption.label);
	},

	handleCancel : function(component, event, helper) {
		try {
			component.set('v.isLoading', true);
			helper.doInit(component, event, helper);
			component.set('v.isReadMode', true);
		} catch (error) {
			console.log('Error ::: ', error.message);
		}
	},

	handleClickSaveButton : function(component, event, helper) {

		try {

			// DNS_TD_FailureArea
			// DNS_TD_FailureAreaDetail
			// DNS_TD_FailurePhenomenon
			var failureAreaCustomLabel = $A.get('$Label.c.DNS_TD_FailureArea');
			var failureAreaDetailCustomLabel = $A.get('$Label.c.DNS_TD_FailureAreaDetail');
			var failurePhenomenonCustomLabel = $A.get('$Label.c.DNS_TD_FailurePhenomenon');

			// var failureAreaValue = document.getElementById('failureAreaValue').value;
			// var failureAreaDetail = document.getElementById('failureAreaDetail').value;
			// var failurePhenomenon = document.getElementById('failurePhenomenon').value;

			var failureAreaValue = component.get('v.selectedFailureArea');
			var failureAreaDetail = component.get('v.selectedFailureAreaDetail');
			var failurePhenomenon = component.get('v.selectedFailurePhenomenon');
			var failureRquired = component.get('v.failureRquired');

			if (failureRquired) {
				if (failureAreaValue == null || failureAreaValue == '' || failureAreaValue == undefined) {
					helper.showMyToast('error', failureAreaCustomLabel);
					component.set('v.isLoading', false);
					event.preventDefault();
				} else if (failureAreaDetail == '' || failureAreaDetail == null) {
					helper.showMyToast('error', failureAreaDetailCustomLabel);
					component.set('v.isLoading', false);
					event.preventDefault();
				} else if (failurePhenomenon == '' || failurePhenomenon == null) {
					helper.showMyToast('error', failurePhenomenonCustomLabel);
					component.set('v.isLoading', false);
					event.preventDefault();
				}
			}

			// DNS_TD_timeValidation
			var timeValidationCustomLabel = $A.get('$Label.c.DNS_TD_timeValidation');

			var applicationDatetime = document.getElementById('applicationDatetime').value;
			var application = new Date(applicationDatetime.replace('T', ' ').replace('.000Z', ''));
			var breakdownDatetime = document.getElementById('breakdownDatetime').value;

			// console.log('applicationDatetime ::: ', applicationDatetime);
			// console.log('breakdownDatetime ::: ', breakdownDatetime);
			if (applicationDatetime != null && breakdownDatetime != null) {
				// var application = new Date(applicationDatetime.replace('T', ' ').replace('.000Z', ''));
				var breakdown = new Date(breakdownDatetime.replace('T', ' ').replace('.000Z', ''));
				console.log('application ::: ', application);
				console.log('breakdown ::: ', breakdown);
				if (application < breakdown) {
					helper.showMyToast('error', timeValidationCustomLabel);
					component.set('v.isLoading', false);
					event.preventDefault();
				}
			}

			// DNS_E_RepairDatetime
			var DNS_E_RepairDatetime = $A.get('$Label.c.DNS_E_RepairDatetime');
			var selectTicketMajor = component.get('v.selectTicketMajor');

			if (selectTicketMajor == 'Internal request' || selectTicketMajor == 'Technical inquiry') {
				var repairRequestDatetime = document.getElementById('repairRequestDatetime').value;
				if (repairRequestDatetime != null && applicationDatetime != null) {
					// var application = new Date(applicationDatetime.replace('T', ' ').replace('.000Z', ''));
					var repairRequest = new Date(repairRequestDatetime.replace('T', ' ').replace('.000Z', ''));
					console.log('application ::: ', application);
					console.log('repairRequest ::: ', repairRequest);
					if (application > repairRequest) {
						helper.showMyToast('error', DNS_E_RepairDatetime);
						component.set('v.isLoading', false);
						event.preventDefault();
					}
				}
			}
		} catch (error) {
			console.log('Error ::: ', error.message);
		}

	},

	handleSubmit : function(component, event, helper) {
		component.set('v.isLoading', true);
		try {
			// DNS_TD_AccountValidation
			var timeValidationCustomLabel = $A.get('$Label.c.DNS_TD_AccountValidation');
	
			var assetAccountId = component.get('v.assetAccountId');
			var selectAccountId = component.get('v.selectAccountId');
	
			// console.log('assetAccountId ::: ', assetAccountId); 
			// console.log('selectAccountId ::: ', selectAccountId);
			var ticketType = component.get('v.selectTicketMiddle');
			// console.log('ticketType ::: ', ticketType);

			var isDNSAGeneral = component.get('v.isDNSAGeneral');
			if (isDNSAGeneral) {
				if (ticketType != 'Installation request' && ticketType != 'Post-delivery training') {
					if (assetAccountId != '' && selectAccountId != '' && assetAccountId != selectAccountId) {
						helper.showMyToast('error', timeValidationCustomLabel);
						component.set('v.isLoading', false);
						event.preventDefault();
					} else if (assetAccountId != '' && selectAccountId == '') {
						helper.showMyToast('error', timeValidationCustomLabel);
						component.set('v.isLoading', false);
						event.preventDefault();
					}
				}
			}
	
			// console.log('submitEvent ::: ', event);			
		} catch (error) {
			console.log('Error ::: ', error.message);
		}


	},

	handleSuccess : function(component, event, helper) {
		helper.doInit(component, event, helper);
		component.set('v.isReadMode', true);
	},

	handleError : function(component, event, helper) {
		// helper.showMyToast('error', event.getParam());
		console.log('event ::: ', event);
		console.log('event.getParam() ::: ', event.getParams().detail);
		helper.showMyToast('error', event.getParams().detail);
		component.set('v.isLoading', false);
	}
})