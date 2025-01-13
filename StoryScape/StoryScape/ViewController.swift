//
//  ViewController.swift
//  StoryScape
//
//  Created by Cameron Tofani on 12/7/24.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var pollinationsLink: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        self.pollinationsLink.isUserInteractionEnabled = true
        let pollLinkGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        pollLinkGesture.numberOfTapsRequired = 1
        self.pollinationsLink.addGestureRecognizer(pollLinkGesture)
        
        requestPermissions()
        print("Main ViewController loaded successfully")
        
    }
    
    @IBAction func startNewStoryTapped(_ sender: UIButton) {   //start new story, opens speech vc
    }
    
    @IBAction func seeSavedStories(_ sender: Any) {
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        if let url = URL(string: "https://pollinations.ai") {
            print("Can open URL")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Failed to create URL.")
        }
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
