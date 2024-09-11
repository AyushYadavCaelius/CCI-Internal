@isTest
public class FPSA_TestResourceAllocation {
    static testMethod void test_resourceAllocation(){
        test.starttest();
            Account accountRecord = FPSA_TestDataFactory.createAccount();//Create Account
            User userRecord = new user(id=userinfo.getuserid());//Create User
            MPM4_BASE__Milestone1_Resource__c resourceRecord = FPSA_TestDataFactory.createResource(userRecord.Id);//Create Resource        
            MPM4_BASE__Milestone1_Project__c projectRecord = FPSA_TestDataFactory.createProject(accountRecord.Id,System.today(),30,userRecord.Id);//Create Project  
            Account acct = new Account(Name = 'Test Cls Acct');
            insert acct;   
            Contact conRecord = FPSA_TestDataFactory.createContact(acct.id, 'Test', 'Contact', TRUE);   
            
          //Call the fetchAccount method
          lookUpController.fetchAccount('Res');
          
          //Call the GetRecentRecords method
          lookupfieldController.GetRecentRecords('MPM4_BASE__Milestone1_Resource__c', null, 1);
        
          //Call the SearchRecords method
          lookupfieldController.SearchRecords('MPM4_BASE__Milestone1_Resource__c', null, null, 'Res', null, null, 1, null);  
        
          //Call the GetRecord method
          lookupfieldController.GetRecord('MPM4_BASE__Milestone1_Resource__c',null,(String)resourceRecord.Id);
        
          //Call the findObjectIcon method
          lookupfieldController.findObjectIcon('MPM4_BASE__Milestone1_Resource__c');
        
          //Call the getObjectDetails method
          lookupfieldController.getObjectDetails('MPM4_BASE__Milestone1_Resource__c');
                
            //Create Resource Allocation wrapper
            FPSA_ResourceAllocation.WrapperResponse  wrap = new FPSA_ResourceAllocation.WrapperResponse();
                wrap.weekStarting =  new List<Date>{system.today()};
                wrap.loggedInUserProfile = true;
                wrap.roleValues =new List<String>{'Developer', 'QA'};
                wrap.duration =10;
                wrap.projRec =projectRecord;
                FPSA_ResourceAllocation.OuterWrapper outwrap = new FPSA_ResourceAllocation.OuterWrapper();
                FPSA_ResourceAllocation.InnerWrapper innerwrap = new FPSA_ResourceAllocation.InnerWrapper();
                    innerwrap.key ='FPSA_Week_1_hrs__c';
                    innerwrap.value=40;
                    outwrap.projAlloc = new FPSA_Project_Allocation__c(Resource_Name__c=conRecord.id);
                    outwrap.projAllocationHours= new list<FPSA_ResourceAllocation.InnerWrapper>{innerwrap};        
                wrap.projAllocationRec = new list<FPSA_ResourceAllocation.OuterWrapper>{outwrap};
            
            //Call the saveAllocations method
            FPSA_ResourceAllocation.saveAllocations(wrap);
            
            //Call the getResourceAllocation method
            FPSA_ResourceAllocation.getResourceAllocation(projectRecord.Id);
            
            //Call the deleteAllocations method
            FPSA_ResourceAllocation.deleteAllocations((String)[Select id from FPSA_Project_Allocation__c LIMIT 1][0].Id);

            FPSA_ResourceAllocation.fetchAllocationWrapper(projectRecord.Id);

            FPSA_ResourceAllocation.getResourceAllocation(projectRecord.Id);

            FPSA_ResourceAllocation.getFieldSetMetadata('FPSA_Project_Allocation__c', 'Allocation_Fields');

            FPSA_ResourceAllocation.fetchResourceAllocations(projectRecord.Id, '809090909');
        test.stopTest();
    }
}