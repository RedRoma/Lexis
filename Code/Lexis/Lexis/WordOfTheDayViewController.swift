//
//  WordOfTheDayViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/13/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import LexisDatabase
import RedRomaColors
import Sulcus
import UIKit

class WordOfTheDayViewController: UITableViewController
{
    
    fileprivate var words: [LexisWord] { return [word] }
    fileprivate var word: LexisWord = LexisDatabase.instance.anyWord
    fileprivate var searchResults: [LexisWord] = []
    fileprivate var searchTerm = ""
    {
        didSet { self.updateSearchResults() }
    }
    
    fileprivate let main = OperationQueue.main
    fileprivate let async = OperationQueue()
    
    fileprivate var emptyCell = UITableViewCell()
    
    //MARK: Searching
    fileprivate var isSearching = false
    {
        didSet
        {
            self.updateTableForSearch()
        }
    }
    
    fileprivate var notSearching: Bool
    {
        return !isSearching
    }
    
    fileprivate let numberOfSectionsWhenSearching = 2
    fileprivate let numberOfSectionsWhenNotSearching = 4
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        LOG.info("Loaded W.O.D. View Controller")
//        self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.update), for: .valueChanged)
    }
    
    func update()
    {
        word = LexisDatabase.instance.anyWord
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
 
}

//MARK: Table View Data Source Methods
extension WordOfTheDayViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if isSearching
        {
            return numberOfSectionsWhenSearching
        }
        else
        {
            return numberOfSectionsWhenNotSearching
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isSearching
        {
            return numberOfRowsWhenSearching(atSection: section)
        }
        else
        {
            return numberOfRowsWhenNotSearching(atSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if notSearching
        {
            let cell = createCellWhenNotSearching(tableView, atIndexPath: indexPath)
            return cell
        }
        else
        {
            let cell = createCellWhenSearching(tableView, atIndexPath: indexPath)
            return cell
        }
    }
    
    private func createCellWhenNotSearching(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let section = indexPath.section
        
        switch section
        {
            case 0 : return createHeaderCell(tableView, atIndexPath: indexPath)
            case 1 : return createWordTitleCell(tableView, atIndexPath: indexPath)
            case 2 : return createWordDefinitionCell(tableView, atIndexPath: indexPath)
            case 3: return createFooterCell(tableView, atIndexPath: indexPath)
            default : break
        }
        
        return emptyCell
    }
    
    
    private func createHeaderCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath)
        return cell
    }
    
    private func createWordTitleCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as? WordNameCell
        else { return emptyCell }
        
        let title = word.forms.first ?? "Accipio"
        cell.wordNameLabel.text = title
        cell.wordInformationLabel.text = wordTypeInfo(for: word)
        
        return cell
    }
    
    private func createWordDefinitionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefinitionCell", for: indexPath) as? WordDefinitionCell
        else { return emptyCell }
        
        let row = indexPath.row
        let definition = word.definitions[row]
        
        let definitionText = "‣ " + definition.terms.joined(separator: ", ")
        cell.definitionLabel.text = definitionText
        styleDefinitionCell(cell, for: indexPath)
        
        return cell
    }
    
    private func styleDefinitionCell(_ cell: WordDefinitionCell, for indexPath: IndexPath)
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
    
    private func createFooterCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordDescriptionCell", for: indexPath) as? WordDescriptionCell
        else { return emptyCell }
        
        return cell
    }
    
}

//MARK: Table View Delegate Methods
extension WordOfTheDayViewController
{
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let sizesForSection: [Int: CGFloat] =
        [
            0: 80,
            1: 100,
            2: 50,
            3: 80
        ]
        
        let section = indexPath.section
        
        return sizesForSection[section] ?? 80
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return isSearching ? 0.0001 : 20
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return isSearching ? 0.0001 : 20
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if let searchEntryCell = cell as? SearchEntryCell
        {
            searchEntryCell.searchTextField.text = nil
            searchEntryCell.searchTextField.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        LOG.info("Selected row \(indexPath)")
        
        let row = indexPath.row
        
        if isSearching
        {
            let index = row
            guard index >= 0 && index < searchResults.count else { return }
            
            let word = searchResults[index]
            self.word = word
            self.isSearching = false
            self.searchTerm = ""
        }
        
    }
}

//MARK: Word Information
fileprivate extension WordOfTheDayViewController
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

//MARK: Search Logic
extension WordOfTheDayViewController
{
    
    fileprivate var anySearchResults: Bool
    {
        return searchResults.notEmpty
    }
    
    @IBAction func onSearch(_ sender: AnyObject)
    {
        isSearching = !isSearching
    }
    
    fileprivate func updateTableForSearch()
    {
        let wasSearching = !isSearching
        
        if isSearching
        {
            let sectionsToReload = IndexSet.init(integersIn: 0...1)
            let sectionsToRemove = IndexSet.init(integersIn: 2...3)
            
            self.tableView.beginUpdates()
            self.tableView.deleteSections(sectionsToRemove, with: .bottom)
            self.tableView.reloadSections(sectionsToReload, with: .automatic)
            self.tableView.endUpdates()
        }
        else if wasSearching
        {
            let sectionsToReload = IndexSet.init(integersIn: 0...1)
            let sectionsToAdd = IndexSet.init(integersIn: 2...3)
            
            self.tableView.beginUpdates()
            self.tableView.insertSections(sectionsToAdd, with: .bottom)
            self.tableView.reloadSections(sectionsToReload, with: .automatic)
            self.tableView.endUpdates()
        }
        else
        {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func numberOfRowsWhenNotSearching(atSection section: Int) -> Int
    {
        switch section
        {
            case 0, 1, 3 : return 1
            default : break
        }
        
        let numberOfDefinitions = words.first!.definitions.count
        return numberOfDefinitions
    }
    
    fileprivate func numberOfRowsWhenSearching(atSection section: Int) -> Int
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
    
    fileprivate func createCellWhenSearching(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
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
    
    private func createEmptySearchResultsCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let emptySearchCell = tableView.dequeueReusableCell(withIdentifier: "SearchEmptyCell", for: indexPath) as? SearchEmptyCell
        else
        {
            LOG.error("Failed to load SearchEmptyCell")
            return emptyCell
        }
        
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
    
    fileprivate func updateSearchResults()
    {
        guard searchTerm.notEmpty
        else
        {
            return
        }
        
        self.async.addOperation
        { [weak self, searchTerm] in
            
            let results = LexisDatabase.instance.seaarchForms(startingWith: searchTerm)
                .first(numberOfElements: 200)
            
            guard let `self` = self else { return }
            
            self.main.addOperation
            {
                self.searchResults = results
                let searchResultsSection = IndexSet(integer: 1)
                self.tableView?.reloadSections(searchResultsSection, with: .automatic)
            }
        }
    }
}

//MARK: TextField Delegate
extension WordOfTheDayViewController: UITextFieldDelegate
{

    func editingDidChange(_ textField: UITextField)
    {
        let text = textField.text ?? ""
        self.searchTerm = text
    }
    
}
