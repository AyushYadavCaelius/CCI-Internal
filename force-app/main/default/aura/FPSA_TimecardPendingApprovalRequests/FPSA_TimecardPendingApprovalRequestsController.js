({
    handleApprovalRequestsSetup : function(component, event, helper) {
        let params = event.getParam("arguments");
        
        if(params) {
            component.set("v.approvalRequests", params.filteredApprovalRequests);
        }
    },

    handleGetApprovalRequests : function(component, event, helper) {
        let approvalRequests = component.get("v.approvalRequests");
        return approvalRequests;
    }
})