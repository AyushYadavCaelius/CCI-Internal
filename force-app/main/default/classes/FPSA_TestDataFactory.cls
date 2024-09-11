@isTest
public class FPSA_TestDataFactory {
    public static Account createAccount() {
        Account acnt = new Account(Name='TestAccount');
        insert acnt;
        return acnt;
    }

    public static Contact createContact(Id accId, String firstName, String lastName, Boolean isInsert) {
        Contact contact = new Contact(FirstName = firstName, LastName = lastName, AccountId=accId);
        if(isInsert)
            insert contact;
        return contact;
    }
        
    public static MPM4_BASE__Milestone1_Project__c createProject(Id acntId, Date startDate, Integer duration, Id projectManagerId) {        
        MPM4_BASE__Milestone1_Project__c proj = new MPM4_BASE__Milestone1_Project__c(Name='test Proj',
                                                                                        FPSA_Start_Date__c = startDate,
                                                                                        FPSA_Duration_days__c = duration,
                                                                                        FPSA_Project_Stage__c = 'Discover',
                                                                                        FPSA_Project_Phase__c = 'Discover'
                                                                                     );
        insert proj;
        return proj;        
    }

    public static MPM4_BASE__Milestone1_Project__c createProject(String projectName, Id acntId, Date startDate, Integer duration, Boolean isInsert) {        
        MPM4_BASE__Milestone1_Project__c proj = new MPM4_BASE__Milestone1_Project__c(Name=projectName,
                                                                                        FPSA_Start_Date__c = startDate,
                                                                                        FPSA_Duration_days__c = duration,
                                                                                        FPSA_Project_Stage__c = 'Discover',
                                                                                        FPSA_Project_Phase__c = 'Discover'
                                                                                     );
        if(isInsert)    
            insert proj;
        return proj;        
    }
    
    public static FPSA_Invoice_Header__c createInvoiceHeader(Id projectId) {        
        FPSA_Invoice_Header__c invoiceHeader = new FPSA_Invoice_Header__c(FPSA_Project__c = projectId);
        insert invoiceHeader;
        return invoiceHeader;        
    }

    public static FPSA_Invoice_Header__c createInvoiceHeader(Id projectId, String type, Boolean isInsert) {     
        FPSA_Invoice_Header__c invoiceHeader = new FPSA_Invoice_Header__c(FPSA_Project__c = projectId);
        invoiceHeader.Type__c = type;

        if(isInsert)
            insert invoiceHeader;
        return invoiceHeader;        
    }
    
    public static MPM4_BASE__Milestone1_Resource__c  createResource(Id userId) {        
        MPM4_BASE__Milestone1_Resource__c resource1 = new MPM4_BASE__Milestone1_Resource__c(Name='Resource 1',
                                                                                           FPSA_Region__c = 'India',
                                                                                           MPM4_BASE__User__c = userId,
                                                                                           FPSA_Practice__c = 'Salesforce',
                                                                                           FPSA_Cost_Rate__c = 100,
                                                                                           FPSA_Default_Cost_Rate__c = 100,                                                                                         
                                                                                           FPSA_Title__c = 'Managing Consultant',                                                                             
                                                                                           FPSA_Default_billing_rate__c = 100,                                                                             
                                                                                           FPSA_Resource_status__c = 'Active',
                                                                                           FPSA_Start_date__c = System.today(),
                                                                                           FPSA_Job_level__c = '1',
                                                                                           FPSA_Resource_Type__c = 'Employee',
                                                                                           FPSA_Utilization_Taget__c = 100,
                                                                                           FPSA_Allow_Project_Allocation__c=true
                                                                                          );
        insert resource1;
        return resource1;        
    }

