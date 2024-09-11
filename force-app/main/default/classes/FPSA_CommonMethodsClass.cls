public without sharing class FPSA_CommonMethodsClass {
     
    //Below method sets values in new Resource TimeLine Entry records req
   /* public static FPSA_Resource_TimeLines__c createResourceTimeLine(FPSA_Project_Allocation__c prjAllocation, Schema.FieldSetMember weekField, Id approverId, Date projectStartDate,String projAutoNumber, Id projMilestone){
        Integer weekNumber = Integer.valueOf(weekField.getLabel().substringAfter('Week ')) - 1; //Fetch the week number
        FPSA_Resource_TimeLines__c timeLine = new FPSA_Resource_TimeLines__c(); //Create TimeLine Instance
        timeLine.FPSA_Assignment__c = prjAllocation.id; //Set Project Allocation Id
        timeLine.FPSA_Milestone__c = projMilestone != null ? projMilestone : null ;//Set the Milestone Id
        timeLine.FPSA_Project__c = prjAllocation.FPSA_Project__c; //Set Project Id
        timeLine.FPSA_BillRate__c = prjAllocation.FPSA_Bill_Rate__c; //Set Project Id
        timeLine.FPSA_Approver__c = approverId != null ? approverId : null;    //Set Approver Id  
        timeLine.OwnerId = approverId != null ? approverId : null;    //Set Owner Id                    
        timeLine.FPSA_Project_Planned_hrs__c = (Decimal)prjAllocation.get(weekField.getFieldPath());//Set Allocated hours
        timeLine.FPSA_Resource__c = prjAllocation.FPSA_Resource__c; //Set Resource
        timeLine.FPSA_Status__c = 'Saved'; //Set default Status
        timeLine.FPSA_Role__c = prjAllocation.FPSA_Role__c; //Set Role
        timeLine.FPSA_Cost_Rate_Amount__c = prjAllocation.FPSA_Bill_Rate__c; //Set Rate
        timeLine.FPSA_Resource_allocation_week__c = projAutoNumber + ':' + prjAllocation.FPSA_Assignment_Number__c + ':W' + (weekNumber+1);//Set the unique key
        timeLine.FPSA_Week_Start_Date__c = projectStartDate.addDays(weekNumber*7).toStartOfWeek();//Set the Week Start Date
        return (timeLine); 
    }*/
    
    //Below method fetches lookup fields from the Project allocation Id to be used in the trigger req
    /*public static map<id,FPSA_Project_Allocation__c> getProjAllocationWithParentFields(set<Id> newProjAllocationIds){
        map<id,FPSA_Project_Allocation__c> projAllocationWithDetails = new map<id,FPSA_Project_Allocation__c>([Select FPSA_Project__c,FPSA_Project__r.FPSA_Project_ID__c,
                                                                        FPSA_Project__r.OwnerId,FPSA_Project__r.FPSA_Start_Date__c,
                                                                        FPSA_Resource__c, FPSA_Resource__r.MPM4_BASE__User__c, FPSA_Resource__r.MPM4_BASE__Contact__c
                                                                        from FPSA_Project_Allocation__c 
                                                                        where Id IN :newProjAllocationIds]);
        return (projAllocationWithDetails);
    }*/
    
    //Method to send email to allocated resource req
   /* public static Messaging.SingleEmailMessage emailNotificationToResource(Id templatedId, Id recipientRecId, Id allocationRecId) {
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templatedId, recipientRecId, allocationRecId);
        email.setTargetObjectId(recipientRecId);
        email.saveAsActivity = false;
        return email;
    }

    //Below method fetches lookup fields from the Project allocation Id to be used in the trigger req
    public static map<id,MPM4_BASE__Milestone1_Project__c> getProjIdsWithMilestones(set<Id> projIds){
        map<id,MPM4_BASE__Milestone1_Project__c> projIdWithMilestones = new map<id,MPM4_BASE__Milestone1_Project__c>([Select Id,(Select id,Name from MPM4_BASE__Project_Milestones__r ORDER BY CreatedDate ASC LIMIT 1) from MPM4_BASE__Milestone1_Project__c where Id IN :projIds]);
        return (projIdWithMilestones);
    }  */  
    
    //Below method returns Role picklist values req
    public static List<string> getPickListValuesIntoList()
    {
        List<string> options = new List<string>();
        Schema.DescribeFieldResult fieldResult = FPSA_Project_Allocation__c.FPSA_Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            options.add( f.getValue());
        }     
        return options;
    }
