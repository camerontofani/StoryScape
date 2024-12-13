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

class SpeechViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let story_types = ["Cartoon","Realistic","Pencil Sketch"]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return story_types.count;
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {return story_types[row]}
    
    
    @IBOutlet weak var StoryType: UIPickerView!
    
    

    // MARK: Properties
    private var storyPanels: [StoryFrameModel] = [] //stores lists of frames
    private var storyPanelsText: [Int: String] = [:] //stores lists of frame text as dictionary
    private var storyPanelsImage: [Int: String] = [:] // stores lists of frame image urls as dictionary
    
    @IBOutlet weak var saveStory: UIButton!
    
    @IBOutlet weak var storyTitle: UILabel!
    
    var Speech: SpeechModel?
    
    // MARK: UI LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
        StoryType.dataSource = self
        StoryType.delegate = self
=======
        
        Speech = SpeechModel(dictLabel: dictation, imageView: imageView)
        
        
        
        // starts button as hidden
        self.saveStory.isHidden = true
        
        // set background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, CurrentParameters.sharedInstance.getColor().cgColor] // Start and end colors
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0) // Top-left corner
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)   // Bottom-right corner
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        storyTitle.text = CurrentParameters.sharedInstance.getTitle()
        
>>>>>>> rick_branch
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
        
        Speech?.startRecording()
    }
    @IBAction func recordingReleased(_ sender: UIButton) {
        // called on "Touch Up Inside" action
        print("Recording stopped.")
        Speech?.stopRecording()
        
        // set button to display "normal"
        sender.setImage(UIImage(systemName: "mic.circle"), for: .normal)
        sender.backgroundColor = UIColor.white
        
        // show save button in case this is the last frame
        self.saveStory.isHidden = false
    }
    
    // displays previous frame
    @IBAction func getPreviousFrame(_ sender: Any) {
        Speech?.getPreviousFrame()
        if Speech!.getNumPanelsInStory() > 1{
            self.saveStory.isHidden = true
        }
        
    }
    
<<<<<<< HEAD
    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recognitionTask?.finish()
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
        
        var selectedValue = story_types[StoryType.selectedRow(inComponent: 0)]
        print(selectedValue)
        var newPrompt = prompt+" "+selectedValue
        let urlString = "https://image.pollinations.ai/prompt/\(newPrompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        print("Generated URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
=======
    // displays following frame
    @IBAction func getNextFrame(_ sender: Any) {
        Speech?.getNextFrame()
        if Speech?.getCurPanelIndex() == Speech!.getNumPanelsInStory()-1{
            self.saveStory.isHidden = false
        }
    }
    
    // deletes current frame
    @IBAction func removeFrame(_ sender: Any) {
        Speech?.deleteFrame()
    }
    
    // saves current list of frames - no complete yet
    @IBAction func saveFinishedStory(_ sender: Any) {
        if let button = sender as? UIButton {
            button.setTitle("Testing", for: .normal)
>>>>>>> rick_branch
        }
        let fileManager = FileManager.default
        var documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        print("Documents Directory: \(documentsDirectory)")
        let storyTitle = "test.txt"
        let storyPath = documentsDirectory!.appendPathComponent(storyTitle)
        print("Story Directory: \(storyPath)")
        
        // preps list of frames in a format that can be saved to a JSON file
        prepFrameList()
        
    }
    
    @IBOutlet weak var dictation: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    func prepFrameList() {
        storyPanels = Speech!.getPanelList()
        
        var counter: Int = 0
        for panel in storyPanels{
            storyPanelsText[counter] = panel.text
            storyPanelsImage[counter] = panel.image.jpegData(compressionQuality: 1.0)?.base64EncodedString()
            let tempString: String = storyPanelsImage[counter]!
            print("Testing this output: ")
            print(tempString)
            counter = counter+1
        }
    }
    
}

