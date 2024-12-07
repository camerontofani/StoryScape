//
//  ViewController.swift
//  StoryScape
//
//  Created by Cameron Tofani on 12/7/24.
//

import UIKit
import Speech

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestPermissions()
        print("Main ViewController loaded successfully")
        
    }
    
    @IBAction func startNewStoryTapped(_ sender: UIButton) {   //start new story, opens speech vc
        performSegue(withIdentifier: "goToSpeech", sender: self)
    }
    
    //need to request permissions before it statrs to record
    func requestPermissions() {
            // Microphone permission for iOS 17+
            AVAudioApplication.requestRecordPermission { granted in
                print(granted ? "Microphone access granted." : "Microphone access denied.")
            }
            
            // Speech recognition permission
            SFSpeechRecognizer.requestAuthorization { authStatus in
                let statusMessages = [
                    SFSpeechRecognizerAuthorizationStatus.authorized: "Speech recognition authorized.",
                    SFSpeechRecognizerAuthorizationStatus.denied: "Speech recognition denied.",
                    SFSpeechRecognizerAuthorizationStatus.restricted: "Speech recognition restricted.",
                    SFSpeechRecognizerAuthorizationStatus.notDetermined: "Speech recognition not determined."
                ]
                print(statusMessages[authStatus] ?? "Unknown authorization status.")
            }
        }
    }