//req
    /*Public static Map<String, String> getRolesOfTheUser(Id resourceId){
        Map<String, String> userRoleMap = new Map<String, String>();
        system.debug(resourceId);
        for(FPSA_Project_Allocation__c eachProjectAllocation : [SELECT Id, Name, FPSA_Role__c, FPSA_Resource__c FROM FPSA_Project_Allocation__c WHERE FPSA_Resource__c =: resourceId]){
            userRoleMap.put(eachProjectAllocation.FPSA_Role__c, eachProjectAllocation.FPSA_Role__c);
        }
        system.debug(userRoleMap);
        return userRoleMap;
    }
    
    //ShareTimeLine with Resource req
    public static FPSA_Resource_TimeLines__Share insertTimeLineShare (Id timeLineId, Id UserId){
        FPSA_Resource_TimeLines__Share TeShare = new FPSA_Resource_TimeLines__Share();
        TeShare.ParentId = timeLineId;
        TeShare.UserOrGroupId = UserId;
        TeShare.AccessLevel = 'Edit';
        TeShare.RowCause = Schema.FPSA_Resource_TimeLines__Share.RowCause.ShareWithResource__c;
        return TeShare;        
    }
    
    //ShareProject with Resource req
    public static MPM4_BASE__Milestone1_Project__Share insertProjectShare (Id projectId, Id UserId){
        MPM4_BASE__Milestone1_Project__Share projectShare = new MPM4_BASE__Milestone1_Project__Share();
        projectShare.ParentId = projectId;
        projectShare.UserOrGroupId = UserId;
        projectShare.AccessLevel = 'Edit';
        projectShare.RowCause = Schema.MPM4_BASE__Milestone1_Project__Share.RowCause.ShareWithPM__c;
        return projectShare;       
    }
    
    // Req
    public static void updateProjectFinancials(set<Id> projectId){
        map<Id,MPM4_BASE__Milestone1_Project__c> uniqueProjectIdSet = new map<Id,MPM4_BASE__Milestone1_Project__c>();
        map<String,Decimal> externalCost = new map<String,Decimal>();
        map<String,Decimal> internalCost = new map<String,Decimal>();
        List<AggregateResult> AggregateResultList = [Select FPSA_Project__c, FPSA_Resource__r.FPSA_Resource_Type__c resType,Sum(FPSA_Resource_CostRate__c) Costs, Sum(FPSA_Total_Billable_Amount__c) BudgetUsed, Sum(FPSA_Total_Hours__c) TotalHoursIncurred from FPSA_Resource_TimeLines__c where FPSA_Project__c IN :projectId AND FPSA_Status__c ='Approved' GROUP BY FPSA_Project__c, FPSA_Resource__r.FPSA_Resource_Type__c];
        if(AggregateResultList != null && AggregateResultList.size() > 0){ 
            for(AggregateResult aggr:AggregateResultList){            
                MPM4_BASE__Milestone1_Project__c projectInstance = new MPM4_BASE__Milestone1_Project__c(Id = (Id)aggr.get('FPSA_Project__c')); 
                String key = (String)aggr.get('FPSA_Project__c') + (String)aggr.get('resType');
                if((String)aggr.get('resType') == 'Contractor'){
                    if(externalCost.containsKey(key)){
                         Decimal totalexternalCost = externalCost.get(key) + (Decimal)aggr.get('Costs');
                         externalCost.remove(key); 
                         externalCost.put(key,totalexternalCost);
                    }else{
                        externalCost.put(key,(Decimal)aggr.get('Costs'));
                    }
                }else if((String)aggr.get('resType') == 'Employee'){
                    if(internalCost.containsKey(key)){
                         Decimal totalinternalCost = internalCost.get(key) + (Decimal)aggr.get('Costs');
                         internalCost.remove(key); 
                         internalCost.put(key,totalinternalCost);
                    }else{
                        internalCost.put(key,(Decimal)aggr.get('Costs'));
                    }
                }
                projectInstance.FPSA_External_Costs__c = externalCost.containsKey(key) ? (Decimal)externalCost.get(key) : 0;
                projectInstance.FPSA_Internal_Costs__c = internalCost.containsKey(key) ? (Decimal)internalCost.get(key) : 0; 
                projectInstance.FPSA_Budget_Used__c = (Decimal)aggr.get('BudgetUsed'); 
                projectInstance.FPSA_Total_Hours_Incurred__c = (Decimal)aggr.get('TotalHoursIncurred'); 
                if(uniqueProjectIdSet.containsKey((Id)aggr.get('FPSA_Project__c'))){
                    uniqueProjectIdSet.remove((Id)aggr.get('FPSA_Project__c'));
                    uniqueProjectIdSet.put((Id)aggr.get('FPSA_Project__c'),projectInstance);
                }else{
                    uniqueProjectIdSet.put((Id)aggr.get('FPSA_Project__c'),projectInstance);
                }
            }
        }
        Database.update(uniqueProjectIdSet.values(),false);
    }*/
}