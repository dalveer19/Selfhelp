public with sharing class shp_FooterLinksController {
    public class footerWrapper{
        @AuraEnabled 
        public String apiName{get;set;}
        @AuraEnabled 
        public Integer columnNumber{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public String errorMsg{get;set;}
    }
    public class emptySOSLResultException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static List<footerWrapper> getFooterLinks(String language){
        List<footerWrapper> fwList = new List<footerWrapper>();
        try{
            List<shp_Footer_Link__mdt> linksMetadataList = [
            SELECT DeveloperName, Column__c, Link_Label__c, Link_Address__c, Order__c 
            FROM shp_Footer_Link__mdt 
            WHERE Language__c=:language
            ORDER BY Order__c
            ];
            if(linksMetadataList.size()<=0){
                throw new emptySOSLResultException(SHP_ConstantUtil.emptySOSLResultExceptionMsg);
            }
            for(shp_Footer_Link__mdt fl : linksMetadataList){
                footerWrapper fw = new footerWrapper();
                fw.apiName = fl.DeveloperName;
                fw.columnNumber = (Integer)fl.Column__c;
                fw.label = fl.Link_Label__c;
                fw.url = fl.Link_Address__c;
                fwList.add(fw);
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
            footerWrapper fw = new footerWrapper();
            fw.errorMsg = e.getMessage();
            fwList.add(fw);
        }
        return fwList;
    }
}