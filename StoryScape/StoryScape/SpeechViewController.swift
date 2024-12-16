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

class SpeechViewController: UIViewController{
    
//    @IBOutlet weak var StoryType: UIPickerView!

    // MARK: Properties
    private var storyPanels: [StoryFrameModel] = [] //stores lists of frames
    private var storyPanelsDict: [Int: [String]] = [:] //stores lists of frames as dictionary
    
    @IBOutlet weak var saveStory: UIButton!
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var getNextFrameButton: UIButton!
    @IBOutlet weak var getPreviousFrameButton: UIButton!
    
    var Speech: SpeechModel?
    
    // MARK: UI LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dictation.adjustsFontSizeToFitWidth = true
//        Speech = SpeechModel(dictLabel: dictation, imageView: imageView, nextButton: getNextFrameButton, dictationLabel: dictation)
//        storyPanels = Speech!.getPanelList()
        
        // starts button as hidden
        self.saveStory.isHidden = true
        self.getNextFrameButton.isHidden = true
        self.getPreviousFrameButton.isHidden = true
        
        Speech = SpeechModel(dictLabel: dictation, imageView: imageView, nextButton: getNextFrameButton, prevButton: getPreviousFrameButton, dictationLabel: dictation)
        storyPanels = Speech!.getPanelList()
        
        
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
        if Speech!.getNumPanelsInStory() > 0 {
            self.getPreviousFrameButton.isHidden = false
        }
    }
    
    // displays previous frame
    @IBAction func getPreviousFrame(_ sender: Any) {
        Speech?.getPreviousFrame()
        if Speech!.getCurPanelIndex() == 0 {
            self.getPreviousFrameButton.isHidden = true
        }else if Speech!.getNumPanelsInStory() > 1{
            self.saveStory.isHidden = true
        }
        self.getNextFrameButton.isHidden = false
        
    }
    

    // displays following frame
    @IBAction func getNextFrame(_ sender: Any) {
        Speech?.getNextFrame()
        if Speech?.getCurPanelIndex() == Speech!.getNumPanelsInStory()-1{
            self.saveStory.isHidden = false
            self.getNextFrameButton.isHidden = true
        }
        self.getPreviousFrameButton.isHidden = false
    }
    
    // deletes current frame
    @IBAction func removeFrame(_ sender: Any) {
        let alert = UIAlertController(title: "My Alert", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .default, handler: { _ in
            //NSLog("The \"OK\" alert occured.")
            self.Speech?.deleteFrame()
            //self.loadView()
            //self.imageView.rel()
            //self.imageView = nil
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { _ in
            //NSLog("The \"OK\" alert occured.")
            //self.Speech?.deleteFrame()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // saves current list of frames - no complete yet
    @IBAction func saveFinishedStory(_ sender: Any) {
        if let button = sender as? UIButton {
            button.setTitle("Saved", for: .normal)
        }
        
        // Creates the local file path
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        print("Documents Directory: \(String(describing: documentsDirectory))")
        let storyTitle = storyTitle.text! + ".json"
        let storyPath = documentsDirectory!.appendingPathComponent(storyTitle)
        print("Story Directory: \(storyPath)")
        
        // preps list of frames in a format that can be saved to a JSON file
        prepFrameList()
        do {
            let jsonData = try JSONEncoder().encode(storyPanelsDict)
                
            // Write JSON data to the file
            try jsonData.write(to: storyPath)
            print("JSON file successfully saved at: \(storyPath)")
        } catch {
            print("Error encoding or saving JSON: \(error)")
        }
        
    }
    
    @IBOutlet weak var dictation: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func prepFrameList() {
        storyPanels = Speech!.getPanelList()
        
        // saves story parameters to dict
        var index: Int = 0
        storyPanelsDict[0] = [CurrentParameters.sharedInstance.getTitle(), getStyleString(stylePrompt: CurrentParameters.sharedInstance.getStyle()), getColorString(color: CurrentParameters.sharedInstance.getColor())]
        index = index+1
        print(storyPanelsDict)
        
        // saves story panels to dict
        for panel in storyPanels{
            storyPanelsDict[index] = [panel.text, panel.image.jpegData(compressionQuality: 1.0)!.base64EncodedString()]
            index = index+1
        }
    }
    
    // changes UIColor to string
    func getColorString(color: UIColor) -> String {
        var colorOutput: String = ""
        
        if (color==UIColor.systemRed){
            colorOutput = "Red"
        } else if (color==UIColor.systemBlue){
            colorOutput = "Blue"
        } else if (color==UIColor.yellow){
            colorOutput = "Yellow"
        } else if (color==UIColor.purple){
            colorOutput = "Purple"
        } else if (color==UIColor.systemOrange){
            colorOutput = "Orange"
        } else if (color==UIColor.black){
            colorOutput = "Black"
        } else if (color==UIColor.gray){
            colorOutput = "Gray"
        } else {
            colorOutput = "Green"
        }
        
        return colorOutput
    }
    
    // changes Style prompt to style name
    func getStyleString(stylePrompt: String) -> String {
        var styleOutput = ""
        
        if (stylePrompt=="Cartoon image of "){
            styleOutput = "Cartoon"
        } else if (stylePrompt=="Black and white image of "){
            styleOutput = "Black and White"
        } else if (stylePrompt=="Comic book style image of "){
            styleOutput = "Comic Book"
        } else if (stylePrompt=="Anime image of "){
            styleOutput = "Anime"
        } else if (stylePrompt=="Pencil sketched image of "){
            styleOutput = "Pencil Sketch"
        } else {
            styleOutput = "Realistic"
        }
        
        return styleOutput
    }
}

