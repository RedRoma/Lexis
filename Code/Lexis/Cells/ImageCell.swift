//
//  ImageCell.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UITableViewCell
{
    @IBOutlet weak var cardView: LexisView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    @IBOutlet weak var cardLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoHeightConstraint: NSLayoutConstraint!
    
    private var pressGesture: UILongPressGestureRecognizer! = nil
    private var onLongPress: ((ImageCell) -> Void)?

    func setupLongPressGesture(callback: @escaping (ImageCell) -> Void)
    {
        removeLongPressGesture()
        
        self.onLongPress = callback
        self.pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressGesture(gesture:)))
        self.addGestureRecognizer(pressGesture)
    }
    
    func removeLongPressGesture()
    {
        if let existingGesture = pressGesture
        {
            self.removeGestureRecognizer(existingGesture)
        }
        onLongPress = nil
    }
    
    func onLongPressGesture(gesture: UIGestureRecognizer)
    {
        onLongPress?(self)
    }
}
