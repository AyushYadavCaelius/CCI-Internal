({
    setupProjectURL : function(component, navigationService) {
        let sObjAPIName = "MPM4_BASE__Milestone1_Project__c";
        let projectId = component.get("v.approvalRequest").projectId;

        this.getPageReference(sObjAPIName, projectId, function(recordPageRef) {
            navigationService.generateUrl(recordPageRef).then($A.getCallback(function(projectURL) {
                component.set("v.projectURL", projectURL);
            }), $A.getCallback(function(error) {
                component.set("v.projectURL", "#");
            }));
        });
    },

    setupResourceURL : function(component, navigationService) {
        let sObjAPIName = "MPM4_BASE__Milestone1_Resource__c";
        let resourceId = component.get("v.approvalRequest").resourceId;

        this.getPageReference(sObjAPIName, resourceId, function(recordPageRef) {
            navigationService.generateUrl(recordPageRef).then($A.getCallback(function(resourceURL) {
                component.set("v.resourceURL", resourceURL);
            }), $A.getCallback(function(error) {
                component.set("v.resourceURL", "#");
            }));
        });
    },

    setupTimecardURL : function(component, navigationService) {
        let sObjAPIName = "FPSA_Resource_TimeLines__c";
        let timecardId = component.get("v.approvalRequest").timecardId;

        this.getPageReference(sObjAPIName, timecardId, function(recordPageRef) {
            navigationService.generateUrl(recordPageRef).then($A.getCallback(function(timecardURL) {
                component.set("v.timecardURL", timecardURL);
            }), $A.getCallback(function(error) {
                component.set("v.timecardURL", "#");
            }));
        });
    },

    setupMilestoneURL : function(component, navigationService) {
        let sObjAPIName = "MPM4_BASE__Milestone1_Milestone__c";
        let milestoneId = component.get("v.approvalRequest").milestoneId;

        this.getPageReference(sObjAPIName, milestoneId, function(recordPageRef) {
            navigationService.generateUrl(recordPageRef).then($A.getCallback(function(milestoneURL) {
                component.set("v.milestoneURL", milestoneURL);
            }), $A.getCallback(function(error) {
                component.set("v.milestoneURL", "#");
            }));
        });
    },

    getPageReference : function(sObjAPIName, recordId, pageRefCallback) {
        let recordPageRef = {};
        recordPageRef["type"] = "standard__recordPage";
        recordPageRef["attributes"] = {"recordId" : recordId, "objectApiName" : sObjAPIName, "actionName" : "view"};
        pageRefCallback(recordPageRef);
    },

    navigateToRecordPage : function(component, sObjAPIName, recordId) {
        let navigationService = component.find("navigationService");
        let recordPageRef = {};
        recordPageRef["type"] = "standard__recordPage";
        recordPageRef["attributes"] = {"recordId" : recordId, "objectApiName" : sObjAPIName, "actionName" : "view"};
        navigationService.navigate(recordPageRef);
    },

    processApprovalAction : function(component, approvalAction, approvalRequest) {
        let timecardId = approvalRequest.timecardId;
        this.fireprocessApprovalRequest(component, timecardId, approvalAction);
    },

    fireprocessApprovalRequest : function(component, timecardId, approvalAction) {
        let processApprovalRequestEvent = component.getEvent("processApprovalRequest");

        processApprovalRequestEvent.setParams({
            "timecardId" : timecardId,
            "approvalAction" : approvalAction
        });

        processApprovalRequestEvent.fire();
    }
})