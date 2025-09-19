({
    showMyToast: function (type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },

    gfnDoinit : function(component, event) {
        component.set('v.isLoading', true);
        let self = this;
        this.apexCall(component, event, this, 'init', {}).then($A.getCallback(function(result) {
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                component.set('v.baseURL', r.url);

                component.set('v.reason1Options', r.reason1Options);
                component.set('v.reason2DependecyAllOptions', r.reason2Options);
            }
            else {
                self.toast('warning', ' 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            component.set('v.isLoading', false);
        });

    },

    gfnSearchReturnRequestOrder : function (component, event, type) {
        console.log(`${component.getName()}.gfnsearchReturnRequestOrder :`);
        component.set('v.isLoading', true);
        let page = this.gfnGetPageInfo(component, type);
        let nextPage = component.get('v.nextPage');

        let params = this.gfnGetSearchParams(component);
        console.log('params : ', JSON.stringify(params));
        params.page = page;
        params.nextPage = nextPage;
        
        let self = this;
        this.apexCall(component,event, this, 'searchReturnRequestOrder', params).then($A.getCallback(function(result) {
            let { r, state } = result;

            console.log('r : ',  r);
            console.log('state : ',  state);
            if(r.status.code === 200 ) {    
                
            
                if(!r.returnRequestList || r.returnRequestList.length ==0)
                    self.toast('Warning', '검색조건에 맞는 데이터가 존재 하지 않습니다.');
                else {
                    let reason1Option = component.get('v.reason1Options');
                    let reason2Option = component.get('v.defaultOptions');
                    r.returnRequestList.forEach((returnRequest)=>{
                        returnRequest.reason1Options = reason1Option;
                        returnRequest.reason2Options = reason2Option;
                    });
                }

                component.set('v.returnRequestList', r.returnRequestList);

                // let page = r.page;
                // let mas = {
                //     'currentPage' : page.currentPage,
                //     'itemsPerPage' : page.itemsPerPage,
                //     'pagesPerGroup' : page.pagesPerGroup,
                //     'currentRecordSize' : r.returnRequestList.length,
                //     'totalRecordSize' : page.totalRecordSize,
                //     'startIdx' : page.startIdx,
                //     'endIdx' : page.endIdx,
                //     'totalPage' : Math.ceil(page.totalRecordSize / page.itemsPerPage),
                //     'eventType' : type
                // };
                // self.messagePublish(component,'dataListSearch',mas);
            }
            else {
                self.toast('warning', ' 관리자한테 문의해주세요. ');
            }
            component.set('v.isLoading', false);
        })).catch(function(error) {
            console.log('# addError error : ' + error.message);
            component.set('v.isLoading', false);
        });
    },

    gfnGetPageInfo : function (component, type) {
        console.log(`${component.getName()}.gfnGetPageInfo :`);

        let currentPage = type =='Search'? 1 : component.get('v.currentPage');
        let nextPage = type =='Search'? 1 : component.get('v.nextPage');
        component.set('v.nextPage', nextPage);
        component.set('v.currentPage', currentPage);
        // 페이징 처리 데이터
        let page = {
            itemsPerPage : component.get('v.itemsPerPage'),
            currentPage : currentPage,
            pagesPerGroup : component.get('v.pagesPerGroup')
            // orderByField : this.orderByField,
            // orderBy : this.orderBy
        };
        
        return page;
        
    },

    //검색 조건 가공 
    gfnGetSearchParams : function (component) {
        //{"CustomerName__c":"a2XF7000000MykiMAC","productCode":"01tF7000008ice9IAA","orderSeq":"TEST"}
        //{"CustomerName__c":"9999999999","productCode":"01tF7000008ice9IAA","orderSeq":"TEST"}
        let headerParams = component.get('v.headerParams');
        console.log(`${component.getName()}.gfnGetSearchParams : `);
        console.log( JSON.stringify(headerParams))
        let params = {};

        for(const key in headerParams) {
            console.log(JSON.stringify(key), ' KEYS');
            if(key === 'CustomerName__c') {
                if(headerParams[key] === '9999999999') {
                    params.customerCode = headerParams[key];
                } else {
                    params.customerName = headerParams[key];
                }
            }else if(key === 'productCode') {
                params.partId = headerParams[key];
            }else {
                params[key] = headerParams[key];
            }
            
        }

        return params;
    },

    messagePublish : function(component, eventType, msg) {
        let messagePush = {
            uuid : component.get('v.uuid'),
            type : eventType,
            message : msg,
            cmpName : 'dataTable'
        }
        component.find("dealerPortalLMC").publish(messagePush);
    },

    gfnCreateReturn : function(component, event) {
        component.set('v.isLoading', true);
        let self = this;
        let selectedOrder = component.get("v.returnRequestList").filter((returnRequest)=>returnRequest.iscomplaintRow);
        if (selectedOrder.length < 1) {
            this.toast('Error', '반품 항목을 선택하여 주세요.');
            component.set('v.isLoading', false);
            return;
        }
        console.log(JSON.stringify(selectedOrder));

        let returnList = component.get("v.returnRequestList");
        let reason1Cmps = component.find('reason1');

        if(!Array.isArray(reason1Cmps)) {
            reason1Cmps = [reason1Cmps];
        }
        console.log('reason1Cmp', JSON.stringify(reason1Cmps));

        console.log(JSON.stringify(component.get('v.uploadFileMap')));
        let isValid = true;
        for (let i = 0; i < selectedOrder.length; i++) {
            if(selectedOrder[i].iscomplaintRow) {
                if(!selectedOrder[i].reason1) {
                    isValid = false;
                    self.toast('Error', 'You should input the Complaint Reason1.');
                    component.set('v.isLoading', false);
                    break;
                }
            }

            if(selectedOrder[i].returnQuantity <= 0 || selectedOrder[i].returnQuantity <= '0' || !selectedOrder[i].returnQuantity) {
                isValid = false;
                self.toast('Error', '반품 수량이 0 존재하여 반품 신청을 할 수 없습니다.');
                component.set('v.isLoading', false);
                break;
            }

            if(selectedOrder[i].returnQuantity > selectedOrder[i].orderQuantity) {
                isValid = false;
                self.toast('Error', '반품 수량이 주문수량을 넘을 수 없습니다.');
                component.set('v.isLoading', false);
                break;
            }

            if(selectedOrder[i].giQuantity < 0) {
                isValid = false;
                self.toast('Error', '출고 수량이 0 보다 작을 수 없습니다.');
                component.set('v.isLoading', false);
                break;
            }

            if(selectedOrder[i].returnQuantity > selectedOrder[i].giQuantity) {
                isValid = false;
                self.toast('Error', '반품 수량이 출고수량을 넘을 수 없습니다.');
                component.set('v.isLoading', false);
                break;
            }

        }

        if (isValid) {
            let params = {
                returnRequestList : selectedOrder
            };
            
            this.apexCall(component, event, this, 'createReturnRequestOrder', params).then($A.getCallback(function(result){
                let { r, state } = result;

                console.log('r : ',  r);
                console.log('state : ',  state);
                if(r.status.code === 200 ) {    
                    self.toast('Success', '반품 생성이 완료 되었습니다.');

                    self.gfnGenerateExcelData(component, r, r.returnRequestOrder);
                    self.navigationTo(component,
                        self.gfnGetCommunityCustomPageRef('OrderReturnManagement__c')
                    );
                } else {
                    self.toast('Error', '반품 생성중에 문제가 발생하였습니다. 시스템 관리자한테 문의 부탁드립니다.');
                }
                component.set('v.isLoading', false);
            }));
        }
    },

    gfnGenerateExcelData : function(component, r, returnOrders) {
        let headerData = [{
            '대리점명': returnOrders[0].dealerName,
            '참고문서번호' : r.returnOrderSeq,
            '생성일자': r.createDate,
            '생성시각' : r.createTime
        }];
        let exceldata = [];
        let index =1;
        let docType = '주문반품_입고';
        returnOrders.forEach(element => {
            exceldata.push({
                '순번' : index,
                '종류': '주문반품',
                '문서번호' : element.orderSeq,
                '품번' : element.partName,
                '품명' : element.partDetails,
                '수량' : element.returnQuantity,
                '재고위치' : element.loc || ''
            });
            index ++;
        });
        component.set('v.headerData',headerData);
        component.set('v.excelGRData',exceldata);
        component.set('v.excelName', `${r.returnOrderSeq}_${docType}증`);
        this.handleGIGRDocumentExcel(component); 
    },

    gfnFileUploadFinished : function(component, event) {
        let fileList = [];
        let uploadedFiles = event.getParam("files");
        let targetId = event.getSource().get('v.id');
        let returnRequestList = component.get("v.returnRequestList");
        let self = this;

        console.log(`targetId:  ${targetId}`);
        console.log(uploadedFiles,' < ===uploadedFiles');
        uploadedFiles.forEach(element => {
            console.log(element, ' > ====test1111');

            let file = self.gfnSetFile(component, targetId, element.documentId, element.name);
            fileList.push(file);
        });

        let fileMap = component.get('v.uploadFileMap');
        if(fileMap == null) fileMap = {};
        
        if(!Array.isArray(fileMap[targetId])) fileMap[targetId] = fileList;
        else fileMap[targetId] = fileMap[targetId].concat(fileList);

        returnRequestList.forEach((returnOrder)=>{
            if(returnOrder.itemId == targetId) {
                if(!Array.isArray(returnOrder.fileList))
                   returnOrder.fileList = fileList;
                else 
                   returnOrder.fileList = returnOrder.fileList.concat(fileList);
            }
        })
        component.set('v.returnRequestList', returnRequestList);

        component.set('v.uploadFileMap', fileMap);
    },

    gfnSetFile : function(component, returnItemId, documentId, title) {
        let previewUrl = component.get('v.baseURL')+'/contentdocument/'+documentId;
        return {
            returnItemId, documentId, title, previewUrl
        };
    },

    gfnRemoveFile : function(component, fileId) {
        component.set('v.isLoading', true);
        let returnRequestList = component.get('v.returnRequestList');
        let self = this;
        this.apexCall(component, null, this, 'fileRemove', {fileId}).then($A.getCallback(function(result) {
            if(result) {
                returnRequestList.forEach((returnRequest)=>{
                    let removeIdx;
                    for(let fileIdx = 0; fileIdx < returnRequest.fileList.length; fileIdx++) {
                        let file = returnRequest.fileList[fileIdx];
                        if(file.documentId == fileId) {
                            removeIdx = fileIdx;
                            break;
                        }
                    }
                    returnRequest.fileList.splice(removeIdx, 1);
                });
                component.set('v.returnRequestList', returnRequestList);
            }
            component.set('v.isLoading', false);
        }));

    },

    gfnSetCustomerInfo : function(component, customer, customerCode, customerName) {
        if(customerCode == '9999999999') {
            //일반 고객
            component.set('v.customerCode', customerCode);
            component.set('v.customer', undefined);
        }else {
            //대리점 고객
            component.set('v.customerCode', undefined);
            component.set('v.customer', customer);
        }
        component.set('v.customerName', customerName);
    },

})