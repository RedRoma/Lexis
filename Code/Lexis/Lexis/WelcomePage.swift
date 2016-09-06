//
//  WelcomePage.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import Sulcus
import RedRomaColors
import UIKit

class WelcomePage
{
    let title: String
    let subtitle: String
    let image: UIImage
    let lineColor: UIColor
    
    init(title: String, subtitle: String, image: UIImage, lineColor: UIColor)
    {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.lineColor = lineColor
    }
    
    
    enum InvalidArgumentException: Error
    {
        case MissingArgument(message: String)
        case EmptyArgument(message: String)
    }
    
    class Builder
    {
        var title: String? = nil
        var subtitle: String? = nil
        var image: UIImage? = nil
        var lineColor: UIColor = RedRomaColors.blackPrimary
        
        
        func with(title: String) -> Builder
        {
            self.title = title
            return self
        }
        
        func with(subtitle: String) -> Builder
        {
            self.subtitle = subtitle
            return self
        }
        
        func with(image: UIImage) -> Builder
        {
            self.image = image
            return self
        }
        
        func with(lineColor: UIColor) -> Builder
        {
            self.lineColor = lineColor
            return self
        }
        
        func build() -> WelcomePage?
        {
            guard let title = title, title.notEmpty
            else
            {
                LOG.warn("Missing Title")
                return nil
            }
            
            guard let subtitle = subtitle, subtitle.notEmpty
            else
            {
                LOG.warn("Missing subtitle")
                return nil
            }
            
            guard let image = image
            else
            {
                LOG.warn("Missing Welcome Page Image")
                return nil
            }
            
            return WelcomePage(title: title, subtitle: subtitle, image: image, lineColor: lineColor)
        }
    }
}
