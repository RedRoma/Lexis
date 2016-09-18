//
//  WordOfTheDayViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/13/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import LexisDatabase
import Sulcus
import UIKit

class WordOfTheDayViewController: UITableViewController
{
    
    fileprivate var words: [LexisWord] { return [word] }
    fileprivate var word: LexisWord = LexisDatabase.instance.anyWord
    fileprivate var searchResults: [LexisWord] = []
    fileprivate var currentSearchTerm = ""
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        LOG.info("Loaded W.O.D. View Controller")
        self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
        
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
        if notSearching
        {
            return 4
        }
        else
        {
            return 1
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
        
        return cell
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
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if let searchEntryCell = cell as? SearchEntryCell
        {
            searchEntryCell.searchTextField.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        LOG.info("Selected row \(indexPath)")
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
extension WordOfTheDayViewController: UITextFieldDelegate
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
        //For now, a simple table reload
        self.tableView?.reloadData()
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
        if anySearchResults
        {
            //1 for the text field
            //and the others for the search results
            return 1 + searchResults.count
        }
        else
        {
            //1 for the text field
            //and another for the emptyCell
            return 2
        }
    }
    
    fileprivate func createCellWhenSearching(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let row = indexPath.row
      
        if row == 0
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
        
        return emptyCell
    }
    
    private func createSearchTextFieldCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchEntryCell", for: indexPath) as? SearchEntryCell
        else
        {
            LOG.warn("Failed to load SearchEntryCell")
            return emptyCell
        }
        
        cell.searchTextField.delegate = self
        
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
        let indexForWord = row - 1
        
        let word = searchResults[indexForWord]
        
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
        
        return ""
    }
}
