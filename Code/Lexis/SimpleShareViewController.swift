//
//  SimpleShareViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/28/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import LexisDatabase
import Sulcus

class SimpleShareViewController: UIViewController
{
    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordTypeLabel: UILabel!
    @IBOutlet weak var wordDefinitionsLabel: UILabel!
    
    var word: LexisWord!
    
    override func viewDidLoad()
    {
        guard word != nil else { return }
        
        setupView()
    }
    
    private func setupView()
    {
        wordNameLabel.text = word.forms.joined(separator: ", ")
        wordTypeLabel.text = word.wordTypeInfo
        
        var definitionsText = ""
        
        for definition in word.definitions
        {
            definitionsText += definition.terms.joined(separator: ", ") + "\n"
        }
        
        wordDefinitionsLabel.text = definitionsText
    }
}
