({
    initApprovalRequestColumns : function(component, event, helper) {
        let columnLabels = ["Timecard Name", "Project", "Milestone", "Resource", "Week Start Date", "Planned Hours", "Total Hours", "Total Billable Amount", "Weekly Notes"];
        helper.setupApprovalRequestColumns(component, columnLabels);
    },

    onToggleSelectAll : function(component, event, helper) {
        let isSelected = event.getParam("value");
        helper.fireToggleAllApprovalRequestSelectionEvent(component, isSelected);
    },

    handleClearSelection : function(component, event, helper) {
        component.set("v.selectAll", true);     // to select all before clearing all
        component.set("v.selectAll", false);    // to clear all selection
    }
})