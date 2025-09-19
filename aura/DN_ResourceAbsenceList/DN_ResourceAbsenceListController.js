/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-14-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   11-29-2024   youjin.shim@sbtglobal.com   Initial Version
**/
({
	doInit : function(component, event, helper) {
		helper.apexCall(component, event, helper, 'getLoginUserInfo', {
		})
		.then($A.getCallback(function(result) {
			let r = result.r;
			component.set('v.WorkCInfo', r.workerInfo);

			if(r.isBranch) {
				component.set('v.isBranch', r.isBranch);
				component.set('v.typeList', [
					{'label' : '전체','value' : 'None'},
					{'label' : '휴가', 'value' : 'Leave'},
					{'label' : '영업/기술', 'value' : 'Sales/Technical'},
					{'label' : '교육/회의', 'value' : 'Training/Meeting'},
				])
			} else {
				component.set('v.typeList', [
					{'label' : '전체','value' : 'None'},
					{'label' : '휴가', 'value' : 'Leave'},
					{'label' : '교육/회의', 'value' : 'Sales/Technical'},
					{'label' : '자체유상', 'value' : 'Own payment'},
				])
			}
		}))
		.catch(function(error) {
			console.log('# search Error : ' + error.message);
		});
		
	},

	 // 츌동인원관리(부재) 생성
	handleResourceAbsenceAdd: function (component, event, helper) {
        $A.createComponent("c:DN_ResourceAbsenceCreate",
            {
                "isBranch": component.get('v.isBranch')
            },
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    var container = component.find("ResourceAbsenceCreate");	
                    container.set("v.body", content);
					
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

	// Type이 None일 경우 초기화
	handleType : function(component,event,helper) {
		let eve = event.getSource();
		if(eve.get("v.value") == 'None') {
			component.set("v.searchType", '');
		}
	},
    
    handleScroll: function (component, event, helper) {
        var table2 = event.target;
        var scrollY = table2.scrollTop;
        let now = Date.now();
        let lastCall = component.get("v._lastScrollCall") || 0;

        // 300ms마다만 실행되게 throttle
        if (now - lastCall < 300) {
            return;
        }

        component.set("v._lastScrollCall", now);
        setTimeout(() => {
            console.log(table2.scrollTop + table2.clientHeight);
            console.log(table2.scrollHeight);
            if( (table2.scrollTop + table2.clientHeight) >= table2.scrollHeight-10) {
            	console.log('test111');
            	component.set('v.isLoading', true);
            	helper.handleSearch(component,event,helper,'scroll');
            	
        	}    
        }, 300); // 300ms 정도 지연
    },
	// scroll
	// handleScroll: function (component, event, helper) {
	// 	var table2 = event.target;
	// 	let now = Date.now();
  //   let lastCall = component.get("v._lastScrollCall") || 0;



	// 			console.log("lastCall", lastCall);

  //       // 300ms마다만 실행되게 throttle
  //       if (now - lastCall < 300) {
  //           return;
  //       }

  //       component.set("v._lastScrollCall", now);
	// 			console.log("table2", table2.clientHeight);
	// 			console.log("table2", table2.scrollHeight);

  //       if (table2.scrollTop + table2.clientHeight >= table2.scrollHeight - 20) {
	// 				console.log("111");
  //           helper.loadMoreItems(component);
  //       }
	// },



	// 검색
	handleSearch : function(component,event,helper) {
		component.set('v.isLoading', true);
		helper.handleSearch(component,event,helper);
	},

	// 삭제
	handleDelete : function(component,event,helper) {
		helper.apexCall(component, event, helper, 'resourceAbsenceDelete', {
			selected : component.get("v.selected")
		})
		.then($A.getCallback(function(result) {
			let r = result.r;
			component.set("v.selected", []);
			$A.enqueueAction(component.get('c.handleSearch'));

		}))
		.catch(function(error) {
			console.log('# search Error : ' + error.message);
		});
	},
	
	// handleCheckAll
	handleCheckAll : function(component,event,helper) {
		let eve = event.getSource();
		let checkAll = component.find("checkbox");
		let seleted = [];
		if(eve.get("v.checked")) {
			checkAll.forEach(element => {
				console.log(element,' > ==element');
				element.set("v.checked", true); 
				seleted.push(element.get("v.id")); 
			});
			component.set("v.selected",seleted);
			console.log(JSON.stringify(seleted),' < ===seleted');
		} else {
			checkAll.forEach(element => {
				console.log(element,' > ==element');
				element.set("v.checked", false); 
				seleted = [];
			});
			component.set("v.selected",seleted);

		}
		
	},
	// handleCheckRow
	handleCheckRow : function(component,event,helper) {
		let eve = event.getSource();
		let seleted = component.get("v.selected");
		console.log(eve.get("v.checked"), 'value11');
		console.log(eve.get("v.id"), ' < ==test');
		if(eve.get("v.checked")) {
			seleted.push(eve.get("v.id"));
		} else {
			let indx = seleted.indexOf(eve.get("v.id"));
			seleted.splice(indx, 1);
			
		}
		console.log(seleted,' < ==seleted');
	},
	// 검색어 입력 정보
	handleChangeValue : function(component,event,helper) {
		let eve = event.getSource();
		if(eve.getLocalId() =='Resource') {
			component.set("v.searchResource", eve.get("v.value"));
		} else {
			component.set("v.searchDate", eve.get("v.value"));
		}
	},
	// 상세조회
	handleDetail: function (component, event, helper) {
		console.log('click');
		let eve = event.currentTarget.getAttribute("data-id");
		let type = event.currentTarget.getAttribute("data-type");
		component.set("v.isLoading", true);
		$A.createComponent(
			"c:DN_ResourceAbsenceEdit",
			{
				"recordId": eve,
				"isBranch": component.get("v.isBranch"),
				"typeValue": type
			},
			function (content, status, errorMessage) {
				if (status === "SUCCESS") {
					var container = component.find("ResourceAbsenceEdit");
					$A.getCallback(function () {
						container.set("v.body", content);	
					})();
				} else if (status === "INCOMPLETE") {
					console.log("No response from server or client is offline.");
				} else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
				// 성공 여부와 상관없이 로딩 상태 해제
				component.set("v.isLoading", false);
			}
		);
	},

	// 이벤트 수신
    handleCompEvent: function (component, event, helper) {
        var modalName = event.getParam("modalName");
		var message = event.getParam("message");
        console.log('modalName::', modalName);
		console.log('message::', message);
		//$A.get('e.force:refreshView').fire();
		component.set('v.isLoading', true);
		//$A.get('e.force:refreshView').fire();
		$A.enqueueAction(component.get('c.handleSearch'));
		// setTimeout(() => {
        //     // Step 3: Enqueue the handleSearch action after refresh
        //     $A.enqueueAction(component.get('c.handleSearch'));
        // }, 1000); // Adjust the timeout duration if needed
		
	}
})