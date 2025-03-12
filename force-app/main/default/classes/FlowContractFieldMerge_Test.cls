@IsTest
private class FlowContractFieldMerge_Test {

    private static final String FLOW_NAME = 'ContractAndForm AI PopulateMergeFields';

    @TestSetup
    static void makeData() {
        Account testAccount = new Account(Name = 'Rey Ordonez Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Rey', LastName = 'Ordonez', AccountId = testAccount.Id);
        insert testContact;

        TREX1__Contract_and_Form__c contract = new TREX1__Contract_and_Form__c(
            Name = 'Test Contract',
            TREX1__Waiver_Text__c = 'Hello {!Name}, your account is {!TREX1__Account__r.Name} and contact account is {!TREX1__Contact__r.Account.Name, "No account provided"}.',
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

    /**
     * If packaged record-triggered flow is active, run record-triggered test
     */
    @IsTest
    static void testRecordTrigger() {
        // Guard against inactive or deleted flow
        if (!isFlowActive()) {
            return;
        }

        TREX1__Contract_and_Form__c contract = [SELECT Id, TREX1__Waiver_Text__c FROM TREX1__Contract_and_Form__c LIMIT 1];

        Test.startTest();
        Database.SaveResult sr = Database.update(contract, false);
        Test.stopTest();

        System.Assert.isTrue(sr.isSuccess(), 'Update should have been successful: ' + sr.getErrors());

        TREX1__Contract_and_Form__c refreshedContract = [SELECT Id, TREX1__Waiver_Text__c FROM TREX1__Contract_and_Form__c WHERE Id = :contract.Id LIMIT 1];
        System.Assert.isTrue(
            refreshedContract.TREX1__Waiver_Text__c.contains('Rey Ordonez Test Account'), 
            'Waiver Text should have contained name of the account record: ' + refreshedContract.TREX1__Waiver_Text__c
        );
    }

    private static Boolean isFlowActive() {
        List<FlowDefinitionView> fdvs = [
            SELECT Id, IsActive, NamespacePrefix, InstalledPackageName, Label, ApiName, ApiVersion, VersionNumber 
              FROM FlowDefinitionView 
             WHERE Label = :FLOW_NAME
             LIMIT 1
        ];
        return !fdvs.isEmpty() && fdvs[0].IsActive;
    }

}