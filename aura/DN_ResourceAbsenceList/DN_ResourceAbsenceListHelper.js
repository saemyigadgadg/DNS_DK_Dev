/**
 * @description       : 
 * @author            : youjin.shim@sbtglobal.com
 * @group             : 
 * @last modified on  : 04-14-2025
 * @last modified by  : youjin.shim@sbtglobal.com
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   04-14-2025   youjin.shim@sbtglobal.com   Initial Version
**/
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
                    }
                });
                $A.enqueueAction(action);
            }
        }));
    },

    handleSearch : function(component,event,helper, type) {
        console.log(type, ' ::: type')
		let self = this;
        component.set('v.isLoading', true);
		let resourceAbsenceList = component.get('v.resourceAbsenceList');
		let pageInfo = component.get('v.pageInfo');
		if (!pageInfo || typeof pageInfo.currentPage !== 'number') {
			pageInfo = {
					currentPage: 1,
					startIdx: 0,
					endIdx: 20,
					nextPage: 2,
					totalRecordSize: 0
			};
			component.set('v.pageInfo', pageInfo); 
		}	
		if(type == undefined) {
			pageInfo.nextPage = 1;
		} else {
			pageInfo.nextPage = pageInfo.currentPage + 1;
		}
	
		self.apexCall(component, event, this, 'getList', {
			resource : component.get("v.searchResource"),
			type : component.get("v.searchType"),
			searchDate : component.get("v.searchDate"),
			pageInfo
		})
		.then($A.getCallback(function(result) {
			let r = result.r;
			component.set('v.isLoading', false);
            console.log(r.returnList,' :: r.returnList');
			if(r.returnList.length > 0 ) {
            	let resourceList = component.get("v.resourceAbsenceList");
            	resourceList = resourceList.concat(r.returnList);
            	console.log(resourceList.length);
                component.set("v.resourceAbsenceList", resourceList);
            	if(type != 'scroll') {
                	component.set("v.resourceAbsenceList", r.returnList);
                }
          		component.set('v.pageInfo', r.pageInfo);
           	}
		}))
		.catch(function(error) {
			console.log('# search Error : ' + error.message);
			component.set('v.isLoading', false);
		});
	},
    
    // loadMoreItems: function (component, event, helper) {
    //     component.set('v.isLoading', true);
    //     console.log("11");
    //     let pageInfo = {
    //         currentPage: 1,
    //         startIdx: 0,
    //         endIdx: 100,
    //         nextPage: 2,
    //         totalRecordSize: 0
    //     };
    //     component.set('v.pageInfo', pageInfo);
    //     console.log("pageInfo", pageInfo);

    //     helper.apexCall(component, event, helper, 'getList', {
    //         resource: component.get("v.searchResource"),
    //         type: component.get("v.searchType"),
    //         searchDate: component.get("v.searchDate"),
    //         pageInfo: pageInfo
    //     })
    //     .then($A.getCallback(function(result) {
    //         let r = result.r;
    //         console.log("result", JSON.stringify(r, null, 2));
    //         component.set('v.isLoading', false);
    //         component.set('v.resourceAbsenceList', r.returnList);
    //         component.set('v.pageInfo', r.pageInfo);
    //     }))
    //     .catch(function(error) {
    //         console.log('# search Error : ' + error.message);
    //     })
    //     .finally(function() {
    //         component.set('v.isLoading', false);
    //     });
    // }


})