    public static MPM4_BASE__Milestone1_Resource__c  createResource(Id userId, String resName, Date startDate, Date endDate, Boolean isInsert) {        
        MPM4_BASE__Milestone1_Resource__c resource = new MPM4_BASE__Milestone1_Resource__c();
        resource.Name= resName;
        resource.FPSA_Region__c = 'India';
        resource.MPM4_BASE__User__c = userId;
        resource.FPSA_Practice__c = 'Salesforce';
        resource.FPSA_Cost_Rate__c = 100;
        resource.FPSA_Default_Cost_Rate__c = 100;                                                                                         
        resource.FPSA_Title__c = 'Managing Consultant';                                                                             
        resource.FPSA_Default_billing_rate__c = 100;                                                                          
        resource.FPSA_Resource_status__c = 'Active';
        resource.FPSA_Start_date__c = startDate;
        resource.FPSA_Last_working_date__c = endDate;
        resource.FPSA_Job_level__c = '1';
        resource.FPSA_Resource_Type__c = 'Employee';
        resource.FPSA_Utilization_Taget__c = 100;
        resource.FPSA_Allow_Project_Allocation__c=true;
        
        if(isInsert)
            insert resource;
        return resource;        
    }

    public static User createUser(Id profileId, Boolean isInsert) {
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User user = new User(firstname = 'ABC', 
                        lastName = 'XYZ', 
                        email = uniqueName + '@test' + orgId + '.org', 
                        Username = uniqueName + '@test' + orgId + '.org', 
                        EmailEncodingKey = 'ISO-8859-1', 
                        Alias = uniqueName.substring(18, 23), 
                        TimeZoneSidKey = 'America/Los_Angeles', 
                        LocaleSidKey = 'en_US', 
                        LanguageLocaleKey = 'en_US', 
                        ProfileId = profileId
                        ); 
        if(isInsert)
            insert user;
        return user;
    }

    public static FPSA_Project_Allocation__c createProjectAllocation(Id projectId, Id resourceId){
        
        FPSA_Project_Allocation__c projectAllocation = new FPSA_Project_Allocation__c();
        projectAllocation.Name = 'Test_Project_Allocation';
        projectAllocation.FPSA_Project__c = projectId;
        projectAllocation.FPSA_Resource__c = resourceId;
        
        return projectAllocation;

    }

    public static FPSA_Project_Allocation__c createProjectAllocationWithRole(Id projectId, Id resourceId, String role, String responsibility, Boolean isInsert){
        FPSA_Project_Allocation__c projectAllocation = new FPSA_Project_Allocation__c();
        projectAllocation.Name = 'Test_Project_Allocation';
        projectAllocation.FPSA_Project__c = projectId;
        projectAllocation.FPSA_Resource__c = resourceId;
        projectAllocation.FPSA_Role__c = role;
        projectAllocation.FPSA_Description__c = responsibility;
        if(isInsert)
            insert projectAllocation;
        return projectAllocation;
    }
    

    public static MPM4_BASE__Milestone1_Milestone__c createMilestone(Id projectId, String milestoneName){
       
        MPM4_BASE__Milestone1_Milestone__c milestone = new MPM4_BASE__Milestone1_Milestone__c ();
        milestone.name = milestoneName;
        milestone.MPM4_BASE__Project__c = projectId;
        return milestone;
        
    }

    public static MPM4_BASE__Milestone1_Task__c createTaskWithMilestone(Id projectId, Id milestoneId, Decimal estimatedHours, string stage){
       
        MPM4_BASE__Milestone1_Task__c tsk = new MPM4_BASE__Milestone1_Task__c ();
        tsk.name = 'Task1';
        tsk.MPM4_BASE__Project_Lookup__c = projectId;
        tsk.MPM4_BASE__Project_Milestone__c = milestoneId;
        tsk.MPM4_BASE__Task_Stage__c = stage;
        tsk.MPM4_BASE__Estimated_Hours__c = estimatedHours;
       	tsk.MPM4_BASE__Description__c = 'test_description';
       	tsk.Name = 'test_project';
        return tsk;

    }

    public static MPM4_BASE__Milestone1_Task__c createTaskWithMilestoneAndResource(Id projectId, Id milestoneId, Id resourceId, Decimal estimatedHours, string stage){
        MPM4_BASE__Milestone1_Task__c tsk = new MPM4_BASE__Milestone1_Task__c ();
        tsk.name = 'Task1';
        tsk.MPM4_BASE__Project_Lookup__c = projectId;
        tsk.MPM4_BASE__Project_Milestone__c = milestoneId;
        tsk.MPM4_BASE__Resource__c = resourceId;
        tsk.MPM4_BASE__Task_Stage__c = stage;
        tsk.MPM4_BASE__Estimated_Hours__c = estimatedHours;
        tsk.MPM4_BASE__Description__c = 'test_description';
        tsk.Name = 'test task';
        return tsk;
    }

