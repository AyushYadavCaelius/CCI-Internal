({
    getPendingTimecardApprovalRequests : function(component, allProjects, selectedProject) {
        let _this = this;
        let action = component.get("c.getPendingTimecardApprovalRequests");
        
        action.setCallback(this, function(response) {
            component.set("v.displaySpinner", false);
            let state = response.getState();
            
            if(state == "SUCCESS") {
                let timecardLines = response.getReturnValue();
                _this.setupApprovalRequests(component, timecardLines, allProjects, selectedProject);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    setupApprovalRequests : function(component, timecardLines, allProjects, selectedProject) {
        let _this = this;
        
        if(timecardLines) {
            _this.initApprovalRequests(component, timecardLines, selectedProject);
            _this.setupProjectList(component, allProjects, selectedProject);
            _this.clearAllApprovalRequestsSelection(component);
        }
    },
    
    initApprovalRequests : function(component, timecardLines, selectedProject) {
        let _this = this;
        
        _this.getAllApprovalRequests(timecardLines, selectedProject, function(allApprovalRequests, filteredApprovalRequests) {
            component.set("v.allApprovalRequests", allApprovalRequests);
            _this.setupFilteredApprovalRequests(component, filteredApprovalRequests);
            _this.filterProjectSelection(component, selectedProject, filteredApprovalRequests.length);
        });
    },
    
    getAllApprovalRequests : function(timecardLines, selectedProject, approvalRequestsCallback) {
        const IS_SELECTED = false;
        
        let _this = this;
        let allApprovalRequests = [];
        
        timecardLines.forEach(timecardLine => {
            /*let approvalRequest = {"isSelected" : IS_SELECTED, "timecardId" : timecardLine.Id, "timecardName" : timecardLine.Name, 
                                   "projectId" : timecardLine.FPSA_Project__c, "projectName" : timecardLine.FPSA_Project__r.Name,
                                   "resourceId" : timecardLine.FPSA_Resource__c, "resourceName" : timecardLine.FPSA_Resource__r.Name, 
                                   "milestoneId" : timecardLine.FPSA_Milestone__c, "milestoneName" : timecardLine.FPSA_Milestone__r.Name, 
                                   "plannedHours" : timecardLine.FPSA_Project_Planned_hrs__c, "totalHours" : timecardLine.FPSA_Total_Hours__c, 
                                   "weekStartDate" : timecardLine.FPSA_Week_Start_Date__c, "totalBillableAmount" : timecardLine.FPSA_Total_Billable_Amount__c, 
                                   "weeklyNotes" : timecardLine.FPSA_Weekly_Notes__c};
                                   */
            
            let approvalRequest = {}  ;
            approvalRequest.isSelected = IS_SELECTED;
            approvalRequest.timecardId = timecardLine.Id;
            approvalRequest.timecardName = timecardLine.Name;
            
            if(timecardLine.FPSA_Project__c != undefined){
                approvalRequest.projectId = timecardLine.FPSA_Project__c;
                approvalRequest.projectName = timecardLine.FPSA_Project__r.Name;
      		}
        	else{
                approvalRequest.projectId = '';
                approvalRequest.projectName = '';
            }
                              
           if(timecardLine.FPSA_Resource__c != undefined){
                approvalRequest.resourceId = timecardLine.FPSA_Resource__c;
                approvalRequest.resourceName = timecardLine.FPSA_Resource__r.Name;
            }
            else{
                approvalRequest.resourceId = '';
                approvalRequest.resourceName = '';
            }
            
            if(timecardLine.FPSA_Milestone__c != undefined){
                approvalRequest.milestoneId = timecardLine.FPSA_Milestone__c;
                approvalRequest.milestoneName = timecardLine.FPSA_Milestone__r.Name;
            }
            else{
                approvalRequest.milestoneId = '';
                approvalRequest.milestoneName = '';
            }
            
            approvalRequest.plannedHours = timecardLine.FPSA_Project_Planned_hrs__c;
            approvalRequest.totalHours = timecardLine.FPSA_Total_Hours__c;
            approvalRequest.weekStartDate = timecardLine.FPSA_Week_Start_Date__c;
            approvalRequest.totalBillableAmount = timecardLine.FPSA_Total_Billable_Amount__c;
            approvalRequest.weeklyNotes = timecardLine.FPSA_Weekly_Notes__c;
            allApprovalRequests.push(approvalRequest);
        });
    
        _this.getFilteredApprovalRequests(allApprovalRequests, selectedProject, function(filteredApprovalRequests) {
        approvalRequestsCallback(allApprovalRequests, filteredApprovalRequests);
        });
	},
    
    getFilteredApprovalRequests : function(allApprovalRequests, selectedProject, filteredApprovalRequestsCallback) {
        const SIZE_ZERO = 0;
        
        let _this = this;
        
        let filteredApprovalRequests = allApprovalRequests.filter(approvalRequest => {
            return approvalRequest.projectId == selectedProject;
        });
        
        filteredApprovalRequests = (filteredApprovalRequests.length == SIZE_ZERO) ? allApprovalRequests : filteredApprovalRequests;
        
        _this.sortApprovalRequestsByProjectName(filteredApprovalRequests);
        filteredApprovalRequestsCallback(filteredApprovalRequests);
    },
        
        sortApprovalRequestsByProjectName : function(approvalRequests) {
            const SORT_LEFT = -1;
            const SORT_RIGHT = 1;
            const SORT_EQUAL = 0;
            
            approvalRequests.sort(function(reqA, reqB) {
                let reqNameA = reqA.projectName.toLowerCase();
                let reqNameB = reqB.projectName.toLowerCase();
                return (reqNameA < reqNameB) ? SORT_LEFT : (reqNameA > reqNameB) ? SORT_RIGHT : SORT_EQUAL;
            });
        },
            
            setupFilteredApprovalRequests : function(component, filteredApprovalRequests) {
                let approvalRequests = component.find("approvalRequests");
                approvalRequests.setupFilteredApprovalRequests(filteredApprovalRequests);
            },
                
                filterProjectSelection : function(component, selectedProject, approvalRequestsCount) {
                    let approvalsHeader = component.find("approvalsHeader");
                    approvalsHeader.filterProjectSelection(selectedProject, approvalRequestsCount);
                },
                    
                    setupProjectList : function(component, allProjects, selectedProject) {
                        let _this = this;
                        let projectMap = {};
                        let hasSelectedProject = false;
                        let allApprovalRequests = component.get("v.allApprovalRequests");
                        
                        allApprovalRequests.forEach(approvalRequest => {
                            projectMap[approvalRequest.projectId] = approvalRequest.projectName;
                            hasSelectedProject = (approvalRequest.projectId == selectedProject) ? true : hasSelectedProject;
                        });
                        
                        let projectList = [];
                        let allProjectsElement = {"projectName" : allProjects, "projectValue" : allProjects, "isSelected" : !hasSelectedProject};
                        
                        for(let projectKey in projectMap) {
                            let isSelectedProject = (projectKey == selectedProject);
                            projectList.push({"projectName" : projectMap[projectKey], "projectValue" : projectKey, "isSelected" : isSelectedProject});
                        }
                        
                        _this.sortProjectListByProjectName(projectList);
                        projectList.splice(0, 0, allProjectsElement);
                        
                        let approvalsHeader = component.find("approvalsHeader");
                        approvalsHeader.setupProjectList(projectList);
                    },
                        
                        sortProjectListByProjectName : function(projectList) {
                            const SORT_LEFT = -1;
                            const SORT_RIGHT = 1;
                            const SORT_EQUAL = 0;
                            
                            projectList.sort(function(projA, projB) {
                                let projNameA = projA.projectName.toLowerCase();
                                let projNameB = projB.projectName.toLowerCase();
                                return (projNameA < projNameB) ? SORT_LEFT : (projNameA > projNameB) ? SORT_RIGHT : SORT_EQUAL;
                            });
                        },
                            
                            clearAllApprovalRequestsSelection : function(component) {
                                let approvalsColumns = component.find("approvalsColumns");
                                approvalsColumns.clearSelection();
                            },
                                
                                toggleAllApprovalRequestSelection : function(component, isSelected, filteredApprovalRequests) {
                                    let _this = this;
                                    
                                    filteredApprovalRequests.forEach(approvalRequest => {
                                        approvalRequest.isSelected = isSelected;
                                    });
                                        
                                        _this.setupFilteredApprovalRequests(component, filteredApprovalRequests);
                                    },
                                        
                                        processApprovalRequest : function(component, timecardId, allProjects, approvalAction, selectedProject) {
                                            let timecardIds = [timecardId];
                                            this.processTimecardApprovalRequests(component, timecardIds, allProjects, approvalAction, selectedProject);
                                        },
                                        
                                        processTimecardApprovalRequests : function(component, timecardIds, allProjects, approvalAction, selectedProject) {
                                            let _this = this;
                                            let action = component.get("c.processTimecardApprovalRequests");
                                            
                                            action.setParams({
                                                "timecardIds" : timecardIds,
                                                "approvalAction" : approvalAction
                                            });
                                            
                                            action.setCallback(this, function(response) {
                                                component.set("v.displaySpinner", false);
                                                let state = response.getState();
                                                
                                                if(state == "SUCCESS") {
                                                    let approvalResultWrapper = response.getReturnValue();
                                                    let timecardLines = approvalResultWrapper.submittedTimecardLines;
                                                    let isRequestProcessed = approvalResultWrapper.isRequestProcessed;
                                                    
                                                    _this.showRequestProcessedToast(approvalAction, isRequestProcessed);
                                                    _this.setupApprovalRequests(component, timecardLines, allProjects, selectedProject);
                                                }
                                            });
                                            
                                            component.set("v.displaySpinner", true);
                                            $A.enqueueAction(action);
                                        },
                                        
                                        showRequestProcessedToast : function(approvalAction, isRequestProcessed) {
                                            const REJECT_ACTION = $A.get("$Label.c.FPSA_Approval_Action_Reject");
                                            
                                            let _this = this;
                                            let timecardRequestsStr = "Timecard requests";
                                            let approvalActionStr = (approvalAction == REJECT_ACTION) ? "rejected" : "approved";
                                            let successToastMessage = timecardRequestsStr + " " + approvalActionStr + " successfully!";
                                            let errorToastMessage = "Something went wrong! Could not process all " + timecardRequestsStr;
                                            
                                            let toastType = isRequestProcessed ? "success" : "error";
                                            let toastMessage = isRequestProcessed ? successToastMessage : errorToastMessage;
                                            
                                            _this.fireToastEvent(toastType, toastMessage);
                                        },
                                        
                                        fireToastEvent : function(toastType, toastMessage) {
                                            let toastEvent = $A.get("e.force:showToast");
                                            
                                            toastEvent.setParams({
                                                "message": toastMessage,
                                                "type": toastType,
                                                "duration": 5000
                                            });
                                            
                                            toastEvent.fire();
                                        },
                                        
                                        processMultipleApprovalRequests : function(component, allProjects, approvalAction, selectedProject, filteredApprovalRequests) {
                                            const SIZE_ZERO = 0;
                                            
                                            let _this = this;
                                            let timecardIds = [];
                                            
                                            filteredApprovalRequests.forEach(approvalRequest => {
                                                if(approvalRequest.isSelected) {
                                                timecardIds.push(approvalRequest.timecardId);
                                            }
                                                                             });
                                            
                                            if(timecardIds.length > SIZE_ZERO) {
                                                _this.processTimecardApprovalRequests(component, timecardIds, allProjects, approvalAction, selectedProject);
                                            }else {
                                                let toastMessage = "No rows selected to " + approvalAction + " Timecard requests!";
                                                _this.fireToastEvent("warning", toastMessage);
                                            }
                                        }
                                    })