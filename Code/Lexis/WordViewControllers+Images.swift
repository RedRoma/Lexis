//
//  WordViewControllers+Images.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import LexisDatabase
import Sulcus


/** Used for searching for images */
fileprivate let imageProvider = FlickrImageProvider()

/** Used for loading images in the background */
fileprivate let asyncImageLoads: OperationQueue =
{
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 5
    
    return queue
}()

fileprivate let main = OperationQueue.main

/**
    This File adds support for Images in the Lexis Dictionary.
 */
extension WordViewController
{
    func loadImagesForWord()
    {
        showNetworkIndicator()
        asyncImageLoads.addOperation
        { [word] in
            
            let urls = imageProvider.searchForImages(withWord: word, limitTo: 25)
            
            
            self.main.addOperation
            {
                defer { self.hideNetworkIndicator() }
                
                self.images = urls
                let sectionToReload = SectionsWhenNotSearching.Images.section
                
                if self.notSearching
                {
                    let section = IndexSet.init(integer: sectionToReload)
                    self.tableView.beginUpdates()
                    self.tableView.reloadSections(section, with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
    }
    
    func createImageCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageCell
        else
        {
            return emptyCell
        }
        
        if images.isEmpty
        {
            cell.photoImageView?.image = #imageLiteral(resourceName: "Sample-1")
        }
        else
        {
            let url = images[indexPath.row]
            
            loadImage(fromURL: url, intoCell: cell, in: tableView, atIndexPath: indexPath)
        }
        
        return cell
    }
    
    private func loadImage(fromURL url: URL, intoCell cell: ImageCell, in tableView: UITableView, atIndexPath indexPath: IndexPath)
    {
        cell.photoImageView.image = nil
        
        asyncImageLoads.addOperation
        {
            guard let image = url.downloadToImage() else { return }
            
            self.main.addOperation
            {
                if tableView.isVisible(indexPath: indexPath)
                {
                    let animations = {
                        cell.photoImageView?.image = image
                        return
                    }
                    
                    UIView.transition(with: cell.photoImageView, duration: 0.6, options: .transitionCrossDissolve, animations: animations, completion: nil)
                }
            }
        }
    }
}

fileprivate extension UITableView
{
    func isVisible(indexPath: IndexPath) -> Bool
    {
        guard let visible = indexPathsForVisibleRows else { return false }
        
        return visible.contains(indexPath)
    }
}
