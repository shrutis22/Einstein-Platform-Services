public class TrainDatasetResponse {
    public Integer datasetId {get;set;} 
    public Integer datasetVersionId {get;set;} 
    public String name {get;set;} 
    public String status {get;set;} 
    public Decimal progress {get;set;} 
    public String createdAt {get;set;} 
    public String updatedAt {get;set;} 
    public Double learningRate {get;set;} 
    public Integer epochs {get;set;} 
    public Integer queuePosition {get;set;} 
    public String modelId {get;set;} 
    public String trainParams {get;set;} 
    public String trainStats {get;set;} 
    public String modelType {get;set;} 
    
    public TrainDatasetResponse() {
        
    }
}