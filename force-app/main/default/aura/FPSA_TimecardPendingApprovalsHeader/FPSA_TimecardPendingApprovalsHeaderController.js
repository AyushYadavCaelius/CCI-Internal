({
    handleProjectSelectionFilter : function(component, event, helper) {
        let params = event.getParam("arguments");

        if(params) {
            component.set("v.selectedProject", params.selectedProject);
            component.set("v.approvalRequestsCount", params.approvalRequestsCount);
        }
    },

    handleProjectListSetup : function(component, event, helper) {
        let params = event.getParam("arguments");
        
        if(params) {
            component.set("v.projectList", params.projectList);
        }
    },

    onChangeProject : function(component, event, helper) {
        let projectValue = component.find("projectList").get("v.value");
        helper.fireFilterApprovalRequestsEvent(component, projectValue);
    },

    handleRejection : function(component, event, helper) {
        const REJECT_ACTION = $A.get("$Label.c.FPSA_Approval_Action_Reject");
        helper.fireProcessMultipleApprovalRequestsEvent(component, REJECT_ACTION);
    },

    handleApproval : function(component, event, helper) {
        const APPROVE_ACTION = $A.get("$Label.c.FPSA_Approval_Action_Approve");
        helper.fireProcessMultipleApprovalRequestsEvent(component, APPROVE_ACTION);
    }
})