/**
 * This class is created to receive
 * the Response of Sentiment Analysis
 * API.
 * 
 * @author      Shruti Sridharan
 * @since       10/08/2017
 * @revisions   N/A
 **/
global class SentimentAnalysisResponse {
    webservice List<Probabilities> probabilities    { get; set; } 
    
    global class Probabilities {
        webservice String label                     { get; set; } 
        webservice Double probability               { get; set; }
    }
}