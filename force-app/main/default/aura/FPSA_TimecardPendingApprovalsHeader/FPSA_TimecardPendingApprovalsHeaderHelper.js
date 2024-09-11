({
    fireFilterApprovalRequestsEvent : function(component, projectValue) {
        let filterApprovalRequestsEvent = component.getEvent("filterApprovalRequests");

        filterApprovalRequestsEvent.setParams({
            "projectValue" : projectValue
        });

        filterApprovalRequestsEvent.fire();
    },

    fireProcessMultipleApprovalRequestsEvent : function(component, approvalAction) {
        let processMultipleApprovalRequestsEvent = component.getEvent("processMultipleApprovalRequests");

        processMultipleApprovalRequestsEvent.setParams({
            "approvalAction" : approvalAction
        });

        processMultipleApprovalRequestsEvent.fire();
    }
})