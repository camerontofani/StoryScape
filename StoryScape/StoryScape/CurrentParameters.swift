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
            colorOutput = UIColor.red
        } else if (color=="Blue"){
            colorOutput = UIColor.blue
        } else if (color=="Yellow"){
            colorOutput = UIColor.yellow
        } else if (color=="Purple"){
            colorOutput = UIColor.purple
        } else if (color=="Orange"){
            colorOutput = UIColor.orange
        } else if (color=="Black"){
            colorOutput = UIColor.black
        } else if (color=="Gray"){
            colorOutput = UIColor.gray
        } else {
            colorOutput = UIColor.green
        }
        
        return colorOutput
    }
    
    func getStoryPanels()->[StoryFrameModel]{
        return self.storyPanels!
    }
    
    // other functions
    func clearStoryPanels() {
        self.storyPanels = nil
        print("Story Panels parameter cleared")
    }
   
}

