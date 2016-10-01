//
//  WordDefinitionCell.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/13/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import LexisDatabase
import UIKit

class WordDefinitionCell: UITableViewCell
{
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var disclosureImageView: UIImageView!
    
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var rightLine: UIView!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    func styleDefinitionCell(forWord word: LexisWord, for indexPath: IndexPath)
    {
        let row = indexPath.row
        let isFirst = row == 0
        let isLast = row == word.definitions.count - 1
        
        bottomLine.isHidden = true
        topLine.isHidden = true
        
        if isFirst
        {
            topLine.isHidden = false
        }
        
        if isLast
        {
            bottomLine.isHidden = false
        }
        
    }
}
