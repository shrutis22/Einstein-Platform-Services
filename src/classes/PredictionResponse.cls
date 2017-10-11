global class PredictionResponse {
    global class Probabilities {
        global String label {get;set;}
        global Double probability {get;set;}
    }

    global List<Probabilities> probabilities {get;set;}
}
