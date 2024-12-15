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
        
        // Creates the local file path
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        var cellName: String = ""
        if let cell = sender as? UITableViewCell{
            cellName = cell.textLabel!.text!
        }
        let storyPath = documentsDirectory!.appendingPathComponent(cellName)
        print("Story Directory: \(storyPath)")
        
        do {
            //
            let jsonData = try Data(contentsOf: storyPath)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
//            print("File contents: \(jsonObject)")
            
            var tempDict: [String: [String]] = [:]
            
            if let jsonDict = jsonObject as? [String: Any] {
                for (key, value) in jsonDict {
                    tempDict[key] = (value as! [String])
                    print("\(key) is holding ---> \(value)")
                    print("\(key) is also holding ---> \(String(describing: tempDict[key]?[0]))")
                }
                
                // set story parameters for transition
                CurrentParameters.sharedInstance.setTitle(inputTitle: tempDict["0"]![0])
                CurrentParameters.sharedInstance.setStyle(inputStyle: tempDict["0"]![1])
                CurrentParameters.sharedInstance.setColor(inputColor: tempDict["0"]![2])
                print("Params: ")
                print(tempDict["0"]![0])
                print("|\(tempDict["0"]![1])|")
                print(tempDict["0"]![2])
                
                // fills out story panels list
                var dictCounter = 0
                var storyPanels: [StoryFrameModel] = []
                for (key, value) in tempDict {
                    if (dictCounter == 0){
                        dictCounter = dictCounter+1
                        print("Reached the zero case!!")
                    } else {
                        let indexString: String = String(dictCounter)
                        print("Index String: \(indexString)")
                        print(tempDict[indexString]![0])
//                        print(tempDict[indexString]![1])
                        print("after wtf-----------------------")
                        
                        // extract data from dictionary
                        let frameText: String = tempDict[indexString]![0]
                        var frameImage: UIImage? = nil
                        if let imageData = Data(base64Encoded: tempDict[indexString]![1]){
                            frameImage = UIImage(data: imageData)!
                        }
                        
                        // save as a storyframe and add to list
                        let curFrame: StoryFrameModel = StoryFrameModel(image: frameImage!, text: frameText)
                        storyPanels.append(curFrame)
                        
                        dictCounter = dictCounter+1
                    }
                }
                
                // assigns panels list to parameters
                CurrentParameters.sharedInstance.setStoryPanels(inputList: storyPanels)
                
                
            } else {
                print("Error: JSON is not a dictionary.")
            }
            
            
            
            
            
//            let storyData = try JSONDecoder().decode([0].self, from: jsonData)
//            var tempDict: [Int: [String]] = [:]
//            if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Int: [String]] {
//                    // Iterate through the dictionary
//                print("Reached")
//                for (key, value) in jsonDict {
////                    if let params = value[0] as? [String], let city = value["city"] as? String {
////                        print("\(key) is \(age) years old and lives in \(city).")
////                    }
//                    tempDict[key] = value
//                    print("\(key) is holding ---> \(value)")
//                }
//            }
        } catch {
            print("Error reading file: \(error)")
        }
        
        
        
        
    }
}
