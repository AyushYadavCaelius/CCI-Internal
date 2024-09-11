public without sharing class FPSA_ResourceTimeEntry {
    
//     //Below method is called on init to fetch the details of landing page on Timesheet
//     @AuraEnabled
//     public static WrapperResponse getResourceName(Id resourceId,String weekStartString){
//         WrapperResponse wrapperResponseInst = new WrapperResponse();
//         String queryStringToFetchResource = 'Select id,Name,FPSA_Relax_Min_Hours_Cap__c from MPM4_BASE__Milestone1_Resource__c where ';
        
//         //Below if else determine whether Timesheet page is opened from Resource Page or from Tab
//         if(String.valueOf(resourceId).startsWith('005')){//Timesheet has opened from Tab hence fetch the corresponding resource record
//             queryStringToFetchResource = queryStringToFetchResource + 'MPM4_BASE__User__c = :resourceId LIMIT 1';            
//         }else{//Timesheet has opened from Resource Page hence fetch corresponding Rsource details
//             queryStringToFetchResource = queryStringToFetchResource + 'id = :resourceId LIMIT 1';
//         }
//         MPM4_BASE__Milestone1_Resource__c userRec = (MPM4_BASE__Milestone1_Resource__c)Database.query(queryStringToFetchResource)[0];
//         wrapperResponseInst.resourceName = userRec.Name; //Set ResourceName on Timesheet
//         wrapperResponseInst.resourceId = userRec.id;//Set User Id on ResourceId
//         wrapperResponseInst.relaxMinHoursCap = userRec.FPSA_Relax_Min_Hours_Cap__c;
        
//         //Below lines fetch the list of Projects already allocated to the resource to add more timeEntries to the same Project
//         set<Id> projIds = new set<Id>();
//         list<String> projIdWithRole = new list<String>();
//         list<AggregateResult> projectQuery = new list<AggregateResult>([Select FPSA_Project__c proj,FPSA_Role__c from FPSA_Project_Allocation__c where FPSA_Resource__c = :wrapperResponseInst.resourceId GROUP BY FPSA_Project__c,FPSA_Role__c]);
//         for(AggregateResult agr : projectQuery){
//             projIds.add((ID)agr.get('proj'));
//             projIdWithRole.add((String)agr.get('proj')+'-'+(String)agr.get('FPSA_Role__c'));
//         }
//         //Setting Role as well to display it again while adding the project
//         wrapperResponseInst.projIdWithRoleValue = projIdWithRole;
        
//         //Below query fetches global projects as well whose FPSA_Allow_Timecards_Without_Assignment__c = true
//         list<MPM4_BASE__Milestone1_Project__c> globalProjects = new list<MPM4_BASE__Milestone1_Project__c>([Select id,Name,FPSA_Milestone_required__c,Weekly_Summary_Required__c,FPSA_Allow_Timecards_Without_Assignment__c,FPSA_Daily_Timecard_Notes_Required__c,(Select Id,Name from MPM4_BASE__Project_Milestones__r) from MPM4_BASE__Milestone1_Project__c where (FPSA_Allow_Timecards_Without_Assignment__c = true OR Id IN:projIds)  AND FPSA_Closed_For_Time_Entry__c = false ORDER BY FPSA_Allow_Timecards_Without_Assignment__c DESC]);
//         wrapperResponseInst.projRec = globalProjects;
        
//         //Not using below line as of now since conditional display of below field on the project selection is not happening
//         wrapperResponseInst.roleValues = FPSA_CommonMethodsClass.getRolesOfTheUser(wrapperResponseInst.resourceId);
//         /* for(String eachRole : FPSA_CommonMethodsClass.getPickListValuesIntoList()){
//             wrapperResponseInst.roleValues.put(eachRole, eachRole);
//         } */
//         //wrapperResponseInst.roleValues = FPSA_CommonMethodsClass.getPickListValuesIntoList();
        
//         //Below line fetches timeEntries of the current week
//         wrapperResponseInst.timeEntries = new list<FPSA_Resource_TimeLines__c>(getResourceTimeEntry(wrapperResponseInst.resourceId, weekStartString));

//         return wrapperResponseInst;
//     }
    
//     //Below method is called whenever we want to see the TimeLine records of a particular week
//     @AuraEnabled
//     public static list<FPSA_Resource_TimeLines__c> getResourceTimeEntry(Id resourceId, String weekStartString){
//         Date weekStart = Date.valueof(weekStartString);
//         list<FPSA_Resource_TimeLines__c> timeEntries;
//             timeEntries = new list<FPSA_Resource_TimeLines__c>([Select id,FPSA_Role__c,FPSA_Project__r.Weekly_Summary_Required__c,
//                                                                     FPSA_Project__r.FPSA_Milestone_required__c,FPSA_Milestone__r.Name,
//                                                                     FPSA_Milestone__c,FPSA_Project__r.FPSA_Daily_Timecard_Notes_Required__c,
//                                                                     FPSA_Assignment__r.id,FPSA_Assignment__r.FPSA_Role__c,FPSA_Status__c,FPSA_Resource__r.Name,FPSA_Week_Start_Date__c, 
//                                                                     FPSA_BillRate__c,FPSA_Week_End_Date__c,FPSA_Total_Hours__c,FPSA_Friday_Hours__c,
//                                                                     FPSA_Friday_Notes__c,FPSA_Monday_Hours__c,FPSA_Monday_Notes__c,
//                                                                     FPSA_Project__r.Name,FPSA_Project_Planned_hrs__c,FPSA_Saturday_Hours__c, 
//                                                                     FPSA_Saturday_Notes__c, FPSA_Sunday_Hours__c, FPSA_Sunday_Notes__c,FPSA_Thursday_Hours__c, 
//                                                                     FPSA_Thursday_Notes__c, FPSA_Tuesday_Hours__c, FPSA_Tuesday_Notes__c, FPSA_Wednesday_Hours__c, 
//                                                                     FPSA_Wednesday_Notes__c,FPSA_Weekly_Notes__c, FPSA_No_Hours__c,
//                                                                     FPSA_Resource_allocation_week__c, FPSA_Project__r.FPSA_Project_ID__c
//                                                                 FROM 
//                                                                 FPSA_Resource_TimeLines__c where FPSA_Resource__c =:resourceId 
//                                                                 AND FPSA_Week_Start_Date__c =:weekStart ORDER BY FPSA_Week_Start_Date__c DESC]);
//             system.debug('timeEntry==='+timeEntries);
//         	for(FPSA_Resource_TimeLines__c timeEntry : timeEntries){
//                     system.debug('timeEntry===No Hours ='+timeEntry.FPSA_No_Hours__c);
//             	}
//         if(!timeEntries.isEmpty()) {
//             system.debug('timeEntry='+timeEntries);
//             return timeEntries;
//         }else{ 
//            return null; 
//         }   
//     }
    
    
// 	//Below method is used to save new time entries created from Time Sheet page
//     @AuraEnabled
//     public static String saveAndSubmitTimeSheet(String timeEntries, Date weekStartDate, string buttonstatus) {
//         try{
//             //string status= buttonstatus;
//             //For checking last week entries for same project
//             System.debug('timeEntries--'+system.JSON.serializePretty(timeEntries));
            
//             string result;
            
//             Date validateDate = weekStartDate.addDays(-7);
//             system.debug('validateDate--'+validateDate);
//             Set<Id> resourceIdSet = new Set<Id>();
//             Set<String> projectIdSet = new Set<String>();
//             List <FPSA_Resource_TimeLines__c> incomingTimeEntries = (List<FPSA_Resource_TimeLines__c>) System.JSON.deserialize(timeEntries, List<FPSA_Resource_TimeLines__c>.Class);
//             system.debug('incomingTimeEntries=='+incomingTimeEntries);
//             if(!incomingTimeEntries.isEmpty()){
//             	for(FPSA_Resource_TimeLines__c timeEntry : incomingTimeEntries){
//                     //timeEntry.get(0).rolesAvailable;
//                 	resourceIdSet.add(timeEntry.FPSA_Resource__c);
//                     projectIdSet.add(timeEntry.FPSA_Project__c);
//                     System.debug('projectIdSet--'+projectIdSet);
//                 	System.debug('resourceIdSet--'+resourceIdSet);
//                     system.debug('timeEntry==='+timeEntry.FPSA_No_Hours__c);
//             	}
//             }
//             List<FPSA_Resource_TimeLines__c> lastWeekTimeEntries = new List<FPSA_Resource_TimeLines__c>();
//             lastWeekTimeEntries  =[Select ID, FPSA_Week_Start_Date__c,FPSA_Project__r.Name, FPSA_Resource__c, FPSA_Project__c, FPSA_Status__c from FPSA_Resource_TimeLines__c where FPSA_Week_Start_Date__c=:validateDate AND FPSA_Resource__c IN :resourceIdSet AND FPSA_Project__c IN :projectIdSet AND (FPSA_Status__c = 'Submitted' OR FPSA_Status__c = 'Approved')];
//             system.debug('lastWeekTimeEntries--'+lastWeekTimeEntries);
//             //Map<string,FPSA_Resource_TimeLines__c> lastWeekEntryMap = new Map<string,FPSA_Resource_TimeLines__c>();
        
//             if(!lastWeekTimeEntries.isEmpty()){
//             	//timeEntriesToUpsert.add(timeEntryInst);//Add the time Entries to be upserted
//                 system.debug('success');
//                 result='Last Week Records are available';
//             }
//             else{
//                 result= 'Last Week Records are not available';
                
//             }
            
            
//             //List <FPSA_Resource_TimeLines__c> incomingTimeEntries = (List<FPSA_Resource_TimeLines__c>) System.JSON.deserialize(timeEntries, List<FPSA_Resource_TimeLines__c>.Class);
//             list<FPSA_Resource_TimeLines__c> timeEntriesToUpsert = new list<FPSA_Resource_TimeLines__c>();
//             set<Id> projIDs = new set<Id>();
//             FPSA_Resource_TimeLines__c timeEntryInst;
//             set<Id> projOnAllocation = new set<Id>();
//             set<Id> resourceOnAllocation = new set<Id>();
//             set<String> roleOnAllocation = new set<String>();
//             system.debug('incomingTimeEntries='+incomingTimeEntries);
//             List<ProcessInstance> lstAlreadySubmittedTimeEntries = [SELECT Id, TargetObjectId 
//                                                                         FROM ProcessInstance 
//                                                                         WHERE TargetObjectId IN :incomingTimeEntries
//                                                                         AND Status = 'Pending'];

//             /*if(lstAlreadySubmittedTimeEntries.size() > 0) {
//                 return 'Submission Error';
//             }else {*/
//                 for(FPSA_Resource_TimeLines__c timeEntry : incomingTimeEntries){
//                     //Below condition collects Proj Id to find Project Manager of the new Time Entries to assign as Approver
//                     projIDs.add((ID)timeEntry.FPSA_Project__c);
//                     if(timeEntry.FPSA_Assignment__c == null){
                        
//                         //Below condition is to collect all the Project,resource and role of timeentry that is directly submitted from Timesheet 
//                         if(timeEntry.FPSA_BillRate__c == null && timeEntry.FPSA_Role__c != null){
//                             projOnAllocation.add(timeEntry.FPSA_Project__c);
//                             resourceOnAllocation.add(timeEntry.FPSA_Resource__c);
//                             roleOnAllocation.add(timeEntry.FPSA_Role__c);
//                         }
//                     }
//                 }

//                 //Below query finds the Manager for Approver
//                 map<id,MPM4_BASE__Milestone1_Project__c> projectIdtoManagerId = new map<id,MPM4_BASE__Milestone1_Project__c>([SELECT OwnerId 
//                                                                                                                                 FROM MPM4_BASE__Milestone1_Project__c 
//                                                                                                                                 WHERE Id IN :projIDs]);
            
//                 //Below query fetches the latest allocation of the resource to get its Bill Rate
//                 Map<String, FPSA_Project_Allocation__c> keyIdentifierToProjectAllocation = new map<String, FPSA_Project_Allocation__c>();

//                 if(!projOnAllocation.isEmpty()) {
//                     for(FPSA_Project_Allocation__c prjAllocation : [SELECT Id, FPSA_Resource__c,FPSA_Project__c,FPSA_Role__c,FPSA_Bill_Rate__c, 
//                                                                         FPSA_Project__r.FPSA_Allow_Timecards_Without_Assignment__c, 
//                                                                         FPSA_Assignment_Number__c, FPSA_Project_Start_Date__c,
//                                                                         FPSA_Project__r.FPSA_Project_ID__c, FPSA_Project__r.FPSA_Start_Date__c
//                                                                         FROM FPSA_Project_Allocation__c 
//                                                                         WHERE FPSA_Project__c IN :projOnAllocation 
//                                                                         AND FPSA_Resource__c IN :resourceOnAllocation 
//                                                                         AND FPSA_Role__c IN :roleOnAllocation 
//                                                                         ORDER BY CreatedDate DESC]) {
//                         String keyIdentifier = prjAllocation.FPSA_Project__c + '+' + prjAllocation.FPSA_Resource__c + '+' + prjAllocation.FPSA_Role__c;
//                         if(!keyIdentifierToProjectAllocation.containskey(keyIdentifier)) {
//                             keyIdentifierToProjectAllocation.put(keyIdentifier, prjAllocation);
//                         }
//                     }
//                 }
//                 system.debug('===keyIdentifierToProjectAllocation==' + keyIdentifierToProjectAllocation);
//                 //Below loop executes on all the Time Entry records present on the page
//                 for(FPSA_Resource_TimeLines__c timeEntry : incomingTimeEntries){
//                     //Exclude all the submitted and approved timesheets, they are locked for editing
//                     //if(timeEntry.FPSA_Status__c != 'Submitted' && timeEntry.FPSA_Status__c != 'Approved'){
//                         timeEntryInst = new FPSA_Resource_TimeLines__c();
//                         timeEntryInst = timeEntry;
//                         timeEntryInst.FPSA_Project__c = (ID)timeEntry.FPSA_Project__c;//set Project Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         timeEntryInst.FPSA_Resource__c = (ID)timeEntry.FPSA_Resource__c;//Set Resource Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         timeEntryInst.OwnerId = projectIdtoManagerId.get((ID)timeEntry.FPSA_Project__c).OwnerId;//Set Status to be updated
//                     	timeEntryInst.FPSA_Status__c = 'Submitted';
                        
                    
//                         if(timeEntryInst.FPSA_Assignment__c == null){ //If no previous allocation is present
//                             timeEntryInst.FPSA_Week_Start_Date__c = weekStartDate;   //Set the Week Start Date                
//                             timeEntryInst.FPSA_Approver__c = projectIdtoManagerId.get((ID)timeEntry.FPSA_Project__c).OwnerId;//Set Approver Id
							
//                             String keyIdentifier = timeEntryInst.FPSA_Project__c + '+' + timeEntryInst.FPSA_Resource__c + '+' + timeEntryInst.FPSA_Role__c;
//                             Boolean containsKeyIdentifier = keyIdentifierToProjectAllocation.containsKey(keyIdentifier);

//                             if(containsKeyIdentifier) {
//                                 FPSA_Project_Allocation__c projectAllocation = keyIdentifierToProjectAllocation.get(keyIdentifier);
//                                 //Boolean isAssignmentRequired = !projectAllocation.FPSA_Project__r.FPSA_Allow_Timecards_Without_Assignment__c;
//                                 //timeEntryInst.FPSA_Assignment__c = isAssignmentRequired ?  projectAllocation.Id : null;
//                                 timeEntryInst.FPSA_Assignment__c = projectAllocation.Id;

//                                 //Populate unique key on Allocation_Week field
//                                 if(timeEntry.FPSA_Resource_allocation_week__c == NULL)
//                                     timeEntryInst.FPSA_Resource_allocation_week__c = getAllocationWeekValue(weekStartDate, projectAllocation); 

//                                 if(timeEntryInst.FPSA_BillRate__c == null && timeEntryInst.FPSA_Role__c != null){
//                                     timeEntryInst.FPSA_BillRate__c = keyIdentifierToProjectAllocation.get(keyIdentifier).FPSA_Bill_Rate__c;
//                                 }
                                
//                                 /*if(result == 'Error'){
                            
//                         			timeEntryInst.FPSA_Status__c = 'Saved';
//                     			}  */                             
//                             }
//                         }else{
//                             timeEntryInst.FPSA_Assignment__c = (ID)timeEntry.FPSA_Assignment__c;//Set Assignment Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         }
                    	
//                         timeEntriesToUpsert.add(timeEntryInst);//Add the time Entries to be upserted
//                     	system.debug('timeEntriesToUpsert--'+timeEntriesToUpsert);
//                     //}        
//                 }
//             	if(result != 'Last Week Records are not available' && buttonstatus != 'saveButton'){
//                     system.debug('buttonstatus=======in Save and Submit=============='+buttonstatus);
//                 	Database.upsert (timeEntriesToUpsert, true);//Upsert the Time Entries
//             	}
//             	return result;
//             //}
//         }catch(Exception ex){
//             //throw new AuraHandledException(ex.getMessage());
//             system.debug(ex.getMessage() + ex.getStackTraceString());
//             return + ex.getMessage() + ex.getStackTraceString();
//         }
//     }
    
//     //Below method is used to save new time entries created from Time Sheet page
//     @AuraEnabled
//     public static String SaveTimeSheet(String timeEntries, Date weekStartDate, string buttonstatus) {
//         try{
            
//             List <FPSA_Resource_TimeLines__c> incomingTimeEntries = (List<FPSA_Resource_TimeLines__c>) System.JSON.deserialize(timeEntries, List<FPSA_Resource_TimeLines__c>.Class);
//             list<FPSA_Resource_TimeLines__c> timeEntriesToUpsert = new list<FPSA_Resource_TimeLines__c>();
//             set<Id> projIDs = new set<Id>();
//             FPSA_Resource_TimeLines__c timeEntryInst;
//             set<Id> projOnAllocation = new set<Id>();
//             set<Id> resourceOnAllocation = new set<Id>();
//             set<String> roleOnAllocation = new set<String>();
//             system.debug('incomingTimeEntries='+incomingTimeEntries);
//             List<ProcessInstance> lstAlreadySubmittedTimeEntries = [SELECT Id, TargetObjectId 
//                                                                         FROM ProcessInstance 
//                                                                         WHERE TargetObjectId IN :incomingTimeEntries
//                                                                         AND Status = 'Pending'];

//             /*if(lstAlreadySubmittedTimeEntries.size() > 0) {
//                 return 'Submission Error';
//             }else {*/
//                 for(FPSA_Resource_TimeLines__c timeEntry : incomingTimeEntries){
//                     //Below condition collects Proj Id to find Project Manager of the new Time Entries to assign as Approver
//                     projIDs.add((ID)timeEntry.FPSA_Project__c);
//                     if(timeEntry.FPSA_Assignment__c == null){
                        
//                         //Below condition is to collect all the Project,resource and role of timeentry that is directly submitted from Timesheet 
//                         if(timeEntry.FPSA_BillRate__c == null && timeEntry.FPSA_Role__c != null){
//                             projOnAllocation.add(timeEntry.FPSA_Project__c);
//                             resourceOnAllocation.add(timeEntry.FPSA_Resource__c);
//                             roleOnAllocation.add(timeEntry.FPSA_Role__c);
//                         }
//                     }
//                 }

//                 //Below query finds the Manager for Approver
//                 map<id,MPM4_BASE__Milestone1_Project__c> projectIdtoManagerId = new map<id,MPM4_BASE__Milestone1_Project__c>([SELECT OwnerId 
//                                                                                                                                 FROM MPM4_BASE__Milestone1_Project__c 
//                                                                                                                                 WHERE Id IN :projIDs]);
            
//                 //Below query fetches the latest allocation of the resource to get its Bill Rate
//                 Map<String, FPSA_Project_Allocation__c> keyIdentifierToProjectAllocation = new map<String, FPSA_Project_Allocation__c>();

//                 if(!projOnAllocation.isEmpty()) {
//                     for(FPSA_Project_Allocation__c prjAllocation : [SELECT Id, FPSA_Resource__c,FPSA_Project__c,FPSA_Role__c,FPSA_Bill_Rate__c, 
//                                                                         FPSA_Project__r.FPSA_Allow_Timecards_Without_Assignment__c, 
//                                                                         FPSA_Assignment_Number__c, FPSA_Project_Start_Date__c,
//                                                                         FPSA_Project__r.FPSA_Project_ID__c, FPSA_Project__r.FPSA_Start_Date__c
//                                                                         FROM FPSA_Project_Allocation__c 
//                                                                         WHERE FPSA_Project__c IN :projOnAllocation 
//                                                                         AND FPSA_Resource__c IN :resourceOnAllocation 
//                                                                         AND FPSA_Role__c IN :roleOnAllocation 
//                                                                         ORDER BY CreatedDate DESC]) {
//                         String keyIdentifier = prjAllocation.FPSA_Project__c + '+' + prjAllocation.FPSA_Resource__c + '+' + prjAllocation.FPSA_Role__c;
//                         if(!keyIdentifierToProjectAllocation.containskey(keyIdentifier)) {
//                             keyIdentifierToProjectAllocation.put(keyIdentifier, prjAllocation);
//                         }
//                     }
//                 }
//                 system.debug('===keyIdentifierToProjectAllocation==' + keyIdentifierToProjectAllocation);
//                 //Below loop executes on all the Time Entry records present on the page
//                 for(FPSA_Resource_TimeLines__c timeEntry : incomingTimeEntries){
//                     //Exclude all the submitted and approved timesheets, they are locked for editing
//                     //if(timeEntry.FPSA_Status__c != 'Submitted' && timeEntry.FPSA_Status__c != 'Approved'){
//                         timeEntryInst = new FPSA_Resource_TimeLines__c();
//                         timeEntryInst = timeEntry;
//                         timeEntryInst.FPSA_Project__c = (ID)timeEntry.FPSA_Project__c;//set Project Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         timeEntryInst.FPSA_Resource__c = (ID)timeEntry.FPSA_Resource__c;//Set Resource Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         timeEntryInst.OwnerId = projectIdtoManagerId.get((ID)timeEntry.FPSA_Project__c).OwnerId;//Set Status to be updated
//                     	if(buttonstatus == 'submitButton'){
//                         	timeEntryInst.FPSA_Status__c = 'Submitted';
//                         }else if(buttonstatus == 'saveButton'){
//                             timeEntryInst.FPSA_Status__c = 'Saved';
//                         }
                    	
                        
//                     	if(timeEntryInst.FPSA_Assignment__c == null){ //If no previous allocation is present
//                             timeEntryInst.FPSA_Week_Start_Date__c = weekStartDate;   //Set the Week Start Date                
//                             timeEntryInst.FPSA_Approver__c = projectIdtoManagerId.get((ID)timeEntry.FPSA_Project__c).OwnerId;//Set Approver Id
							
//                             String keyIdentifier = timeEntryInst.FPSA_Project__c + '+' + timeEntryInst.FPSA_Resource__c + '+' + timeEntryInst.FPSA_Role__c;
//                             Boolean containsKeyIdentifier = keyIdentifierToProjectAllocation.containsKey(keyIdentifier);

//                             if(containsKeyIdentifier) {
//                                 FPSA_Project_Allocation__c projectAllocation = keyIdentifierToProjectAllocation.get(keyIdentifier);
//                                 //Boolean isAssignmentRequired = !projectAllocation.FPSA_Project__r.FPSA_Allow_Timecards_Without_Assignment__c;
//                                 //timeEntryInst.FPSA_Assignment__c = isAssignmentRequired ?  projectAllocation.Id : null;
//                                 timeEntryInst.FPSA_Assignment__c = projectAllocation.Id;

//                                 //Populate unique key on Allocation_Week field
//                                 if(timeEntry.FPSA_Resource_allocation_week__c == NULL)
//                                     timeEntryInst.FPSA_Resource_allocation_week__c = getAllocationWeekValue(weekStartDate, projectAllocation); 

//                                 if(timeEntryInst.FPSA_BillRate__c == null && timeEntryInst.FPSA_Role__c != null){
//                                     timeEntryInst.FPSA_BillRate__c = keyIdentifierToProjectAllocation.get(keyIdentifier).FPSA_Bill_Rate__c;
//                                 }
                                                             
//                             }
//                         }else{
//                             timeEntryInst.FPSA_Assignment__c = (ID)timeEntry.FPSA_Assignment__c;//Set Assignment Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         }
                    	
//                         timeEntriesToUpsert.add(timeEntryInst);//Add the time Entries to be upserted
//                     	system.debug('timeEntriesToUpsert--'+timeEntriesToUpsert);
//                     //}        
//                 }
//             		system.debug('buttonstatus=======in Submit========='+buttonstatus);
//                 	Database.upsert (timeEntriesToUpsert, true);//Upsert the Time Entries
//             	   	return 'Success';
//             //}
//         }catch(Exception ex){
//             //throw new AuraHandledException(ex.getMessage());
//             system.debug(ex.getMessage() + ex.getStackTraceString());
//             return + ex.getMessage() + ex.getStackTraceString();
//         }
//     }
    
//     @AuraEnabled
//     public static String SubmitTimeSheet(String timeEntries, Date weekStartDate, string buttonstatus) {
//         try{
            
//             List <FPSA_Resource_TimeLines__c> incomingTimeEntries = (List<FPSA_Resource_TimeLines__c>) System.JSON.deserialize(timeEntries, List<FPSA_Resource_TimeLines__c>.Class);
//             list<FPSA_Resource_TimeLines__c> timeEntriesToUpsert = new list<FPSA_Resource_TimeLines__c>();
//             set<Id> projIDs = new set<Id>();
//             FPSA_Resource_TimeLines__c timeEntryInst;
//             set<Id> projOnAllocation = new set<Id>();
//             set<Id> resourceOnAllocation = new set<Id>();
//             set<String> roleOnAllocation = new set<String>();
//             system.debug('incomingTimeEntries='+incomingTimeEntries);
//             List<ProcessInstance> lstAlreadySubmittedTimeEntries = [SELECT Id, TargetObjectId 
//                                                                         FROM ProcessInstance 
//                                                                         WHERE TargetObjectId IN :incomingTimeEntries
//                                                                         AND Status = 'Pending'];

//             /*if(lstAlreadySubmittedTimeEntries.size() > 0) {
//                 return 'Submission Error';
//             }else {*/
//                 for(FPSA_Resource_TimeLines__c timeEntry : incomingTimeEntries){
//                     //Below condition collects Proj Id to find Project Manager of the new Time Entries to assign as Approver
//                     projIDs.add((ID)timeEntry.FPSA_Project__c);
//                     if(timeEntry.FPSA_Assignment__c == null){
                        
//                         //Below condition is to collect all the Project,resource and role of timeentry that is directly submitted from Timesheet 
//                         if(timeEntry.FPSA_BillRate__c == null && timeEntry.FPSA_Role__c != null){
//                             projOnAllocation.add(timeEntry.FPSA_Project__c);
//                             resourceOnAllocation.add(timeEntry.FPSA_Resource__c);
//                             roleOnAllocation.add(timeEntry.FPSA_Role__c);
//                         }
//                     }
//                 }

//                 //Below query finds the Manager for Approver
//                 map<id,MPM4_BASE__Milestone1_Project__c> projectIdtoManagerId = new map<id,MPM4_BASE__Milestone1_Project__c>([SELECT OwnerId 
//                                                                                                                                 FROM MPM4_BASE__Milestone1_Project__c 
//                                                                                                                                 WHERE Id IN :projIDs]);
            
//                 //Below query fetches the latest allocation of the resource to get its Bill Rate
//                 Map<String, FPSA_Project_Allocation__c> keyIdentifierToProjectAllocation = new map<String, FPSA_Project_Allocation__c>();

//                 if(!projOnAllocation.isEmpty()) {
//                     for(FPSA_Project_Allocation__c prjAllocation : [SELECT Id, FPSA_Resource__c,FPSA_Project__c,FPSA_Role__c,FPSA_Bill_Rate__c, 
//                                                                         FPSA_Project__r.FPSA_Allow_Timecards_Without_Assignment__c, 
//                                                                         FPSA_Assignment_Number__c, FPSA_Project_Start_Date__c,
//                                                                         FPSA_Project__r.FPSA_Project_ID__c, FPSA_Project__r.FPSA_Start_Date__c
//                                                                         FROM FPSA_Project_Allocation__c 
//                                                                         WHERE FPSA_Project__c IN :projOnAllocation 
//                                                                         AND FPSA_Resource__c IN :resourceOnAllocation 
//                                                                         AND FPSA_Role__c IN :roleOnAllocation 
//                                                                         ORDER BY CreatedDate DESC]) {
//                         String keyIdentifier = prjAllocation.FPSA_Project__c + '+' + prjAllocation.FPSA_Resource__c + '+' + prjAllocation.FPSA_Role__c;
//                         if(!keyIdentifierToProjectAllocation.containskey(keyIdentifier)) {
//                             keyIdentifierToProjectAllocation.put(keyIdentifier, prjAllocation);
//                         }
//                     }
//                 }
//                 system.debug('===keyIdentifierToProjectAllocation==' + keyIdentifierToProjectAllocation);
//                 //Below loop executes on all the Time Entry records present on the page
//                 for(FPSA_Resource_TimeLines__c timeEntry : incomingTimeEntries){
//                     //Exclude all the submitted and approved timesheets, they are locked for editing
//                     //if(timeEntry.FPSA_Status__c != 'Submitted' && timeEntry.FPSA_Status__c != 'Approved'){
//                         timeEntryInst = new FPSA_Resource_TimeLines__c();
//                         timeEntryInst = timeEntry;
//                         timeEntryInst.FPSA_Project__c = (ID)timeEntry.FPSA_Project__c;//set Project Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         timeEntryInst.FPSA_Resource__c = (ID)timeEntry.FPSA_Resource__c;//Set Resource Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         timeEntryInst.OwnerId = projectIdtoManagerId.get((ID)timeEntry.FPSA_Project__c).OwnerId;//Set Status to be updated
//                     	timeEntryInst.FPSA_Status__c = 'Submitted';
                        
                    	
//                         if(timeEntryInst.FPSA_Assignment__c == null){ //If no previous allocation is present
//                             timeEntryInst.FPSA_Week_Start_Date__c = weekStartDate;   //Set the Week Start Date                
//                             timeEntryInst.FPSA_Approver__c = projectIdtoManagerId.get((ID)timeEntry.FPSA_Project__c).OwnerId;//Set Approver Id
							
//                             String keyIdentifier = timeEntryInst.FPSA_Project__c + '+' + timeEntryInst.FPSA_Resource__c + '+' + timeEntryInst.FPSA_Role__c;
//                             Boolean containsKeyIdentifier = keyIdentifierToProjectAllocation.containsKey(keyIdentifier);

//                             if(containsKeyIdentifier) {
//                                 FPSA_Project_Allocation__c projectAllocation = keyIdentifierToProjectAllocation.get(keyIdentifier);
//                                 //Boolean isAssignmentRequired = !projectAllocation.FPSA_Project__r.FPSA_Allow_Timecards_Without_Assignment__c;
//                                 //timeEntryInst.FPSA_Assignment__c = isAssignmentRequired ?  projectAllocation.Id : null;
//                                 timeEntryInst.FPSA_Assignment__c = projectAllocation.Id;

//                                 //Populate unique key on Allocation_Week field
//                                 if(timeEntry.FPSA_Resource_allocation_week__c == NULL)
//                                     timeEntryInst.FPSA_Resource_allocation_week__c = getAllocationWeekValue(weekStartDate, projectAllocation); 

//                                 if(timeEntryInst.FPSA_BillRate__c == null && timeEntryInst.FPSA_Role__c != null){
//                                     timeEntryInst.FPSA_BillRate__c = keyIdentifierToProjectAllocation.get(keyIdentifier).FPSA_Bill_Rate__c;
//                                 }
                                
                                                        
//                             }
//                         }else{
//                             timeEntryInst.FPSA_Assignment__c = (ID)timeEntry.FPSA_Assignment__c;//Set Assignment Id, Ids are set explicitly as JSON.stringify had converted them to String
//                         }
                    	
//                         timeEntriesToUpsert.add(timeEntryInst);//Add the time Entries to be upserted
//                     	system.debug('timeEntriesToUpsert--'+timeEntriesToUpsert);
//                     //}        
//                 }
//             	//if(result != 'Error' && buttonstatus == 'saveAndSubmitButton'){
//             		system.debug('buttonstatus=======in Save====================='+buttonstatus);
//                 	Database.upsert (timeEntriesToUpsert, true);//Upsert the Time Entries
//             	//}
//             	return 'Success';
//             //}
//         }catch(Exception ex){
//             //throw new AuraHandledException(ex.getMessage());
//             system.debug(ex.getMessage() + ex.getStackTraceString());
//             return + ex.getMessage() + ex.getStackTraceString();
//         }
//     }
    
//     private static String getAllocationWeekValue(Date weekStartDate, FPSA_Project_Allocation__c prjAllocation) {
//         String allocationWeekKey = prjAllocation.FPSA_Project__r.FPSA_Project_ID__c + ':' + prjAllocation.FPSA_Assignment_Number__c + ':W';
//         Integer weekNumber = (prjAllocation.FPSA_Project__r.FPSA_Start_Date__c.toStartOfWeek().daysBetween(weekStartDate))/7;
//         allocationWeekKey += weekNumber+1;
//         system.debug('===allocationWeekKey===' + allocationWeekKey);
//         return allocationWeekKey;
//     }

//     //Below method is to delete TimeEntry record
//     @AuraEnabled
//     public static boolean deleteTimeEntry(String timeEntryId){ 
//         try{
//             //Delete only the Saved TimeEntries
//             list<FPSA_Resource_TimeLines__c> timeEntry = new list<FPSA_Resource_TimeLines__c>([Select id from FPSA_Resource_TimeLines__c where Id = :(ID)timeEntryId AND FPSA_Status__c = 'Saved']);
//             if(!timeEntry.isEmpty()){
//                 Database.delete(timeEntry,false);
//                 return true;
//             }else{
//                 return false;
//             }
//             }catch(Exception ex){
//                 return false;
//             }        
//     }

//     //Below method is to get TimeEntry record
//     @AuraEnabled
//     public static WrapperForTasks getHrsFromTasks(String resourceId, List<Id> milestoneIds, String weekStartString){
//         system.debug('milestoneIds'+milestoneIds);
//         Map<String, Decimal> mapWeeklyHours;
//         Map<Id, Map<String, Decimal>>  mapMilestoneIdToWeeklyHours = new Map<Id, Map<String, Decimal>>();
//         Map<Id, Map<String, String>> mapMilestoneIdToNotes = new Map<Id, Map<String, String>>();
//         WrapperForTasks wrapperForTasksInst = new WrapperForTasks();

//         Date weekStart = Date.valueof(weekStartString);
//         Date weekEnd = weekStart.addDays(6); 
//         system.debug(weekStart + '===start date of week==' + weekEnd);
//         System.debug('*************resourceId**********' + resourceId);
//         //for getting Aggregated Daily hours on each project level
//         try{
//             for(Log_Table__c logTable : [SELECT ResourceName__c, Date__c, Name, Task__r.name, Time_Spent__c,
//                                                 Task__r.MPM4_BASE__Project_Milestone__c, Work_Description__c
//                                             FROM Log_Table__c
//                                             WHERE Date__c >= :weekStart
//                                             AND Date__c <= :weekEnd
//                                             AND Resource__c = :resourceId
//                                             AND Task__c != null
//                                             order by Task__r.MPM4_BASE__Project_Milestone__c, Date__c]) {
//                 if(!mapMilestoneIdToWeeklyHours.containsKey(logTable.Task__r.MPM4_BASE__Project_Milestone__c))
//                     mapMilestoneIdToWeeklyHours.put(logTable.Task__r.MPM4_BASE__Project_Milestone__c, new Map<String, Decimal>());
                
//                 Datetime dt = DateTime.newInstance(logTable.Date__c, Time.newInstance(0, 0, 0, 0));
//                 String dayOfWeek = dt.format('EEEE');
//                 if(!mapMilestoneIdToWeeklyHours.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).containsKey(dayOfWeek))
//                     mapMilestoneIdToWeeklyHours.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).put(dayOfWeek, 0);
                
//                 Decimal hoursSpent = (logTable.Time_Spent__c != null ? logTable.Time_Spent__c : 0)
//                                          + mapMilestoneIdToWeeklyHours.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).get(dayOfWeek);
//                 mapMilestoneIdToWeeklyHours.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).put(dayOfWeek, hoursSpent);
                
//                 //Preparing a map of weekly notes
//                 if(!mapMilestoneIdToNotes.containsKey(logTable.Task__r.MPM4_BASE__Project_Milestone__c))
//                     mapMilestoneIdToNotes.put(logTable.Task__r.MPM4_BASE__Project_Milestone__c, new Map<String, String>());
                
//                 if(!mapMilestoneIdToNotes.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).containsKey(dayOfWeek))
//                     mapMilestoneIdToNotes.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).put(dayOfWeek, 'o ' + dayOfWeek);

//                 String dayNotes =  mapMilestoneIdToNotes.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).get(dayOfWeek);
//                 dayNotes +='\n • '+ logTable.Task__r.name + ': ' + (logTable.Time_Spent__c != null ? logTable.Time_Spent__c : 0) + ' hrs';
//                 mapMilestoneIdToNotes.get(logTable.Task__r.MPM4_BASE__Project_Milestone__c).put(dayOfWeek, dayNotes);
//             }
            
//             //-------------------------------------------------
//             if(!mapMilestoneIdToWeeklyHours.isEmpty()){
//                 Set<Id> setProjectIdsToAllow = new Set<Id>();
//                 for(MPM4_BASE__Milestone1_Milestone__c milestone : [SELECT Id, MPM4_BASE__Project__c
//                                                                         FROM MPM4_BASE__Milestone1_Milestone__c
//                                                                         WHERE Id IN :milestoneIds
//                                                                     ]) {
//                     if(!setProjectIdsToAllow.contains(milestone.MPM4_BASE__Project__c))
//                         setProjectIdsToAllow.add(milestone.MPM4_BASE__Project__c);
//                 }

//                 Map<Id, MPM4_BASE__Milestone1_Milestone__c> mapMilestones = new Map<Id, MPM4_BASE__Milestone1_Milestone__c>();
//                 for(MPM4_BASE__Milestone1_Milestone__c  milestone : [SELECT Id, Name, MPM4_BASE__Project__c, MPM4_BASE__Project__r.Name, MPM4_BASE__Project__r.FPSA_Allow_Timecards_Without_Assignment__c,
//                                                                             MPM4_BASE__Project__r.Weekly_Summary_Required__c,MPM4_BASE__Project__r.FPSA_Daily_Timecard_Notes_Required__c
//                                                                         FROM MPM4_BASE__Milestone1_Milestone__c
//                                                                         WHERE Id IN :mapMilestoneIdToWeeklyHours.keySet()
//                                                                         AND Id Not IN :milestoneIds 
//                                                                         AND MPM4_BASE__Project__r.FPSA_Daily_Timecard_Notes_Required__c = false
//                                                                         ]) {
//                     if(setProjectIdsToAllow.contains(milestone.MPM4_BASE__Project__c) 
//                         || (!setProjectIdsToAllow.contains(milestone.MPM4_BASE__Project__c) && milestone.MPM4_BASE__Project__r.FPSA_Allow_Timecards_Without_Assignment__c) ) {
                        
//                         if(!mapMilestones.containsKey(milestone.Id)) {
//                             mapMilestones.put(milestone.Id, milestone);
//                         }   
//                     }                                      
//                 }
//                 //Summarizing hours at timeline entry level
//                 for(Id milestoneId : mapMilestoneIdToWeeklyHours.keySet()) {
//                     Decimal totalWeeklyHours = 0;
//                     for(Decimal dayHoursSpent : mapMilestoneIdToWeeklyHours.get(milestoneId).values()) {
//                         totalWeeklyHours += dayHoursSpent;
//                     }
//                     mapMilestoneIdToWeeklyHours.get(milestoneId).put('Total', totalWeeklyHours);
//                 }
//                 wrapperForTasksInst.mapMilestoneIdToWeeklyHours = mapMilestoneIdToWeeklyHours;
//                 wrapperForTasksInst.mapMilestoneIdToNotes = mapMilestoneIdToNotes;
//                 wrapperForTasksInst.mapMilestones = mapMilestones;
//                 System.debug('*************wrapperForTasksInst**********' + wrapperForTasksInst);  
//                 return wrapperForTasksInst;
//             }else{
//                 return wrapperForTasksInst;
//             }
//         }catch(Exception ex){
//             return wrapperForTasksInst;
//         }        
//     }

//     @AuraEnabled
//     Public static Map<String, String> getRolesOfTheUser(Id resourceId, Id projectId){
//         Map<String, String> userRoleMap = new Map<String, String>();
//         system.debug(resourceId);
//         for(FPSA_Project_Allocation__c eachProjectAllocation : [SELECT Id, Name, FPSA_Role__c, FPSA_Resource__c FROM FPSA_Project_Allocation__c WHERE FPSA_Resource__c =: resourceId AND FPSA_Project__c =: projectId]){
//             userRoleMap.put(eachProjectAllocation.FPSA_Role__c, eachProjectAllocation.FPSA_Role__c);
//         }
//         system.debug('userRoleMap=='+userRoleMap);
//         return userRoleMap;
//     }
    
//     @AuraEnabled
//     Public static Map<string, string> getMilestoneForProject(Id projectId){
//         Map<String, String> userMilestoneMap = new Map<String, String>();
    
//         system.debug('projectId'+projectId);
//         for(MPM4_BASE__Milestone1_Milestone__c objMilestone : [Select Id, Name, MPM4_BASE__Project__r.id, MPM4_BASE__Project__r.Name from MPM4_BASE__Milestone1_Milestone__c where MPM4_BASE__Project__r.id=:projectId]){
//             userMilestoneMap.put(objMilestone.Id, objMilestone.Name);
            
//         }
//         system.debug('userMilestoneMap=='+userMilestoneMap);
//         return userMilestoneMap;
//     }

//     //Wrapper response to be displayed on the TimeEntry page
//     public class WrapperForTasks{
//         @AuraEnabled
//         public Map<Id, Map<String, Decimal>>  mapMilestoneIdToWeeklyHours{get;set;}
//         @AuraEnabled
//         public Map<Id, Map<String, String>> mapMilestoneIdToNotes {get;set;} 
//         @AuraEnabled
//         public Map<Id, MPM4_BASE__Milestone1_Milestone__c> mapMilestones {get;set;} 
//     }
    
//     //Wrapper response to be displayed on the TimeEntry page
//     public class WrapperResponse{
//         @AuraEnabled
//         public String resourceName {get;set;}//Has the resource name
//         @AuraEnabled
//         public Id resourceId {get;set;}//Has the resource Id
//         @AuraEnabled
//         public Boolean relaxMinHoursCap {get;set;}//Has the resource Id
//         /* @AuraEnabled
//         public list<String> roleValues {get;set;}//Has all the Role values */
//         @AuraEnabled
//         Public Map<String, String> roleValues {get; set;}
//         @AuraEnabled
//         public list<MPM4_BASE__Milestone1_Project__c> projRec {get;set;}//Has list of Projects to be displayed
//         @AuraEnabled
//         public list<FPSA_Resource_TimeLines__c> timeEntries {get;set;}//Has all the time Entry records
//         @AuraEnabled
//         public list<String> projIdWithRoleValue {get;set;}//Concatenation of Project Id with Role separated by -
//         @AuraEnabled
//         public list<String> projIdWithMilestoneValue {get;set;}//Concatenation of Project Id with MilestoneId and Name separated by -
//     }
// 	*/
}