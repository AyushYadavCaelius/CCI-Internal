({
    onInit : function(component, event, helper) {
        let allProjects = component.get("v.allProjectsStr");
        let selectedProject = component.get("v.selectedProject");
        helper.getPendingTimecardApprovalRequests(component, allProjects, selectedProject);
    },

    handleFilterApprovalRequestsEvent : function(component, event, helper) {
        let projectValue = event.getParam("projectValue");
        let selectedProject = component.get("v.selectedProject");

        if(projectValue != selectedProject) {
            let allApprovalRequests = component.get("v.allApprovalRequests");

            helper.clearAllApprovalRequestsSelection(component);

            helper.getFilteredApprovalRequests(allApprovalRequests, projectValue, function(filteredApprovalRequests) {
                component.set("v.selectedProject", projectValue);
                helper.setupFilteredApprovalRequests(component, filteredApprovalRequests);
                helper.filterProjectSelection(component, projectValue, filteredApprovalRequests.length);
            });
        }
    },

    handleToggleAllApprovalRequestSelectionEvent : function(component, event, helper) {
        let isSelected = event.getParam("isSelected");
        let approvalRequests = component.find("approvalRequests");
        let filteredApprovalRequests = approvalRequests.getApprovalRequests();
        helper.toggleAllApprovalRequestSelection(component, isSelected, filteredApprovalRequests);
    },

    handleProcessApprovalRequestEvent : function(component, event, helper) {
        let timecardId = event.getParam("timecardId");
        let allProjects = component.get("v.allProjectsStr");
        let approvalAction = event.getParam("approvalAction");
        let selectedProject = component.get("v.selectedProject");
        helper.processApprovalRequest(component, timecardId, allProjects, approvalAction, selectedProject);
    },

    handleProcessMultipleApprovalRequestsEvent : function(component, event, helper) {
        let allProjects = component.get("v.allProjectsStr");
        let approvalAction = event.getParam("approvalAction");
        let selectedProject = component.get("v.selectedProject");
        let approvalRequests = component.find("approvalRequests");
        let filteredApprovalRequests = approvalRequests.getApprovalRequests();
        helper.processMultipleApprovalRequests(component, allProjects, approvalAction, selectedProject, filteredApprovalRequests);
    }
})