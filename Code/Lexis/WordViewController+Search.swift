//
//  WordViewController+Search.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AlchemyGenerator
import AromaSwiftClient
import Foundation
import LexisDatabase
import Archeota
import UIKit


//MARK: Search Logic
extension WordViewController
{

    private var bookArt: [UIImage]
    {
        return [#imageLiteral(resourceName: "Book-On-Floor-Open-1"), #imageLiteral(resourceName: "Book-On-Floor-Open-3"), #imageLiteral(resourceName: "Book-Black-Open"), #imageLiteral(resourceName: "Books-On-Shelf")]
    }
    
    private var emptyBookArt: UIImage?
    {
        return AlchemyGenerator.anyOf(bookArt)
    }
    
    internal var anySearchResults: Bool
    {
        return searchResults.notEmpty
    }
    
    internal var noSearchResults: Bool
    {
        return !anySearchResults
    }
    
    @IBAction func onSearch(_ sender: AnyObject)
    {
        isSearching = !isSearching
    }
    
    internal func updateTableForSearch()
    {
        let wasSearching = !isSearching
        
        if isSearching
        {
            AromaClient.sendLowPriorityMessage(withTitle: "Search Enabled")
            
            self.clearAllExpandedCells()
            
            let sectionsToReload: [SectionsWhenNotSearching] = [ .WordHeader, .WordTitle ]
            let sectionsToRemove: [SectionsWhenNotSearching] = [.WordDefinitions, .WordDescription, .Action, .ImageHeader, .Images]
            
            let reload = IndexSet.init(sectionsToReload.map() { $0.rawValue })
            let delete = IndexSet.init(sectionsToRemove.map() { $0.rawValue })
            
            self.tableView.beginUpdates()
            self.tableView.deleteSections(delete, with: .bottom)
            self.tableView.reloadSections(reload, with: .automatic)
            self.tableView.endUpdates()
            
            self.scrollToTheTop()
        }
        else if wasSearching
        {
            let sectionsToReload: [SectionsWhenNotSearching] = [ .WordHeader, .WordTitle ]
            let sectionsToAdd: [SectionsWhenNotSearching] = [.WordDefinitions, .WordDescription, .Action, .ImageHeader, .Images]
            
            let reload = IndexSet.init(sectionsToReload.map() { $0.rawValue })
            let add = IndexSet.init(sectionsToAdd.map() { $0.rawValue })
            
            self.tableView.beginUpdates()
            self.tableView.insertSections(add, with: .bottom)
            self.tableView.reloadSections(reload, with: .automatic)
            self.tableView.endUpdates()
        }
        else
        {
            self.tableView.reloadData()
        }
    }
    
    internal func numberOfRowsWhenNotSearching(atSection section: Int) -> Int
    {
        guard let `section` = SectionsWhenNotSearching.forSection(section) else { return 0 }
        
        switch section
        {
            case .WordHeader, .WordTitle, .WordDescription, .Action, .ImageHeader:
                return 1
            case .WordDefinitions:
                return word.definitions.count
            case .Images:
                return images.notEmpty ? images.count : 1 //Include an image when no results are found
        }
        
    }
    
    internal func numberOfRowsWhenSearching(atSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        
        if anySearchResults
        {
            return  searchResults.count
        }
        else
        {
            //This is one is for the empty art view
            return 1
        }
    }
    
    internal func createCellWhenSearching(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let section = indexPath.section
        
        //Is the Search Text Field
        if section == 0
        {
            return createSearchTextFieldCell(tableView, atIndexPath: indexPath)
        }
      
        if anySearchResults
        {
            return createSearchResultCell(tableView, atIndexPath: indexPath)
        }
        else
        {
            return createEmptySearchResultsCell(tableView, atIndexPath: indexPath)
        }
        
    }
    
    private func createSearchTextFieldCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchEntryCell", for: indexPath) as? SearchEntryCell
        else
        {
            LOG.warn("Failed to load SearchEntryCell")
            return emptyCell
        }
        
        cell.searchTextField.addTarget(self, action: #selector(self.editingDidChange(_:)), for: .editingChanged)
        cell.searchTextField.text = self.searchTerm
        
        return cell
    }
    
    private func createSearchResultCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell
        else
        {
            LOG.error("Could not load SearchResultCell")
            return emptyCell
        }
        
        let row = indexPath.row
        
        let word = searchResults[row]
        
        cell.wordLabel.text = word.forms.first!
        
        let wordInfo = shortDescription(for: word)
        cell.wordInformationLabel.text = wordInfo
        
        return cell
    }
    
