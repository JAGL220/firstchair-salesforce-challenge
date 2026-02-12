@isTest
private class QuoteApprovalLwcControllerTest {

    /**
     * verifica que el metodo getPendingQuotes
     * retorne unicamente las quotes en Pending Approval asignadas al usuario actual.
     */
    @isTest
    static void testGetPendingQuotes() {

        Account acc = new Account(Name='Test Acc');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            CloseDate=Date.today(),
            AccountId=acc.Id
        );
        insert opp;

        Id currentUserId = UserInfo.getUserId();

        // quote que debe ser retornada
        Quote q = new Quote(
            Name='Pending Quote',
            OpportunityId=opp.Id,
            Approval_Status__c='Pending Approval',
            Total_Amount__c=1000,
            Manager__c=currentUserId
        );
        insert q;

        Test.startTest();
        List<Quote> result = QuoteApprovalLwcController.getPendingQuotes();
        Test.stopTest();

        System.assertEquals(1, result.size(),
            'Debe retornar una Quote pendiente del usuario actual');
    }

    /**
     * verifica que el metodo approveQuotes
     * actualice correctamente el campo Approval_Status__c
     * a Approved para las quotes enviadas.
     */
    @isTest
    static void testApproveQuotes() {

        Account acc = new Account(Name='Test Acc 2');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Test Opp 2',
            StageName='Prospecting',
            CloseDate=Date.today(),
            AccountId=acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name='Pending Quote',
            OpportunityId=opp.Id,
            Approval_Status__c='Pending Approval',
            Total_Amount__c=2000
        );
        insert q;

        Test.startTest();
        QuoteApprovalLwcController.approveQuotes(
            new List<Id>{ q.Id }
        );
        Test.stopTest();

        q = [SELECT Approval_Status__c FROM Quote WHERE Id = :q.Id];

        System.assertEquals('Approved', q.Approval_Status__c,
            'La Quote debe actualizar su estado a Approved');
    }
}