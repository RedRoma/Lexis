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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteWordsCell") as? FavoriteWordCell else
        {
            LOG.error("Failed to dequeue FavoriteWordsCell")
            return emptyCell
        }
        
        let row = indexPath.row
        guard row >= 0 && row < favoriteWords.count else { return emptyCell }
        
        
        
        return cell
    }
}
