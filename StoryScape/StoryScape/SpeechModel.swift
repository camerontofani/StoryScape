//
//  SpeechModel.swift
//  StoryScape
//
//  Created by Rick Lattin on 12/11/24.
//

import UIKit
import AVFoundation
import Speech

class SpeechModel{
    
    // MARK: Properties
    /// The speech recogniser used by the controller to record the user's speech.
    private let speechRecogniser = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        
    /// The current speech recognition request. Created when the user wants to begin speech recognition.
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
            
    /// The current speech recognition task. Created when the user wants to begin speech recognition.
    private var recognitionTask: SFSpeechRecognitionTask?
    var inputNode: AVAudioInputNode?
        
    /// The audio engine used to record input from the microphone.
    private let audioEngine = AVAudioEngine()
    
    private var storyPanels: [StoryFrameModel] = []  //for now, jsut to store each string spoken as a "panel"->updated in recocnitionResultHandler
    var frame: StoryFrameModel?
    private var curPanelIndex: Int = 0
    
    
    //frame variables
    private var curText: String = ""
    private var curTextInd: Int = 0
    private var textList: [String] = []
    private var curImage: UIImage? = nil
    
    //labels in view controller
    var dictLabel: UILabel
    var imageView: UIImageView
    var getNextFrameButton: UIButton
    var getPrevFrameButton: UIButton
    var dictationLabel: UILabel
    
    // MARK: Public Methods
    init(dictLabel: UILabel, imageView: UIImageView, nextButton: UIButton, prevButton: UIButton, dictationLabel: UILabel) {
        self.dictLabel = dictLabel
        self.imageView = imageView
        self.getNextFrameButton = nextButton
        self.getPrevFrameButton = prevButton
        self.dictationLabel = dictationLabel
        
        self.curTextInd = 0
        
        // initialize story panels
        let tempListPanels:[StoryFrameModel]? = CurrentParameters.sharedInstance.getStoryPanels()
        if let storyPanelsParam = tempListPanels, storyPanelsParam.count != 0 {
            storyPanels = CurrentParameters.sharedInstance.getStoryPanels()
            print("Story panels in speech length: \(storyPanels.count)")
            displayCurFrame(displayImage: storyPanels[0].getImage(), displayString: storyPanels[0].getText())
            print("story panels parameter is not nil")
        } else {
            print("story panels parameter is nil")
        }
        
        if getNumPanelsInStory() > 1 {
            self.getNextFrameButton.isHidden = false
        }
    }
    
    func startRecording() {
        // setup recognizer
        guard speechRecogniser.isAvailable else {
            // Speech recognition is unavailable, so do not attempt to start.
            print("Speech recognizer is not available.")
            return
        }
        
        // make sure we have permission
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            print("Speech recognition permission denied or not determined.")
            SFSpeechRecognizer.requestAuthorization({ (status) in
                // Handle the user's decision
                print(status)
            })
            return
        }
        
