/**
 * @description       : 납품 후 교육 요청
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 06-16-2025
 * @last modified by  : chungwoo.lee@sobetec.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-22-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
    doInit: function (component, event, helper) {

        // 검색 조건 수주번호(false 로 변경시 장비번호)
        component.set("v.isSelected", true);

        // 교육요청일시(1) 에 대한 설정(오늘 + 1일을 기본일로 잡음)
        let tommorow = new Date();
        tommorow.setDate(tommorow.getDate() + 1);
        tommorow = tommorow.toISOString().split('T')[0] + 'T00:00';
        component.set('v.eduDateOne', tommorow); // 교육요청일시(1)에 할당
        component.set('v.tommorow', tommorow);   // 교육요총일시 발리데이션 적용시

        // 접속한 사용자 정보 가져오기
        helper.apexCall(component, 'GetUserInfo', {})
        .then($A.getCallback(function(result) {
            console.log('사용자(=딜러) 정보 가져오기');
            let response = result.r;
            console.log('유저 정보 :: ' +JSON.stringify(response,null,4));
            component.set('v.dealerInfo', response);

            // 교육 담당 정보 가져오기
            let eduRep = 'eduRep';
            return helper.apexCall(component, 'GetEduRep', {eduRep : eduRep});
        }))
        .then($A.getCallback(function(result) {
            let response = result.r;
            let eduRepOptions = response.map(edu => {
                return { label : edu.UserOrGroup.Name, value : edu.UserOrGroup.Id }
            })
            component.set('v.eduRepOptions',eduRepOptions)
        }))
        .catch($A.getCallback(function(errors) {
            if(errors && errors[0] && errors[0].message) {
                console.log('에러 발생 사유 :: ' + errors[0].message);
            } else {
                console.log('에러 발생 사유 :: 알 수 없음');
            }
        }))
    },

    // 속성 이름과 값 매칭
    handleChange : function(component, event, helper) {
        helper.updateFieldValue(component, event);
    },

    // 교육 요청일시 별도 로직
    requestDate : function(component, event, helper) {
        helper.dateCheck(component, event, helper);
    },

    // 뒤로가기
    /* goBack: function (component, event, helper) {
        component.set('v.isLoading', true);
        const navTrainingList = component.find("navTrainingList");
        const page = {
            type: "standard__webPage",
            attributes: {
                url: "/post-delivery-training-list",
            }
        };
        navTrainingList.navigate(page);
        component.set('v.isLoading', false);
    },
    */

    // 뒤로가기 (딜러포탈/메인오그 전체적용)
    goBack: function(component, event, helper) {
    component.set('v.isLoading', true);
    const navList = component.find("navTrainingList");
    const path    = window.location.pathname;

    // 메인 오그(Lightning Experience)일 경우
    if (!path.includes('/s/')) {
        navList.navigate({
            type: 'standard__navItemPage',
            attributes: { 
                apiName: 'DN_postDeliveryTrainingList' 
                }
            });
        }
    
    // 딜러 포탈(Experience Cloud)일 경우
    else {
        navList.navigate({
            type: 'standard__webPage',
            attributes: {
                 url: '/post-delivery-training-list' 
                }
            });
        }

    component.set('v.isLoading', false);
    },


    selectNumber: function(component, event, helper) {
        var numberCategoryValue = event.getParam("value");
        console.log("numberCategoryValue", numberCategoryValue);
    
        if (numberCategoryValue == "수주번호") {
            component.set("v.isSelected", true);
            component.set('v.erpPSONo', null);
            component.set('v.assetInfo', null);
            component.set('v.shipToInfo', null);
            component.set('v.orderInfo', null);
            component.set('v.conOptions', null);
            component.set('v.repId', null);
            component.set('v.repName', null);
            component.set('v.repMP', null);
            component.set('v.repTitle', null);
            component.set('v.eduLevel', null);
            component.set('v.eduCnt', null);
            component.set('v.stuLevel', null);
            component.set('v.eduRep', null);
            component.set('v.eduDateOne', null);
            component.set('v.eduDateTwo', null);
            component.set('v.eduDateThr', null);
            component.set('v.note', null);


        } else if (numberCategoryValue == "장비번호") {
            component.set("v.isSelected", false);
            component.set('v.assetNo', null);
            component.set('v.assetInfo', null);
            component.set('v.shipToInfo', null);
            component.set('v.orderInfo', null);
            component.set('v.conOptions', null);
            component.set('v.repId', null);
            component.set('v.repName', null);
            component.set('v.repMP', null);
            component.set('v.repTitle', null);
            component.set('v.eduLevel', null);
            component.set('v.eduCnt', null);
            component.set('v.stuLevel', null);
            component.set('v.eduRep', null);
            component.set('v.eduDateOne', null);
            component.set('v.eduDateTwo', null);
            component.set('v.eduDateThr', null);
            component.set('v.note', null);
        }
    },

    //수주번호 모달 열기
    openOrderListModal : function(component, event, helper) {
        component.set("v.isLoading", true);
        // let assetList = component.get('v.assetList');
        let dealerInfo = component.get('v.dealerInfo');
        let eduTicket = true;
        $A.createComponent("c:DN_OrderListModalforServiceHistoryResult",
                {
                // 'assetList'  : assetList,
                 'dealerInfo' : dealerInfo,
                 'eduTicket'  : eduTicket
                },
            function(content, status, errorMessage) {
            if (status === "SUCCESS") {
            var container = component.find("OrderListModal");
            container.set("v.body", content);
            }else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.")
            } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
            }
        });
        component.set("v.isLoading", false);

    },
    
    // 장비번호 모달 
    openSerialNumberModal: function (component, event, helper) {
        component.set("v.isLoading", true);
        let machineName = component.get("v.machineName");
        var type = '장비번호';
        
        let dealerInfo = component.get('v.dealerInfo');
        let isRequest = true;
        $A.createComponent("c:DN_ModelSearchModal",
            {
                'type': type,
                'MachineName' : machineName,
                'isRequest' : isRequest,
                'dealerInfo' : dealerInfo
            
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ModelSearchModal");
                    container.set("v.body", content);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        component.set("v.isLoading", false);
    },

    // 수주번호, 장비번호 가져오는 이벤트
    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam("modalName");
        var message = event.getParam("message");

        if (modalName == 'DN_OrderListModalforServiceHistoryResult') {
            console.log('수주번호정보 가져오기');
            console.log('message :: ' +JSON.stringify(message,null,4));
            var erpPSONo = message.psoNumber;
            component.set('v.erpPSONo', erpPSONo);
            
        } else if (modalName == 'SerialModal') {
            console.log('장비번호정보 가져오기');
            component.set('v.assetNo', message.label);
            console.log('messgae :: ' +JSON.stringify(message,null,4))
        }
    },

    doSearch : function (component, event, helper) {
        component.set('v.isLoading', true);
        
        var isSelected = component.get('v.isSelected'); // 수주 : 장비
        var dealerInfo = component.get('v.dealerInfo'); // 딜러 정보
        var erpPSONo   = component.get('v.erpPSONo');   // 수주번호
        var assetNo    = component.get('v.assetNo');    // 장비번호
        
        let userProfile = dealerInfo.userProfile;
        let userId = dealerInfo.dealerId;

        // 수주번호로 검색시
        console.log('수주번호 검색 시작');
        console.log('userProfile  :: ' +userProfile)
        console.log('userId       :: ' +userId)
        console.log('erpPSONo     :: ' +erpPSONo)

        let type = isSelected ? 'erp' : 'asset';
        let type2 = isSelected ? erpPSONo : assetNo;
        let type3 = isSelected ? '수주번호' : '장비번호';
            
        console.log('type>> ' +type);
        console.log('type2>> ' +type2);
        console.log('type3>> ' +type3);
        if(!type2){
            helper.toast('WARNING', `${type3} 를 입력해 주세요.`);
            component.set('v.isLoading', false);
            return;
        }else {
            helper.apexCall(component, 'GetAssetInfo', {
                type        : type,
                dealerInfo  : dealerInfo,
                erpPSONo    : type2
            })
            .then($A.getCallback(function(result) {
                console.log('수주번호 기반 정보 가져오기');
                let response = result.r;
                console.log('response : '+JSON.stringify(response,null,4))

                if (response.length == 0) {
                  return Promise.reject('noOrder');
                }
                
                // 장비 정보
                let assetInfo = {
                    assetId      : response[0].SOSerialNumber__r.Id, // 장비 Id
                    erpPsoNo     : response[0].ERPPSONo__c,   // 수주번호
                    assetName    : response[0].SOSerialNumber__r.MachineName__c, // 기종
                    machineNo    : response[0].SOSerialNumber__r.Name,           // 장비번호
                    completeDate : response[0].SOSerialNumber__r && response[0].SOSerialNumber__r.InstallationFinish__c ? response[0].SOSerialNumber__r.InstallationFinish__c : null,  // 설치완료일
                    warranty     : response[0].SOSerialNumber__r.FM_EquipmentWarrantyEquipmentParts__c, // 보증여부
                    ncType       : response[0].SOSerialNumber__r.NCType__c          // NC type
                }
                console.log('장비정보 >> ' +JSON.stringify(assetInfo,null,4))
                // 배송처 정보
                let shipToInfo = {
                    shipToName  : response[0].ShipTo_PSO__r.Name, // 배송처 이름
                    shipToId    : response[0].ShipTo_PSO__c,   // 배송처 Id
                    shipToPhone : response[0].ShipTo_PSO__r.Phone, // 배송처 전화번호
                    // shipToAddress : response[0].ShipTo_PSO__r.FM_Address__c // 배송처 주소(운영)
                    shipToAddress : response[0].ShipTo_PSO__r.fm_address__c // 배송처 주소(샌박)
                }
                console.log('배송처 >> ' +JSON.stringify(shipToInfo,null,4))
                // 오더 정보
                let orderInfo = {
                    Id : response [0].Id,
                    erpNo : response [0].ERPPSONo__c,
                }
                console.log('오더 정보 >> ' +JSON.stringify(orderInfo,null,4))
                
                component.set('v.assetInfo', assetInfo);
                component.set('v.shipToInfo', shipToInfo);
                component.set('v.orderInfo', orderInfo);

                
                let accId = shipToInfo.shipToId;
                return helper.apexCall(component, 'GetAccContact', {accId : accId});
            }))
            .then($A.getCallback(function(result) {
                let response = result.r;
                console.log('contact 정보 ::: ' +JSON.stringify(response,null,4));
                component.set('v.conList', response.Contacts);
                if(response && response.Contacts) {
                        let conOptions = response.Contacts.map(con => {
                        return {
                            label : con.Name, value : con.Id
                        }
                        })
                    component.set('v.conOptions', conOptions);
                }else {
                    // helper.toast('SUCCESS', '담당자가 배정되지 않았습니다.');
                }
                                
                component.set('v.isLoading', false);
            }))
            .catch($A.getCallback(function(errors) {
                component.set('v.isLoading', false);
                if(errors == 'noOrder') {
                    helper.toast('INFO', '판매한 장비에 대한 권한이 없습니다. 판매한 딜러가 요청하시기 바랍니다.');
                }else {
                	helper.toast('ERRORS','반복되면 관리자에게 문의 부탁 드립니다.');
                    console.log('error >> ' + errors);
                }
            }))
        }
    },

    // 수주번호 지우기
    clearOrderNumber: function (component, event, helper) {
        let erpPSONo = component.get("v.erpPSONo");
        if (!erpPSONo) {
            helper.toast("WARNING", "저장된 수주번호 값이 없습니다."); //  수주번호 값이 없을 때 알림
            return;
        }
        component.set('v.erpPSONo', null);
        component.set('v.assetInfo', null);
        component.set('v.shipToInfo', null);
        component.set('v.orderInfo', null);
        component.set('v.repId', null);
        component.set('v.repName', null);
        component.set('v.repMP', null);
        component.set('v.repTitle', null);
        component.set('v.eduLevel', null);
        component.set('v.eduCnt', null);
        component.set('v.stuLevel', null);
        component.set('v.eduRep', null);
        component.set('v.eduDateOne', null);
        component.set('v.eduDateTwo', null);
        component.set('v.eduDateThr', null);
        component.set('v.note', null);
        component.set('v.conOptions', null);
    },

    //장비번호 지우기
    clearAsset : function (component, event, helper) {
        let assetNo = component.get("v.assetNo");
        if (!assetNo) {
            helper.toast("WARNING", "저장된 장비번호 값이 없습니다."); // 장비번호 값이 없을 때 알림
            return;
        }
        component.set('v.assetNo', null);
        component.set('v.assetInfo', null);
        component.set('v.shipToInfo', null);
        component.set('v.orderInfo', null);
        component.set('v.repId', null);
        component.set('v.repName', null);
        component.set('v.repMP', null);
        component.set('v.repTitle', null);
        component.set('v.eduLevel', null);
        component.set('v.eduCnt', null);
        component.set('v.stuLevel', null);
        component.set('v.eduRep', null);
        component.set('v.eduDateOne', null);
        component.set('v.eduDateTwo', null);
        component.set('v.eduDateThr', null);
        component.set('v.note', null);
        component.set('v.conOptions', null);
    },

    //고객사명 지우기
    clearCustomerName : function (component, event, helper) {
        let customerName = component.get("v.customerName");
        if (!customerName) {
            helper.toast("WARNING", "저장된 고객사명 값이 없습니다."); // 장비번호 값이 없을 때 알림
            return;
        }
        component.set("v.customerName", "");
        },

    // 첨부파일 업로드 후처리
    handleUploadFinished: function (component, event) {
        const uploadedFiles = event.getParam("files");
        const fileList = component.get("v.fileList");

        uploadedFiles.forEach((file) => {
            fileList.push({
                title: file.name,
                contentDocumentId: file.documentId
            });
        });

        component.set("v.fileList", fileList);
    },

    // 파일 제거
    removeFile: function (component, event, helper) {
        component.set('v.isLoading', true);
        const fileId = event.currentTarget.dataset.id;
        let fileList = component.get("v.fileList");
        console.log('fileList >> ' +JSON.stringify(fileList,null,4));

        helper.apexCall(component, 'deleteFiles', {fileId : fileId})
        .then($A.getCallback(function(result) {
            let response = result.r;
            helper.toast('SUCCESS', '선택하신 첨부파일을 제외 했습니다.');
            fileList = fileList.filter((file) => file.contentDocumentId !== fileId);
            component.set("v.fileList", fileList);
            component.set('v.isLoading', false);
        }))
        .catch($A.getCallback(function(error){
            helper.toast('ERROR', '첨부파일 삭제에 실패했습니다.');
            component.set('v.isLoading', false);
        }))
        console.log('삭제해야할 파일 ID '+JSON.stringify(fileId,null,4))
    },

    doSave : function (component, event, helper) {
        component.set('v.isLoading', true);
    
        // 수주/장비 선택값 체크
        let erpPSONo = component.get('v.erpPSONo');
        let assetNo = component.get('v.assetNo');
        let isSelected = component.get('v.isSelected');
    
        if (isSelected && (!erpPSONo || erpPSONo === '')) {
            helper.toast('WARNING', '수주번호를 확인 해주세요.');
            component.set('v.isLoading', false);
            return;
        } else if (!isSelected && (!assetNo || assetNo === '')) {
            helper.toast('WARNING', '장비번호를 확인 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        // 기본 정보
        let dealerInfo = component.get('v.dealerInfo');
        let shipToInfo = component.get('v.shipToInfo');
        let shipToRepId = component.get('v.repId');
        let shipToRepName = component.get('v.repName');
        let shipToRepMP = component.get('v.repMP');
        let shipToRepTitle = component.get('v.repTitle');

        // 2025-06-13 이청우 추가 : 검색하지 않고 저장하는 경우 고객사명이 없이 호출 방지
        if (!shipToInfo || !shipToInfo.shipToName || shipToInfo.shipToName.trim() === '') {
            helper.toast('WARNING', '고객사 정보와 장비정보가 기입되어야합니다.');
            component.set('v.isLoading', false);
            return;
        }

    
        if (!dealerInfo.userMobilePhone || dealerInfo.userMobilePhone.trim() === '') {
            helper.toast('WARNING', '접수자 전화번호를 확인 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!shipToRepName || shipToRepName.trim() === '') {
            helper.toast('WARNING', '고객사 담당자를 선택 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!shipToRepMP || shipToRepMP.trim() === '') {
            helper.toast('WARNING', '고객사 연락처를 입력 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!shipToRepTitle || shipToRepTitle.trim() === '') {
            helper.toast('WARNING', '고객사 직책을 입력 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!shipToInfo.shipToAddress || shipToInfo.shipToAddress.trim() === '') {
            helper.toast('WARNING', '고객사 주소를 입력 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        // 교육 정보
        let eduLevel = component.get('v.eduLevel');
        let eduCnt = component.get('v.eduCnt');
        let stuLevel = component.get('v.stuLevel');
        let eduRep = component.get('v.eduRep');
        let eduDateOne = component.get('v.eduDateOne');
        let eduDateTwo = component.get('v.eduDateTwo');
        let eduDateThr = component.get('v.eduDateThr');
        let note = component.get('v.note');
    
        if (!eduLevel) {
            helper.toast('WARNING', '교육 종류을 선택 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!eduCnt) {
            helper.toast('WARNING', '교육 횟수를 선택 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!stuLevel) {
            helper.toast('WARNING', '피교육자 수준을 선택 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!eduRep) {
            helper.toast('WARNING', '교육 담당자를 선택 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!eduDateOne) {
            helper.toast('WARNING', '교육 요청 일시(1)을 선택 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!eduDateOne && (eduDateTwo || eduDateThr)) {
            helper.toast('WARNING', '교육 요청 일시(1)을 먼저 입력 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!eduDateTwo && eduDateThr) {
            helper.toast('WARNING', '교육 요청 일시(2)를 먼저 입력 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        if (!note || note.trim() === '') {
            helper.toast('WARNING', '접수내용을 작성 해주세요.');
            component.set('v.isLoading', false);
            return;
        }
    
        // eduInfo 구성
        let eduInfo = {
            eduLevel : eduLevel, 
            eduCnt : eduCnt, 
            stuLevel : stuLevel, 
            eduRep : eduRep,
            eduDateOne : eduDateOne, 
            eduDateTwo : eduDateTwo, 
            eduDateThr : eduDateThr,
            note : note
        };
    
        // shipToInfo 구성
        shipToInfo = {
            shipToName: shipToInfo.shipToName,
            shipToId: shipToInfo.shipToId,
            salesAgents: dealerInfo.accountName,
            dealerName: dealerInfo.dealerName,
            dealerPhone: dealerInfo.userMobilePhone,
            shipToRepId: shipToRepId,
            shipToRepName: shipToRepName,
            shipToRepMP: shipToRepMP,
            shipToRepTitle: shipToRepTitle,
            shipToAddress: shipToInfo.shipToAddress
        };
    
        let orderInfo = component.get('v.orderInfo');
        let assetInfo = component.get('v.assetInfo');
        let files = JSON.stringify(component.get('v.fileList'));
    
        // Contact가 없으면 먼저 생성
        let contactPromise;
        if (!shipToInfo.shipToRepId) {
            contactPromise = helper.apexCall(component, 'insertContact', { ci: shipToInfo })
                .then($A.getCallback(function(result) {
                    shipToInfo.shipToRepId = result.r;
                    console.log('확인 1 >> ' +JSON.stringify(shipToInfo,null,4));
                    return shipToInfo;
                }));
        } else {
            contactPromise = Promise.resolve(shipToInfo);
        }
    
        // 티켓 생성 + 후속 처리
        contactPromise
            .then($A.getCallback(function(shipToInfo) {
                console.log('확인 2 >> ' +JSON.stringify(shipToInfo,null,4));
                return helper.apexCall(component, 'insertTicket', {
                    oi: orderInfo,
                    ai: assetInfo,
                    di: dealerInfo,
                    si: shipToInfo,
                    ei: eduInfo,
                    fi: files
                });
            }))
            .then($A.getCallback(function(result) {
                component.set('v.isLoading', false);
                let recordId = result.r;
                helper.toast('SUCCESS', '교육 티켓이 생성되었습니다.');
                return recordId;
            }))
            .then($A.getCallback(function(recordId) {
                localStorage.setItem('caseNo', recordId);
                helper.toast('SUCCESS', '티켓 조회 화면으로 이동합니다.');
                //helper.abackOrderInquiry(); 기존 딜러포탈 기준 코드
               
                // 메인 오그 환경 : 메인 오그 목록 화면으로 이동동
                const path = window.location.pathname;
                if (!path.includes('/s/')) {
                    component.find('navTrainingList').navigate({
                       type: 'standard__navItemPage',
                       attributes: { apiName: 'DN_postDeliveryTrainingList' },
                       state: { c__orderNumber: recordId }
                   });
                   return;
                }
                // 딜러포탈 환경: 딜러 포탈 목록 화면으로 이동
                helper.abackOrderInquiry();
            
            }
            )) 
                
            .catch($A.getCallback(function(errors) {
                component.set('v.isLoading', false);
                if (errors && errors[0] && errors[0].message) {
                    console.log('insert 에러 사유 : ' + errors[0].message);
                } else {
                    console.log('insert 에러 사유 : ??? ?????');
                }
            }));
    }
    
})