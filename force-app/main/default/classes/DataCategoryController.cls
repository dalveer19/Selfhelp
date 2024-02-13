public without sharing class DataCategoryController {
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getTopCategories(String clientCode) {
    Map<String, String> categories = new Map<String, String>();
    top_categories__c setting = top_categories__c.getOrgDefaults();
    String childCategories = setting.Categories_List__c;

    if(clientCode == 'All'){
       List<Schema.DataCategory> result = SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName);
        for(Schema.DataCategory dc : result) {
            if(childCategories.contains(dc.getName())){
              categories.put(dc.getName(), dc.getLabel());
            }
        }
    }
    else{
      Integer i = 0;
      List<Schema.DataCategory> result = SHP_ConstantUtil.GetTopCategories(SHP_ConstantUtil.ArticleObject, SHP_ConstantUtil.DataCategoryName);
      System.debug(result);
      Account_Info__c clientCategories = [Select Id, Top_categories__c, client__r.Client_code__c 
                                          from Account_Info__c where client__r.Client_code__c =: clientCode];

      if(clientCategories != null){
        String topCategories = clientCategories.Top_categories__c;

          if(topCategories != null) {
            List<String> separatedCategories = topCategories.split(';\\s*');
            System.debug(separatedCategories);
              for(Schema.DataCategory dc : result) {
                  if(separatedCategories.contains(dc.getName())){
                    if(i < setting.size__c){
                        categories.put(dc.getName(), dc.getLabel());
                        i++;
                    }
                  }
              }   
           }
      System.debug(categories);
      }
    }
    return categories;
  }

  @AuraEnabled(cacheable=true)
  public static String getDataCategoryLabel(String dataCategoryName){
    string dataCategoryLabel = '';
    List<Schema.DataCategory> dataCategoryList = SHP_ConstantUtil.GetTopCategories('KnowledgeArticleVersion', 'Candidate');
    for(Schema.DataCategory dc : dataCategoryList) {
        if(dataCategoryName == dc.getName()){
            dataCategoryLabel=dc.getLabel();
        }
    }
    system.debug('dataCategoryLabel - '+dataCategoryLabel);
    return dataCategoryLabel;
  }
}