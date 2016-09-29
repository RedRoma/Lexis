//
//  ShareViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/28/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import LexisDatabase
import RedRomaColors
import Sulcus
import UIKit

class ShareViewController: UITableViewController
{
    
    var word: LexisWord!
    var wordIsExpanded = false
    var expandedDefinitions: [Int] = []
    
    fileprivate var emptyCell = UITableViewCell()
    
    
    override func viewDidLoad()
    {
        guard word != nil else
        {
            LOG.error("View Controller started without LexisWord")
            self.dismiss()
            return
        }
    }
    
    private func dismiss()
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}


//MARK: Table View Data Source Methods
extension ShareViewController
{
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var rows = 1 //For the header
        rows += 1 //For the word title
        rows += word.definitions.count //For the number of definitions
        rows += 1 //For the word description
        
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let row = indexPath.row
        
        switch row
        {
            case 0 : return createHeaderCell(tableView, atIndexPath: indexPath)
            case 1 : return createWordNameCell(tableView, atIndexPath: indexPath)
            case 2...(2 + word.definitions.count) : return createWordDefinitionCell(tableView, atIndexPath: indexPath)
            default : return createWordDescriptionCell(tableView, atIndexPath: indexPath)
        }
    }
    
    private func createHeaderCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? HeaderCell else
        {
            return emptyCell
        }
        
        return cell
    }
    
    private func createWordNameCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordNameCell", for: indexPath) as? WordNameCell else
        {
            return emptyCell
        }
        
        if wordIsExpanded
        {
            let joinedWords = word.forms.joined(separator: ", ")
            cell.wordNameLabel.text = joinedWords
        }
        else
        {
            let firstWord = word.forms.first ?? ""
            cell.wordNameLabel.text = firstWord
        }
        
        cell.wordInformationLabel.text = word.wordTypeInfo
        
        return cell
    }
    
    private func createWordDefinitionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordDefinitionCell", for: indexPath) as? WordDefinitionCell else
        {
            return emptyCell
        }
        
        let row = indexPath.row
        let index = row - 2
        
        guard index >= 0 && index < word.definitions.count else { return emptyCell }
    
        let definition = word.definitions[index]
        cell.definitionLabel.text = definition.terms.joined(separator: ", ")
        
        return cell
    }
    
    private func createWordDescriptionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordDescriptionCell", for: indexPath) as? WordDescriptionCell else
        {
            return emptyCell
        }
        
        let description = word.supplementalInformation.humanReadableDescription
        cell.wordDescriptionLabel.text = description
        
        return cell
    }
}