        // setup audio
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            fatalError("Audio engine could not be set up")
        }

        if recognitionRequest == nil {
            // setup reusable request (if not already)
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
            
            // perform on device, if possible
            // NOTE: this will usually limit the voice analytics results
            if speechRecogniser.supportsOnDeviceRecognition {
                print("Using on device recognition, voice analytics may be limited.")
                recognitionRequest!.requiresOnDeviceRecognition = true
            } else {
                print("Using server for recognition.")
            }
        }
        
        // get a handle to microphone input handler
        self.inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            // Handle error
            return
        }
        
        // define recognition task handling, set handler
        recognitionTask = speechRecogniser.recognitionTask(with: recognitionRequest, resultHandler: self.recognitionResultHandler)
        
        // now setup input node to send buffers to the transcript
        // this is a block that is called continuously
        let recordingFormat = inputNode!.outputFormat(forBus: 0)
        inputNode!.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            // this is a fast operation, only adding to the audio queue
            self.recognitionRequest?.append(buffer)
        }

        // this kicks off the entire recording process, adding audio to the queue
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            fatalError("Audio engine could not start")
        }
    }
    
    func stopRecording() {
        if audioEngine.isRunning {
//            audioEngine.stop()
//            recognitionRequest?.endAudio()
//            recognitionTask?.finish()
            
            // stop recognition
            recognitionTask?.finish()
            recognitionTask = nil

            // stop audio
            recognitionRequest!.endAudio()
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0) // Remove tap on bus when stopping recording.
        }
    }
    
    func tokenize(_ text: String) -> String {
                // Basic example: Removing common stop words for brevity
                let stopWords = ["a", "an", "the", "and", "or", "but", "is", "are", "was", "were", "in", "on", "at", "to", "of", "for", "with", "as", "by",
                                 "today", "yesterday", "tomorrow", "i", "me", "you", "he", "she", "it", "we", "they", "this", "that", "here", "there",
                                 "from", "up", "down", "then", "now", "when", "where", "how", "why", "not", "all", "some", "any", "very", "just", "can",
                                 "could", "would", "will", "shall", "should", "did", "does", "do", "has", "have", "had", "having", "be", "been", "being",
                                 "once", "upon", "a", "time", "story", "tale", "narrative", "legend", "fable", "began", "started", "ended", "continued",
                                 "was", "were", "had", "had", "thought", "felt", "saw", "heard", "said", "asked", "told", "replied", "answered", "spoke",
                                 "spoke", "began", "told", "knew", "found", "discovered", "wanted", "needed", "desired", "believed", "dreamed", "hoped",
                                 "believe", "think", "believed", "thought", "understood", "remembered", "forgot", "suddenly", "finally", "then", "later",
                                 "was", "were", "in", "out", "into", "upon", "before", "after", "during", "between", "along", "through", "over", "under",
                                 "while", "whenever", "wherever", "soon", "always", "never", "maybe", "perhaps", "suddenly", "first", "last", "next", "this",
                                 "that", "each", "many",
                                 "more", "less", "most", "least", "much", "many", "nothing", "everything", "anything", "everything", "nothing", "something",
                                 "someone", "anyone", "everyone", "noone", "all", "none", "any", "every", "each", "some", "another", "such", "that", "these",
                                 "those", "who", "whom", "which", "what", "where", "how", "why", "how", "much", "less", "few", "more", "one", "two"]
                let words = text.split(separator: " ")
                let filteredWords = words.filter { !stopWords.contains($0.lowercased()) }
                return filteredWords.joined(separator: " ")
            }
    
    func recognitionResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        // if result is not nil, update label with transcript
        if let result = result {
            let spokenText = result.bestTranscription.formattedString
            print("Recognized text: \(spokenText)")
            
            let tokenizedText = tokenize(spokenText)
            print("Tokenized text: \(tokenizedText)")
            
            if result.isFinal {
                        // Save the new panel
                        textList.append(spokenText)
                        self.curText = spokenText
                        print("Saved panel: \(spokenText)")
                        
                        DispatchQueue.main.async {
                            // Update the dictation label with the full story
//                            self.dictLabel.text = self.storyPanels.joined(separator: " ")
                            self.dictLabel.text = spokenText

                            
                            self.fetchGeneratedImage(for: tokenizedText) { [weak self] image in
                                                   DispatchQueue.main.async {
                                                       if let image = image {
                                                           self?.imageView.image = image
                                                       } else {
                                                           print("Failed to fetch image")
                                                           self!.displayErrorInDictation(errorCode: "Failed to fetch image")
                                                       }
                                                   }
                                               }
                            
                            
                        }
                    }
        }
        
        // if the result is complete, stop listening to microphone
        // this can happen if the user lifts their finger from the button OR request times out
        // ?? is used if anything fails to unwrap in expression
        if result?.isFinal ?? (error != nil) {
            // this will remove the listening tap
            // so that the transcription stops
            self.inputNode!.removeTap(onBus: 0)
            if error != nil {
                print(error!)
            } else {
                print(result!)
            }
        }
    }
    
    func fetchGeneratedImage(for prompt: String, completion: @escaping (UIImage?) -> Void) {
        
        print("Fetching image for prompt: \(prompt)")
                
                // Check if the prompt is empty
                if prompt.isEmpty {
                    print("Empty prompt received, aborting image fetch.")
                    completion(nil)
                    return
                }
        
        // add style
        let prompt = CurrentParameters.sharedInstance.getStyle()+prompt
        print("Prompt with style is: \(prompt)")
        
        let urlString = "https://image.pollinations.ai/prompt/\(prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        print("Generated URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        print("Starting URLSession data task...")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error)")
                completion(nil)
                self.displayErrorInDictation(errorCode: "Error fetching image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                print("Image fetched successfully for prompt: \(prompt)")
                completion(image)
                self.curImage = image
                self.addStoryFrame(frameImage: self.curImage!, frameText: self.textList[self.curTextInd])
                self.curTextInd = self.curTextInd+1
                if self.getNumPanelsInStory() > 1 {
                    self.getPrevFrameButton.isHidden = false
                }
            } else {
                print("Failed to fetch image for prompt: \(prompt) - no data or invalid image.")
                self.displayErrorInDictation(errorCode: "Failed to fetch image for prompt: \(prompt) - no data or invalid image.")
                completion(nil)
            }
        }.resume()
    }
    
