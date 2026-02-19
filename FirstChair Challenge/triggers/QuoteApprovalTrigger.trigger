trigger QuoteApprovalTrigger on Quote (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        QuoteApprovalHandler.onAfterInsert(Trigger.new);
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        QuoteApprovalHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}