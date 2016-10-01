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
    
    @IBOutlet weak var definitionLabel1: UILabel!
    @IBOutlet weak var definitionLabel2: UILabel!
    @IBOutlet weak var definitionLabel3: UILabel!
    @IBOutlet weak var definitionLabel4: UILabel!
    
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
        
        hideDefinitionLabels()
        
        let definitions: [String] = word.definitions.flatMap() { $0.terms.joined(separator: ", ") }
        
        setDefinitions(definitions)
    }
    
    private func hideDefinitionLabels()
    {
        [definitionLabel1, definitionLabel2, definitionLabel3, definitionLabel4].forEach() { $0?.isHidden = true }
    }
    
    private func show(_ view: UIView)
    {
        view.isHidden = false
    }
    
    private func setDefinitions(_ definitions: [String])
    {
        let amount = definitions.count
        
        guard amount > 0 else { return }
        
        if amount >= 1
        {
            let first = definitions[0]
            show(definitionLabel1)
            definitionLabel1.text = "‣  \(first)"
        }
        
        if amount >= 2
        {
            let second = definitions[1]
            show(definitionLabel2)
            definitionLabel2.text = "‣ \(second)"
        }
        
        if amount >= 3
        {
            let third = definitions[2]
            show(definitionLabel3)
            definitionLabel3.text = "‣ \(third)"
        }
        
        if amount >= 4
        {
            let fourth = definitions[3]
            show(definitionLabel4)
            definitionLabel4.text = "‣ \(fourth)"
        }
    }
}
