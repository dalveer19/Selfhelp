public without sharing class shp_accountUtility {

// To get the account id using clientcode
    @AuraEnabled
    public static Id getAccountId (String clientCode){
        return [SELECT id FROM Account WHERE Client_code__c =: clientCode LIMIT 1].id;
    }

// To get langauges list from metadata based on the order 
@AuraEnabled
public static list<langWrap> selfHelpLanguages(){
    try{
list<langWrap> langList = new list<langWrap>();
    for( Self_Help_Language__mdt lang : [SELECT language_Display__c, language__c,MasterLabel,order__c  FROM Self_Help_Language__mdt ORDER BY order__c ASC]){
        langList.add(new langWrap(lang.MasterLabel, lang.language_Display__c, lang.language__c));
    }
    return langList;
    }
    catch(exception err){
        throw new AuraHandledException(err.getMessage());
    }
}

//Wrapper class to hold language details from custom metadata
public class langWrap{
    @AuraEnabled
    public string label{get;set;}
    @AuraEnabled
    public string display{get;set;}
    @AuraEnabled
    public string code{get;set;}

    public langWrap(string label, string display,string code){
        this.label = label;
        this.display = display;
        this.code = code;
    }
}
    
  // To get langauge display label from metadata based on the language code
@AuraEnabled
public static string getLanguage(string langCode){
    try{
    return [SELECT language_Display__c, language__c  FROM Self_Help_Language__mdt WHERE language__c=:langCode LIMIT 1 ].language_Display__c;
    }
    catch(exception err){
        throw new AuraHandledException(err.getMessage());
    }
}  

}