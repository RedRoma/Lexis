//
//  ActionsCell.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit

class ActionsCell: UITableViewCell
{
    @IBOutlet weak var cardView: LexisView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var shareCallback: ((ActionsCell) -> Void)?
    var favoriteCallback: ((ActionsCell) -> Void)?
    
    @IBAction func onShare(_ sender: AnyObject) {
        shareCallback?(self)
    }
}
