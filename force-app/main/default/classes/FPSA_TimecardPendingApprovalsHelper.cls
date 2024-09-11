public class FPSA_TimecardPendingApprovalsHelper {

    /*private static final String TIMECARD_STATUS_SUBMITTED = Label.FPSA_Timecard_Status_Submitted;

    public static List<FPSA_Resource_TimeLines__c> getSubmittedTimecardLines() {
        Id approverId = UserInfo.getUserId();

        return [SELECT Id, Name, FPSA_Week_Start_Date__c, FPSA_Total_Hours__c, FPSA_Project_Planned_hrs__c, FPSA_Total_Billable_Amount__c,
                FPSA_Weekly_Notes__c, FPSA_Resource__c, FPSA_Resource__r.Name, FPSA_Project__c, FPSA_Project__r.Name, 
                FPSA_Milestone__c, FPSA_Milestone__r.Name
                FROM FPSA_Resource_TimeLines__c
                WHERE FPSA_Approver__c = :approverId AND
                FPSA_Status__c = :TIMECARD_STATUS_SUBMITTED];
    }

    public static List<Id> getTypecastTimecardIds(List<String> timecardIds) {
        List<Id> timecardIdList = new List<Id>();

        for(String timecardId : timecardIds) {
            timecardIdList.add(Id.valueOf(timecardId));
        }

        return timecardIdList;
    }

    public static List<Approval.ProcessWorkItemRequest> getProcessWorkItemRequests(List<Id> timecardIds, String approvalAction) {
        Map<Id, Id> timecardIdToWorkItemIdMap = getTimecardIdToWorkItemIdMap(timecardIds);

        List<Approval.ProcessWorkItemRequest> workItemRequests = new List<Approval.ProcessWorkItemRequest>();

        for(Id timecardId : timecardIds) {
            Approval.ProcessWorkItemRequest workItemRequest = new Approval.ProcessWorkItemRequest();
            workItemRequest.setAction(approvalAction);
            workItemRequest.setWorkitemId(timecardIdToWorkItemIdMap.get(timecardId));
            workItemRequests.add(workItemRequest);
        }

        return workItemRequests;
    }

    private static Map<Id, Id> getTimecardIdToWorkItemIdMap(List<Id> timecardIds) {
        Map<Id, Id> timecardIdToWorkItemIdMap = new Map<Id, Id>();
        List<ProcessInstanceWorkItem> workItems = [SELECT Id, ProcessInstance.TargetObjectId 
                                                   FROM ProcessInstanceWorkItem 
                                                   WHERE ProcessInstance.TargetObjectId IN :timecardIds];
        
        for(ProcessInstanceWorkItem workItem : workItems) {
            timecardIdToWorkItemIdMap.put(workItem.ProcessInstance.TargetObjectId, workItem.Id);
        }

        return timecardIdToWorkItemIdMap;
    }

    public static Boolean isApprovalRequestProcessed(List<Approval.ProcessResult> approvalResults) {
        Boolean isProcessed = true;

        for(Approval.ProcessResult approvalResult : approvalResults) {
            if(!approvalResult.isSuccess()) {
                isProcessed = false;
            }
        }

        return isProcessed;
    }*/
}