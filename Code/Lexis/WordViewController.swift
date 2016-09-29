//
//  WordOfTheDayViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/13/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import LexisDatabase
import RedRomaColors
import Sulcus
import UIKit


class WordViewController: UITableViewController
{
    
    //WORDS
    //========================================================================
//    internal var words: [LexisWord] { return [word] }
    internal var word: LexisWord = LexisDatabase.instance.anyWord
    {
        didSet
        {
            self.loadImagesForWord()
        }
    }
    
    //SECTIONS
    //========================================================================
    
    enum SectionsWhenNotSearching: Int
    {
        case WordHeader
        case WordTitle
        case WordDefinitions
        case WordDescription
        case Action
        case ImageHeader
        case Images
        
        var section: Int { return rawValue }
        
        static let sections: [SectionsWhenNotSearching] =
        [
            .WordHeader,
            .WordTitle,
            .WordDefinitions,
            .WordDescription,
            .Action,
            .ImageHeader,
            .Images
        ]
        
        static func forSection(_ section: Int) -> SectionsWhenNotSearching?
        {
            guard section >= 0 && section < sections.count else { return nil }
            
            return sections[section]
        }
    }
    
    internal let numberOfSectionsWhenSearching = 2
    /** Header, Title, Definitions, Description, Action, Header, Images */
    internal let numberOfSectionsWhenNotSearching = SectionsWhenNotSearching.sections.count
    
    
    //IMAGES
    //========================================================================
    var images: [FlickrImage] = []
    
    //SEARCH
    //========================================================================
    internal var searchResults: [LexisWord] = []
    internal var searchTerm = ""
    {
        didSet { self.updateSearchResults() }
    }
    
    internal var isSearching = false
    {
        didSet
        {
            self.updateTableForSearch()
        }
    }
    
    internal var notSearching: Bool
    {
        return !isSearching
    }
 

    //ASYNC
    //========================================================================
    internal let main = OperationQueue.main
    internal let async = OperationQueue()
    
    internal var emptyCell = UITableViewCell()
    
    //EXPANDING CELLS
    //========================================================================
    internal var expandedCells: [IndexPath: Bool] = [:]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        loadImagesForWord()
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.update), for: .valueChanged)
    }
    
    func update()
    {
        word = LexisDatabase.instance.anyWord
        clearAllExpandedCells()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
 
}

//MARK: Table View Data Source Methods
extension WordViewController
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
        guard let section = SectionsWhenNotSearching.forSection(indexPath.section) else { return emptyCell }
        
        switch section
        {
            case .WordHeader, .ImageHeader : return createHeaderCell(tableView, atIndexPath: indexPath)
            case .WordTitle         : return createWordTitleCell(tableView, atIndexPath: indexPath)
            case .WordDefinitions   : return createWordDefinitionCell(tableView, atIndexPath: indexPath)
            case .WordDescription   : return createWordDescriptionCell(tableView, atIndexPath: indexPath)
            case .Action            : return createActionsCell(tableView, atIndexPath: indexPath)
            case .Images            : return createImageCell(tableView, atIndexPath: indexPath)
        }
        
        return emptyCell
    }
    
    
    private func createHeaderCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? HeaderCell
        else
        {
            return emptyCell
        }
        
        guard let section = SectionsWhenNotSearching.forSection(indexPath.section) else { return cell }
        
        if section == .WordHeader
        {
            cell.headerTitleLabel.text = "WORD OF THE MOMENT"
            cell.highlightLine.backgroundColor = RedRomaColors.lightPurple
        }
        else if section == .ImageHeader
        {
            var header = "IMAGES"
            if let form = word.forms.first
            {
                header += " OF \(form.uppercased())"
            }
                
            cell.headerTitleLabel.text = header
            cell.highlightLine.backgroundColor = RedRomaColors.lightBlue
        }
        
        return cell
    }
    
    //MARK: Create Word Definition Cell
    private func createWordDefinitionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        if isExpanded(indexPath)
        {
            return createExpandedWordDefinitionCell(tableView, atIndexPath: indexPath)
        }
        else
        {
            return createCollapsedWordDefinitionCell(tableView, atIndexPath: indexPath)
        }
    }
    
    //MARK: Create Word Description Cell
    private func createWordDescriptionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WordDescriptionCell", for: indexPath) as? WordDescriptionCell
        else { return emptyCell }
        
        let wordSynopsis = word.supplementalInformation.humanReadableDescription
        cell.wordDescriptionLabel.text = wordSynopsis
        
        return cell
    }
    
    //MARK: Create Actions Cell
    private func createActionsCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionsCell", for: indexPath) as? ActionsCell
        else
        {
            return emptyCell
        }
        
        cell.toolbar.clipsToBounds = true
        cell.shareCallback = { [word, weak view] cell in
            
            guard let `view` = view else { return }
            
            let titlePath = IndexPath(row: 0, section: 1)
            let titleIsExpanded = self.isExpanded(titlePath)
            
            self.share(word: word, in: view, expanded: titleIsExpanded)
        }
        
        return cell
    }
    
}

//MARK: Table View Delegate Methods
extension WordViewController
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
        return isSearching ? 0.0001 : 15
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return isSearching ? 0.0001 : 15
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
        else
        {
            if isExpandable(indexPath: indexPath)
            {
                if isExpanded(indexPath)
                {
                    collapse(atIndexPath: indexPath)
                }
                else
                {
                    expand(atIndexPath: indexPath)
                }
            }
            
            if isImageCell(indexPath: indexPath)
            {
                showImage(atIndexPath: indexPath)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        
        if isSearching
        {
            let searchFieldRow = IndexPath(item: 0, section: 0)
         
            if noSearchResults
            {
                return false
            }
            else
            {
                return indexPath != searchFieldRow
            }
        }
        else
        {
            let highlightedSection = indexPath.section
            let headerSection = 0
            let wordDescriptionSection = 3
            
            return highlightedSection != headerSection && highlightedSection != wordDescriptionSection
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if let searchEntryCell = cell as? SearchEntryCell
        {
            searchEntryCell.searchTextField.text = nil
            searchEntryCell.searchTextField.becomeFirstResponder()
        }
        
        if notSearching && cell is WordNameCell
        {
            AromaClient.beginMessage(withTitle: "Word Viewed")
                .addBody("\(word.forms.first!)").addLine(2)
                .addBody("\(word.description)")
                .withPriority(.low)
                .send()
        }
    }
}

//MARK: Segues
extension WordViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destination = segue.destination as? WebViewController
        {
            if let image = sender as? FlickrImage, let link = image.webURL
            {
                destination.link = link
            }
        }
    }
}


//MARK: TextField Delegate
extension WordViewController: UITextFieldDelegate
{

    func editingDidChange(_ textField: UITextField)
    {
        let text = textField.text ?? ""
        self.searchTerm = text
    }
    
}
