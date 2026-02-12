@isTest
private class QuoteApprovalTest {

    /**
     * verifica que al insertar una Quote ya aprobada
     * se actualice el Amount de la Opportunity.
     */
    @isTest
    static void testInsertApprovedQuote() {

        Account acc = new Account(Name='Test Acc');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Test Opp',
            StageName='Prospecting',
            CloseDate=Date.today(),
            AccountId=acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name='Quote 1',
            OpportunityId=opp.Id,
            Approval_Status__c='Approved',
            Total_Amount__c=1000
        );

        Test.startTest();
        insert q;
        Test.stopTest();

        opp = [SELECT Amount FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(1000, opp.Amount,
            'La Opportunity debe actualizar su Amount al insertar una Quote aprobada');
    }

    /**
     * verifica que al actualizar una Quote de Pending a Approved
     * se actualice correctamente la Opportunity.
     */
    @isTest
    static void testUpdateFromPendingToApproved() {

        Account acc = new Account(Name='Test Acc 2');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Opp 2',
            StageName='Prospecting',
            CloseDate=Date.today(),
            AccountId=acc.Id
        );
        insert opp;

        Quote q = new Quote(
            Name='Quote Pending',
            OpportunityId=opp.Id,
            Approval_Status__c='Pending Approval',
            Total_Amount__c=2000
        );
        insert q;

        Test.startTest();
        q.Approval_Status__c = 'Approved';
        update q;
        Test.stopTest();

        opp = [SELECT Amount FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(2000, opp.Amount,
            'La Opportunity debe actualizarse cuando la Quote cambia a Approved');
    }

    /**
     * verifica que solo la Quote aprobada mas reciente
     * actualice el Amount de la Opportunity.
     */
    @isTest
    static void testLatestApprovedQuoteWins() {

        Account acc = new Account(Name='Test Acc 3');
        insert acc;

        Opportunity opp = new Opportunity(
            Name='Opp 3',
            StageName='Prospecting',
            CloseDate=Date.today(),
            AccountId=acc.Id
        );
        insert opp;

        // Primera aprobada
        Quote q1 = new Quote(
            Name='Quote 1',
            OpportunityId=opp.Id,
            Approval_Status__c='Approved',
            Total_Amount__c=1000
        );
        insert q1;

        // segunda aprobada (mas reciente)
        Quote q2 = new Quote(
            Name='Quote 2',
            OpportunityId=opp.Id,
            Approval_Status__c='Approved',
            Total_Amount__c=3000
        );

        Test.startTest();
        insert q2;
        Test.stopTest();

        opp = [SELECT Amount FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(3000, opp.Amount,
            'La Opportunity debe tomar el Amount de la Quote aprobada más reciente');
    }
}