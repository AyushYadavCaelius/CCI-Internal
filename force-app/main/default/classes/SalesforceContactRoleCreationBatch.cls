//
//Batch will move Salesforce contacts from Contact Roles to custom object "Salesforce Contact Roles"
//
public class SalesforceContactRoleCreationBatch implements Database.Batchable<sobject>, Schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select ID,ContactId,Contact.email, OpportunityId  from opportunityContactRole where contact.Email like \'%salesforce.com\' OR contact.Email like \'%mulesoft.com\'  ';
        return Database.getQueryLocator(query);
    }
     
    public void execute(Database.BatchableContext bc, List<opportunityContactRole> scope){
        try{
        Map<Id,opportunityContactRole> contactRoleMap = new Map<Id,opportunityContactRole>();
        Map<Id,Id> opportunityIdMap = new Map<Id,Id>();
        Map<Id,Id> contactMap = new Map<Id,Id>();
        List<Opportunity_Salesforce_Contact__c> newOppContactList = new List<Opportunity_Salesforce_Contact__c>();
        
        for(opportunityContactRole ocrRecord: scope ){
        	contactRoleMap.put(ocrRecord.Id,ocrRecord);
            opportunityIdMap.put(ocrRecord.Id, ocrRecord.OpportunityId);
            contactMap.put(ocrRecord.Id,ocrRecord.ContactId);
        }
        
        List<String> existingOppSalesforceContactList = new List<String>();
        
        for(Opportunity_Salesforce_Contact__c existingRec : [Select ID ,Salesforce_Contact__c, Opportunity__c  from Opportunity_Salesforce_Contact__c where salesforce_Contact__c in: contactMap.values() and Opportunity__c in: opportunityIdMap.values()  ]){
            existingOppSalesforceContactList.add(existingRec.Salesforce_Contact__c+''+existingRec.Opportunity__c);
        }
        
        for(opportunityContactRole ocrRecord : scope){
            if(!existingOppSalesforceContactList.contains(ocrRecord.ContactId+''+ocrRecord.OpportunityId)){
                Opportunity_Salesforce_Contact__c newRecord = new Opportunity_Salesforce_Contact__c(Opportunity__c = ocrRecord.OpportunityId,Salesforce_Contact__c = ocrRecord.ContactId );
            	newOppContactList.add(newRecord);
            }
        }

        //Insert new Salesforce Opportunity Contact Records
        if(newOppContactList.size() > 0){
            INSERT newOppContactList;
        }
        
        //Delete old Opportunity Contact Role Records
        DELETE contactRoleMap.values();
        } catch(Exception e){
            String errorMessage = 'Error in ContactStatusUpdateBatch: ' + e.getMessage() + '\n' + e.getStackTraceString();
            SendErrorEmail.sendEmail(errorMessage);
        }
    }

    public void finish(Database.BatchableContext bc){
        
    }
    
    public void execute(SchedulableContext SC){
        database.executeBatch(new SalesforceContactRoleCreationBatch());
    }

}