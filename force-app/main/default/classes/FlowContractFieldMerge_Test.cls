@IsTest
private class FlowContractFieldMerge_Test {

    @TestSetup
    static void makeData() {
        Account testAccount = new Account(Name = 'Rey Ordonez Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Rey', LastName = 'Ordonez', AccountId = testAccount.Id);
        insert testContact;

        TREX1__Contract_and_Form__c contract = new TREX1__Contract_and_Form__c(
            Name = 'Test Contract',
            TREX1__Waiver_Text__c = 'Hello {!Name}, your account is {!TREX1__Account__r.Name} and contact account is {!TREX1__Contact__r.Account.Name}.',
            TREX1__Account__c = testAccount.Id,
            TREX1__Contact__c = testContact.Id,
            TREX1__Contract_Expiry_Policy__c = 'Always Required',
            TREX1__Valid_For__c = 'Account',
            TREX1__Type__c = 'Waiver Form',
            TREX1__Status__c = 'Draft'
        );
        insert contract;
    }

    @IsTest
    static void testPopulateMergeFields() {
        List<TREX1__Contract_and_Form__c> contracts = [SELECT Id, TREX1__Waiver_Text__c FROM TREX1__Contract_and_Form__c];

        List<FlowContractFieldMerge.Result> results;
        Test.startTest();
        FlowContractFieldMerge.Request request = new FlowContractFieldMerge.Request();
        request.contract = contracts[0];

        results = FlowContractFieldMerge.populateMergeFields(
            new List<FlowContractFieldMerge.Request>{ request }
        );
        Test.stopTest();

        TREX1__Contract_and_Form__c updatedContract = results[0].updatedContract;

        System.Assert.areEqual(contracts[0].Id, updatedContract.Id, 'Should have received the original contract');
    }

}