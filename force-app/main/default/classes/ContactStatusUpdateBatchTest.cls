@isTest
public class ContactStatusUpdateBatchTest {

    @testSetup
    
    static void setupTestData() {
        // Create test Contacts
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            Contact con = new Contact(
                LastName = 'TestContact' + i
            );
            contacts.add(con);
        }
        insert contacts;

        // Create test Opportunities
        List<Opportunity> opps = new List<Opportunity>();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Initial_Opp_Won__c = null;
        insert acc;
        for (Integer i = 0; i < 3; i++) {
            Opportunity opp = new Opportunity(
                Name = 'TestOpportunity' + i,
                StageName = (i == 0) ? 'Prospecting' : (i == 1) ? 'Closed Won' : 'Closed Lost',
                CloseDate = Date.today().addDays(30),
                AccountId = acc.Id
            );
            opps.add(opp);
        }
        insert opps;

        // Create Opportunity_Salesforce_Contact__c records
        List<Opportunity_Salesforce_Contact__c> oppContacts = new List<Opportunity_Salesforce_Contact__c>();
        for (Integer i = 0; i < 3; i++) {
            Opportunity_Salesforce_Contact__c osc = new Opportunity_Salesforce_Contact__c(
                Salesforce_Contact__c = contacts[i].Id,
                Opportunity__c = opps[Math.MOD(i,2)].Id // Associate with the first two opportunities
            );
            oppContacts.add(osc);
        }
        insert oppContacts;
    }

    @isTest
    static void testContactStatusUpdateBatch() {
        // Start the test
        Test.startTest();

        // Execute the batch
        
        ContactStatusUpdateBatch batch = new ContactStatusUpdateBatch();
        Database.executeBatch(batch);

        // End the test
        Test.stopTest();

        // Verify the results
        List<Contact> updatedContacts = [SELECT Id, Salesforce_Relationship_Level__c, LastName FROM Contact];
        for (Contact c : updatedContacts) {
            if (c.LastName == 'TestContact0') {
                System.assertEquals('First Active Pursuit', c.Salesforce_Relationship_Level__c, 'Status should be First Active Pursuit');
            } else if (c.LastName == 'TestContact1') {
                System.assertEquals('Closed Business', c.Salesforce_Relationship_Level__c, 'Status should be Closed Business');
            } else if (c.LastName == 'TestContact2') {
                System.assertEquals('First Active Pursuit', c.Salesforce_Relationship_Level__c, 'Status should be Actively Referring');
            }
        }
    }
}