//    func getCurPrompt() -> String{
//        return self.curPrompt
//    }
//    
//    func getCurImage() -> UIImage{
//        return self.curImage!
//    }
//    
    // loads any image requested
    func displayCurFrame(displayImage: UIImage, displayString: String) {
        self.imageView.image = displayImage
        self.dictLabel.text = displayString
    }
    
    //create story frame
    func addStoryFrame(frameImage: UIImage, frameText: String) {
        let frameImage:UIImage = frameImage
        let frameText:String = frameText
        frame = StoryFrameModel(image: frameImage, text: frameText)
        storyPanels.append(frame!)
        curPanelIndex = storyPanels.count-1
    }
    
    //move back one frame and show it
    func getPreviousFrame() {
        if curPanelIndex > 0 {
            curPanelIndex = curPanelIndex-1
            let newFrame:StoryFrameModel = storyPanels[curPanelIndex]
            displayCurFrame(displayImage: newFrame.getImage(), displayString: newFrame.getText())
        }else {
            print("Reached the first story panel")
        }
    }
    
    //move up one frame and show it
    func getNextFrame() {
        if curPanelIndex < storyPanels.count-1 {
            curPanelIndex = curPanelIndex+1
            let newFrame:StoryFrameModel = storyPanels[curPanelIndex]
            displayCurFrame(displayImage: newFrame.getImage(), displayString: newFrame.getText())
        }else{
            print("Reached the most recent story panel")
        }
    }
    
    //delete the current frame and show previous frame if possible
    func deleteFrame(){
        // tests to make sure there is another frame that can be shown
        if storyPanels.count > 1{
            storyPanels.remove(at: curPanelIndex)
            
            // loads previous frame unless frame deleted was the first
            if curPanelIndex > 0 {
                getPreviousFrame()
            } else {
                getNextFrame()
            }
            
//            curPanelIndex = curPanelIndex-1
        }else if storyPanels.count > 0 {
            storyPanels.remove(at: curPanelIndex)
            curPanelIndex = curPanelIndex-1
        }else {
            print("No more frames to delete")
        }
    }
    
    
    // get functions
    func getCurPanelIndex() -> Int{
        return curPanelIndex
    }
    
    func getNumPanelsInStory() -> Int{
        return storyPanels.count
    }
    
    func getPanelList() -> [StoryFrameModel]{
        return storyPanels
    }
    
    func displayErrorInDictation(errorCode: String) {
        self.dictationLabel.text = errorCode
    }
    
}
