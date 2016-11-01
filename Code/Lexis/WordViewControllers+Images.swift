//
//  WordViewControllers+Images.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AromaSwiftClient
import AlchemyGenerator
import Foundation
import LexisDatabase
import RedRomaColors
import SafariServices


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

fileprivate let samplePhotos = [ #imageLiteral(resourceName: "Art-Mural"), #imageLiteral(resourceName: "Art-Cicero"), #imageLiteral(resourceName: "Art-Vase"), #imageLiteral(resourceName: "Books-On-Shelf") ]

fileprivate let maxImages = 50

fileprivate var collapsedImageHeight: CGFloat = 5000

/**
    This File adds support for Images in the Lexis Dictionary.
 */

//MARK: Loads Images from Flickr for a word
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
}

//MARK: Handles creation of Image Cells
extension WordViewController
{
    func createImageCell(_ tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        if images.isEmpty
        {
            return createEmptyImageCell(tableView, at: indexPath)
        }
        
        return createImageCell(tableView, at: indexPath)
    }
    
    private func createEmptyImageCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return emptyCell
        }
    
        cell.photoImageView?.image = AlchemyGenerator.anyOf(samplePhotos)
        cell.photoImageView.contentMode = .scaleAspectFit
        
        return cell
    }
    
    private func createImageCell(_ tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return emptyCell
        }
     
        let row = indexPath.row
        
        guard row >= 0 && row < images.count else { return emptyCell }
        guard let url = images[row].imageURL else { return emptyCell }
        
        cell.photoImageView.contentMode = .scaleAspectFill
        loadImage(fromURL: url, intoCell: cell, in: tableView, atIndexPath: indexPath)
        
        //Adjust the collapse ImageHeight & remember it
        collapsedImageHeight = min(collapsedImageHeight, cell.photoHeightConstraint.constant)
        
        adjustStyle(for: cell, at: indexPath)
    
        return cell
    }
    
    func expandImageCell(_ tableView: UITableView, at indexPath: IndexPath, refreshTable refresh: Bool = true)
    {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImageCell else { return }
        
        adjustStyle(for: cell, at: indexPath)
        refreshTable()
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func collapseImageCell(_ tableView: UITableView, at indexPath: IndexPath)
    {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImageCell else { return }
        
        adjustStyle(for: cell, at: indexPath)
        refreshTable()
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    private func adjustStyle(for cell: ImageCell, at indexPath: IndexPath)
    {
        let isExpanded = self.isExpanded(indexPath)
        
        adjustHeight(for: cell, isExpanded: isExpanded)
        adjustColors(for: cell, isExpanded: isExpanded)
        adjustContentMode(for: cell, isExpanded: isExpanded)
    }
    
    private func adjustHeight(for cell: ImageCell, isExpanded: Bool)
    {
        let tableHeight = tableView?.frame.height ?? collapsedImageHeight
        var expandedHeight = tableHeight
        
        let height = isExpanded ? expandedHeight : collapsedImageHeight
        cell.photoHeightConstraint.constant = height
    }
    
    private func adjustColors(for cell: ImageCell, isExpanded: Bool)
    {
        let color = isExpanded ? RedRomaColors.fullyBlack :  RedRomaColors.white
//        cell.cardView.borderColor = color
        cell.cardView.backgroundColor = color
    }
    
    private func adjustContentMode(for cell: ImageCell, isExpanded: Bool)
    {
        let contentMode: UIViewContentMode = isExpanded ? .scaleAspectFit : .scaleAspectFill
        cell.photoImageView.contentMode = contentMode
    }

    private func refreshTable()
    {
        tableView.beginUpdates()
        tableView.endUpdates()
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
                    let animations =
                    {
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
        
        guard let cell = tableView?.cellForRow(at: indexPath) as? ImageCell else { return }
        
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
    
    private func openSafari(at url: URL)
    {
        let safari = SFSafariViewController(url: url)
        safari.delegate = self
        safari.preferredBarTintColor = RedRomaColors.redPrimary
        safari.preferredControlTintColor = UIColor.white

        self.present(safari, animated: true, completion: nil)
        AromaClient.sendMediumPriorityMessage(withTitle: "Opened Image Link", withBody: url.absoluteString)
    }
}

extension WordViewController: SFSafariViewControllerDelegate
{
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool)
    {
        LOG.info("Completed initializtion of Image")
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
