trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    
    if (Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)) {
        OpportunityHelper.populateAccountPlanning(Trigger.new);
    }
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            OpportunityHelper.updateAccountPlanning(Trigger.new,Trigger.OldMap);
    } 
}