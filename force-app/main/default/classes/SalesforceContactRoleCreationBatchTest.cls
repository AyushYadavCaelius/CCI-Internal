@isTest
public class SalesforceContactRoleCreationBatchTest {
    
    @testSetup
    static void setup() {
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        
        List<Account> accountList = new List<Account> {acc1, acc2};
            insert accountList;
        
        
        Opportunity opp1 = new Opportunity(Name = 'Opportunity 1', AccountId = accountList[0].Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Type = 'New Business');
        Opportunity opp2 = new Opportunity(Name = 'Opportunity 2', AccountId = accountList[0].Id, StageName = 'Prospecting', CloseDate = Date.today().addDays(30), Type = 'New Business');
        
        List<Opportunity> opportunityList = new List<Opportunity> {opp1, opp2 };
            insert opportunityList;
        
        contact con1 = new Contact(LastName = 'Test1', email = 'test1@salesforce.com');
        contact con2 = new Contact(LastName = 'Test2', email = 'test1@salesforce.com');
        
        List<Contact> contactList = new List<Contact> {con1, con2 };
            insert contactList;
        
        opportunityContactRole ocr1 = new opportunityContactRole(ContactId = con1.Id, opportunityId = opp1.Id, role='Solution Consultant');
        opportunityContactRole ocr2 = new opportunityContactRole(ContactId = con2.Id, opportunityId = opp2.Id, role='Solution Consultant');
        
        List<opportunityContactRole> ocrList = new List<opportunityContactRole> {ocr1, ocr2 };
            insert ocrList;
        
        
    }
    
    @istest
    static void testmethod1(){
        SalesforceContactRoleCreationBatch newbatch = new SalesforceContactRoleCreationBatch();
        test.startTest();
        database.executeBatch(newBatch);
        test.stoptest();
    }
}