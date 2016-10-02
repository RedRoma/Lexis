//
//  UILabels+.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/1/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UILabel
{
    
    /**
        If the currently set text is different than `newText`,
        this function sets the text of the label and adjusts the size of the font
        to fit the new text.
    */
    func setTextAndAdjustIfNotEqualTo(newText text: String)
    {
        if ((self.text ?? "") != text)
        {
            setTextAndAdjustSize(newText: text)
        }
    }
    
    /**
        Sets the text of the label and adjusts the size of the font
        to fit the new text.
     
        - parameter newText: The new text to set to the label.
     */
    func setTextAndAdjustSize(newText: String)
    {
        self.text = newText
        adjustFontSizeToFitText(newText: newText)
    }
    
    /**
     Does the actual adjustment work.
     */
    func adjustFontSizeToFitText(newText: String) {
        
        guard adjustsFontSizeToFitWidth,
            let originalFont = font,
            let text = self.text
        else { return }
        
        let desiredWidth = getDesiredWidth(forText: text, andFont: originalFont)
        
        if frame.width < desiredWidth {
            // The text does not fit!
            let scaleFactor = max(frame.width / desiredWidth, minimumScaleFactor)
            
            font = UIFont(name: originalFont.fontName, size: originalFont.pointSize * scaleFactor)
        }
        else {
            // Revert to normal
            font = originalFont
        }
    }
    
    /**
     Calculates what the width of the label should be to fit the text.
     
     - parameter text:   Text to fit.
     */
    func getDesiredWidth(forText text: String, andFont font: UIFont) -> CGFloat {
        let size = text.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: frame.height),
            options: [NSStringDrawingOptions.usesLineFragmentOrigin],
            attributes: [NSFontAttributeName: font],
            context: nil).size
        
        return ceil(size.width)
    }
}
