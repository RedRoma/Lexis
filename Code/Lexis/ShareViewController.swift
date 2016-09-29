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
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard word != nil else { return 0 }
        
        switch section
        {
            case 0, 1, 3: return 1
            case 2: return word.definitions.count
            default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let section = indexPath.section
    
        let isHeaderRow = section == 0
        let isWordNameRow = section == 1
        let isDefinitionRow = section == 2
        let isWordDescriptionRow = section == 3
        
        if isHeaderRow
        {
            return createHeaderCell(tableView, atIndexPath: indexPath)
        }
        else if isWordNameRow
        {
            return createWordNameCell(tableView, atIndexPath: indexPath)
        }
        else if isDefinitionRow
        {
            return createWordDefinitionCell(tableView, atIndexPath: indexPath)
        }
        else if isWordDescriptionRow
        {
            return createWordDescriptionCell(tableView, atIndexPath: indexPath)
        }
        else
        {
            return emptyCell
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
        let index = row
        
        guard index >= 0 && index < word.definitions.count else { return emptyCell }
    
        let definition = word.definitions[index]
        cell.definitionLabel.text = definition.terms.joined(separator: ", ")
        cell.styleDefinitionCell(forWord: word, for: indexPath)
        
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

//MARK: Table View Delegate Methods
extension ShareViewController
{
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}
