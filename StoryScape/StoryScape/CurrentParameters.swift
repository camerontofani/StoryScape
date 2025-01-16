//
//  CurrentParameters.swift
//  StoryScape
//
//  Created by Rick Lattin on 12/10/24.
//

import UIKit

class CurrentParameters: NSObject {
    static let sharedInstance = CurrentParameters()
    
    var style = ""
    var color = ""
    var title = ""
    var storyPanels:[StoryFrameModel]? = nil
    var lang = ""
    
    private override init() { }
    
    // setter functions
    func setTitle(inputTitle:String){
        self.title = inputTitle
    }
    
    func setStyle(inputStyle:String){
        self.style = inputStyle
        print(inputStyle)
    }
    
    func setColor(inputColor:String){
        self.color = inputColor
        print(inputColor)
    }
    
    func setStoryPanels(inputList:[StoryFrameModel]){
        self.storyPanels = inputList
        print("Story panels set")
    }
    
    // getter functions
    func getTitle()->String{
        return self.title
    }
    
    func getStyle()->String{
        var styleText = ""
        
        if (style=="Cartoon"){
            styleText = "Cartoon image of "
        } else if (style=="Black and White"){
                styleText = "Black and white image of "
        } else if (style=="Comic Book"){
                styleText = "Comic book style image of "
        } else if (style=="Anime"){
                styleText = "Anime image of "
        } else if (style=="Pencil Sketch"){
                styleText = "Pencil sketched image of "
        } else {
            styleText = "Realistic image of "
        }
        
        return styleText
    }
    
    func getColor()->UIColor{
        var colorOutput: UIColor = UIColor.green
        
        if (color=="Red"){
            colorOutput = UIColor.systemRed
        } else if (color=="Blue"){
            colorOutput = UIColor.systemBlue
        } else if (color=="Yellow"){
            colorOutput = UIColor.yellow
        } else if (color=="Purple"){
            colorOutput = UIColor.purple
        } else if (color=="Orange"){
            colorOutput = UIColor.systemOrange
        } else if (color=="Black"){
            colorOutput = UIColor.black
        } else if (color=="Gray"){
            colorOutput = UIColor.gray
        } else {
            colorOutput = UIColor.systemGreen
        }
        
        return colorOutput
    }
    
    func getStoryPanels()->[StoryFrameModel]{
        let storyPanelList: [StoryFrameModel]? = self.storyPanels
        if let temp = storyPanelList{
            return self.storyPanels!
        } else {
            let emptyList: [StoryFrameModel] = []
            return emptyList
        }
    }
    
    func setLang(inputLang:String){
        self.lang = inputLang
        print("Reading Language: ", self.lang)
    }
    
    func getLang() -> String{
        var langOutput: String = "English"
        
        if (lang=="Spanish"){
            langOutput = "es-ES"
        } else if (lang=="French"){
            langOutput = "fr-FR"
        } else if (lang=="Portuguese"){
            langOutput = "pt-BR"
        } else if (lang=="German"){
            langOutput = "de-DE"
        } else if (lang=="Italian"){
            langOutput = "it-IT"
        } else {
            langOutput = "en-US"
        }
        
        return langOutput
    }
    
    // other functions
    func clearStoryPanels() {
        self.storyPanels = nil
        print("Story Panels parameter cleared")
    }
   
}

