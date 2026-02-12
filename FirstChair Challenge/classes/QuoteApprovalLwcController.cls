public with sharing class QuoteApprovalLwcController {


@AuraEnabled(cacheable=true)
public static List<Quote> getPendingQuotes() {

    return [
        SELECT Id,
               Name,
               Opportunity.Name,
               Discount__c,
               Total_Amount__c,
               Approval_Status__c
        FROM Quote
        WHERE Approval_Status__c = 'Pending Approval'
        AND Manager__c = :UserInfo.getUserId()
    ];
}

@AuraEnabled
    public static void approveQuotes(List<Id> quoteIds) {

        if (quoteIds == null || quoteIds.isEmpty()) {
            return;
        }

        List<Quote> quotesToUpdate = [
            SELECT Id, Approval_Status__c
            FROM Quote
            WHERE Id IN :quoteIds
        ];

        for (Quote q : quotesToUpdate) {
            q.Approval_Status__c = 'Approved';
        }

        update quotesToUpdate;
    }
}