//
//  WordViewControllers+Images.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import AlchemyGenerator
import Foundation
import LexisDatabase
import Archeota


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

fileprivate let samplePhotos = [ #imageLiteral(resourceName: "Sample-1"), #imageLiteral(resourceName: "Sample-2"), #imageLiteral(resourceName: "Sample-3") ]

fileprivate let maxImages = 50

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
            
            let images: [FlickrImage] = imageProvider.searchFlickrForImages(withWord: word)
            
            self.main.addOperation
            {
                defer { self.hideNetworkIndicator() }
                
                self.images = images
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
            cell.photoImageView?.image = AlchemyGenerator.anyOf(samplePhotos)
        }
        else
        {
            let row = indexPath.row
            
            guard row >= 0 && row < images.count else { return emptyCell }
            guard let url = images[row].imageURL else { return emptyCell }
            
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

extension WordViewController
{
    
    func isImageCell(indexPath: IndexPath) -> Bool
    {
        guard images.notEmpty else { return false }
        guard let section = SectionsWhenNotSearching.forSection(indexPath.section) else { return false }
        
        return section == .Images
    }
    
    func shareImage(atIndexPath indexPath: IndexPath)
    {
        guard images.notEmpty else { return }
        
        guard let imageCell = self.tableView.cellForRow(at: indexPath) as? ImageCell
        else
        {
            return
        }
        
        shareImage(atCell: imageCell, indexPath: indexPath)
    }
    
    func showImage(atIndexPath indexPath: IndexPath)
    {
        guard images.notEmpty else { return }
        
        let row = indexPath.row
        
        if row.isValidIndexFor(array: images)
        {
            let image = images[row]
            goToImage(image)
        }
    }
    
    private func shareImage(atCell cell: ImageCell, indexPath: IndexPath)
    {
        guard let image = cell.photoImageView.image else { return }
        
        let row = indexPath.row
        guard row >= 0 && row < images.count else { return }
        
        guard let url = images[row].imageURL else { return }
        
        LOG.info("Sharing image: \(url)")
        
        AromaClient.beginMessage(withTitle: "Sharing Image")
            .addBody("For word:").addLine()
            .addBody("\(word.description)").addLine(2)
            .addBody("\(url)")
            .withPriority(.medium)
            .send()
        
        
        guard let controller = createShareController(forImage: image, atURL: url) else { return }
        
        if isPhone
        {
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
        else if isPad
        {
            // Change Rect to position Popover
            controller.modalPresentationStyle = .popover
            
            guard let popover = controller.popoverPresentationController else { return }
            popover.permittedArrowDirections = .any
            popover.sourceView = cell.photoImageView
            
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
        
    }
    
    private func createShareController(forImage image: UIImage, atURL url: URL) -> UIActivityViewController?
    {
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            
            let activity =  activity?.rawValue ?? ""
            
            if success
            {
                AromaClient.beginMessage(withTitle:"Image Shared")
                    .withPriority(.high)
                    .addBody("At").addLine()
                    .addBody("\(url)").addLine(2)
                    .addBody("To Activity: ").addLine()
                    .addBody("\(activity)")
                    .send()
            }
            else if let error = error
            {
                AromaClient.beginMessage(withTitle:"Image Share Failed")
                    .withPriority(.high)
                    .addBody("At").addLine()
                    .addBody("\(url)").addLine(2)
                    .addBody("\(error)")
                    .send()
            }
            else
            {
                AromaClient.beginMessage(withTitle:"Image Share Canceled")
                    .withPriority(.low)
                    .addBody("At").addLine()
                    .addBody("\(url)").addLine(2)
                    .addBody("\(error)")
                    .send()
            }
        }
        
        return activityViewController
    }
}

//MARK: Segues
fileprivate extension WordViewController
{
    func goToImage(_ flickerImage: FlickrImage)
    {
        self.performSegue(withIdentifier: "ToWebView", sender: flickerImage)
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
