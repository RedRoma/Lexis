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
    @IBOutlet weak var definitionLabel5: UILabel!
    
    private var definitionLabels: [UILabel]
    {
        return [definitionLabel1, definitionLabel2, definitionLabel3, definitionLabel4, definitionLabel5]
    }
    
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
        definitionLabels.forEach() { $0.isHidden = true }
    }
    
    private func show(_ view: UIView)
    {
        view.isHidden = false
    }
    
    private func setDefinitions(_ definitions: [String])
    {
        let amount = definitions.count
        
        guard amount > 0 else { return }
        
        for (index, definition) in definitions.enumerated()
        {
            guard index.isValidIndexFor(array: definitionLabels) else { continue }
            
            let text = definition.removingFirstCharacterIfWhitespace()
            
            let label = definitionLabels[index]
            show(label)
            label.text = "‣  \(text)"
        }
    }
}
