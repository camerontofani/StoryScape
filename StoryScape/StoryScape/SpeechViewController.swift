//
//  SpeechViewController.swift
//  StoryScape
//
//  Created by Cameron Tofani on 12/7/24.
//

import UIKit
import AVFoundation
import Speech

// starter code used from https://github.com/darjeelingsteve/speech-recognition

class SpeechViewController: UIViewController {

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
    
    private var storyPanels: [String] = []  //for now, jsut to store each string spoken as a "panel"->updated in recocnitionResultHandler
    

    // MARK: UI LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.systemPurple.cgColor] // Start and end colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0) // Top-left corner
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)   // Bottom-right corner
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // can also be changed at runtime via storyboard!!
        //self.dictation.layer.masksToBounds = true
        //self.dictation.layer.cornerRadius = 2
    }
    
    // MARK: UI Elements
    @IBAction func recordingPressed(_ sender: UIButton) {
        // called on "Touch Down" action
        print("Recording started.")
        // set button to display "recording"
        sender.setImage(UIImage(systemName: "mic.circle.fill"), for: .normal)
        sender.backgroundColor = UIColor.gray
        
        self.startRecording()
    }
    @IBAction func recordingReleased(_ sender: UIButton) {
        // called on "Touch Up Inside" action
        print("Recording stopped.")
        self.stopRecording()
        
        // set button to display "normal"
        sender.setImage(UIImage(systemName: "mic.circle"), for: .normal)
        sender.backgroundColor = UIColor.white
    }
    
    @IBOutlet weak var dictation: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}

// MARK: SFAudioTranscription
extension SpeechViewController {

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
            
            // perform on device, if possible
            // NOTE: this will usually limit the voice analytics results
            if speechRecogniser.supportsOnDeviceRecognition {
                print("Using on device recognition, voice analytics may be limited.")
                recognitionRequest?.requiresOnDeviceRecognition = true
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
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
    }
    
    func recognitionResultHandler(result: SFSpeechRecognitionResult?, error: Error?) {
        // if result is not nil, update label with transcript
        if let result = result {
            let spokenText = result.bestTranscription.formattedString
            print("Recognized text: \(spokenText)")
//            DispatchQueue.main.async {
//                // fill in the label here
//                self.dictation.text = spokenText
//            }
            
            if result.isFinal {
                        storyPanels.append(spokenText) // Save the new panel
                        print("Saved panel: \(spokenText)")
                        
                        DispatchQueue.main.async {
                            // Update the dictation label with the full story
                            self.dictation.text = self.storyPanels.joined(separator: " ")
                            
                            self.fetchGeneratedImage(for: spokenText) { [weak self] image in
                                                   DispatchQueue.main.async {
                                                       if let image = image {
                                                           self?.imageView.image = image
                                                       } else {
                                                           print("Failed to fetch image")
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
}

extension SpeechViewController {
    func fetchGeneratedImage(for prompt: String, completion: @escaping (UIImage?) -> Void) {
        
        print("Fetching image for prompt: \(prompt)")
                
                // Check if the prompt is empty
                if prompt.isEmpty {
                    print("Empty prompt received, aborting image fetch.")
                    completion(nil)
                    return
                }
        
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
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                print("Image fetched successfully for prompt: \(prompt)")
                completion(image)
            } else {
                print("Failed to fetch image for prompt: \(prompt) - no data or invalid image.")
                completion(nil)
            }
        }.resume()
    }
}
