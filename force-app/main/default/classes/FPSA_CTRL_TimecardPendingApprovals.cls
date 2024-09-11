public class FPSA_CTRL_TimecardPendingApprovals {

   /* public class ApprovalResultWrapper {
        @AuraEnabled public Boolean isRequestProcessed {get; private set;}
        @AuraEnabled public List<FPSA_Resource_TimeLines__c> submittedTimecardLines {get; private set;}

        public ApprovalResultWrapper(Boolean isRequestProcessed, List<FPSA_Resource_TimeLines__c> submittedTimecardLines) {
            this.isRequestProcessed = isRequestProcessed;
            this.submittedTimecardLines = submittedTimecardLines;
        }
    }
    
    @AuraEnabled
    public static List<FPSA_Resource_TimeLines__c> getPendingTimecardApprovalRequests() {
        return FPSA_TimecardPendingApprovalsHelper.getSubmittedTimecardLines();
    }

    @AuraEnabled
    public static ApprovalResultWrapper processTimecardApprovalRequests(List<String> timecardIds, String approvalAction) {
        List<Id> timecardIdList = FPSA_TimecardPendingApprovalsHelper.getTypecastTimecardIds(timecardIds);
        List<Approval.ProcessWorkItemRequest> workItemRequests = FPSA_TimecardPendingApprovalsHelper.getProcessWorkItemRequests(timecardIdList, approvalAction);
        List<Approval.ProcessResult> approvalResults = Approval.process(workItemRequests, false);
        
        Boolean isProcessed = FPSA_TimecardPendingApprovalsHelper.isApprovalRequestProcessed(approvalResults);
        return new ApprovalResultWrapper(isProcessed, FPSA_TimecardPendingApprovalsHelper.getSubmittedTimecardLines());
    }
	*/
}