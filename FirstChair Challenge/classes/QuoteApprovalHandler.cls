public class QuoteApprovalHandler {

    public static void onAfterInsert(List<Quote> newQuotes) {
        QuoteApprovalHelper.syncOpportunityAmount(newQuotes, null);
    }

    public static void onAfterUpdate(List<Quote> newQuotes, Map<Id, Quote> oldQuotes) {
        QuoteApprovalHelper.syncOpportunityAmount(newQuotes, oldQuotes);
    }
}