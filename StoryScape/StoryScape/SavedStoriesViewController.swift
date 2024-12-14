//
//  SavedStoriesViewController.swift
//  StoryScape
//
//  Created by Rick Lattin on 12/9/24.
//

import UIKit

class SavedStoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var savedStoriesTable: UITableView!
    
    var storyList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedStoriesTable.delegate = self
        savedStoriesTable.dataSource = self
        
        savedStoriesTable.backgroundColor = UIColor.clear
        
        // set background color
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.systemPurple.cgColor] // Start and end colors
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0) // Top-left corner
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)   // Bottom-right corner
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        print("UI Color Test:")
        let colorArray = UIColor.systemPurple.cgColor.components
//        let doubleArray = colorArray.map { Double($0) }
        print(UIColor.systemPurple.cgColor.components![0])
//        print(doubleArray)
//        print("String: " + colorArray)
        
        // reading in saved files
        let fileManager = FileManager.default
        var documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        print("Documents Directory: \(String(describing: documentsDirectory))")
        do{
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory!, includingPropertiesForKeys: nil, options: [])
            
            print("Files in the Documents Directory:")
            for fileURL in fileURLs {
                storyList.append(fileURL.lastPathComponent)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let storyCell = savedStoriesTable.dequeueReusableCell(withIdentifier: "story")
        
//        storyCell?.textLabel?.text = storyList[indexPath.row]
        storyCell!.textLabel!.text = storyList[indexPath.row]
        
        return storyCell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Did a Segue YAYYYY!!!")
    }
}
