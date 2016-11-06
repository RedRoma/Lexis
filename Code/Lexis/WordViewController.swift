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
import LTMorphingLabel
import RedRomaColors
import Archeota
import UIKit


class WordViewController: UITableViewController
{
    //MARK: Variables
    
    //OUTLETS
    //========================================================================
    @IBOutlet weak var navBarTitleLabel: LTMorphingLabel!
    
    
    //WORDS
    //========================================================================
    internal var word: LexisWord = LexisWord.emptyWord
    {
        didSet
        {
            self.clearAllExpandedCells()
            self.loadImagesForWord()
            self.scrollToTheTop()
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
    
    fileprivate var isViewingImages: Bool = false
    {
        didSet(wasViewingImages)
        {
            if wasViewingImages != isViewingImages //Execute only if the switch changed
            {
                if isViewingImages
                {
                    AromaClient.beginMessage(withTitle: "Images Viewed")
                        .addBody("For Word: ").addBody("\(word.description)")
                        .withPriority(.low)
                        .send()
                }
            }
        }
    }
    
    fileprivate var originalFontSize: CGFloat = 0
    
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

        async.maxConcurrentOperationCount = 1
        loadImagesForWord()
        prepareUI()
        update()
    }
    
    private func prepareUI()
    {
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.clear
        refreshControl?.addTarget(self, action: #selector(self.update), for: .valueChanged)
        
        originalFontSize = navBarTitleLabel.font?.pointSize ?? 0
    }
    
    func update()
    {
        async.addOperation {
            let word = LexisDatabase.instance.anyWord
            
            self.main.addOperation {
                self.word = word
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
        
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
    
    
    //MARK: Create Header Cell
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
            var header = "images"
            if let form = word.forms.first?.lowercased()
            {
                header += " of \(form)"
                
                if images.isEmpty
                {
                    header = "no images found for \(form)"
                }
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
            
            self.share(word: word, in: view, expanded: true)
        }
        
        let settings = Settings.instance
        let pinUpImage = #imageLiteral(resourceName: "Pin-Up")
        let pinDownImage = #imageLiteral(resourceName: "Pin-Down")
        
        if settings.isFavorite(word: word)
        {
            cell.bookmarkButton.image = pinDownImage
        }
        else
        {
            cell.bookmarkButton.image = pinUpImage
        }
        
        
        cell.favoriteCallback = { [word] cell in
            
            let animations: () -> ()
            
            if settings.isFavorite(word: word)
            {
                settings.removeFavoriteWord(word)
                animations = { cell.bookmarkButton.image = pinUpImage }
                AromaClient.sendMediumPriorityMessage(withTitle: "Word Unfavorited", withBody: "\(word)")
            }
            else
            {
                settings.addFavoriteWord(word)
                animations = { cell.bookmarkButton.image = pinDownImage }
                AromaClient.sendMediumPriorityMessage(withTitle: "Word Favorited", withBody: "\(word)")
            }
            
            
            UIView.transition(with: cell, duration: 0.5, options: .transitionCrossDissolve, animations: animations, completion: nil)
            
           
        }
        
        return cell
    }
    
    private func hideBarButton(item: UIBarButtonItem)
    {
        item.tintColor = UIColor.clear
        item.isEnabled = false
    }
    
    private func showBarButton(item: UIBarButtonItem)
    {
        item.tintColor = RedRomaColors.lightPurple
        item.isEnabled = true
    }
    
}

//MARK: Table View Delegate Methods
extension WordViewController
{
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let sizesForSection: [Int: CGFloat] =
        [
            0: 70,
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
            guard let section = SectionsWhenNotSearching.forSection(indexPath.section) else { return false }
            
            switch section
            {
                case .WordTitle, .WordDefinitions, .Images:
                    return true
                default :
                    return false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
        if let searchEntryCell = cell as? SearchEntryCell
        {
            searchEntryCell.searchTextField.text = searchTerm
            searchEntryCell.searchTextField.becomeFirstResponder()
        }
        
        if notSearching && cell is WordNameCell
        {
            notifyAromaWordViewed()
        }
        
        if notSearching
        {
            guard let section = SectionsWhenNotSearching.forSection(indexPath.section),
                  let wordName = word.forms.first?.capitalized
            else { return }
            
            if section == .Images && indexPath.row > 3
            {
                navBarTitleLabel.setTextAndAdjustSize(newText: wordName)
                
                self.isViewingImages = true
            }
            else
            {
                self.isViewingImages = false
            }
            
            if section == .WordTitle
            {
                navBarTitleLabel.setTextAndAdjustIfNotEqualTo(newText: "LEXIS")
                
                if let font = navBarTitleLabel.font
                {
                    navBarTitleLabel.font = font.withSize(originalFontSize)
                }
            }
        }
        
        if isSearching
        {
            navBarTitleLabel.setTextAndAdjustIfNotEqualTo(newText: "LEXIS")
            isViewingImages = false
        }
        
    }
    
    private func notifyAromaWordViewed()
    {
        let firstWord = word.forms.first ?? ""
        AromaClient.beginMessage(withTitle: "Word Viewed")
            .addBody("\(firstWord)").addLine(2)
            .addBody("\(word.description)")
            .withPriority(.low)
            .send()
    }
}

//MARK: Segues
extension WordViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let destination = segue.destination as? WebViewController
        {
            destination.word = self.word
            
            if let image = sender as? FlickrImage, let link = image.webURL
            {
                destination.link = link
            }
            
        }
    }
}


