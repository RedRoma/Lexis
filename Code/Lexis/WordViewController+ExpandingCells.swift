//
//  WordViewController+ExpandingCells.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import LexisDatabase
import Sulcus
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
        cell.wordInformationLabel.text = wordTypeInfo(for: word)
        
        return cell
        
    }
    
    func createExpandedWordNameCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandedWordNameCell", for: indexPath) as? ExpandedWordNameCell
        else { return emptyCell }
        
        let names = word.forms.joined(separator: ", ")
        cell.wordNameLabel.text = names
        cell.wordDescriptionLabel.text = wordTypeInfo(for: word)
        
        return cell
    }
    
    //MARK: Word Definitions
    
    func createCollapsedWordDefinitionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefinitionCell", for: indexPath) as? WordDefinitionCell
        else { return emptyCell }
        
        let row = indexPath.row
        let definition = word.definitions[row]
        
        var definitionText = definition.terms.joined(separator: ", ")
        definitionText = definitionText.removingFirstCharacterIfWhitespace()
        definitionText =  "‣  " + definitionText
        
        cell.definitionLabel.text = definitionText
        
        styleDefinitionCell(cell, for: indexPath)
        
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
        let definition = word.definitions[row]
        
        var definitionText = definition.terms.joined(separator: ", ")
        definitionText = definitionText.removingFirstCharacterIfWhitespace()
        
        cell.definitionTextView.text = definitionText
        
        
        return cell
    }
    
    func styleDefinitionCell(_ cell: WordDefinitionCell, for indexPath: IndexPath)
    {
        let row = indexPath.row
        let isFirst = row == 0
        let isLast = row == self.word.definitions.count - 1
        
        cell.bottomLine.isHidden = true
        cell.topLine.isHidden = true
        
        if isFirst
        {
            cell.topLine.isHidden = false
        }
        
        if isLast
        {
            cell.bottomLine.isHidden = false
        }
        
    }
    
    func isExpandable(indexPath: IndexPath) -> Bool
    {
        guard notSearching else { return false }
        
        let section = indexPath.section
        return section == 1 || section == 2
    }
    
    func isExpanded(_ indexPath: IndexPath) -> Bool
    {
        return self.expandedCells[indexPath] != nil
    }
    
    func expand(atIndexPath indexPath: IndexPath)
    {
        self.expandedCells[indexPath] = true
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func collapse(atIndexPath indexPath: IndexPath)
    {
        self.expandedCells[indexPath] = nil
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func clearAllExpandedCells()
    {
        self.expandedCells.removeAll()
    }
    
}


//MARK: Word Information
fileprivate extension WordViewController
{
    
    func wordTypeInfo(for word: LexisWord) -> String
    {
        let type = word.wordType
        
        switch type
        {
            case .Adjective :
                return "Adjective"
            case .Adverb:
                return "Adverb"
            case .Conjunction:
                return "Conjunction"
            case .Interjection:
                return "Conjunction"
            case let .Noun(declension, gender):
                return "\(declension.name) Noun, (\(gender.name))"
            case .Numeral:
                return "Numeral"
            case .PersonalPronoun:
                return "Personal Pronoun"
            case let .Preposition(declension):
                return "Preposition \(declension.name)"
            case let .Verb(conjugation, verbType):
                return "Verb \(conjugation.shortNumber) \(verbType.name)"
            default:
                break
        }
        
        
        return ""
    }
    
}
