public class PredictionResponse {
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

    public class Probabilities {
        public String label {get;set;} 
        public Double probability {get;set;} 

        public Probabilities(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'label') {
                            label = parser.getText();
                        } else if (text == 'probability') {
                            probability = parser.getDoubleValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Probabilities consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    

    public List<Probabilities> probabilities {get;set;} 
    public String object_Z {get;set;} // in json: object

    public PredictionResponse(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'probabilities') {
                        probabilities = new List<Probabilities>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            probabilities.add(new Probabilities(parser));
                        }
                    } else if (text == 'object') {
                        object_Z = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'PredictionResponse consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public PredictionResponse() {
        
    }
    
    public static PredictionResponse parse(String json) {
        return new PredictionResponse(System.JSON.createParser(json));
    }
}