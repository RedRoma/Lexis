//
//  WelcomePage.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
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
        var lineColor: UIColor? = nil
        
        
        
        func build() -> WelcomePage?
        {
            guard let title = title, title.notEmpty
        }
    }
}
