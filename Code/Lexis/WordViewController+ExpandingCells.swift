//
//  WordViewController+ExpandingCells.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import Foundation
import LexisDatabase
import UIKit

//MARK: Expanding Cells
//========================================================================
extension WordViewController
{
    
    //MARK: Word Titles
    func createWordTitleCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        if isExpanded(indexPath)
        {
            return createExpandedWordNameCell(tableView, atIndexPath: indexPath)
        }
        else
        {
            return createCollapsedWordNameCell(tableView, atIndexPath: indexPath)
        }
    }
    
    func createCollapsedWordNameCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordNameCell", for: indexPath) as? WordNameCell
        else { return emptyCell }
        
        let title = word.forms.first ?? "Accipio"
        cell.wordNameLabel.text = title
        cell.wordInformationLabel.text = word.wordTypeInfo.lowercased()
        
        return cell
        
    }
    
    func createExpandedWordNameCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedWordNameCell", for: indexPath) as? ExpandedWordNameCell
        else { return emptyCell }
        
        let names = word.forms.joined(separator: ", ")
        cell.wordNameLabel.text = names
        cell.wordDescriptionLabel.text = word.wordTypeInfo.lowercased()
        
        return cell
    }
    
    //MARK: Word Definitions
    
    func createCollapsedWordDefinitionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefinitionCell", for: indexPath) as? WordDefinitionCell
        else { return emptyCell }
        
        let row = indexPath.row
        guard row.isValidIndexFor(array: word.definitions) else { return cell }
        
        let definition = word.definitions[row]
        
        var definitionText = definition.terms.joined(separator: ", ")
        definitionText = definitionText.removingFirstCharacterIfWhitespace()
        definitionText =  "‣  " + definitionText
        
        cell.definitionLabel.text = definitionText
        cell.styleDefinitionCell(forWord: word, for: indexPath)
        
        return cell
    }
    
    func createExpandedWordDefinitionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedDefinitionCell", for: indexPath) as? ExpandedDefinitionCell
        else
        {
            return emptyCell
        }
        
        let row = indexPath.row
        guard row.isValidIndexFor(array: word.definitions) else { return cell }
        
        let definition = word.definitions[row]
        
        var definitionText = definition.terms.joined(separator: ", ")
        definitionText = definitionText.removingFirstCharacterIfWhitespace()
        
        cell.definitionTextView.text = definitionText
        
        
        return cell
    }
    
    
    
    func isExpandable(indexPath: IndexPath) -> Bool
    {
        guard notSearching else { return false }
        
        guard let section = SectionsWhenNotSearching.forSection(indexPath.section) else {
            return false
        }
        
        switch section
        {
            case .WordTitle, .WordDefinitions, .Images : return true
            default : return false
        }
    }
    
    func isExpanded(_ indexPath: IndexPath) -> Bool
    {
        return self.expandedCells[indexPath] != nil
    }
    
    func expand(atIndexPath indexPath: IndexPath)
    {
        self.expandedCells[indexPath] = true
        
        guard let section = SectionsWhenNotSearching.forSection(indexPath.section) else { return }
        
        switch section
        {
            case .WordTitle, .WordDefinitions:
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .Images:
                self.expandImageCell(tableView, at: indexPath)
            default :
                return
        }
    }
    
    func collapse(atIndexPath indexPath: IndexPath)
    {
        self.expandedCells[indexPath] = nil
        
        guard let section = SectionsWhenNotSearching.forSection(indexPath.section) else { return }
        
        switch section
        {
            case .WordTitle, .WordDefinitions :
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .Images:
                self.collapseImageCell(tableView, at: indexPath)
            default :
                return
        }
    }
    
    func clearAllExpandedCells()
    {
        self.expandedCells.removeAll()
    }
    
}


//MARK: Word Information
fileprivate extension WordViewController
{
    
    
    
}
