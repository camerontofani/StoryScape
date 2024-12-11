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
    
    @IBOutlet weak var storyTitle: UILabel!
    
    var Speech: SpeechModel?
    
    // MARK: UI LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Speech = SpeechModel(dictLabel: dictation, imageView: imageView)
        
        
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
    }
    
    @IBAction func getPreviousFrame(_ sender: Any) {
        Speech?.getPreviousFrame()
    }
    
    @IBOutlet weak var dictation: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}

