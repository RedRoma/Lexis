//
//  WordViewController+ExpandingCells.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit

//MARK: Expanding Cells
//========================================================================
extension WordViewController
{
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
        
        var definitionText = definition.terms.joined(separator: "\n")
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
    
    
    func isDefinitionCell(indexPath: IndexPath) -> Bool
    {
        guard notSearching else { return false }
        
        let section = indexPath.section
        return section == 2
    }
    
    func isExpanded(_ indexPath: IndexPath) -> Bool
    {
        return self.expandedCells[indexPath] != nil
    }
    
    func expandDefinition(atIndexPath indexPath: IndexPath)
    {
        self.expandedCells[indexPath] = true
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func collapseDefinition(atIndexPath indexPath: IndexPath)
    {
        self.expandedCells[indexPath] = nil
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func clearAllExpandedCells()
    {
        self.expandedCells.removeAll()
    }
    
    
}