    internal func createEmptySearchResultsCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let emptySearchCell = tableView.dequeueReusableCell(withIdentifier: "SearchEmptyCell", for: indexPath) as? SearchEmptyCell
        else
        {
            LOG.error("Failed to load SearchEmptyCell")
            return emptyCell
        }
        
        let animations = {
            emptySearchCell.artImageView.image = self.emptyBookArt
        }
        
        UIView.transition(with: emptySearchCell.artImageView, duration: 0.6, options: .transitionCrossDissolve, animations: animations, completion: nil)
        
        return emptySearchCell
    }
    
    private func shortDescription(for word: LexisWord) -> String
    {
        let type = word.wordType
        
        switch type
        {
            case .Adjective:
                return "(Adj)"
            
            case .Adverb:
                return "(Adv)"
           
            case .Conjunction:
                return "(Conj)"
            
            case .Interjection:
                return "(Interj)"
            
            case let .Noun(_, gender) :
                return "(Noun, \(gender.letter))"
           
            case .Numeral:
                return "(Num)"
            
            case .PersonalPronoun:
                return "(Pers. Pron)"
           
            case .Preposition:
                return "(Prep)"
            
            case .Pronoun:
                return "(Pron)"
            
            case let .Verb(conjugation, verbType):
                let verbTypeShort = verbType.shortName
                return "(V) (\(conjugation.shortNumber)) (\(verbTypeShort))"
           
            default:
                break
        }
        
        return "(Uknwn)"
    }
    
    internal func updateSearchResults()
    {
        guard searchTerm.notEmpty
        else
        {
            return
        }
        
        self.async.cancelAllOperations()
        self.showNetworkIndicator()
        self.async.addOperation
        { [weak self, searchTerm] in
            
            defer { self?.hideNetworkIndicator() }
            
            //First search words starting with
            var results = LexisDatabase.instance.searchForms(startingWith: searchTerm).first(numberOfElements: 200)
            
            //If no results, search through for words containing the search term.
            //At this point they could be at any position.
            if results.isEmpty
            {
                results = LexisDatabase.instance.searchForms(withTerm: searchTerm).first(numberOfElements: 200)
            }
            
            //If still no results, search through the word's definition.
            //This might happen, for example, if the user enters an English word
            if results.isEmpty
            {
                results = LexisDatabase.instance.searchDefinitions(withTerm: searchTerm).first(numberOfElements: 100)
            }
            
            guard let `self` = self else { return }
            
            self.main.addOperation
            {
                self.searchResults = results
                let searchResultsSection = IndexSet(integer: 1)
                self.tableView?.reloadSections(searchResultsSection, with: .automatic)
            }
        }
        
        AromaClient.beginMessage(withTitle: "Searched")
            .withPriority(.low)
            .addBody("User searched for: ").addBody(searchTerm)
            .send()
    }
    
    internal func scrollToTheTop(animated: Bool = true)
    {
        let beginning = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: beginning, at: .top, animated: animated )
    }
    
    internal func enableScrolling()
    {
        tableView?.isScrollEnabled = true
    }
    
    internal func disableScrolling()
    {
        tableView.isScrollEnabled = false
    }
}


//MARK: TextField Delegate
extension WordViewController: UITextFieldDelegate
{

    @objc
    func editingDidChange(_ textField: UITextField)
    {
        let text = textField.text ?? ""
        self.searchTerm = text
    }
    
}
