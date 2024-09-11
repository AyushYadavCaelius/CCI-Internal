@isTest
private class FPSA_CTRL_TimecardPendingApprovalsTest {

    private static final String TIMECARD_STATUS_SUBMITTED = Label.FPSA_Timecard_Status_Submitted;
/*    
    @TestSetup
    private static void setupTestData() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User testUser = new User(Alias = 'standt', Email = 'testUser9118@xyz.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', 
                                 LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = adminProfile.Id, 
                                 TimeZoneSidKey = 'America/Los_Angeles', UserName = 'testUser9118@xyz.com');
        insert testUser;

        Account accountRecord = FPSA_TestDataFactory.createAccount();
        User userRecord = new user(Id = UserInfo.getUserId());
        MPM4_BASE__Milestone1_Resource__c resourceRecord = FPSA_TestDataFactory.createResource(testUser.Id);
        MPM4_BASE__Milestone1_Project__c projectRecord = FPSA_TestDataFactory.createProject(accountRecord.Id, System.today(), 30, testUser.Id);

        FPSA_ResourceAllocation.InnerWrapper innerwrap = new FPSA_ResourceAllocation.InnerWrapper();
        innerwrap.key ='FPSA_Week_1_hrs__c';
        innerwrap.value = 40;
        
        FPSA_ResourceAllocation.InnerWrapper innerwrap2 = new FPSA_ResourceAllocation.InnerWrapper();
        innerwrap2.key ='FPSA_Week_2_hrs__c';
        innerwrap2.value = 40;

        FPSA_ResourceAllocation.OuterWrapper outwrap = new FPSA_ResourceAllocation.OuterWrapper();
        outwrap.projAlloc = new FPSA_Project_Allocation__c(FPSA_Resource__c = resourceRecord.Id);
        outwrap.projAllocationHours= new List<FPSA_ResourceAllocation.InnerWrapper>{innerwrap, innerwrap2};

        FPSA_ResourceAllocation.WrapperResponse  wrap = new FPSA_ResourceAllocation.WrapperResponse();
        wrap.weekStarting =  new List<Date>{system.today()};           
        wrap.loggedInUserProfile =true;
        wrap.roleValues =new List<String>{'Developer', 'QA'};
        wrap.duration = 10;
        wrap.projRec = projectRecord;
        wrap.projAllocationRec = new List<FPSA_ResourceAllocation.OuterWrapper> {outwrap};

        FPSA_ResourceAllocation.saveAllocations(wrap);
        FPSA_ResourceAllocation.getResourceAllocation(projectRecord.Id);

        MPM4_BASE__Milestone1_Project__c projectInst = new MPM4_BASE__Milestone1_Project__c(Id = projectRecord.Id, FPSA_Start_Date__c = System.today().addDays(8));
        Database.update(projectInst,false);
    }
*/
/*
    @isTest
    private static void testGetPendingTimecardApprovalRequests() {
        List<FPSA_Resource_TimeLines__c> timesheets = [SELECT Id, FPSA_Status__c, FPSA_Approver__c FROM FPSA_Resource_TimeLines__c ];
        
        for(FPSA_Resource_TimeLines__c timesheet : timesheets) {
            timesheet.FPSA_Approver__c = UserInfo.getUserId();
            timesheet.FPSA_Status__c = TIMECARD_STATUS_SUBMITTED;
        }

        update timesheets;

        Test.startTest();
        List<FPSA_Resource_TimeLines__c> timecardEntries = FPSA_CTRL_TimecardPendingApprovals.getPendingTimecardApprovalRequests();
        Test.stopTest();

        System.assertEquals(timesheets.size(), timecardEntries.size());
    }

    @isTest (SeeAllData=true)
    private static void testProcessTimecardApprovalRequests() {
        List<FPSA_Resource_TimeLines__c> timesheets = [SELECT Id, FPSA_Status__c, FPSA_Approver__c FROM FPSA_Resource_TimeLines__c];
        List<String> timecardIds = new List<String> {timesheets[0].Id, timesheets[1].Id};

        Test.startTest();
        FPSA_CTRL_TimecardPendingApprovals.processTimecardApprovalRequests(timecardIds, 'Approve');
        Test.stopTest();
    }*/
}