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
    
    @IBOutlet weak var langPicker: UIPickerView!
    
    @IBOutlet weak var langTitle: UILabel!
    
    var styles = ["Realistic", "Cartoon", "Black and White", "Pencil Sketch", "Comic Book", "Anime"]
    var selectedStyle: String = "Realistic"
    
    var colors = ["Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Black", "Gray"]
    var selectedColor: String = "Green"
    
    var languages = ["English", "Spanish", "French", "Portuguese", "German", "Italian"]
    var selectedLang: String = "English"
    
    var selectedTitle:String = "My Story"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // set up picker for colors
        langPicker.delegate = self
        langPicker.dataSource = self
        langPicker.isHidden = true
        langPicker.tag = 3
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
                button.setTitle("Select a style", for: .normal)
            }
            styleTitle.text = selectedStyle
            styleTitle.textColor = UIColor.systemPurple
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
                button.setTitle("Select a color", for: .normal)
            }
            colorTitle.text = selectedColor
            colorTitle.textColor = UIColor.systemPurple
        }
    }
    
    @IBAction func runLang(_ sender: Any) {
        if (langPicker.isHidden){
            langPicker.isHidden = false
            if let button = sender as? UIButton {
                button.setTitle("Confirm", for: .normal)
            }
        }else{
            langPicker.isHidden = true
            if let button = sender as? UIButton {
                button.setTitle("Select a language", for: .normal)
            }
            langTitle.text = selectedLang
            langTitle.textColor = UIColor.systemPurple
        }
    }
    
    @IBAction func startStoryCreation(_ sender: Any) {
        CurrentParameters.sharedInstance.setStyle(inputStyle: selectedStyle)
        CurrentParameters.sharedInstance.setColor(inputColor: selectedColor)
        CurrentParameters.sharedInstance.setLang(inputLang: selectedLang)
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
            case 3:
                return languages.count
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
            case 3:
                return languages[row]
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
            case 3:
                selectedLang = languages[row]
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
}
