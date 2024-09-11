@isTest
public class OpportunityTypeUpdateBatchTest {
    
    @testSetup
    static void setup() {
        // Create test Accounts
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        Account acc3 = new Account(Name = 'Test Account 3');
        List<Account> accountList = new List<Account> {acc1, acc2, acc3};
        insert accountList;
    
        
        // Create test Opportunities
        Opportunity opp1 = new Opportunity(Name = 'Opportunity 1', AccountId = accountList[0].Id, StageName = 'Closed Won', CloseDate = Date.today().addDays(30), Type = 'Existing Business (2nd Engagement)');
        Opportunity opp2 = new Opportunity(Name = 'Opportunity 2', AccountId = accountList[0].Id, StageName = 'Closed Won', CloseDate = Date.today().addDays(30), Type = 'Existing Business (2+ Engagements)');
        Opportunity opp3 = new Opportunity(Name = 'Opportunity 3', AccountId = accountList[1].Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Type = 'Existing Business (1+ Year Engagement)');
        Opportunity opp4 = new Opportunity(Name = 'Opportunity 4', AccountId = accountList[1].Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(60), Type = 'New Business');
        Opportunity opp5 = new Opportunity(Name = 'Opportunity 5', AccountId = accountList[1].Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(60), Type = 'New Business');
        opportunity opp6 = new Opportunity(Name = 'Opportunity 6', AccountId = accountList[1].Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(90), Type = 'New Business');
        List<Opportunity> opportunityList = new List<Opportunity> {opp1, opp2, opp3, opp4,opp5,opp6};
        insert opportunityList;
        
        

    }
    
    @isTest
    static void testSingleOpportunityClosedWon() {
        // Start test
        Test.startTest();
        opportunity opp5 = [Select ID from opportunity where name = 'Opportunity 5' limit 1];
        opp5.StageName = 'Closed Won';
        update opp5;
        
        // Execute the batch
        OpportunityTypeUpdateBatch testbatch = new OpportunityTypeUpdateBatch();
        Database.executeBatch(testbatch);
        
        // End test
        Test.stopTest();
        
        // Verify the results
       /* Opportunity opp1 = [SELECT Type FROM Opportunity WHERE Name = 'Opportunity 1'];
        Opportunity opp2 = [SELECT Type FROM Opportunity WHERE Name = 'Opportunity 2'];
        Opportunity opp3 = [SELECT Type FROM Opportunity WHERE Name = 'Opportunity 3'];
        
        System.assertEquals('Existing Business (2nd Engagement)', opp1.Type, 'Opportunity 1 Type was not updated correctly.');
        System.assertEquals('Existing Business (2+ Engagements)', opp2.Type, 'Opportunity 2 Type was not updated correctly.');
        System.assertEquals('Existing Business (1+ Year Engagement)', opp3.Type, 'Opportunity 3 Type was not updated correctly.');*/
        
    }
    @isTest
    static void testMultipleClosedWon(){
        
         Test.startTest();
        List<Opportunity> oppList = [Select ID from opportunity where name = 'Opportunity 5' OR name = 'Opportunity 6'];
        oppList[0].stageName = 'Closed Won';
        oppList[1].stagename = 'Closed won';
        update oppList;
        
        // Execute the batch
        OpportunityTypeUpdateBatch testbatch = new OpportunityTypeUpdateBatch();
        Database.executeBatch(testbatch);
        
        // End test
        Test.stopTest();
    }
}