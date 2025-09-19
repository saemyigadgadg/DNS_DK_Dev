({
    
    apexCall : function( component, event, helper, methodName, params ) {
        var self = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            let action = component.get('c.' + methodName);

            if(typeof action !== 'undefined') {
                action.setParams(params);

                action.setCallback(helper, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        resolve({'c':component, 'h':helper, 'r':response.getReturnValue(), 'state' : response.getState()});
                    } else {
                        let errors = response.getError();
                        console.log(methodName, errors);
						reject(errors);
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },
    toast: function (type, mmg) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            message: mmg
        });
        toastEvent.fire();
    },

    navigationTo: function (component, pageReference, isReplace) {
        let navService = component.find("navService");
        navService.navigate(pageReference, isReplace);
    },

    gfnPadStart : function (number, totalLength ,pattern) {
        return String(number).padStart(totalLength, pattern);
    },

    excelDataSet: function(component) {
        return new Promise((resolve, reject) => {
    
            let excelData = component.get('v.excelData');
            if (!excelData || excelData.length === 0) {
                //this.toast('Error', 'Excel data is empty.');
                component.set('v.isLoading', false);
                reject('Excel data is empty.');
                return;
            }
    
            let workbook = new ExcelJS.Workbook();
            let worksheet = workbook.addWorksheet('Sheet1');
    
            // ✅ 압축 속도 최적화
            workbook.zipOptions = { compression: "DEFLATE", compressionOptions: { level: 1 } };
    
            worksheet.columns = Object.keys(excelData[0]).map(key => ({
                header: key, 
                key: key
            }));
            // ✅ 성능 개선: 개별 addRow 대신 한 번에 추가
            worksheet.addRows(excelData);
            worksheet.columns.forEach(column => {
                let maxLength = 6;
                let headerCell = worksheet.getCell(1, column.number);
                let headerLength = headerCell.value ? headerCell.value.toString().length : 0;
                maxLength = Math.max(maxLength, headerLength);

                worksheet.eachRow({ includeEmpty: true }, row => {
                    let cell = row.getCell(column.key);
                    let cellValue = cell.value;
                    if (typeof cellValue === 'string' && cellValue.match(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/)) {
                        maxLength = Math.max(maxLength, cellValue.length + 6);
                    } else if (typeof cellValue === 'string') {
                        maxLength = Math.max(maxLength, cellValue.length + 2);
                    } else if (typeof cellValue === 'number') {
                        maxLength = Math.max(maxLength, String(cellValue).length);
                    }
                });

                column.width = maxLength + 2;

                headerCell.font = { bold: true };
                headerCell.alignment = { vertical: 'middle', horizontal: 'center' };
                headerCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'D3D3D3' } };
            });

            worksheet.eachRow({ includeEmpty: false }, row => {
                row.eachCell({ includeEmpty: false }, cell => {
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' }
                    };
                });
            });

            // ✅ 비동기 실행하여 UI 멈춤 방지
            setTimeout(() => {
                workbook.xlsx.writeBuffer().then(buffer => {
                    component.set('v.blob', new Blob([buffer], { type: 'application/octet-stream' }));
                    resolve('Excel 생성 완료!');
                }).catch(error => {
                    console.error('Excel 생성 중 오류 발생:', error);
                    reject(error);
                });
            }, 0);
        });
    },
    
    // 액셀 다운로드
    handleExcelDownload : function(component) {
        let self = this;
        let excelData = component.get('v.excelData');
        if (excelData.length === 0) {
            self.toast('Error', 'Excel data is empty.');
            component.set('v.isLoading', false);
            return;
        }
        let excelName   = component.get('v.excelName');
        let blob        = component.get('v.blob');
        var link        = document.createElement('a');
        link.href       = URL.createObjectURL(blob);
        link.download   = excelName + '.xlsx';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        component.set('v.isLoading', false);
    },

    // 단순 리스트 다운로드
    handleExcel : function(component) {
        //console.log('handleExcel');
        let self = this;
        let excelData = component.get('v.excelData');
        console.log(JSON.stringify(excelData), ' M == excelData');

        if (excelData.length === 0) {
            self.toast('Error', 'Excel data is empty.');
            component.set('v.isLoading', false);
            return;
        }

        let excelName = component.get('v.excelName');
        let workbook = new ExcelJS.Workbook();
        let worksheet = workbook.addWorksheet('Sheet1');
        let excelField = component.get('v.excelField');
        let columns = [];

        if (excelField.length > 0) {
            columns = excelField;
        } else {
            let firstRecord = excelData[0];
            columns = Object.keys(firstRecord).map(key => ({
                header: key.charAt(0).toUpperCase() + key.slice(1),
                key: key
            }));
        }

        console.log(JSON.stringify(columns), ' : columns');
        worksheet.columns = columns;


        // 500개씩 청크 단위로 추가하는 함수
        function addRowsInChunks(index) {
            if (index >= excelData.length) {
                formatWorksheet(worksheet);
                saveExcel(workbook, excelName);
                return;
            }

            let chunkSize = 500; // 한 번에 추가할 개수
            let chunk = excelData.slice(index, index + chunkSize);
            chunk.forEach(record => worksheet.addRow(record));

            setTimeout(() => addRowsInChunks(index + chunkSize), 10);
        }

        addRowsInChunks(0); // 비동기 방식으로 실행

        function formatWorksheet(worksheet) {
            worksheet.columns.forEach(column => {
                let maxLength = 6;
                let headerCell = worksheet.getCell(1, column.number);
                let headerLength = headerCell.value ? headerCell.value.toString().length : 0;
                maxLength = Math.max(maxLength, headerLength);

                worksheet.eachRow({ includeEmpty: true }, row => {
                    let cell = row.getCell(column.key);
                    let cellValue = cell.value;
                    if (typeof cellValue === 'string' && cellValue.match(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/)) {
                        maxLength = Math.max(maxLength, cellValue.length + 6);
                    } else if (typeof cellValue === 'string') {
                        maxLength = Math.max(maxLength, cellValue.length + 2);
                    } else if (typeof cellValue === 'number') {
                        maxLength = Math.max(maxLength, String(cellValue).length);
                    }
                });

                column.width = maxLength + 2;

                headerCell.font = { bold: true };
                headerCell.alignment = { vertical: 'middle', horizontal: 'center' };
                headerCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'D3D3D3' } };
            });

            worksheet.eachRow({ includeEmpty: false }, row => {
                row.eachCell({ includeEmpty: false }, cell => {
                    cell.border = {
                        top: { style: 'thin' },
                        left: { style: 'thin' },
                        bottom: { style: 'thin' },
                        right: { style: 'thin' }
                    };
                });
            });
        }

        function saveExcel(workbook, excelName) {
            workbook.xlsx.writeBuffer().then(buffer => {
                let blob = new Blob([buffer], { type: 'application/octet-stream' });
                let link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = excelName + '.xlsx';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                component.set('v.isLoading', false);
            });
        }
        
        
    },

    //출력 기능
    handleprint : function(component) {
        let openUrl = component.get('v.openUrl');
        console.log(openUrl + ' :::openUrl');
        
        //localStorage.setItem("uuid", "새로고침");
        // post message
        const B = window.open(`${openUrl}`, `출력`, `top=10, left=10, width=500, height=500, status=no, menubar=no, toolbar=no, resizable=no, scrollbars=true`);
        // //새창으로 메세지 전송
        // setTimeout(() => {
        //     B.postMessage("홀리홀리", "*");    
        // }, 5000);

        // window.addEventListener("message", function(event) {
        //     console.log("부모창에서 메세지 받기", event.data);
            
        // }, false);
        
    },
    //엑셀 업로드 헤더
    handleHeaderUpload: function(component,file,event) {
        if(file) {

            /**
         * application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
            xlsx
            application/vnd.ms-excel
            xls
         */
            return new Promise((resolve, reject) => {
                try {

                    const ext = file.name.split('.').pop().toLowerCase();
                    const validTypes = [
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // xlsx
                    'application/vnd.ms-excel', // xls or sometimes csv
                    'text/csv'
                    ];

                    if (!validTypes.includes(file.type) && !['xlsx', 'xls', 'csv'].includes(ext)) {
                        reject('엑셀 또는 CSV 파일만 업로드할 수 있습니다.');
                    }
                                        
                    // if(file.type !='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' && file.type !='application/vnd.ms-excel') {
                    //     reject('올바르지 않는 파일타입입니다.');
                    // }


                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var data = new Uint8Array(e.target.result);
                        var workbook = XLSX.read(data, { type: "array" });
                        // 첫 번째 시트 선택
                        var sheetName = workbook.SheetNames[0];
                        var sheet = workbook.Sheets[sheetName];
                        // 키벨류
                        var sheetData = XLSX.utils.sheet_to_json(sheet); // 엑셀데이터
                        sheetData = sheetData.map(item => {
                            return Object.fromEntries(
                                Object.entries(item).map(([key, value]) => {
                                    if (typeof value === "string") {
                                        return [key, value.toUpperCase().trim()]; // 문자열인 경우 대문자로 변환
                                    }
                                    return [key, value]; // 문자열이 아니면 그대로 유지
                                })
                            );
                        });    
                        console.log('Row Data:', JSON.stringify(sheetData));
                        component.set('v.uploadData', sheetData); // Row 데이터 설정
                        resolve();
                    }
                    reader.onerror = function(error) {
                        // 오류 메시지 확인 후, 보안 프로그램으로 인한 오류인지를 추정
                       if (error.target.error && error.target.error.message.includes("permission")) {
                            reject("보안 프로그램으로 인해 파일을 업로드할 수 없습니다.");
                       } else {
                            reject("파일 업로드 형태를 확인해주세요.");
                       }
                       //reject('보안프로그램으로 인해 파일을 읽을 수 없습니다.');
                   };
                    reader.readAsArrayBuffer(file);    
                } catch (error) {
                    reject(error); 
                }
            });
        } 
    },
    //엑셀 업로드 첫번쨰 행 제외
    handleNotOneRowUpload: function(component, file,event) {
        if (file) {
            return new Promise((resolve, reject) => {
                try {
                    const ext = file.name.split('.').pop().toLowerCase();
                    const validTypes = [
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // xlsx
                    'application/vnd.ms-excel', // xls or sometimes csv
                    'text/csv'
                    ];

                    if (!validTypes.includes(file.type) && !['xlsx', 'xls', 'csv'].includes(ext)) {
                        reject('엑셀 또는 CSV 파일만 업로드할 수 있습니다.');
                    }
                    // if(file.type !='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' && file.type !='application/vnd.ms-excel') {
                    //     reject('올바르지 않는 파일타입입니다.');
                    // }
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var data = new Uint8Array(e.target.result);
                        var workbook = XLSX.read(data, { type: "array" });
                        
                        // 첫 번째 시트 선택
                        var sheetName = workbook.SheetNames[0];
                        var sheet = workbook.Sheets[sheetName];
                        
                        // Excel 데이터를 JSON 형태로 변환
                        var sheetData = XLSX.utils.sheet_to_json(sheet, { header: 1 });
                        
                        // 첫 번째 행 제외
                        var filteredData = sheetData.slice(1); // 첫 행 제거
                        
                        filteredData = filteredData.map(item => {
                            return Object.fromEntries(
                                Object.entries(item).map(([key, value]) => {
                                    if (typeof value === "string") {
                                        return [key, value.trim()]; // 문자열인 경우 대문자로 변환
                                    }
                                    return [key, value]; // 문자열이 아니면 그대로 유지
                                })
                            );
                        });    
                        
                        // 컴포넌트에 데이터 설정
                        component.set('v.uploadData', filteredData);
                        
                        resolve();
                    };
                    reader.onerror = function(error) {
                        // 오류 메시지 확인 후, 보안 프로그램으로 인한 오류인지를 추정
                       if (error.target.error && error.target.error.message.includes("permission")) {
                            reject("보안 프로그램으로 인해 파일을 업로드할 수 없습니다.");
                       } else {
                            reject("파일 업로드 형태를 확인해주세요.");
                       }
                       //reject('보안프로그램으로 인해 파일을 읽을 수 없습니다.');
                   };
                    reader.readAsArrayBuffer(file);    
                    
                } catch (error) {
                    reject(error);
                }
            });
        }
    },

    //엑셀 업로드 - no Header
    handleUpload: function(component,file,event) {
        if(file) {
            return new Promise((resolve, reject) => {
                try {
                    const ext = file.name.split('.').pop().toLowerCase();
                    const validTypes = [
                    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // xlsx
                    'application/vnd.ms-excel', // xls or sometimes csv
                    'text/csv'
                    ];

                    if (!validTypes.includes(file.type) && !['xlsx', 'xls', 'csv'].includes(ext)) {
                        reject('엑셀 또는 CSV 파일만 업로드할 수 있습니다.');
                    }
                    // if(file.type !='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' && file.type !='application/vnd.ms-excel') {
                    //     reject('올바르지 않는 파일타입입니다.');
                    // }
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        var data = new Uint8Array(e.target.result);
                        var workbook = XLSX.read(data, { type: "array" });
                        // 첫 번째 시트 선택
                        var sheetName = workbook.SheetNames[0];
                        var sheet = workbook.Sheets[sheetName];
                        var sheetData = XLSX.utils.sheet_to_json(sheet, { header: 1 });
                        
                        sheetData = sheetData.map(item => {
                            return Object.fromEntries(
                                Object.entries(item).map(([key, value]) => {
                                    if (typeof value === "string") {
                                        return [key, value.toUpperCase().trim()]; // 문자열인 경우 대문자로 변환
                                    }
                                    return [key, value]; // 문자열이 아니면 그대로 유지
                                })
                            );
                        });    

                        component.set('v.uploadData', sheetData); // Row 데이터 설정
                        resolve();
                    }
                    reader.onerror = function(error) {
                        // 오류 메시지 확인 후, 보안 프로그램으로 인한 오류인지를 추정
                       if (error.target.error && error.target.error.message.includes("permission")) {
                            reject("보안 프로그램으로 인해 파일을 업로드할 수 없습니다.");
                       } else {
                            reject("파일 업로드 형태를 확인해주세요.");
                       }
                       //reject('보안프로그램으로 인해 파일을 읽을 수 없습니다.');
                   };
                    reader.readAsArrayBuffer(file);    
                } catch (error) {
                    reject(error); 
                }
            });
        } 
    },
    gfnGetCommunityCustomPageRef : function(pageName, state) {
        let pageRef = {
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            },
            state : state
        };
        return pageRef;
    },
    gfnGetStandardPagerRef : function(recordId, objectAPI, actionName) {
        let pageRef = {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": recordId,
                    "objectApiName": objectAPI,
                    "actionName": actionName
                }
        };
        return pageRef;
    },
    
    //입출고증
    handleGIGRDocumentExcel : function(component) {
        console.log('testet111');
        var excelData = component.get('v.excelGRData');
        var excelHeaderData = component.get('v.headerData');
        // let orderType = '_구매입고증';
        // let docType = '증';
        // if(excelData[0]['종류'] == '입고취소') {
        //     orderType = '입고취소_출고증';
        //     docType = '_출고증';
        // }
        var excelName       = component.get('v.excelName');
        if(excelData.length === 0) {
            //this.toast('Error', 'Excel data is empty.');
            return;
        }
        var workbook = new ExcelJS.Workbook();
        var worksheet = workbook.addWorksheet('Sheet1');
        
        // 1. Header Section
        worksheet.mergeCells('A1:B2');
        
        worksheet.getCell('A1').value = excelData[0]['종류'] + '증';
        worksheet.getCell('A1').font = { bold: true, size: 14 };

        worksheet.getCell('D1').value = '대리점명';
        worksheet.getCell('D1').font = { bold: true, size: 14 };
        worksheet.getCell('E1').value = '참고문서번호';
        worksheet.getCell('E1').font = { bold: true, size: 14 };
        worksheet.getCell('F1').value = '생성일자';
        worksheet.getCell('F1').font = { bold: true, size: 14 };
        worksheet.getCell('G1').value = '생성시각';
        worksheet.getCell('G1').font = { bold: true, size: 14 };
        worksheet.getRow(1).eachCell((cell) => {
            cell.font = { bold: true };
            cell.alignment = { horizontal: 'center' };
            cell.border = {
                top: { style: 'thin' },
                left: { style: 'thin' },
                bottom: { style: 'thin' },
                right: { style: 'thin' }
            };
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'F2F2F2' }
            };
        });
        //Headers 디자인
        const alignment = { horizontal: 'center' };
        const border = {
            top: { style: 'thin' },
            left: { style: 'thin' },
            bottom: { style: 'thin' },
            right: { style: 'thin' }
        };
        const fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'F2F2F2' }
        };
        // 헤더 데이터 설정 excelHeaderData
        worksheet.getCell('D2').value = excelHeaderData[0]['대리점명'];
        worksheet.getCell('D2').alignment = alignment;
        worksheet.getCell('D2').border = border;
        worksheet.getCell('D2').fill = fill;

        worksheet.getCell('E2').value = excelHeaderData[0]['참고문서번호'];
        worksheet.getCell('E2').alignment = alignment;
        worksheet.getCell('E2').border = border;
        worksheet.getCell('E2').fill = fill;
        
        worksheet.getCell('F2').value = excelHeaderData[0]['생성일자'];
        worksheet.getCell('F2').alignment = alignment;
        worksheet.getCell('F2').border = border;
        worksheet.getCell('F2').fill = fill;
        
        worksheet.getCell('G2').value = excelHeaderData[0]['생성시각'];
        worksheet.getCell('G2').alignment = alignment;
        worksheet.getCell('G2').border = border;
        worksheet.getCell('G2').fill = fill;

        //  입고 정보 데이터 시작
        let dataStart = 4;
       
        //입고 정보 헤더 디자인
        worksheet.getRow(dataStart).eachCell((cell) => {
            cell.font = { bold: true };
            cell.alignment = { horizontal: 'center' };
            cell.border = {
                top: { style: 'thin' },
                left: { style: 'thin' },
                bottom: { style: 'thin' },
                right: { style: 'thin' }
            };
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'F2F2F2' }
            };
        });
        dataStart = dataStart +1;
        let itemCol =excelData[0];
        const itemColumns = Object.keys(itemCol);
        worksheet.getRow(4).values = itemColumns;
        worksheet.getRow(4).eachCell((cell) => {
            cell.font = { bold: true };
            cell.alignment = { horizontal: 'center' };
            cell.border = {
                top: { style: 'thin' },
                left: { style: 'thin' },
                bottom: { style: 'thin' },
                right: { style: 'thin' }
            };
            cell.fill = {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: 'F2F2F2' }
            };
        });

        for(let i=0; i<excelData.length; i++) {
            let excelDataRow =excelData[i];
            let startRow = dataStart+i;
            let dataList = [];
            for(let j=0; j<itemColumns.length; j++) {
                dataList.push(excelDataRow[itemColumns[j]]);
            }
            worksheet.getRow(startRow).values = dataList; 
            worksheet.getRow(startRow).eachCell((cell) => {
                // cell.font = { bold: true };
                cell.alignment = { horizontal: 'center' };
                cell.border = {
                    top: { style: 'thin' },
                    left: { style: 'thin' },
                    bottom: { style: 'thin' },
                    right: { style: 'thin' }
                };
                // cell.fill = {
                //     type: 'pattern',
                //     pattern: 'solid',
                // };
            });
            console.log(JSON.stringify(dataList), ' < ===dataList');
        }
        // Adjust column widths
        worksheet.columns.forEach((column) => {
            let maxLength = 0;
            column.eachCell({ includeEmpty: true }, (cell) => {
                if (cell.value) {
                    maxLength = Math.max(maxLength, cell.value.toString().length);
                }
            });
            column.width = Math.max(maxLength + 2, 15);
        });

        // Export file
        workbook.xlsx.writeBuffer().then(function (buffer) {
            var blob = new Blob([buffer], { type: 'application/octet-stream' });
            var link = document.createElement('a');
            link.href = URL.createObjectURL(blob);
            link.download = excelName + '.xlsx';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        });
    },

    getUrlParameter : function(paramName) {
        let url = window.location.href;
        let params = new URL(url).searchParams;
        return params.get(paramName);
    },

    // 컨핌창 호출
    openConfirm: function(message, theme, variant) {
        return new Promise((resolve, reject) => {
            this.LightningConfirm.open({
                message: message,
                theme: theme,
                variant: variant
            })
            .then($A.getCallback(function(result) {
                resolve(result); // Promise를 resolve
            }))
            .catch($A.getCallback(function(error) {
                reject(error); // Promise를 reject
            }));
        });
    },

    gfnDiscountRateFromPrice : function(price, discountRate) {
        return parseFloat(price) * (1 - parseFloat(discountRate) / 100);
    },

    // dN_DealerPortalInputBox value 재설정
    setInputValue : function(component, partList, auraId) {
        let inputCmpAll  = component.find(`${auraId}`);
        partList.forEach( (element,index) => {
            if (Array.isArray(inputCmpAll)) {
                //this.istable
                console.log('여러 개의 요소가 있습니다:', inputCmpAll);
                inputCmpAll[index].handleCmpValue(element.MATNR);
            } else {
                console.log('단일 요소입니다:', inputCmpAll);
                inputCmpAll.handleCmpValue(element.MATNR);
            }    
        });
    },

    setNumberValue : function(value, component, index) {
        let inputCmpAll  = component.find(`inputCheck`);
        if (Array.isArray(inputCmpAll)) {
            console.log(inputCmpAll[index].checkValidity(),' list check');
            //this.istable
            if(inputCmpAll[index].checkValidity()) {
                
            }
            
        } else {
            console.log(inputCmpAll.checkValidity(), ' chekck');
            if(inputCmpAll.checkValidity()) {
                
            }
            
        } 
        
        
    }

})