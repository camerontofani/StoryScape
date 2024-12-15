//
//  StoryParametersViewController.swift
//  StoryScape
//
//  Created by Rick Lattin on 12/9/24.
//

import UIKit

class StoryParametersViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var storyNameTextField: UITextField!
    
    @IBOutlet weak var stylePicker: UIPickerView!
    @IBOutlet weak var styleTitle: UILabel!
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var colorTitle: UILabel!
    
    var styles = ["Realistic", "Cartoon", "Black and White", "Pencil Sketch", "Comic Book", "Anime"]
    var selectedStyle: String = "Realistic"
    
    var colors = ["Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Black", "Gray"]
    var selectedColor: String = "Green"
    
    var selectedTitle:String = "My Story"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.systemPurple.cgColor] // Start and end colors
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0) // Top-left corner
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)   // Bottom-right corner
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // set up text field for title
        storyNameTextField.delegate = self
        
        // set up picker for styles
        stylePicker.delegate = self
        stylePicker.dataSource = self
        stylePicker.isHidden = true
        stylePicker.tag = 1
        
        // set up picker for colors
        colorPicker.delegate = self
        colorPicker.dataSource = self
        colorPicker.isHidden = true
        colorPicker.tag = 2
    }
    
    @IBAction func runStylePicker(_ sender: Any) {
        if (stylePicker.isHidden){
            stylePicker.isHidden = false
            if let button = sender as? UIButton {
                button.setTitle("Confirm", for: .normal)
            }
        }else{
            stylePicker.isHidden = true
            if let button = sender as? UIButton {
                button.setTitle("Options", for: .normal)
            }
            styleTitle.text = selectedStyle
            styleTitle.textColor = UIColor.red
        }
    }
    
    @IBAction func runColorPicker(_ sender: Any) {
        if (colorPicker.isHidden){
            colorPicker.isHidden = false
            if let button = sender as? UIButton {
                button.setTitle("Confirm", for: .normal)
            }
        }else{
            colorPicker.isHidden = true
            if let button = sender as? UIButton {
                button.setTitle("Options", for: .normal)
            }
            colorTitle.text = selectedColor
            colorTitle.textColor = UIColor.red
        }
    }
    
    @IBAction func startStoryCreation(_ sender: Any) {
        CurrentParameters.sharedInstance.setStyle(inputStyle: selectedStyle)
        CurrentParameters.sharedInstance.setColor(inputColor: selectedColor)
        CurrentParameters.sharedInstance.setTitle(inputTitle: selectedTitle)
        CurrentParameters.sharedInstance.clearStoryPanels()
        
    }
    
    //picker view methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;      //only picking from one component
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
            case 1:
                return styles.count
            case 2:
                return colors.count
            default:
                return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
            case 1:
                return styles[row]
            case 2:
                return colors[row]
            default:
                return nil
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
            case 1:
                selectedStyle = styles[row]
            case 2:
                selectedColor = colors[row]
            default:
                break
        }
    }
    
    
    // text field functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        storyTitle.text = "Story Title: "+storyNameTextField.text!
        selectedTitle = storyNameTextField.text!
        storyNameTextField.resignFirstResponder()
        return true;
    }
    
    
    
    
//    class dropDownBtn: UIButton {
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//        }
//        required init?(code aDecoder: NSCoder)
}
