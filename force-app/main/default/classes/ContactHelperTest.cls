@isTest
public class ContactHelperTest {
	@TestSetup
	static void createTestData() {
    	Account acc = new Account();
    	acc.Name = 'Test Account';
        acc.Stage__c = 'Staged';
        acc.FPSA_Is_Public__c = false;
        insert acc;
        
        Account acc2 = new Account();
    	acc2.Name = 'Test Account 2';
        acc2.Stage__c = 'Staged';
        acc2.FPSA_Is_Public__c = false;
        insert acc2;
        
        List<Contact> testContactsList = new List<Contact>();
        Contact testAlignmentParentCon = new Contact();
        testAlignmentParentCon.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Salesforce').getRecordTypeId();
        testAlignmentParentCon.LastName = 'Test Alignment Individual';
        testAlignmentParentCon.AccountId = acc2.Id;
        insert testAlignmentParentCon;
        
        Contact testAlignmentContact = new Contact();
        testAlignmentContact.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Salesforce').getRecordTypeId();
        testAlignmentContact.LastName = 'Test Alignment Contact';
        testAlignmentContact.AccountId = acc.Id;
        testAlignmentContact.ReportsToId = testAlignmentParentCon.Id;
        insert testAlignmentContact;
            
        Contact testCon1 = new Contact();
        testCon1.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Salesforce').getRecordTypeId();
        testCon1.LastName = 'testCont1';
        testCon1.AccountId = acc.Id;
        insert testCon1;
        
        Contact testCon2 = new Contact();
        testCon2.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Salesforce').getRecordTypeId();
        testCon2.LastName = 'testCont2';
        testCon2.AccountId = acc.Id;
        testCon2.ReportsToId = testCon1.Id;
        insert testCon2;
        Contact testCon3 = new Contact();
        testCon3.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByName().get('Salesforce').getRecordTypeId();
        testCon3.LastName = 'testCont3';
        testCon3.AccountId = acc.Id;
        testCon3.ReportsToId = testCon2.Id;
        
        
        insert testCon3;
	}
    
    @isTest
    static void updateChildRecordsTest() {
		List<Contact> alignmentConList = [SELECT Id FROM Contact WHERE LastName = 'Test Alignment Individual'];
        Contact parentCon = [SELECT Id FROM Contact WHERE LastName = 'testCont1'][0];
        parentCon.Caelius_Alignment__c = alignmentConList[0].Id;
        Test.startTest();
        update parentCon;
        Test.stopTest();
    } 
}