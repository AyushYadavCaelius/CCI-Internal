({
    setupApprovalRequestColumns : function(component, columnLabels) {
        let approvalRequestColumns = [];
        
        for(let colIndex=0; colIndex < columnLabels.length; colIndex++) {
            let columnStyleClass = "col-" + (colIndex + 2) + "-style";
            approvalRequestColumns.push({"columnLabel" : columnLabels[colIndex], "columnStyleClass" : columnStyleClass});
        }

        component.set("v.approvalRequestColumns", approvalRequestColumns);
    },

    fireToggleAllApprovalRequestSelectionEvent : function(component, isSelected) {
        let toggleAllApprovalRequestSelectionEvent = component.getEvent("toggleAllApprovalRequestSelection");

        toggleAllApprovalRequestSelectionEvent.setParams({
            "isSelected" : isSelected
        });

        toggleAllApprovalRequestSelectionEvent.fire();
    }
})