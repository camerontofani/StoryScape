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
    private var storyPanels: [StoryFrameModel] = [] //stores lists of frames
    private var storyPanelsText: [Int: String] = [:] //stores lists of frame text as dictionary
    private var storyPanelsImage: [Int: String] = [:] // stores lists of frame image urls as dictionary
    
    @IBOutlet weak var saveStory: UIButton!
    
    @IBOutlet weak var storyTitle: UILabel!
    
    var Speech: SpeechModel?
    
    // MARK: UI LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

