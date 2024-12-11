//
//  StoryFrameModel.swift
//  StoryScape
//
//  Created by Rick Lattin on 12/11/24.
//

import UIKit

class StoryFrameModel{

    var image: UIImage
    var text: String
    
    
    // MARK: Public Methods
    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
    }
    
    
    // setters
    func setImage(newImage: UIImage) {
        self.image = newImage
    }
    
    func setText(newText: String) {
        self.text = newText
    }
    
    // getters
    func getImage() -> UIImage{
        return self.image
    }
    
    func getText() -> String{
        return self.text
    }
    
}
