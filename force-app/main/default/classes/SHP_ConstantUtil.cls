public with sharing class SHP_ConstantUtil {
    public static final String emptySOSLResultExceptionMsg = 'No articles found for search parameters provided.';
    public static final String KnowledgeArticleVersion = 'KnowledgeArticleVersion';
    public static final String All = 'All';
    public static final String Candidate = 'Candidate';
    public static final String ArticleObject = 'KnowledgeArticleVersion';
    public static final String DataCategoryName = 'Candidate';
    public static final String KnowledgeRecordTypeName = 'Candidate';
    
    /**
     * @description Method to fetch list of all level 1 data categories from the specified data category and Sobject  
     * @param sObjectName - The API name of the object
     * @param categoryName - The API name of the data category
     * @return subCats - The list of Schema.DataCategory which has the info of data categories
     */
    public static list<Schema.DataCategory> GetTopCategories(String sObjectName, String categoryName ){
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();

        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject(sObjectName);
        pair1.setDataCategoryGroupName(categoryName);
        pairs.add(pair1);
        List<Schema.DataCategory> subCats = new List<Schema.DataCategory>();

        List<Schema.DescribeDataCategoryGroupStructureResult>results = Schema.describeDataCategoryGroupStructures(pairs, false);
                  for(Schema.DescribeDataCategoryGroupStructureResult r : results){
                      Schema.DataCategory[] topCategories = r.getTopCategories();
                      for(Schema.DataCategory c : topCategories){
                         subCats = c.getChildCategories();
                      }
                  }    
        return subCats;
    }
    
    
    public static Boolean varForTestClass() {
        Boolean varForTestClass = false;
        return varForTestClass;
    }
}