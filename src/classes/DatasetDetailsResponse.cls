public class DatasetDetailsResponse {
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public class LabelSummary {
        public List<Labels> labels {get;set;} 

        public LabelSummary(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'labels') {
                            labels = new List<Labels>();
                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                labels.add(new Labels(parser));
                            }
                        } else {
                            System.debug(LoggingLevel.WARN, 'LabelSummary consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Labels {
        public Integer id {get;set;} 
        public Integer datasetId {get;set;} 
        public String name {get;set;} 
        public Integer numExamples {get;set;} 

        public Labels(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'datasetId') {
                            datasetId = parser.getIntegerValue();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'numExamples') {
                            numExamples = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Labels consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    

    public Integer id {get;set;} 
    public String name {get;set;} 
    public String createdAt {get;set;} 
    public String updatedAt {get;set;} 
    public LabelSummary labelSummary {get;set;} 
    public Integer totalExamples {get;set;} 
    public Integer totalLabels {get;set;} 
    public Boolean available {get;set;} 
    public String statusMsg {get;set;} 
    public String type_Z {get;set;} // in json: type
    public String object_Z {get;set;} // in json: object

    public DatasetDetailsResponse(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'id') {
                        id = parser.getIntegerValue();
                    } else if (text == 'name') {
                        name = parser.getText();
                    } else if (text == 'createdAt') {
                        createdAt = parser.getText();
                    } else if (text == 'updatedAt') {
                        updatedAt = parser.getText();
                    } else if (text == 'labelSummary') {
                        labelSummary = new LabelSummary(parser);
                    } else if (text == 'totalExamples') {
                        totalExamples = parser.getIntegerValue();
                    } else if (text == 'totalLabels') {
                        totalLabels = parser.getIntegerValue();
                    } else if (text == 'available') {
                        available = parser.getBooleanValue();
                    } else if (text == 'statusMsg') {
                        statusMsg = parser.getText();
                    } else if (text == 'type') {
                        type_Z = parser.getText();
                    } else if (text == 'object') {
                        object_Z = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'DatasetDetailsResponse consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public DatasetDetailsResponse() {
        
    }
    
    public static DatasetDetailsResponse parse(String json) {
        return new DatasetDetailsResponse(System.JSON.createParser(json));
    }
}