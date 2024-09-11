trigger AccountTrigger on Account (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        AccountHelper.updateOpportunityAccountPlanning(Trigger.new);
    }
}