public class VisionTrainingStatusResponse {
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

    public VisionTrainingStatusResponse() {
        
    }

    public Integer datasetId {get;set;} 
    public Integer datasetVersionId {get;set;} 
    public String name {get;set;} 
    public String status {get;set;} 
    public Integer progress {get;set;} 
    public String createdAt {get;set;} 
    public String updatedAt {get;set;} 
    public Double learningRate {get;set;} 
    public Integer epochs {get;set;} 
    public String object_Z {get;set;} // in json: object
    public String modelId {get;set;} 
    public Object trainParams {get;set;} 
    public TrainStats trainStats {get;set;} 
    public String modelType {get;set;} 

    public VisionTrainingStatusResponse(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'datasetId') {
                        datasetId = parser.getIntegerValue();
                    } else if (text == 'datasetVersionId') {
                        datasetVersionId = parser.getIntegerValue();
                    } else if (text == 'name') {
                        name = parser.getText();
                    } else if (text == 'status') {
                        status = parser.getText();
                    } else if (text == 'progress') {
                        progress = parser.getIntegerValue();
                    } else if (text == 'createdAt') {
                        createdAt = parser.getText();
                    } else if (text == 'updatedAt') {
                        updatedAt = parser.getText();
                    } else if (text == 'learningRate') {
                        learningRate = parser.getDoubleValue();
                    } else if (text == 'epochs') {
                        epochs = parser.getIntegerValue();
                    } else if (text == 'object') {
                        object_Z = parser.getText();
                    } else if (text == 'modelId') {
                        modelId = parser.getText();
                    } else if (text == 'trainParams') {
                        trainParams = parser.getText();
                    } else if (text == 'trainStats') {
                        trainStats = new TrainStats(parser);
                    } else if (text == 'modelType') {
                        modelType = parser.getText();
                    } else {
                        System.debug(LoggingLevel.WARN, 'VisionTrainingStatusResponse consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Transforms {
        public Boolean toFlip {get;set;} 
        public Boolean toRotate {get;set;} 
        public String cropLocation {get;set;} 

        public Transforms(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'toFlip') {
                            toFlip = parser.getBooleanValue();
                        } else if (text == 'toRotate') {
                            toRotate = parser.getBooleanValue();
                        } else if (text == 'cropLocation') {
                            cropLocation = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Transforms consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class TrainStats {
        public Integer labels {get;set;} 
        public Integer examples {get;set;} 
        public String totalTime {get;set;} 
        public Transforms transforms {get;set;} 
        public String trainingTime {get;set;} 
        public Boolean earlyStopping {get;set;} 
        public Integer lastEpochDone {get;set;} 
        public String modelSaveTime {get;set;} 
        public Integer testSplitSize {get;set;} 
        public Integer trainSplitSize {get;set;} 
        public String datasetLoadTime {get;set;} 
        public Object preProcessStats {get;set;} 
        public Object postProcessStats {get;set;} 

        public TrainStats(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'labels') {
                            labels = parser.getIntegerValue();
                        } else if (text == 'examples') {
                            examples = parser.getIntegerValue();
                        } else if (text == 'totalTime') {
                            totalTime = parser.getText();
                        } else if (text == 'transforms') {
                            transforms = new Transforms(parser);
                        } else if (text == 'trainingTime') {
                            trainingTime = parser.getText();
                        } else if (text == 'earlyStopping') {
                            earlyStopping = parser.getBooleanValue();
                        } else if (text == 'lastEpochDone') {
                            lastEpochDone = parser.getIntegerValue();
                        } else if (text == 'modelSaveTime') {
                            modelSaveTime = parser.getText();
                        } else if (text == 'testSplitSize') {
                            testSplitSize = parser.getIntegerValue();
                        } else if (text == 'trainSplitSize') {
                            trainSplitSize = parser.getIntegerValue();
                        } else if (text == 'datasetLoadTime') {
                            datasetLoadTime = parser.getText();
                        } else if (text == 'preProcessStats') {
                            preProcessStats = parser.getText();
                        } else if (text == 'postProcessStats') {
                            postProcessStats = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'TrainStats consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static VisionTrainingStatusResponse parse(String json) {
        return new VisionTrainingStatusResponse(System.JSON.createParser(json));
    }
}