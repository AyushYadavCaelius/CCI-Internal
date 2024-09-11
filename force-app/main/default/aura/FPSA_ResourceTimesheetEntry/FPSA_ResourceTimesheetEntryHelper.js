({
    getTimeEntriesAction: function(component, weekDate) {
        component.set("v.showSpinner", true);
        var action = component.get("c.getResourceTimeEntry");
        action.setParams({
            resourceId: component.get("v.resourceId"),
            weekStartString: weekDate
        });
        action.setCallback(this, function(response) {
            component.set("v.showSpinner", false);
            var timeEntries = response.getReturnValue() || [];
            console.log('timeEntries from apex==', timeEntries);
            var dayWiseTotal = [];
            component.get("v.daysForTotal").forEach(function(day) {
                var totalHrs = timeEntries.reduce(function(total, current) {
                    return total + (current["FPSA_" + day + "_Hours__c"] || 0);
                }, 0);
                dayWiseTotal.push(totalHrs);
            });
            component.set("v.dayWiseTotalHr", dayWiseTotal);
            var timeTotal = dayWiseTotal.reduce(
                (accumulator, currentValue) => accumulator + currentValue
            );
            component.set("v.grandTotal", timeTotal);
            var allocationsTotal = 0;
            var grandProjectRecords = component.get("v.projectList");
            for (var i = 0; i < timeEntries.length; i++) {
                timeEntries[i].FPSA_Project__r = grandProjectRecords.find( ({ Id }) => Id === timeEntries[i].FPSA_Project__c);
                if (timeEntries[i].FPSA_Project_Planned_hrs__c) {
                    allocationsTotal =
                        allocationsTotal +
                        timeEntries[i].FPSA_Project_Planned_hrs__c;
                }
                                                                       
            }
                                                              
            component.set("v.timeEntry", timeEntries);
            component.set("v.totalAllocations", allocationsTotal);
        });
        return action;
    }
});