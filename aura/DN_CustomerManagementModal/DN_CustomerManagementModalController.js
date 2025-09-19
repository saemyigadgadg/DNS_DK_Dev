/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 12-17-2024
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   12-11-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({	
	
	// init
	doInit : function(component, event, helper) {
		// 디테일 페이지에서 edit 눌럿을때 recordId 설정
		const url = window.location.href; // 현재 URL
		const params = new URLSearchParams(new URL(url).search); 
		const recordId = params.get('recordId');
		// const isCustom = params.get('isCustom');
		if(recordId !=null) {
			component.set('v.recordId',recordId);
		}

		component.set('v.isLoading', true);
		helper.apexCall(component, event, helper, 'getInit', {
			recordId : component.get('v.recordId')
        })
        .then($A.getCallback(function(result) {
			let r = result.r;
			component.set('v.customer', {
				'IsActive__c' : true
			});
			
			if(component.get('v.recordId') !=undefined) {
				component.find('PartsManagerPhone__c').set('v.value',r['delaer'][0].PartsManagerPhone__c);
				component.find('PartManagerName__c').set('v.value',r['delaer'][0].PartManagerName__c);
				component.find('PartsManagerContact__c').set('v.value',r['delaer'][0].PartsManagerContact__c);
				component.find('PartsManagerEmail__c').set('v.value',r['delaer'][0].PartsManagerEmail__c);
				component.find('PartsManagerFax__c').set('v.value',r['delaer'][0].PartsManagerFax__c);
				component.set('v.customer', r['delaer'][0]);				
				component.find('Address__c').set('v.value',r['delaer'][0].Address__Street__s);
			} 
			const currentUser = r['currentUser'][0];
			if(currentUser.UserType =='PowerPartner') {
				component.set('v.isCustom', true);
			} else {
				component.set('v.isCustom', false);
			}
			component.set("v.currentUser",currentUser);
			let isCustom = component.get('v.isCustom');
			// 어드민 구분
			if(isCustom) {
				let customer = component.get('v.customer');
				console.log(JSON.stringify(currentUser), ' < ==currentUser');
				component.find('Dealer__c').set('v.value',currentUser.Contact.AccountId);	
				component.find('Organization').set('v.value',currentUser.SalesOrganization__c);	
				component.find('DistributionChannel').set('v.value',currentUser.DistributionChannel__c);	
				component.find('Division').set('v.value',currentUser.Division__c);	
				
				customer.SalesOrganization__c = currentUser.SalesOrganization__c;
				customer.DistributionChannel__c = currentUser.DistributionChannel__c;
				customer.Division__c = currentUser.Division__c;
				component.set('v.customer', customer);
			} else {

			}
			component.set("v.uuid", self.crypto.randomUUID());
			
		}))
        .catch(function(error) {
            console.log(error[0],' < == error');
			helper.toast('ERROR', error[0].message);
        }).finally($A.getCallback(function () {
                component.set("v.isLoading", false);
            })
        );		
	},
	
	// 저장
	handleSave : function(component, event, helper) {
		component.set('v.isLoading', true);
		
		// if(!component.find('PartManagerName__c').get('v.value')) {
		// 	helper.toast('ERROR', '부품 담당자는 필수로 입력해야합니다.');
		// 	return;
		// } 
		let isCustom = component.get('v.isCustom');
		let address = component.get('v.address')
		let cust = component.get('v.customer');
		// let dealer = component.find('Name').getElement();
		
		// 필수값 표기
		// console.log(dealer, ' :: dealer.getElement()');
		let dealer = document.querySelectorAll('.inputfield');
		dealer.forEach(element => {
			console.log(element, ' ::: element');
			console.log(element.disabled, ' disabled:::');
			console.log(element.value, ' value ::');
			if(!element.value) {
				console.log(element.value,' :: element.value');
				element.reportValidity();
				if(element.disabled) {
					element.classList.add('slds-has-error');
					let isErrorMsg = false;
					let errorMessages = document.querySelectorAll('.slds-form-element__help');
					errorMessages.forEach(errorMessage => {
						console.log(errorMessage,' :: errorMessage');
						if(errorMessage != undefined) {
							isErrorMsg = true;
						}
					});
					if(!isErrorMsg) {
						let errorMessage = document.createElement('div');
						errorMessage.className = 'slds-form-element__help';
						errorMessage.innerText = '이 필드를 완료하십시오.';
						element.appendChild(errorMessage);
					}
					
				}
			} else {
				if(element.disabled) {
					//let input= element.querySelector('.custom-error');
					element.classList.remove('slds-has-error');
					//let shadowRoot = element.shadowRoot; // Shadow DOM 접근
					let errorMessages = document.querySelectorAll('.slds-form-element__help');
					errorMessages.forEach(errorMessage => {
						errorMessage.remove();
						console.log(errorMessage,' :: errorMessage');
					});
					
				}
			}
		
			
		});
		

		let currentUser = component.get('v.currentUser');
		console.log(JSON.stringify(cust), ' < ==cust');
		console.log(currentUser.ContactId,' < ===currentUser.Contact.AccountId');
		if(currentUser.ContactId !=undefined) {
			cust.Dealer__c=currentUser.Contact.AccountId;
		}
		
		if(address !=null) {
			console.log(JSON.stringify(address), ' < ==22222');
			cust.Address__Street__s = address.roadAddr + '\n' + address.detailInfo;
			cust.Address__PostalCode__s = address.postalCode;
			cust.Address__City__s = address.city;
			cust.Address__CountryCode__s = 'kr';
			cust.Address__c = address.roadAddr + '\n' + address.detailInfo;
			cust.RoadAddr__c = address.roadAddr;
			cust.DetailInfo__c = address.detailInfo;
		}
        let childComponent = component.find("DN_DealerPortalShipToList");
		let shippingType = childComponent.find('ShippingType__c').get("v.value");
		cust.ShippingType__c = shippingType;
		let shipToList = childComponent.get('v.shipToList');
		console.log(' < ==22222');
		let deleted = childComponent.get('v.deleted');
		let shipToObj = [];
		shipToList.forEach(element => {
			let obj ={}
			if(element.id !='')  { 
				obj.Id = element.id; 
			} else {
				delete element.id;
			}
			obj.Address__Street__s		= element.roadAddr + '\n' + element.detailInfo;
			obj.Address__PostalCode__s	= element.postalCode;							
			obj.Address__City__s		= element.city;						
			obj.Address__CountryCode__s	= 'KR';									
			obj.DetailInfo__c			= element.detailInfo;					
			obj.RoadAddr__c				= element.roadAddr;		
			shipToObj.push(obj);
		});
		console.log(JSON.stringify(shipToObj),  '33333');
		helper.apexCall(component, event, helper, 'saveRecord', {
            recordId 	: component.get('v.recordId'),
            customer 	: cust,
			shipToList 	: shipToObj,
			deleteShip : deleted
        })
        .then($A.getCallback(function(result) {
            let r = result.r;
			console.log(JSON.stringify(r), ' < ==11');
			// if(isCustom) {
			// 	helper.closeModal(component, event);	
			// } 
			let navService = component.find("navService");
			let pageReference = {
				type: 'standard__recordPage',
				attributes: {
					recordId: `${r.Id}`,
                	actionName: 'view',
				}
			};
			navService.navigate(pageReference);
			$A.get('e.force:refreshView').fire();
		}))
        .catch(function(error) {
			console.log(error[0].message ,' ::: error[0].message');
			helper.toast('ERROR', error[0].message);
        }).finally($A.getCallback(function () {
                component.set("v.isLoading", false);
            })
        );
	},

	// 닫기
	closeModal : function(component, event, helper) {
		let isCustom = component.get("v.isCustom");
		if(isCustom) {
			helper.closeModal(component, event);
		} else {
			window.history.back();
			$A.get('e.force:refreshView').fire();
		}
	},

	//뒤로 가기
	goBack :function(component, event, helper) {
		window.history.back()
	},

	handlePartDataChange : function(component, event, helper) {
		let parts = component.get('v.customer');
		parts[event.getSource().getLocalId()] = event.getSource().get("v.value");
		console.log(JSON.stringify(parts), ' :::parts');
		component.set('v.customer',parts);
	},

	// // parts 정보 수신
	// handleCmpEvent : function(component, event, helper) {
	// 	let message = event.getParam('message'); 
	// 	let parts = {};
	// 	for (const key in message) {
	// 		if(key =='Name') {
	// 			parts['LastName'] = message[key];	
	// 		} else{
	// 			parts[key] = message[key];
	// 		}
	// 	}
	// 	console.log(JSON.stringify(parts),' < ======parts');
	// 	component.find('LastName').set('v.value', message.Name);
	// 	component.find('MobilePhone').set('v.value', message.MobilePhone);
	// 	component.find('Phone').set('v.value', message.Phone);
	// 	component.find('Email').set('v.value', message.Email);
	// 	component.find('Fax').set('v.value', message.Fax);
	// 	component.set('v.parts',parts);
	// 	component.set('v.partsId', message.Id);
	// },

	// //파츠 데이터 삭제
	// clearParts : function(component, event, helper) {
	// 	component.find('PartsManager__c').set('v.value', '');
	// 	if(component.get('v.partId') !='') {
	// 		component.set('v.partsId', '');
	// 		component.find('MobilePhone').set('v.value', '');
	// 		component.find('Phone').set('v.value', '');
	// 		component.find('Email').set('v.value', '');
	// 		component.find('Fax').set('v.value', '');
	// 	} else {
	// 		component.find('LastName').set('v.value', '');
	// 	}
		
	// },

	// value 변경
	handleChange : function(component, event, helper) {		
		let cus =component.get('v.customer');
		console.log(cus, ' < ==cus');
		cus[event.getSource().getLocalId()] = event.getSource().get("v.value");
		console.log(JSON.stringify(cus),' < ===cus');
		component.set('v.customer',cus);
		console.log(JSON.stringify(component.get('v.customer')),' < =customer');
		// 부품대리점인 경우 설정값
		if(event.getSource().getLocalId() == 'IsDealer__c') {
			component.set('v.isDealer', event.getSource().get("v.value"));
			if(component.get('v.isDealer')) {
				component.find('DiscountRate__c').set('v.value','');
				component.find('Etc__c').set('v.value',''); 
				cus.DiscountRate__c ='';
				cus.Etc__c ='';
			}
		} 
	},
		

	// 주소검색
	handleJuso : function(component, event, helper) {
		component.set('v.isAddress', true);
	},

	// 주소삭제
	clearJuso : function(component, event, helper) {
		var addressField = component.find("Address__c");
    	addressField.set("v.value", "");
	},

	// 주소 정보 수신
	handleCompEvent : function(component, event, helper) {
		component.set('v.isAddress', false);
		let message = event.getParam('message');  
		console.log(JSON.stringify(message), ' < ===message');
		console.log(component.get('v.uuid'),' < == uuid');
		console.log(message.uuid,' < == uuid'); 
		console.log(' 주소검색 후 ele' );
		
		let address = component.find("Address__c");		
		
		if(component.get('v.uuid') == message.uuid) {
			// css 제거
			address.getElement().classList.remove('slds-has-error');
			let errorMessages = document.querySelectorAll('.slds-form-element__help');
			errorMessages.forEach(errorMessage => {
				errorMessage.remove();
				console.log(errorMessage,' :: errorMessage');
			})


			address.set("v.value",message.selectedResult.roadAddr + '\n' +message.detailedAddress);
			let addressSet ={
					roadAddr : message.selectedResult.roadAddr,
					street : message.selectedResult.roadAddr + '\n' +message.detailedAddress,
					postalCode : message.selectedResult.zipNo,
					sggNm : message.selectedResult.siNm + ' ' + message.selectedResult.sggNm,
					city : message.selectedResult.siNm,
					detailInfo : message.detailedAddress
			}
			console.log("message", message);
			component.set('v.address',addressSet);
			// ship to List에 대표주소를 첫번째 로우에만 추가
			let childComponent = component.find("DN_DealerPortalShipToList");
			let shipToList = childComponent.get("v.shipToList");
			let shipTo = {};
			if(shipToList[0].id !=undefined) {
				shipTo.id = shipToList[0].id;
			}
			shipTo.roadAddr = message.selectedResult.roadAddr;    
			shipTo.street = message.selectedResult.roadAddr + '\n' +message.detailedAddress;
			shipTo.postalCode = message.selectedResult.zipNo;
			shipTo.sggNm = message.selectedResult.siNm + ' ' + message.selectedResult.sggNm;
			shipTo.city = message.selectedResult.siNm;
			shipTo.detailInfo = message.detailedAddress;
			shipToList[0]= shipTo;
			childComponent.set('v.shipToList',shipToList);
			
			
		}
		// 재랜더링으로 인해 화면에 값들이 초기화되어 재할당
		/*let cust = component.get('v.customer');
		for (const key in cust) {
			let obj = component.find(`${key}`);
			if(cust[key] !='') {
				let value = cust[key]
				obj.set('v.value',value);
			}
			//component.find(`${key}`).set(`${cust[key]}`);
		}*/
	},



	// handleSearch : function(component, event, helper) {
	// 	component.set('v.searchCustomer', event.getSource().get("v.value"));
	// },
	// // 대리점 고객(admin) 기능
	// handleCustomerSearch : function(component, event, helper) {
	// 	let customer =component.get('v.customer');
	// 	helper.apexCall(component, event, helper, 'getCustomer', {
    //         customerCode : customer.SourceAccount__c
    //     })
    //     .then($A.getCallback(function(result) {
    //         let r = result.r;
	// 		console.log(JSON.stringify(r), ' < ===rr');
	// 		if(r.length > 0) {
	// 			component.set('v.customer',r[0]);
	// 			component.set('v.recordId', r[0].Id);
	// 			let partsId = r[0].PartsManager__c;
	// 			component.set('v.partsId', partsId);
	// 			console.log(partsId,' < ===partsId');
	// 		} else {
	// 			component.set('v.customer',{});
	// 			component.set('v.recordId','');
	// 			component.set('v.partsId','');
	// 		}
	// 		component.find("forceRecord").reloadRecord()
	// 		//component.find("recordEditForm").reloadRecord()
	// 		//component.find("partEditForm").reloadRecord()
	// 	}))
    //     .catch(function(error) {
	// 		helper.toast('ERROR', error[0].message);
    //     }).finally($A.getCallback(function () {
    //             component.set("v.isLoading", false);
    //         })
    //     );
	// },

	// 서브밋 이벤트 제거
	onSubmit : function(component, event, helper) {
		event.preventDefault();
		return;
	},
})