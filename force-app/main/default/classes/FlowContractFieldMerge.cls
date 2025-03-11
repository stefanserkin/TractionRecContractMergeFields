/***********************************************************************
 * @description Invocable action for merge field substitution in contract and forms
 * @date 2025
 ***********************************************************************/
public with sharing class FlowContractFieldMerge {

    @InvocableMethod(label='Populate Contract Merge Fields' category='Traction Rec' description='Contract and form merge service')
    public static List<Result> populateMergeFields(List<Request> requests) {
        List<Result> results = new List<Result>();

        List<TREX1__Contract_and_Form__c> contracts = new List<TREX1__Contract_and_Form__c>();
        for (Request request : requests) {
            contracts.add(request.contract);
        }

        ContractFieldMerge fieldMerge = new ContractFieldMerge(contracts);
        List<TREX1__Contract_and_Form__c> updatedContracts = fieldMerge.populateMergeFields();

        for (TREX1__Contract_and_Form__c contract : updatedContracts) {
            Result result = new Result();
            result.updatedContract = contract;
            results.add(result);
        }

        return results;
    }
    
    public class Request {
        @InvocableVariable(label='Contract and Form' required=true)
        public TREX1__Contract_and_Form__c contract;
    }

    public class Result {
        @InvocableVariable(label='Updated Contract and Form')
        public TREX1__Contract_and_Form__c updatedContract;
    }

}