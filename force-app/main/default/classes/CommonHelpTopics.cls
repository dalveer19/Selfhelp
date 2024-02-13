public without sharing class CommonHelpTopics {


@AuraEnabled(cacheable=true)
    public static List<CommonWrapper> getCommonHelpTopics(String language) {

        List<CommonWrapper> commonWrapperListToReturn = new List<CommonWrapper>();
        // Query the "Common Help Topics" object to fetch the desired fields
        

        for( Common_help_topics__c cht :  [SELECT Id,Label__c,Url__c,Language__c,Order__c,Open_New_tab__c FROM Common_help_topics__c WHERE Language__c =:language ORDER BY Order__c ASC LIMIT 9]){
            CommonWrapper cw = new CommonWrapper();
            cw.label = cht.Label__c;
            cw.url = cht.Url__c;
            cw.language = cht.Language__c;
            cw.order = cht.Order__c;
            cw.externalLink = cht.Open_New_tab__c;
            if(cht.Open_New_tab__c){
                cw.target = '_blank';
            }else{
                cw.target = '_self';
            }
            commonWrapperListToReturn.add(cw);
        }

        return commonWrapperListToReturn;
    }


    public class CommonWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String language;
        @AuraEnabled
        public String order;
        @AuraEnabled
        public String target;
        @AuraEnabled
        public Boolean externalLink;
    }
}