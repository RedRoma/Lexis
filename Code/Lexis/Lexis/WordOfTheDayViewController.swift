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
    
    fileprivate var words: [LexisWord] = [LexisDatabase.instance.anyWord]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        LOG.info("Loaded W.O.D. View Controller")
    }
}

//MARK: Table View Data Source Methods
extension WordOfTheDayViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
            case 0, 1, 3 : return 1
            default : break
        }
        
        let numberOfDefinition = words.first!.definitions.count
        return numberOfDefinition
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let emptyCell = UITableViewCell()
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath)
        
        return cell
    }
    
    private func createWordDefinitionCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefinitionCell", for: indexPath)
        
        return cell
    }
    
    private func createFooterCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordDescriptionCell", for: indexPath)
        return cell
    }
    
}
