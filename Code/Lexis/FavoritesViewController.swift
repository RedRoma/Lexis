//
//  FavoriteViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/9/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import Foundation
import LexisDatabase
import UIKit

class FavoritesViewController: UITableViewController
{
    
    fileprivate var favoriteWords: [LexisWord] = []
    
    fileprivate var noFavoriteWords: Bool { return favoriteWords.isEmpty }
    
    override func viewDidLoad()
    {
        LOG.debug("Loading favorite words...")
        loadFavorites()
        LOG.debug("Loaded favorite words.")
    }
    
    func loadFavorites()
    {
        self.favoriteWords = Settings.instance.favoriteWords
        self.reloadSection(0)
    }
}

//MARK: Table View Data Source Methods
extension FavoritesViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if noFavoriteWords
        {
            return 1
        }
        else
        {
            return favoriteWords.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let emptyCell = UITableViewCell()
        
        if noFavoriteWords
        {
            return tableView.dequeueReusableCell(withIdentifier: "NoFavoritesCell", for: indexPath)
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell") as? FavoriteWordCell else
        {
            LOG.error("Failed to dequeue FavoriteWordsCell")
            return emptyCell
        }
        
        let row = indexPath.row
        guard row >= 0 && row < favoriteWords.count else { return emptyCell }
        
        let word = favoriteWords[row]
        guard let firstForm = word.forms.first else { return emptyCell }
        
        cell.wordLabel.text = firstForm
        cell.wordInformationLabel.text = word.wordTypeInfo
        
        return cell
    }
}

//MARK: Table View Delegate Methods
extension FavoritesViewController
{
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if noFavoriteWords
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
    
        let delete = UITableViewRowAction(style: .destructive, title: "Remove", handler: self.removeWord)
        
        return [delete]
        
    }
    
    private func removeWord(action: UITableViewRowAction, path: IndexPath)
    {
        let row = path.row
        guard row >= 0 && row < favoriteWords.count else { return }
        
        let wordToRemove = favoriteWords[row]
        Settings.instance.removeFavoriteWord(wordToRemove)
        
        self.favoriteWords.removeObject(wordToRemove)
        
        if noFavoriteWords
        {
            self.tableView.reloadRows(at: [path], with: .automatic)
        }
        else
        {
            self.tableView.deleteRows(at: [path], with: .automatic)
        }
    }
}
