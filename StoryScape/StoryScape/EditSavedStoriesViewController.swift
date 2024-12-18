//
//  EditSavedStoriesViewController.swift
//  StoryScape
//
//  Created by Rick Lattin on 12/15/24.
//

import UIKit

protocol ModalViewControllerDelegate: AnyObject {
    func didDismissModal()
}

class EditSavedStoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    weak var delegate: ModalViewControllerDelegate?

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
        gradientLayer.colors = [UIColor.systemRed.cgColor, UIColor.darkGray.cgColor] // Start and end colors
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0) // Top-left corner
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)   // Bottom-right corner
        view.layer.insertSublayer(gradientLayer, at: 0)
        
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
        let storyCell = savedStoriesTable.dequeueReusableCell(withIdentifier: "storyDel")
        storyCell!.textLabel!.text = storyList[indexPath.row]
        storyCell!.textLabel?.textColor = UIColor.red
        return storyCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get cell selected
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        let cellName:String = cell.textLabel!.text!
        
        // Creates the local file path
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let storyPath = documentsDirectory!.appendingPathComponent(cellName)
        print("Story Directory: \(storyPath)")
        
        do {
            try fileManager.removeItem(at: storyPath)
        } catch {
            print("Failed to read data from \(storyPath): \(error.localizedDescription)")
        }
        dismissModal()
    }

    func dismissModal() {
        delegate?.didDismissModal()
        self.dismiss(animated: true, completion: nil)
    }
}