    public static FPSA_Resource_TimeLines__c createResourceTimeLine(Id projectId, Id milestoneId, Id allocationId, Id resourceId){
       
        FPSA_Resource_TimeLines__c resourceTimeLine = new FPSA_Resource_TimeLines__c();
        resourceTimeline.FPSA_Original_Planned_Hours__c = 28;
        resourceTimeline.FPSA_Project_Planned_hrs__c = 20;
        resourceTimeline.FPSA_Project__c  = projectId;
        resourceTimeline.FPSA_Assignment__c  = allocationId;
        resourceTimeLine.FPSA_Milestone__c = milestoneId;
        resourceTimeline.FPSA_Resource__c = resourceId;
        resourceTimeline.FPSA_Resource_allocation_week__c = 'P113:471:W29';
        resourceTimeline.FPSA_Week_Start_Date__c =  Date.today().toStartofWeek(); 
        resourceTimeline.FPSA_Status__c = 'Approved';
        resourceTimeline.FPSA_Monday_Hours__c = 4;
        resourceTimeline.FPSA_Tuesday_Hours__c = 4;
        resourceTimeline.FPSA_Wednesday_Hours__c = 4;
        resourceTimeline.FPSA_Thursday_Hours__c = 4;
        resourceTimeline.FPSA_Friday_Hours__c = 4;
        return resourceTimeLine;
    
    }

    public static MPM4_BASE__Milestone1_Log__c createIssue(Id projectId, Id resourceId, Boolean isInsert) {
        MPM4_BASE__Milestone1_Log__c issue1 = new MPM4_BASE__Milestone1_Log__c();
        issue1.MPM4_BASE__Subject__c = 'test issue';
        issue1.MPM4_BASE__Project__c = projectId;
        issue1.Resource__c = resourceId;
        issue1.FPSA_Effort_Estimate__c = 4;
        issue1.MPM4_BASE__Detail__c = 'testdescription';
        if(isInsert)
            insert issue1;
        return issue1;
    }

    public static Opportunity createOpportunity(Id accId, Id projId, String oppName, String stageName, Decimal amount, Date closeDate, Boolean isClosed, Boolean isInsert) {
        Opportunity opp = new Opportunity();
        opp.name = oppName;
        opp.Accountid = accId;
        opp.StageName = stageName;
        opp.Amount = amount;
        opp.CloseDate = closeDate;
        if(isClosed) {
            opp.NextStep = 'Test';
            opp.Description = 'test';
            opp.Project_Win_Story__c = 'test';
            opp.Prospect_Role_Summary__c = 'test';
            opp.Pain_Goal_Summary__c = 'test';
            opp.Compelling_Event__c = 'Test';
            opp.Decision_making_process__c  = 'test';
            opp.Main_Competitors__c = 'test';
            opp.Investment_Summary__c = 'test';
            opp.Solution_Fit__c = 'test';
            opp.Competitor_Comparison__c  = 'Test';
            opp.Solution_Details__c = 'test';
            opp.Solution_Response__c = true;
            opp.Agreed_Implementation__c = true;
            opp.Objections__c = 'test';
            opp.Service_Start_Date__c  = system.today();
            opp.Service_End_Date__c = system.today().addDays(10);
            opp.Follow_up_Date__c = system.today().addDays(2);
            opp.Project__c = projId;
            opp.S_W_vendor_contract_Signed__c = 'Yes';
            opp.Contract_for_Partner_Services_Signed__c = true;
            opp.Signed_MSA_NSA_Verified__c = true;
            opp.Signed_SOW_Verified__c = true;
            opp.LeadSource = 'Event';
        }

        if(isInsert)
            insert opp;
        return opp;
    }

}