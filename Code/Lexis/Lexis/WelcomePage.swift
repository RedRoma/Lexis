//
//  WelcomePage.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import RedRomaColors
import Sulcus
import UIKit

class WelcomePage
{
    let title: String
    let subtitle: String
    let image: UIImage
    let lineColor: UIColor
    let isLast: Bool
    
    init(title: String, subtitle: String, image: UIImage, lineColor: UIColor, isLast: Bool = false)
    {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.lineColor = lineColor
        self.isLast = isLast
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
        var isLast = false
        
        static func new() -> Builder
        {
            return Builder()
        }
        
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
        
        func asLast() -> Builder
        {
            self.isLast = true
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
            
            return WelcomePage(title: title, subtitle: subtitle, image: image, lineColor: lineColor, isLast: isLast)
        }
    }
}

extension WelcomePage
{
    static let first = WelcomePage.Builder.new()
        .with(title: "CLASSIC")
        .with(subtitle: "WITH A MODERN FEEL")
        .with(image: #imageLiteral(resourceName: "Art-Open-Book"))
        .with(lineColor: RedRomaColors.blackPrimary)
        .build()
    
    
    static let second = WelcomePage.Builder.new()
        .with(title: "REDISCOVER")
        .with(subtitle: "THE LANGUAGE OF MEANING")
        .with(image: #imageLiteral(resourceName: "Art-Books-On-Shelf"))
        .with(lineColor: Colors.from(hexString: "990808")!)
        .build()
    
    static let third = WelcomePage.Builder.new()
        .with(title: "UNLOCK")
        .with(subtitle: "SECRETS OF THE ANCIENT EMPIRE")
        .with(image: #imageLiteral(resourceName: "Art-Mural"))
        .with(lineColor: RedRomaColors.darkPurple)
        .build()
    
    static let fourth = WelcomePage.Builder.new()
        .with(title: "CONQUER")
        .with(subtitle: "THE LEXICON OF POWER")
        .with(image: #imageLiteral(resourceName: "Art-Cicero"))
        .with(lineColor: RedRomaColors.redPrimary)
        .asLast()
        .build()
    
    static let pages = [first, second, third, fourth]
}
