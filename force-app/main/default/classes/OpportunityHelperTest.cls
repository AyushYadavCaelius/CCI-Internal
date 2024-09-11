@isTest
public class OpportunityHelperTest {
    @isTest
    static void testPopulateAccountPlanning() {
        // Create test Account
        Account acc = new Account(Name = 'Test Account', Account_Planning__c = 'https://caelius-consulting-inc.quip.com');
        insert acc;

        // Create test Opportunity with null Account Planning
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Pending', CloseDate = System.Today());
        insert opp;

        // Call the method to populate Account Planning
        OpportunityHelper.populateAccountPlanning(new List<Opportunity>{ opp });

        // Retrieve the updated Opportunity
        Opportunity updatedOpp = [SELECT Id, Account_Planning__c FROM Opportunity WHERE Id = :opp.Id];

        // Verify that Account Planning is populated
        System.assertEquals(acc.Account_Planning__c, updatedOpp.Account_Planning__c);
    }

    @isTest
    static void testUpdateAccountPlanning() {
        // Create test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create test Opportunity with Account Planning to update
        Opportunity oppToUpdate = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Pending', CloseDate = System.Today(), Account_Planning__c = 'https://caelius-consulting-inc.quip.com');
        insert oppToUpdate;

        // Prepare a new Opportunity with updated Account Planning
        Opportunity newOpp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Pending', CloseDate = System.Today(), Account_Planning__c = 'https://caelius-consulting-inc.quip.com');

        // Call the method to update Account Planning
        OpportunityHelper.updateAccountPlanning(new List<Opportunity>{ newOpp } ,null);
    }
}