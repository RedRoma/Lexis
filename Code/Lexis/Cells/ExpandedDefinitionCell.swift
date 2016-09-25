//
//  ExpandedDefinitionCell.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit

class ExpandedDefinitionCell: UITableViewCell
{
    @IBOutlet weak var cardView: LexisView!
    @IBOutlet weak var definitionTextView: UITextView!
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var rightLine: UIView!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
}
