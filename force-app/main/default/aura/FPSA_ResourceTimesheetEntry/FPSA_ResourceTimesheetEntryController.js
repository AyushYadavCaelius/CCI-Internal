({
	doInit: function(component, event, helper) {
        	console.log("====================In doinit===========");
			component.set("v.showSpinner", true);
			var curr = new Date();
			var first = curr.getDate() - curr.getDay();
			curr.setDate(first);
			var weekDateTemp = $A.localizationService.formatDate(curr, "YYYY-MM-DD");
			component.set("v.weekStart", weekDateTemp);
			curr.setDate(first + 6);
			component.set("v.weekEnd", curr);
			var resourceIdfromURL = component.get("v.recordId");
			if (resourceIdfromURL == null) {
					resourceIdfromURL = $A.get("$SObjectType.CurrentUser.Id");
			}
			var action = component.get("c.getResourceName");
			action.setParams({
					resourceId: resourceIdfromURL,
					weekStartString: component.get("v.weekStart")
			});
			action.setCallback(this, function(response) {
					var state = response.getState();
					if (state === "SUCCESS") {
							let returnedResonse = response.getReturnValue();
							component.set("v.resourceName", returnedResonse.resourceName);
							component.set("v.projectList", returnedResonse.projRec);
							/* var rolesPickList = returnedResonse.roleValues;
							var rolesMap = [];
							for(var key in rolesPickList){
								rolesMap.push({key : key, value: rolesPickList[key]})
							}
							component.set("v.roleList", rolesMap);
							console.log('Roles map are '+JSON.stringify(rolesMap)); */
							component.set("v.resourceId", returnedResonse.resourceId);
							component.set("v.projWithRole", returnedResonse.projIdWithRoleValue);
							component.set("v.relaxMinHoursCap", returnedResonse.relaxMinHoursCap);
							//component.set("v.isChecked",returnedResonse.isChecked);
                        	//component.set("v.disableTimeEntry",returnedResonse.isChecked);
							// component.set( "v.projWithMilestone",returnedResonse.projIdWithMilestoneValue);

							var dayWiseTotal = [];
							component.get("v.daysForTotal").forEach(function(day) {
									var totalHrs = returnedResonse.timeEntries.reduce(function(
													total,
													current
											) {
													return total + (current["FPSA_" + day + "_Hours__c"] || 0);
											},
											0);
									dayWiseTotal.push(totalHrs);
							});
							component.set("v.dayWiseTotalHr", dayWiseTotal);
							var timeTotal = dayWiseTotal.reduce(
									(accumulator, currentValue) => accumulator + currentValue
							);

							component.set("v.grandTotal", timeTotal);
							var allocationsTotal = 0;
							for (var i = 0; i < returnedResonse.timeEntries.length; i++) {
									returnedResonse.timeEntries[
											i
									].FPSA_Project__r = returnedResonse.projRec.find(
											({
													Id
											}) => Id === returnedResonse.timeEntries[i].FPSA_Project__c
									);
									if (returnedResonse.timeEntries[i].FPSA_Project_Planned_hrs__c) {
											allocationsTotal =
													allocationsTotal +
													returnedResonse.timeEntries[i].FPSA_Project_Planned_hrs__c;
									}
                                    
							}
							component.set("v.totalAllocations", allocationsTotal);
							component.set("v.timeEntry", returnedResonse.timeEntries);
                            // component.set("v.disableTimeEntry",returnedResonse.isChecked);               
							component.set("v.showSpinner", false);
					}
			});
			$A.enqueueAction(action);
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(false);
			component.set("v.customUnsavedChanges", false);
	},

	handleSave: function(component, event, helper) {
			var dmlAllowed = true;
			var ErrorString = "Error - ";
			component.set("v.showSpinner", true);
			var timeEntryRecords = component.get("v.timeEntry");
        	console.log("timeEntry=="+timeEntryRecords);
			var timeEntriesToUpdate = timeEntryRecords.filter(timeEntry => timeEntry.FPSA_Status__c != 'Approved' && timeEntry.FPSA_Status__c != 'Submitted');
			if (timeEntriesToUpdate && timeEntriesToUpdate.length > 0) {
					var isValidTimeEntry = timeEntriesToUpdate.every((timeEntry) => timeEntry.FPSA_Project__c)
					if (isValidTimeEntry) {
							console.log("Test-before weekly save");
							for (var i = 0; i < timeEntriesToUpdate.length; i++) {
									//console.log(timeEntriesToUpdate[i].FPSA_Total_Hours__c, '====', timeEntriesToUpdate[i].FPSA_Project__r);
									if (timeEntriesToUpdate[i].FPSA_Total_Hours__c != 0  && timeEntriesToUpdate[i].FPSA_Project__r.Weekly_Summary_Required__c === true && (timeEntriesToUpdate[i].FPSA_Weekly_Notes__c === undefined || timeEntriesToUpdate[i].FPSA_Weekly_Notes__c === '')) {
											dmlAllowed = false;
											ErrorString = "Weekly Summary required for " +
													timeEntriesToUpdate[i].FPSA_Project__r.Name;
											break;
									}
                                	if (timeEntriesToUpdate[i].FPSA_Total_Hours__c != 0 && timeEntriesToUpdate[i].FPSA_No_Hours__c == true &&  timeEntriesToUpdate[i].FPSA_Weekly_Notes__c == '<<NO HOURS>>') {
										dmlAllowed = false;
										//isdataRequired = true;
										ErrorString = "Please clear the weekly hours before checking this checkbox. " +timeEntriesToUpdate[i].FPSA_Project__r.Name;
										break;
									}

							}
				 			console.log("Test-after weekly save");
							if (dmlAllowed) {
									for (var i = 0; i < timeEntriesToUpdate.length; i++) {
											delete timeEntriesToUpdate[i].FPSA_Project__r;
											delete timeEntriesToUpdate[i].FPSA_Milestone__r;
											delete timeEntriesToUpdate[i].FPSA_Resource__r;
											delete timeEntriesToUpdate[i].FPSA_Total_Hours__c;
											//delete timeEntriesToUpdate[i].FPSA_No_Hours__c;
											delete timeEntriesToUpdate[i].rolesAvailable;
											delete timeEntriesToUpdate[i].disableTimeEntry;
											delete timeEntriesToUpdate[i].milesStoneAvailable;
                                        	//delete timeEntriesToUpdate[i].FPSA_No_Hours__c;
									}
									
									var action = component.get("c.SaveTimeSheet");
									action.setParams({
											timeEntries: JSON.stringify(timeEntriesToUpdate),
											weekStartDate: component.get("v.weekStart"),
                                        	buttonstatus:'saveButton'
									});
									action.setCallback(this, function(response) {
											var state = response.getState();
											component.set("v.showSpinner", false);
											console.log("Test-save action");
											if (state === "SUCCESS") {
                          if(response.getReturnValue() === 'Success') {
                            alert("Records updated successfully!!");
                            var a = component.get("c.handleStartDateChange");
                            $A.enqueueAction(a);
                          }else if(response.getReturnValue() === 'Error'){
                            var a = component.get("c.cancelButton");
                				$A.enqueueAction(a);
                              //alert("There is an error with your time submission. Please contact the System Administrator to resubmit time.");
                            var a = component.get("c.handleStartDateChange");
                            $A.enqueueAction(a);
                          }else {
                            //alert("There is an error with your time submission. Please contact the System Administrator to resubmit time.");
                            alert(response.getReturnValue());
                          }
											} else {
                          var errors = action.getError();
													if (errors) {
															if (errors[0] && errors[0].message) {
																	alert(errors[0].message);
															}
													}
											}
									});
									$A.enqueueAction(action);
							} else {
									component.set("v.showSpinner", false);
									alert(ErrorString);
							}
					} else {
							component.set("v.showSpinner", false);
							alert("Please fill in a Project!!");
					}
			} else {
					component.set("v.showSpinner", false);
					alert("No records to update");
			}
        return action;
	},

	handleSaveAndSubmit: function(component, event, helper) {
        component.set("v.showSpinner", true);
		var timeEntryRecords = component.get("v.timeEntry");
		var relaxMinHoursCap = component.get("v.relaxMinHoursCap");
		var dmlAllowed = true;
		var ErrorString = "Error - ";
		var grandTotal = component.get("v.grandTotal");
		var updateStatus = "Submitted";
		var isSaveOnly = false;

		var timeEntriesToUpdate = timeEntryRecords.filter(
			timeEntry =>
			timeEntry.FPSA_Status__c != "Approved" &&
			timeEntry.FPSA_Status__c != "Submitted"
		);

		if (timeEntriesToUpdate && timeEntriesToUpdate.length > 0) {

			console.log("relaxMinHoursCap : " + relaxMinHoursCap);
			console.log("grandTotal : " + grandTotal);
			// if (grandTotal < 40 && !relaxMinHoursCap) {
			// 	alert("Total time charged for the week is less than 40.");
			// 	updateStatus = "Saved";
			// 	dmlAllowed = true;
			// }

			//14-06-23 changes by krishna starts
			if (relaxMinHoursCap) { 
				if(grandTotal < 40){ 
					alert("Total time charged for the week is less than 40.");
				}				
				updateStatus = "Saved";
				dmlAllowed = true;
			}else if(grandTotal >= 40){ 
				updateStatus = "Saved";
				dmlAllowed = true;
			}else{ 
				alert("Total time charged for the week is less than 40. So, The timesheet will be Saved Only.");
				updateStatus = "Saved";
				isSaveOnly = true;
			}
			//14-06-23 changes by krishna ends
			 
			var isdataRequired = false;
			for (var i = 0; i < timeEntriesToUpdate.length; i++) {

				if (!timeEntriesToUpdate[i].FPSA_Project__c) {
					dmlAllowed = false;
					isdataRequired = true;
					ErrorString = "Please fill in a Project!!";
					break;
				}

				if (timeEntriesToUpdate[i].FPSA_Project__r.FPSA_Daily_Timecard_Notes_Required__c) {
					var daysNames = component.get("v.daysForTotal");

					for (const day of daysNames.values()) {

						if (timeEntriesToUpdate[i]["FPSA_" + day + "_Hours__c"] > 0 && !timeEntriesToUpdate[i]["FPSA_" + day + "_Notes__c"]) {
							dmlAllowed = false;
							isdataRequired = true;
							ErrorString = "Notes mandatory for " + timeEntriesToUpdate[i].FPSA_Project__r.Name + "-" + day;
							break;
						}

						if (!dmlAllowed) {
							break;
						}
					}
				}

				if (timeEntriesToUpdate[i].FPSA_Project__r.FPSA_Milestone_required__c && !timeEntriesToUpdate[i].FPSA_Milestone__c) {
					dmlAllowed = false;
					isdataRequired = true;
					ErrorString = "Milestone required for " +
							timeEntryRecords[i].FPSA_Project__r.Name;
					break;
				}
				console.log("Test-before weekly");
				if (timeEntriesToUpdate[i].FPSA_Total_Hours__c != 0 && timeEntriesToUpdate[i].FPSA_Project__r.Weekly_Summary_Required__c === true && (timeEntriesToUpdate[i].FPSA_Weekly_Notes__c === undefined || timeEntriesToUpdate[i].FPSA_Weekly_Notes__c === '')) {
					dmlAllowed = false;
					isdataRequired = true;
					ErrorString = "Weekly Summary required for " +
							timeEntriesToUpdate[i].FPSA_Project__r.Name;
					break;
				}
                if (timeEntriesToUpdate[i].FPSA_Total_Hours__c == 0 && timeEntriesToUpdate[i].FPSA_No_Hours__c != true) {
					dmlAllowed = false;
					isdataRequired = true;
					ErrorString = "Please check the No Hours checkbox or add hours in the weekly hours for " +
							timeEntriesToUpdate[i].FPSA_Project__r.Name;
					break;
				}
			}
			if(!isdataRequired){
				var msg = 'You are submitting time for the week of ' + $A.localizationService.formatDate(component.get("v.weekStart")) + ' Is that correct?';
				if (!confirm(msg)) {
					console.log('No');
					component.set("v.showSpinner", false);
					return false;
				} else {
					console.log('Yes');
				}
			}

			console.log("Test-after weekly");
			if (dmlAllowed) {
				for (var i = 0; i < timeEntriesToUpdate.length; i++) {
					delete timeEntriesToUpdate[i].FPSA_Project__r;
					delete timeEntriesToUpdate[i].FPSA_Milestone__r;
					delete timeEntriesToUpdate[i].FPSA_Resource__r;
					if (updateStatus == "Submitted" && timeEntriesToUpdate[i].FPSA_Weekly_Notes__c != '') {
							timeEntriesToUpdate[i].FPSA_Status__c = "Submitted";
					}
					// else if(updateStatus = 'SaveOnly'){
					// 	timeEntriesToUpdate[i].FPSA_Status__c = "SaveOnly";
					// }
					delete timeEntriesToUpdate[i].FPSA_Total_Hours__c;
                    //delete timeEntriesToUpdate[i].FPSA_No_Hours__c;
					delete timeEntriesToUpdate[i].rolesAvailable;
											delete timeEntriesToUpdate[i].disableTimeEntry;
											delete timeEntriesToUpdate[i].milesStoneAvailable;
				}
                
				var action = component.get("c.saveAndSubmitTimeSheet");

				action.setParams({
						timeEntries: JSON.stringify(timeEntriesToUpdate),
						weekStartDate: component.get("v.weekStart"),
                    	buttonstatus:"saveAndSubmitButton"
				});

				action.setCallback(this, function(response) {
					var state = response.getState();
					component.set("v.showSpinner", false);
					console.log("Test-Action");
					if (state === "SUCCESS") {
               			if(response.getReturnValue() === 'Last Week Records are available') {
                			alert("Records updated successfully!! Any Project with total hours as 0 will not be submitted.");
                			
                            var a = component.get("c.handleStartDateChange");
                			$A.enqueueAction(a);
               			}
                            else if(response.getReturnValue() === 'Last Week Records are not available'){
                			var msg = 'You have unsubmitted Timesheets in the previous week. Are you sure you want to submit current week Timesheets? ';
							if (!confirm(msg)) {
								console.log('No');
								component.set("v.showSpinner", false);
                    			
                                var a = component.get("c.cancelButton");
                				$A.enqueueAction(a);
								//return false;
								
							
							} else {
								console.log('Yes');
                                var a;
								if(isSaveOnly){
									a = component.get("c.cancelButton");
								}else{
									a = component.get("c.yesbutton");
								}

                				$A.enqueueAction(a);
                    			//alert("Records updated successfully!! Any Project with total hours as 0 will not be submitted.");
							}
                			var a = component.get("c.handleStartDateChange");
                			$A.enqueueAction(a);
              		}else {
                		alert("Something went wrong. Please contact your administrator");
              		}
				} else {
              		alert("Something went wrong. Please contact your administrator");
				}
				});

				$A.enqueueAction(action);
			} else {
				component.set("v.showSpinner", false);
				alert(ErrorString);
			}
				
		} else {
				component.set("v.showSpinner", false);
				alert("No records to update");
		}
        
	},
	
    yesbutton : function(component, event,helper) {
        component.set("v.showSpinner", true);
		var timeEntryRecords = component.get("v.timeEntry");
		var relaxMinHoursCap = component.get("v.relaxMinHoursCap");
		var dmlAllowed = true;
		var ErrorString = "Error - ";
		
		
        
        	console.log("timeEntry=="+timeEntryRecords);
			var timeEntriesToUpdate = timeEntryRecords.filter(timeEntry => timeEntry.FPSA_Status__c != 'Approved'  && timeEntry.FPSA_Status__c != 'Submitted');
			if (timeEntriesToUpdate && timeEntriesToUpdate.length > 0) {
			if (dmlAllowed) {
									
									var action = component.get("c.SubmitTimeSheet");
									action.setParams({
											timeEntries: JSON.stringify(timeEntriesToUpdate),
											weekStartDate: component.get("v.weekStart"),
                                        	buttonstatus:'submitButton'
									});
									action.setCallback(this, function(response) {
											var state = response.getState();
											component.set("v.showSpinner", false);
											console.log("Test-save action");
											if (state === "SUCCESS") {
                          if(response.getReturnValue() === 'Success' || response.getReturnValue() === 'Error') {
                            alert("Records updated successfully!! Any Project with total hours as 0 will not be submitted.");
                            var a = component.get("c.handleStartDateChange");
                            $A.enqueueAction(a);
                          }else if(response.getReturnValue() === 'Submission Error'){
                            alert("There is an error with your time submission. Please contact the System Administrator to resubmit time.");
                            var a = component.get("c.handleStartDateChange");
                            $A.enqueueAction(a);
                          }else {
                            alert(response.getReturnValue());
                          }
											} else {
                          var errors = action.getError();
													if (errors) {
															if (errors[0] && errors[0].message) {
																	alert(errors[0].message);
															}
													}
											}
									});
									$A.enqueueAction(action);
							} else {
									component.set("v.showSpinner", false);
									alert(ErrorString);
							}
            }
    },
	
   	cancelButton : function(component, event,helper) {
        
        var dmlAllowed = true;
        var ErrorString = "Error - ";
			component.set("v.showSpinner", true);
			var timeEntryRecords = component.get("v.timeEntry");
        	console.log("timeEntry=="+timeEntryRecords);
			var timeEntriesToUpdate = timeEntryRecords.filter(timeEntry => timeEntry.FPSA_Status__c != 'Approved'  && timeEntry.FPSA_Status__c != 'Submitted');
			if (timeEntriesToUpdate && timeEntriesToUpdate.length > 0) {
			if (dmlAllowed) {
									

									var action = component.get("c.SaveTimeSheet");
									action.setParams({
											timeEntries: JSON.stringify(timeEntriesToUpdate),
											weekStartDate: component.get("v.weekStart"),
                                        	buttonstatus:"saveButton"
									});
									action.setCallback(this, function(response) {
											var state = response.getState();
											component.set("v.showSpinner", false);
											console.log("Test-save action");
											if (state === "SUCCESS") {
                          if(response.getReturnValue() === 'Success' || response.getReturnValue() === 'Error') {
                            alert("Records updated successfully!! ");
                            var a = component.get("c.handleStartDateChange");
                            $A.enqueueAction(a);
                          }else if(response.getReturnValue() === 'Submission Error'){
                            alert("There is an error with your time submission. Please contact the System Administrator to resubmit time.");
                            var a = component.get("c.handleStartDateChange");
                            $A.enqueueAction(a);
                          }else {
                            alert(response.getReturnValue());
                          }
											} else {
                          var errors = action.getError();
													if (errors) {
															if (errors[0] && errors[0].message) {
																	alert(errors[0].message);
															}
													}
											}
									});
									$A.enqueueAction(action);
							} else {
									component.set("v.showSpinner", false);
									alert(ErrorString);
							}
            }
    },
                                                
	handleStartDateChange: function(component, event, helper) {
			var selectedDate = component.get("v.weekStart");
			const [year, month, day] = selectedDate.split("-");
			var curr = new Date(Number(year), Number(month) - 1, Number(day));
			var first = curr.getDate();
			curr.setDate(first + 6);
			component.set("v.weekEnd", curr);
			var action = helper.getTimeEntriesAction(component, selectedDate);
			$A.enqueueAction(action);
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(false);
			component.set("v.customUnsavedChanges", false);
	},
	weekChange: function(component, event, helper) {
			var selectedDate = component.get("v.weekStart");
			const clickAction = event.target.getAttribute("name");
			const [year, month, day] = selectedDate.split("-");
			var curr = new Date(Number(year), Number(month) - 1, Number(day));
			var first = curr.getDate();
			if (clickAction == 'back') {
					selectedDate = $A.localizationService.formatDate(curr.setDate(first - 7), "yyyy-MM-dd");
			} else {
					selectedDate = $A.localizationService.formatDate(curr.setDate(first + 7), "yyyy-MM-dd");
			}
			component.set("v.weekStart", selectedDate);
			var second = curr.getDate();
			curr.setDate(second + 7);
			component.set("v.weekEnd", curr);
			var action = helper.getTimeEntriesAction(component, selectedDate);
			$A.enqueueAction(action);
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(false);
			component.set("v.customUnsavedChanges", false);

			var curr = new Date();
			var first = curr.getDate() - curr.getDay();
			curr.setDate(first);
			var weekDateTemp = $A.localizationService.formatDate(curr, "YYYY-MM-DD");
			var weekStart = component.get("v.weekStart");
			console.log("********************************weekStart************************************"+weekStart);  
			console.log("********************************weekDateTemp************************************"+weekDateTemp);  
		    if(weekDateTemp != weekStart){
				component.set("v.showFetchButton", false)  
				console.log("********************************false************************************");    
		    }
		    else if(weekDateTemp == weekStart){
				component.set("v.showFetchButton", true)    
				console.log("**********************************true**********************************");  
		    }
	},

	showNote: function(component, event, helper) {
			var day = event.getSource().get("v.name");
			var dayIndex = event.getSource().get("v.value");
			component.set("v.openNoteDay", day + "_" + dayIndex);
			component.set("v.customUnsavedChanges", true);
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(true);
	},
	closeNote: function(component, event, helper) {
			component.set("v.openNoteDay", "");
	},
	handleAdd: function(component, event, helper) {
			var newTimeEntry = {
					FPSA_Resource__c: component.get("v.resourceId"),
					FPSA_Total_Hours__c: 0,
					FPSA_Status__c: "Saved",
                	FPSA_No_Hours__c:false,
                    disableTimeEntry: false
			};
			var timeEntries = component.get("v.timeEntry");
			timeEntries.push(newTimeEntry);
			component.set("v.timeEntry", timeEntries);
        	var disableTimeEntries = component.get("v.disableTimeEntry");
        	disableTimeEntries.push(false);
        	component.set("v.disableTimeEntry", disableTimeEntries);
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(true);
			component.set("v.customUnsavedChanges", true);
        	
	},
	hrschange: function(component, event, helper) {
			var timeEntries = component.get("v.timeEntry") || [];
			var enteredHours = event.getSource().get("v.value");
			if (enteredHours > 24 || enteredHours < -1) {
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
							title: "Error!",
							message: "Enter a valid value which is more than 0 and less than 24"
					});
					toastEvent.fire();
					var indexAndNameField = event.getSource().get("v.name");
					const splitArr = indexAndNameField.split("-");
					const timeEntryIndex = splitArr[0];
					const day = splitArr[1];
					timeEntries[timeEntryIndex][day] = 0;
			}
			var dayWiseTotal = [];

			component.get("v.daysForTotal").forEach(function(day) {
					var totalHrs = timeEntries.reduce(function(total, current) {
							return total + (Number(current["FPSA_" + day + "_Hours__c"]) || 0);
					}, 0);
					dayWiseTotal.push(totalHrs);
			});
			component.set("v.dayWiseTotalHr", dayWiseTotal);
			var timeTotal = dayWiseTotal.reduce(
					(accumulator, currentValue) => accumulator + currentValue
			);
			component.set("v.grandTotal", timeTotal);

			let timeEntryWiseTotal = [];
			timeEntries.forEach(function(timeEntry) {
					var totalHrs = component
							.get("v.daysForTotal")
							.reduce(function(total, current) {
									return (
											total + (Number(timeEntry["FPSA_" + current + "_Hours__c"]) || 0)
									);
							}, 0);
					timeEntry.FPSA_Total_Hours__c = totalHrs;
			});
			component.set("v.timeEntry", timeEntries);
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(true);
			component.set("v.customUnsavedChanges", true);
	},

	removeRow: function(component, event, helper) {
			component.set("v.showSpinner", true);
			var rowIndex = event.target.getAttribute("name");
			var idAndIndex = rowIndex.split('-');
			if (idAndIndex[0]) {
					var action = component.get("c.deleteTimeEntry");
					action.setParams({
							timeEntryId: idAndIndex[0]
					});
					action.setCallback(this, function(response) {
							component.set("v.showSpinner", false);
							if (response.getReturnValue()) {
									alert("Time Entry deleted successfully!");
									var a = component.get("c.handleStartDateChange");
									$A.enqueueAction(a);
							} else {
									alert("Something went wrong. Please contact your administrator");
							}
					});
					$A.enqueueAction(action);
			} else {
					var newTimeEntry = component.get('v.timeEntry');
					newTimeEntry.splice(idAndIndex[1], 1);
					component.set('v.timeEntry', newTimeEntry);
					component.set("v.showSpinner", false);
			}
	},
	handleSaveMethod: function(component, event) {
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(true);
	},
	handleDiscardMethod: function(component, event) {
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(false);
	},
	handleCustomSaveMethod: function(component, event) {
			component.set("v.showConfirmDialog", false);
	},
	handleCustomDiscardMethod: function(component, event) {
			component.set("v.customUnsavedChanges", false);
			component.set("v.showConfirmDialog", false);
			var a = component.get("c.handleStartDateChange");
			$A.enqueueAction(a);
	},
	askForConfirmation: function(component, event) {
			if (component.get("v.customUnsavedChanges")) {
					component.set("v.showConfirmDialog", true);
			} else {
					component.set("v.showConfirmDialog", false);
					var a = component.get("c.handleStartDateChange");
					$A.enqueueAction(a);
			}
			var curr = new Date();
			var first = curr.getDate() - curr.getDay();
			curr.setDate(first);
			var weekDateTemp = $A.localizationService.formatDate(curr, "YYYY-MM-DD");
			var weekStart = component.get("v.weekStart");
			console.log("********************************weekStart************************************"+weekStart);  
			console.log("********************************weekDateTemp************************************"+weekDateTemp);  
		    if(weekDateTemp != weekStart){
				component.set("v.showFetchButton", false)  
				console.log("********************************false************************************");    
		    }
		    else if(weekDateTemp == weekStart){
				component.set("v.showFetchButton", true)    
				console.log("**********************************true**********************************");  
		    }
	},

	onProjectChange: function(component, event, helper) {
    	var timeEntries = component.get("v.timeEntry");
        console.log('timeEntry=='+component.get("v.timeEntry"));
    	const timeEntryIndex = Number(event.getSource().get("v.name"));
        
    	var projectWithRole = component.get("v.projWithRole");
    	//var projWithMilestone = component.get('v.projWithMilestone');
    	let selectedProjId = event.getSource().get("v.value");
        	        
    	console.log('projectWithRole=='+projectWithRole);
    	console.log('selectedProjId=='+selectedProjId);
    	var action = component.get("c.getRolesOfTheUser");
    	action.setParams({
        	resourceId: component.get("v.resourceId"),
        	projectId: selectedProjId
    	});
    	action.setCallback(this, function(response) {
        	var state = response.getState();
        	console.log('state is '+state);
        	if (state === "SUCCESS") {
            	console.log('returned reponse is '+JSON.stringify(response.getReturnValue()));
            	let returnedResonse = response.getReturnValue();
            	//var rolesPickList = response.roleValues;
            	var rolesMap = [];
            	for(var key in returnedResonse){
                	rolesMap.push({key : key, value: returnedResonse[key]})
            	}
            	console.log('roles map is ===',rolesMap);
            	component.set("v.roleList", rolesMap);
                timeEntries[timeEntryIndex].rolesAvailable = rolesMap;
                component.set("v.timeEntry",timeEntries);
                var action_1 = component.get('c.onRoleChange');
                component.set("v.timeEntryIndexForRole", timeEntryIndex);
        		$A.enqueueAction(action_1);
                    
            	var a = component.get("c.getMilestoneForProject");
            	a.setParams({
                	projectId: selectedProjId
            	});
            	a.setCallback(this, function(response) {
                	var state = response.getState();
                	console.log('state is '+state);
                	if (state === "SUCCESS") {
                    	console.log('Getting Milestone successfully...');
                    	console.log('returned reponse is '+JSON.stringify(response.getReturnValue()));
                    	let returnedResonse = response.getReturnValue();
                    	var milestoneMap = [];
                    	for(var key in returnedResonse){
                        	milestoneMap.push({key : key, value: returnedResonse[key]})
                    	}
                        
                    	console.log('milestone == '+JSON.stringify(response.getReturnValue()));
                    	component.set("v.milestoneList", milestoneMap);
                    	
                        timeEntries[timeEntryIndex].milesStoneAvailable = milestoneMap;
                		timeEntries[timeEntryIndex].FPSA_Project__c = selectedProjId;
                        component.set("v.timeEntry", timeEntries);
                    	console.log('Project Handle== '+timeEntries[timeEntryIndex].FPSA_Project__c);
                    	
                        var availableProjects = component.get("v.projectList");
						var selectedProjectRecord;
						for (var i = 0; i < availableProjects.length; i++) {
							if (availableProjects[i].Id == selectedProjId) {
								selectedProjectRecord = availableProjects[i];
							}
						}
        				console.log('selectedProjectRecord=='+selectedProjectRecord);
						timeEntries[timeEntryIndex].FPSA_Project__r = selectedProjectRecord;
                        component.set("v.timeEntry", timeEntries);
                        console.log('timeEntries=========',timeEntries);
                        console.log('FPSA_Project__r',timeEntries[timeEntryIndex].FPSA_Project__r);
						if (selectedProjectRecord.Weekly_Summary_Required__c == true) {
							component.set('v.weeklySummaryRequired', true);
						} else {
							component.set('v.weeklySummaryRequired', false);
						}
						component.set('v.selectedProject',selectedProjectRecord);
                	}
            	});
            	$A.enqueueAction(a);
        	}
    	});
    	$A.enqueueAction(action);	
	},

	onMilestoneSelection: function(component, event, helper) {
        	
        var projectWithRole = component.get("v.projWithRole");
        	//console.log('Project Name in milestone=='+projectWithRole);
           	//console.log('in milestone selection');
			let selectedMilestoneId = event.getSource().get("v.value");
        	console.log('in milestone selectedMilestoneId=='+selectedMilestoneId);
			var timeEntries = component.get("v.timeEntry");
			const timeEntryIndex = Number(event.getSource().get("v.name"));
			timeEntries[event.getSource().get("v.name")].FPSA_Milestone__c = selectedMilestoneId;
			component.set("v.timeEntry", timeEntries);
        	console.log('timeEntries=='+timeEntries);
        	//component.find("milestoneList").set("v.value", selectedMilestoneId);
        var unsaved = component.find("unsaved");
						unsaved.setUnsavedChanges(true);
						component.set("v.customUnsavedChanges", true);
	},
                                                
	onRoleChange: function(component, event, helper) {
        	
        //console.log('in role selection');
    	var projectWithRole = component.get("v.projWithRole");
    	//console.log('Project Name in role =='+projectWithRole);
        //console.log(event);
        var timeEntries = component.get("v.timeEntry");
       if(event != undefined){
    		let selectedRoleId = component.find("roleId").get("v.value");// getting id
            console.log('===================in role selectedRoleId==',selectedRoleId);
            const timeEntryIndex = Number(event.getSource().get("v.name"));
           	console.log('==========selectedRoleName========',component.get("v.roleList")[timeEntryIndex].value);
            timeEntries[event.getSource().get("v.name")].FPSA_Role__c = selectedRoleId;
            component.set("v.timeEntry", timeEntries);
            //component.find("roleList").set("v.value", selectedRoleId);
            
       }else{
            let selectedRoleId = component.get("v.roleList")[0].value;//getting name
            console.log('===================in role selectedRoleId=='+selectedRoleId);
            var timeEntries = component.get("v.timeEntry");
            timeEntries[component.get("v.timeEntryIndexForRole")].FPSA_Role__c = selectedRoleId;
            component.set("v.timeEntry", timeEntries);
            //component.find("roleList").set("v.value", selectedRoleId);
       }
        
        var unsaved = component.find("unsaved");
						unsaved.setUnsavedChanges(true);
						component.set("v.customUnsavedChanges", true);
	},
                                                
	cloneRow: function(component, event) {
        	var noHoursCheckbox = component.get("v.isChecked");
			var timeEntries = component.get("v.timeEntry");
			const timeEntryIndex = Number(event.target.getAttribute("name"));
			var newTimeEntry = {
					FPSA_Resource__c: timeEntries[timeEntryIndex].FPSA_Resource__c,
					FPSA_Total_Hours__c: 0,
					FPSA_Status__c: "Saved",
                	FPSA_No_Hours__c :noHoursCheckbox,
					FPSA_Role__c: timeEntries[timeEntryIndex].FPSA_Role__c,
					/* "FPSA_Milestone__c" : timeEntries[timeEntryIndex].FPSA_Milestone__c,
								"FPSA_Milestone__r" : {
										"Name" : timeEntries[timeEntryIndex].FPSA_Milestone__r.Name
								},*/
					FPSA_Project__c: timeEntries[timeEntryIndex].FPSA_Project__c,
					FPSA_Project__r: {
							Name: timeEntries[timeEntryIndex].FPSA_Project__r.Name,
							FPSA_Milestone_required__c: timeEntries[timeEntryIndex].FPSA_Project__r
									.FPSA_Milestone_required__c,
							FPSA_Daily_Timecard_Notes_Required__c: timeEntries[timeEntryIndex].FPSA_Project__r
									.FPSA_Daily_Timecard_Notes_Required__c,
							MPM4_BASE__Project_Milestones__r: timeEntries[timeEntryIndex].FPSA_Project__r
									.MPM4_BASE__Project_Milestones__r
					}
			};
			timeEntries.push(newTimeEntry);
			component.set("v.timeEntry", timeEntries);
			var unsaved = component.find("unsaved");
			unsaved.setUnsavedChanges(true);
			component.set("v.customUnsavedChanges", true);
	},

	ShowretriveHoursFromTasksModal: function(component, event) {
		component.set("v.ShowRetrieveConfirmDialog", true);
	},

	YESretriveHoursFromTasks: function(component, event) {
		var a = component.get("c.retriveHoursFromTasks");
		$A.enqueueAction(a);
		component.set("v.ShowRetrieveConfirmDialog", false);
	},

	NOretriveHoursFromTasks: function(component, event) {
		component.set("v.ShowRetrieveConfirmDialog", false);
	},

	CantEditHours: function(component, event) {
		let Editonce = component.get("v.HoursEditAlertOnlyOnce"); 
		console.log("********************************Editonce************************************"+Editonce);
		if (Editonce==true) {
			component.set("v.HoursEditAlert", true);	
		}else{
			component.set("v.HoursEditAlert", false);	
		}
	},
    CancelEditNoHours: function(component, event) {
    	let isDisable = event.getSource().get("v.value");
        var timeEntryRecords = component.get("v.timeEntry");
        var timeEntriesToUpdate = timeEntryRecords.filter(timeEntry => timeEntry.FPSA_Total_Hours__c != 0 ||timeEntry.FPSA_Total_Hours__c == 0);
        
    	if(isDisable  &&(timeEntriesToUpdate[event.getSource().get("v.name")].FPSA_Total_Hours__c!=0) &&(timeEntriesToUpdate[event.getSource().get("v.name")].FPSA_Weekly_Notes__c != '<<NO HOURS>>') ){
                            alert("Please clear the weekly hours before checking this checkbox.");
               
        }
    },

	CancelCantEditHours: function(component, event) {
		component.set("v.HoursEditAlertOnlyOnce", false);
		component.set("v.HoursEditAlert", false);	
	},

	retriveHoursFromTasks : function(component, event, helper) {
        console.log("********************************entry retriveHoursFromTasks************************************");
		component.set("v.showSpinner", true);
		var timeEntryVar = component.get("v.timeEntry");
		var milestoneIds = [];
		for (var i = 0; i < timeEntryVar.length; i++) {
			milestoneIds.push(timeEntryVar[i].FPSA_Milestone__c);
		}
		console.log('==milestoneIds==', milestoneIds);
		var resourceRecId = component.get("v.resourceId");
		//console.log('==resourceRecId==', resourceRecId);
		var action = component.get("c.getHrsFromTasks");
		action.setParams({
				resourceId: resourceRecId,
				milestoneIds: milestoneIds,
				weekStartString: component.get("v.weekStart")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				let returnedResonse = response.getReturnValue();
				//Adding new rows if allocation is not for the logged-in user
				var mapMilestones = returnedResonse.mapMilestones;
				console.log('===mapMilestones==', JSON.stringify(mapMilestones));
				if(mapMilestones && mapMilestones !== undefined) {
					var availableProjects = component.get("v.projectList");
					var projectWithRoles = component.get("v.projWithRole");
					var isChecked = component.get("v.isChecked");
                    //component.set("v.disableTimeEntry",component.get("v.isChecked"));
					for (const [key, value] of Object.entries(mapMilestones)) {
						//console.log(key, '====new row===', value.Name);
						var newTimeEntry = {
							FPSA_Resource__c: resourceRecId,
							FPSA_Total_Hours__c: 0,
                            FPSA_No_Hours__c:isChecked,
							FPSA_Status__c: "Saved",
							FPSA_Milestone__c : key,
							FPSA_Milestone__r : {
													"Name" : value.Name
												},
                            FPSA_Role__c : text.FPSA_Role__c,
							
							FPSA_Project__c: value.MPM4_BASE__Project__c
						};
                        
						//console.log('====newTimeEntry111==', newTimeEntry);
						var selectedProjectRecord;
						for (var i = 0; i < availableProjects.length; i++) {
							if (availableProjects[i].Id === newTimeEntry.FPSA_Project__c) {
									selectedProjectRecord = availableProjects[i];
							}
						}
						if(selectedProjectRecord && selectedProjectRecord !== undefined) {
							newTimeEntry.FPSA_Project__r = selectedProjectRecord;
							if (selectedProjectRecord.Weekly_Summary_Required__c == true) {
								component.set('v.weeklySummaryRequired', true);
							}
						}else {
							newTimeEntry.FPSA_Project__r = {
																Name: value.MPM4_BASE__Project__r.Name,
																Weekly_Summary_Required__c: value.MPM4_BASE__Project__r.Weekly_Summary_Required__c,
																FPSA_Daily_Timecard_Notes_Required__c: value.MPM4_BASE__Project__r.FPSA_Daily_Timecard_Notes_Required__c
															};
						}
						//console.log('====newTimeEntry222==', newTimeEntry);
						var filteredArray = projectWithRoles.filter(name =>
								name.startsWith(newTimeEntry.FPSA_Project__c)
						);
						//console.log('===filteredArray==', filteredArray);
						newTimeEntry.FPSA_Role__c = filteredArray.length > 0 ? filteredArray[0].split("-")[1] : "";
						//console.log('====newTimeEntry333==', newTimeEntry);
						timeEntryVar.push(newTimeEntry);
					}
				}
				
				if(timeEntryVar && timeEntryVar.length > 0) {
					for (var i = 0; i < timeEntryVar.length; i++) {
						//console.log(timeEntryVar[i].FPSA_Status__c, '===row FPSA_Status__c==');
						if(timeEntryVar[i].FPSA_Status__c !== 'Submitted' && timeEntryVar[i].FPSA_Status__c !== 'Approved') {
							if(returnedResonse.mapMilestoneIdToWeeklyHours && returnedResonse.mapMilestoneIdToWeeklyHours !== undefined) {
								var mapDailyHoursForMilestone = returnedResonse.mapMilestoneIdToWeeklyHours[timeEntryVar[i].FPSA_Milestone__c];
								console.log('===mapDailyHoursForMilestone==', mapDailyHoursForMilestone);
								if(mapDailyHoursForMilestone && mapDailyHoursForMilestone !== undefined) {
									timeEntryVar[i].FPSA_Sunday_Hours__c  = mapDailyHoursForMilestone["Sunday"];
									timeEntryVar[i].FPSA_Monday_Hours__c  = mapDailyHoursForMilestone["Monday"];
									timeEntryVar[i].FPSA_Tuesday_Hours__c  = mapDailyHoursForMilestone["Tuesday"];
									timeEntryVar[i].FPSA_Wednesday_Hours__c  = mapDailyHoursForMilestone["Wednesday"];
									timeEntryVar[i].FPSA_Thursday_Hours__c  = mapDailyHoursForMilestone["Thursday"];
									timeEntryVar[i].FPSA_Friday_Hours__c  = mapDailyHoursForMilestone["Friday"];
									timeEntryVar[i].FPSA_Saturday_Hours__c  = mapDailyHoursForMilestone["Saturday"];
									timeEntryVar[i].FPSA_Total_Hours__c  = mapDailyHoursForMilestone["Total"];
                                    if(timeEntryVar[i].FPSA_Total_Hours__c == 0){
                                        timeEntryVar[i].FPSA_No_Hours__c==true;
                                        //component.set("v.disableTimeEntry",true);
                                    }
                                    else{
                                        timeEntryVar[i].FPSA_No_Hours__c==false;
                                        //component.set("v.disableTimeEntry",false);
                                    }
									var mapDailyNotesForMilestone = returnedResonse.mapMilestoneIdToNotes[timeEntryVar[i].FPSA_Milestone__c];
									if(mapDailyNotesForMilestone && mapDailyNotesForMilestone !== undefined) {
										var milestoneWeeklyNotes = '';
										for (const [key, value] of Object.entries(mapDailyNotesForMilestone)) {
											console.log(key, '<<<dailyNotes>>', value);
											milestoneWeeklyNotes += (milestoneWeeklyNotes !== '' ? '\n' : '') + value ;
										}
										console.log('===milestoneWeeklyNotes==', milestoneWeeklyNotes);
										timeEntryVar[i].FPSA_Weekly_Notes__c  = milestoneWeeklyNotes;
									}
								}
							}
						}
					}
				}
				component.set("v.timeEntry", timeEntryVar);
                //component.set("v.disableTimeEntry",isChecked);
					
				//var timeEntries = component.get("v.timeEntry") || [];
				var dayWiseTotal = [];

				component.get("v.daysForTotal").forEach(function(day) {
						var totalHrs = timeEntryVar.reduce(function(total, current) {
								return total + (Number(current["FPSA_" + day + "_Hours__c"]) || 0);
						}, 0);
						dayWiseTotal.push(totalHrs);
				});
				component.set("v.dayWiseTotalHr", dayWiseTotal);
				var timeTotal = dayWiseTotal.reduce(
						(accumulator, currentValue) => accumulator + currentValue
				);
				component.set("v.grandTotal", timeTotal);
			}
			component.set("v.showSpinner", false);
		});
		$A.enqueueAction(action);
		var unsaved = component.find("unsaved");
		unsaved.setUnsavedChanges(false);
		component.set("v.customUnsavedChanges", false);
		console.log("********************************exit retriveHoursFromTasks************************************");
	},
                                                
    handleCheckboxChange: function(component, event, helper) {
        console.log('handleCheckboxChange called');   
        debugger;
        var projectWithRole = component.get("v.projWithRole");
		let selectedProjId = event.getSource().get("v.value");
        var selectedHeaderCheck = event.getSource().get("v.value");
        console.log('selectedProjId is '+selectedProjId);
        var disableTimeEntries = component.get("v.disableTimeEntry");
        disableTimeEntries[event.getSource().get("v.name")]=false ;
        
        //var row=component.find("index")[i].get("v.value")
        console.log('selectedHeaderCheck:', selectedHeaderCheck); 
    	var timeEntryRecords = component.get("v.timeEntry");
        var timeEntriesToUpdate = timeEntryRecords.filter(timeEntry => timeEntry.FPSA_Total_Hours__c != 0 ||timeEntry.FPSA_Total_Hours__c == 0);
        

        if(selectedHeaderCheck){
            if((selectedHeaderCheck || timeEntryRecords[event.getSource().get("v.name")].FPSA_No_Hours__c == true) &&(timeEntryRecords[event.getSource().get("v.name")].FPSA_Total_Hours__c!=0) &&(timeEntryRecords[event.getSource().get("v.name")].FPSA_Weekly_Notes__c = '<<NO HOURS>>') ){
                            alert("Please clear the weekly hours before checking this checkbox.");
               
            }
            if((selectedHeaderCheck || timeEntryRecords[event.getSource().get("v.name")].FPSA_No_Hours__c ==true)&& timeEntryRecords[event.getSource().get("v.name")].FPSA_Total_Hours__c!=0)
        	{
            	alert("Please clear the weekly hours before checking this checkbox.");
                timeEntryRecords[event.getSource().get("v.name")].disableTimeEntry = false;
                timeEntryRecords[event.getSource().get("v.name")].FPSA_Weekly_Notes__c = '';
            	timeEntryRecords[event.getSource().get("v.name")].FPSA_No_Hours__c =false;
                timeEntryRecords[event.getSource().get("v.name")].isChecked =false;
				//component.find("index").set("v.value", false);
                component.set("v.disableTimeEntry", false);
            	selectedHeaderCheck = "false";
        	}else if((selectedHeaderCheck || timeEntryRecords[event.getSource().get("v.name")].FPSA_No_Hours__c ==true) && timeEntryRecords[event.getSource().get("v.name")].FPSA_Total_Hours__c==0){
            	console.log('in if'+selectedHeaderCheck);
            	timeEntryRecords[event.getSource().get("v.name")].disableTimeEntry = selectedHeaderCheck;
            	timeEntryRecords[event.getSource().get("v.name")].FPSA_No_Hours__c =true;
            
            	timeEntryRecords[event.getSource().get("v.name")].FPSA_Weekly_Notes__c = '<<NO HOURS>>';
            	//component.find("index").set("v.value", true);
            	component.set("v.disableTimeEntry", true);
        	} 
        }else {
            console.log('in else'+selectedHeaderCheck);
            timeEntryRecords[event.getSource().get("v.name")].disableTimeEntry = selectedHeaderCheck;
            timeEntryRecords[event.getSource().get("v.name")].FPSA_Weekly_Notes__c = '';
            timeEntryRecords[event.getSource().get("v.name")].FPSA_No_Hours__c =false;
            //component.find("index").set("v.value", false);
            component.set("v.disableTimeEntry", false);
        } 
        component.set("v.timeEntry",timeEntryRecords);
          
		
    }
                                                
   
});