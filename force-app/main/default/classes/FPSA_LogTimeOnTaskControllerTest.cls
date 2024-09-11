/*
* Test class for FPSA_LogTimeOnTaskController class
*/
@isTest
public class FPSA_LogTimeOnTaskControllerTest {
    static testMethod void test_resourceAllocation(){
        Account accountRecord = FPSA_TestDataFactory.createAccount();//Create Account 
        User userRecord = new user(id=userinfo.getuserid());//Create User
        MPM4_BASE__Milestone1_Resource__c resourceRecord = FPSA_TestDataFactory.createResource(userRecord.Id);//Create Resource        
        MPM4_BASE__Milestone1_Project__c projectRecord = FPSA_TestDataFactory.createProject(accountRecord.Id,System.today(),30,userRecord.Id);//Create Project         
        MPM4_BASE__Milestone1_Milestone__c MilestoneRecord = FPSA_TestDataFactory.createMilestone(projectRecord.Id, 'Milestone1Test');//Create Milestone         
        
        MPM4_BASE__Milestone1_Task__c taskOne = FPSA_TestDataFactory.createTaskWithMilestone(projectRecord.Id, MilestoneRecord.Id, 2, 'New');
        
        //Call the getLog method
        FPSA_LogTimeOnTaskController.getLog(taskOne.Id);
        
        FPSA_LogTimeOnTaskController.insertLog(2,'Description',system.today(),String.valueof(taskOne.Id));
        FPSA_LogTimeOnTaskController.findLogs('searchKey');
    }
}