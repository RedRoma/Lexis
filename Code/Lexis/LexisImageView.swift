//
//  LexisImageView.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/30/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import RedRomaColors
import UIKit

@IBDesignable class LexisImageView: UIImageView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func prepareForInterfaceBuilder()
    {
        updateView()
    }
    
    @IBInspectable var circular: Bool = false
    {
        didSet
        {
            updateView()
        }
    }
    
    @IBInspectable var borderThickness: CGFloat = 0
    {
        didSet
        {
            updateView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black
    {
        didSet
        {
            updateView()
        }
    }
    
    @IBInspectable var shouldRasterize: Bool = false
    {
        didSet
        {
            updateView()
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 3, height: 0)
    {
        didSet
        {
            updateView()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = Colors.fromRGBA(red: 0, green: 0, blue: 0, alpha: 50)
    {
        didSet
        {
            updateView()
        }
    }
    
    @IBInspectable var shadowBlur: CGFloat = 4
    {
        didSet
        {
            updateView()
        }
    }
    
    private func updateView()
    {
        
        if circular
        {
            let radius = self.frame.width / 2
            layer.cornerRadius = radius
            layer.masksToBounds = true
        }
        else
        {
            layer.cornerRadius = 0
            layer.masksToBounds = false
        }
        
        layer.borderWidth = borderThickness
        layer.borderColor = borderColor.cgColor
        layer.shouldRasterize = shouldRasterize
        layer.shadowOffset = shadowOffset
        layer.shadowColor = shadowColor.cgColor
        
        
        if shouldRasterize
        {
            layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        updateView()
    }
    
    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        updateView()
    }
    

}
