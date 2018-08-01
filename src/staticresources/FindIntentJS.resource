var FindIntent = {
    variables : {
        datasetId   : null,
        modelId     : null,
        picker      : null,
        config      : null
    },
    helpers : {
        showProgress : function( statusMsg, friendlyMsg ) {
            $( "#mdlHeader" ).html( statusMsg );
            
            $( "#statusMsg" ).html( friendlyMsg );
            
            $( "#mdlSpinner" ).show();
            
            $( "#btnClose" ).prop( "disabled", true );
            
            $( "#mdlStatus" ).show();
            
            $( "#mdlBackDrop" ).show();
        },
        showCompletion : function( statusMsg, friendlyMsg ) {
            $( "#mdlHeader" ).html( statusMsg );
            
            $( "#statusMsg" ).html( friendlyMsg );
            
            $( "#mdlSpinner" ).hide();
            
            $( "#btnClose" ).prop( "disabled", false );
            
            $( "#mdlStatus" ).show();
            
            $( "#mdlBackDrop" ).show();
        },
        enableButton : function( btnId, isEnabled ) {
            if( isEnabled ) {
                $( "#" + btnId ).prop( "disabled", false );
            }
            else {
                $( "#" + btnId ).prop( "disabled", true );
            }
        },
        createPicker : function () {
            FindIntent.variables.picker = new google.picker.PickerBuilder()
                    .addView( new google.picker.DocsUploadView().setParent( FindIntent.variables.config.intentDatasetFolderId ) )
                    .setOAuthToken( FindIntent.variables.config.accessToken )
                    .setCallback( FindIntent.helpers.pickerCallback )
                    .build();
        },
        pickerCallback : function ( data ) {
            if( data[google.picker.Response.ACTION] === google.picker.Action.PICKED ) {
                var downloadUrl = data[google.picker.Response.DOCUMENTS][0].downloadUrl;
                
                FindIntentController.saveDownloadUrl(
                    downloadUrl,
                    function( result, event ) {
                        FindIntent.actions.uploadMyDataset();
                    }
                );
            }
        },
        loadPickerModule : function() {
            gapi.load( "picker", { "callback" : FindIntent.helpers.createPicker } );
        }
    },
    actions : {
        uploadDataset : function() {
            FindIntentController.uploadDataset(
                function( result, event ) {
                    FindIntent.variables.datasetId = result.id;
                    
                    FindIntent.helpers.showProgress( result.statusMsg, "The CSV is being uploaded to create the Dataset. Please wait..." );
                    
                    FindIntent.actions.getDatasetDetails();
                }
            );
        },
        uploadMyDataset : function() {
            FindIntentController.uploadMyDataset(
                function( result, event ) {
                    FindIntent.variables.datasetId = result.id;
                    
                    FindIntent.helpers.showProgress( result.statusMsg, "The CSV is being uploaded to create the Dataset. Please wait..." );
                    
                    FindIntent.actions.getDatasetDetails();
                }
            );
        },
        getDatasetDetails : function() {
            window.setTimeout( 
                function() {
                    FindIntentController.getDatasetDetails(
                        FindIntent.variables.datasetId,
                        function( result, event ) {
                            if( result.statusMsg !== "SUCCEEDED" ) {
                                FindIntent.actions.getDatasetDetails();
                                
                                FindIntent.helpers.showProgress( result.statusMsg, "The Dataset is being uploaded. Please wait..." );
                            }
                            else {
                                FindIntent.helpers.showCompletion( result.statusMsg, "The Dataset has been created successfully. Now please hit the Train button." );
                                
                                FindIntent.helpers.enableButton( "btnTrainDS", true );
                            }
                        }
                    );
                },
                1000
            );
        },
        trainDataset : function() {
            FindIntentController.trainDataset(
                FindIntent.variables.datasetId,
                function( result, event ) {
                    FindIntent.variables.modelId = result.modelId;
                    
                    FindIntentController.saveModelId(
                        FindIntent.variables.modelId,
                        function( result, event ) {
                            
                        }
                    );
                    
                    FindIntent.helpers.showProgress( result.status, "A Model has been created from the Dataset. The Training process will start shortly." );
                    
                    FindIntent.helpers.enableButton( "btnClose", false );
                    
                    FindIntent.actions.getDatasetTrainingStatus();
                }
            );
        },
        getDatasetTrainingStatus : function() {
            window.setTimeout( 
                function() {
                    FindIntentController.getDatasetTrainingStatus(
                        FindIntent.variables.modelId,
                        function( result, event ) {
                            if( result.status !== "SUCCEEDED" ) {
                                FindIntent.actions.getDatasetTrainingStatus();
                                
                                FindIntent.helpers.showProgress( result.status, "The Training process has started. This might take few minutes to complete. It usually takes like 5+ minutes. So you have enough time to grab some caffeine." );
                            }
                            else {
                                FindIntent.helpers.showCompletion( result.status, "The Training process has been completed successfully. You can now try out the Prediction." );
                                
                    			FindIntent.helpers.enableButton( "btnPredict", true );
                            }
                        }
                    );
                },
                1000
            );
        },
        predictIntent : function() {
            var textToPredict = $( "#txtTextToIntent" ).val();
            
            FindIntentController.predictIntent(
                FindIntent.variables.modelId,
                textToPredict,
                function( result, event ) {
                    var largest = 0;
                    var position = 0;
                    for( var i = 0; i < result.probabilities.length; i++ ) {
                        if( largest <= result.probabilities[i].probability ) {
                            largest = result.probabilities[i].probability;
                            position = i;
                        }
                    }
                    
                    FindIntent.helpers.showCompletion( "PREDICTION RESULTS", "Einstein found the Intent in the text as a - <strong>" + result.probabilities[position].label + "</strong>." );
                    
                    FindIntent.helpers.enableButton( "btnPredict", true );
                }
            );
        },
        closeModal : function() {
            $( "#mdlStatus" ).hide();
            $( "#mdlBackDrop" ).hide();
        }
    },
    eventHandlers : {
        uploadDataset : function() {
            FindIntent.actions.uploadDataset();
        },
        uploadMyDataset : function() {
            FindIntent.actions.uploadMyDataset();
        },
        getDatasetDetails : function() {
            FindIntent.actions.getDatasetDetails();
        },
        trainDataset : function() {
            FindIntent.actions.trainDataset();
        },
        getDatasetTrainingStatus : function() {
            FindIntent.actions.getDatasetTrainingStatus();
        },
        predictIntent : function() {
            FindIntent.actions.predictIntent();
        },
        closeModal : function() {
            FindIntent.actions.closeModal();
        }
    },
    init : function( config ) {
        FindIntent.variables.config = config;
        
        $( "#btnUploadDS" ).click(
            function() {
                FindIntent.helpers.enableButton( "btnUploadDS", false );
                FindIntent.helpers.enableButton( "btnUploadMyDS", false );
                
                FindIntent.eventHandlers.uploadDataset();
            }
        );
        
         $( "#btnUploadMyDS" ).click(
            function() {
                FindIntent.helpers.enableButton( "btnUploadDS", false );
                FindIntent.helpers.enableButton( "btnUploadMyDS", false );
                
                FindIntent.variables.picker.setVisible( true );
            }
        );
        
        $( "#btnTrainDS" ).click(
            function() {
                FindIntent.helpers.enableButton( "btnTrainDS", false );
                
                FindIntent.eventHandlers.trainDataset();
            }
        );
        
        $( "#btnPredict" ).click(
            function() {
                FindIntent.helpers.enableButton( "btnPredict", false );
                
                FindIntent.eventHandlers.predictIntent();
            }
        );
        
        $( "#btnClose" ).click(
            function() {
                FindIntent.eventHandlers.closeModal();
            }
        );
    }
};