({
    onInit : function(component, event, helper) {
        let navigationService = component.find("navigationService");
        helper.setupProjectURL(component, navigationService);
        helper.setupResourceURL(component, navigationService);
        helper.setupTimecardURL(component, navigationService);
        helper.setupMilestoneURL(component, navigationService);
    },

    onSelectApprovalAction : function(component, event, helper) {
        let approvalAction = event.getParam("value");
        let approvalRequest = component.get("v.approvalRequest");
        helper.processApprovalAction(component, approvalAction, approvalRequest);
    }
})