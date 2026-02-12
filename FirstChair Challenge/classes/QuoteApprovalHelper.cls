public with sharing class QuoteApprovalHelper {

    private static final String APPROVED_STATUS = 'Approved';

    public static void syncOpportunityAmount(List<Quote> newList, Map<Id, Quote> oldMap) {

        Set<Id> oppIds = new Set<Id>();

        // Detectar Quotes que pasaron a Approved
        for (Quote q : newList) {

            if (q.OpportunityId != null) {
                // Caso insert
                if (oldMap == null) {
                    if (q.Approval_Status__c == APPROVED_STATUS) {
                        oppIds.add(q.OpportunityId);
                    }
                    continue;
                }

                // Caso update
                Quote oldQ = oldMap.get(q.Id);

                if (q.Approval_Status__c == APPROVED_STATUS &&
                    oldQ.Approval_Status__c != APPROVED_STATUS) {

                    oppIds.add(q.OpportunityId);
                }
            }
        }

        if (oppIds.isEmpty()) return;

        // Traer todos los Quotes Approved para esas Opportunities
        List<Quote> approvedQuotes = [
            SELECT Id,
                   OpportunityId,
                   Total_Amount__c,
                   LastModifiedDate
            FROM Quote
            WHERE OpportunityId IN :oppIds
            AND Approval_Status__c = :APPROVED_STATUS
            ORDER BY LastModifiedDate DESC, Id DESC
        ];

        // Elegir el más reciente por Opportunity
        Map<Id, Quote> latestApprovedByOpp = new Map<Id, Quote>();

        for (Quote q : approvedQuotes) {
            if (!latestApprovedByOpp.containsKey(q.OpportunityId)) {
                latestApprovedByOpp.put(q.OpportunityId, q);
            }
        }

        // Preparar update en bulk
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for (Opportunity opp : [SELECT Id, Amount FROM Opportunity WHERE Id IN :latestApprovedByOpp.keySet()]) {
            
            Quote latest = latestApprovedByOpp.get(opp.Id);

            opp.Amount = latest.Total_Amount__c;

            oppsToUpdate.add(opp);
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}