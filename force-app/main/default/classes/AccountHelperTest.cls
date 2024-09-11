@isTest
private class AccountHelperTest {
    
    @isTest
    static void testUpdateOpportunityAccountPlanning() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account', Account_Planning__c = 'https://caelius-consulting-inc.quip.com');
        insert testAccount;

        // Create a test opportunity associated with the test account
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', AccountId = testAccount.Id, StageName = 'Pending', CloseDate = System.Today(), Account_Planning__c = 'https://caelius-consulting-inc.quip.com');
        insert testOpportunity;
        
        // Update the account planning
        testAccount.Account_Planning__c = 'https://caelius-consulting-inc';
        update testAccount;
        
        Test.startTest();
        // Call the method to test
        AccountHelper.updateOpportunityAccountPlanning(new List<Account>{testAccount});
        Test.stopTest();
        
        // Verify that the opportunity associated with the updated account has been updated
        Opportunity updatedOpp = [SELECT Id, Account_Planning__c FROM Opportunity WHERE AccountId = :testAccount.Id LIMIT 1];
        System.assertEquals('https://caelius-consulting-inc', updatedOpp.Account_Planning__c);
    }
}