({
    fetchFilteredOpportunities: function (component, keyword) {
        const action = component.get("c.searchOpportunities");
        action.setParams({ 
            upperId : component.get('v.lookupValue'),
            searchKeyword: keyword 
        });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const opportunities = response.getReturnValue();
                console.log('opportunities',opportunities);
                const options = opportunities.map(opp => {
                    return { label: opp.Name, value: opp.Id };
                });

                component.set("v.opportunityOptions", options);
                component.set("v.isDropdownOpen", options.length > 0);
                console.log('isDropdownOpen',component.get('v.isDropdownOpen'));
            } else {
                console.error("Error fetching opportunities: ", response.getError());
            }
        });

        $A.enqueueAction(action);
    }
});