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
import Kingfisher
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

fileprivate var startingCollapsedImageHeight: CGFloat = 5000
fileprivate var collapsedImageHeight: CGFloat = startingCollapsedImageHeight

/**
    This File adds support for Images in the Lexis Dictionary.
 */

//MARK: Loads Images from Flickr for a word
extension WordViewController
{
    private var imagesTitleCell: HeaderCell?
    {
        guard notSearching else { return nil }
        
        let section = SectionsWhenNotSearching.ImageHeader.section
        let path = IndexPath(row: 0, section: section)
        
        return self.tableView?.cellForRow(at: path) as? HeaderCell
    }
    
    func loadImagesForWord()
    {
        showNetworkIndicator()
        imagesTitleCell?.headerTitleLabel?.text = "images loading..."
        
        asyncImageLoads.addOperation
        { [word] in
            
            let images: [FlickrImage] = imageProvider.searchFlickrForImages(withWord: word)
            
            self.main.addOperation
            {
                defer { self.hideNetworkIndicator() }
                
                self.images = images
                let sectionsToReload = [SectionsWhenNotSearching.Images.section, SectionsWhenNotSearching.ImageHeader.section]
                
                if self.notSearching
                {
                    let sections = IndexSet(sectionsToReload)
                    self.tableView.beginUpdates()
                    self.tableView.reloadSections(sections, with: .automatic)
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
        
        loadImage(fromURL: url, intoCell: cell, in: tableView, atIndexPath: indexPath)
        
        //Adjust the collapse ImageHeight only if it hasn't been done before
        if !alreadyRememberedCollapsedHeight()
        {
            let imageHeight = min(collapsedImageHeight, cell.photoHeightConstraint.constant)
            collapsedImageHeight = imageHeight
        }
        
        adjustStyle(for: cell, at: indexPath)
    
        return cell
    }
    
    private func alreadyRememberedCollapsedHeight() -> Bool
    {
        return collapsedImageHeight < startingCollapsedImageHeight
    }
    
    func expandImageCell(_ tableView: UITableView, at indexPath: IndexPath, refreshTable refresh: Bool = true)
    {
        adjustCell(tableView, at: indexPath)
    }
    
    func collapseImageCell(_ tableView: UITableView, at indexPath: IndexPath)
    {
        adjustCell(tableView, at: indexPath)
    }
      
    private func loadImage(fromURL url: URL, intoCell cell: ImageCell, in tableView: UITableView, atIndexPath indexPath: IndexPath)
    {
        let fade = KingfisherOptionsInfoItem.transition(.fade(0.6))
        let scale = KingfisherOptionsInfoItem.scaleFactor(UIScreen.main.scale * 2)
        let options: KingfisherOptionsInfo = [fade, scale]
        
        cell.photoImageView.kf.setImage(with: url, placeholder: nil, options: options, progressBlock: nil, completionHandler: nil)
    }
    
    private func adjustCell(_ tableView: UITableView, at indexPath: IndexPath)
    {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImageCell else { return }
        
        self.adjustStyle(for: cell, at: indexPath, animated: false)
        
        self.refreshTable()
        UIView.animate(withDuration: 0.6)
        {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
        
        notifyImageClicked(at: indexPath)
    }
    
    private func adjustStyle(for cell: ImageCell, at indexPath: IndexPath, animated: Bool = false)
    {
        let isExpanded = self.isExpanded(indexPath)
        
        let adjustments =
        {
            self.adjustSize(for: cell, isExpanded: isExpanded)
            self.adjustColors(for: cell, isExpanded: isExpanded)
            self.adjustContentMode(for: cell, isExpanded: isExpanded)
            self.adjustGestures(for: cell, isExpanded: isExpanded)
        }
        
        if animated
        {
            UIView.animate(withDuration: 0.5, animations: adjustments)
        }
        else
        {
            adjustments()
        }
    }
    
    private func adjustSize(for cell: ImageCell, isExpanded: Bool)
    {
        let tableHeight = tableView?.frame.height ?? collapsedImageHeight
        let expandedHeight = tableHeight
        
        let height = isExpanded ? expandedHeight : collapsedImageHeight
        cell.photoHeightConstraint.constant = height
        
        let cardOffset: CGFloat = isExpanded ? 0 : 8
        cell.cardLeadingConstraint.constant = cardOffset
        cell.cardTrailingConstraint.constant = cardOffset
    }
    
    private func adjustColors(for cell: ImageCell, isExpanded: Bool)
    {
        let color = isExpanded ? RedRomaColors.fullyBlack :  RedRomaColors.white
        cell.photoImageView.backgroundColor = color
    }
    
    private func adjustContentMode(for cell: ImageCell, isExpanded: Bool)
    {
        let contentMode: UIViewContentMode = isExpanded ? .scaleAspectFit : .scaleAspectFill
        cell.photoImageView.contentMode = contentMode
    }
    
    private func adjustGestures(for cell: ImageCell, isExpanded: Bool)
    {
        cell.setupLongPressGesture() { [weak self] cell in
            
            guard let `self` = self else { return }
            guard let path = self.tableView?.indexPath(for: cell) else { return }
            guard let controller = self.createActionSheetFor(cell: cell, at: path) else { return }
            
            self.present(controller, animated: true, completion: nil)
        }
    }

    private func refreshTable()
    {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func notifyImageClicked(at indexPath: IndexPath)
    {
        let expanded = isExpanded(indexPath)
        let row = indexPath.row
        guard row.isValidIndexFor(array: images) else { return }
        
        let title = expanded ? "Image Expanded" : "Image Collapsed"
        
        let image = images[row]
        
        AromaClient.beginMessage(withTitle: title)
            .addBody("For: \(word)").addLine(2)
            .addBody("\(image)")
            .withPriority(.low)
            .send()
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
        
}

//MARK: Action Sheet
fileprivate extension WordViewController
{
    func createActionSheetFor(cell: ImageCell, at indexPath: IndexPath) -> UIAlertController?
    {
        let row = indexPath.row
        guard row.isValidIndexFor(array: images) else { return nil }
        
        let image = images[row]
        
        let sheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        
        let download = UIAlertAction(title: "Download", style: .default) { [path = indexPath, images, word, weak cell] action in
            
            guard let `cell` = cell else { return }
            
            cell.photoImageView.image?.saveImage()
            
            let row = path.row
            guard row.isValidIndexFor(array: images) else { return }
            
            let flickrImage = images[row]
            
            AromaClient.beginMessage(withTitle: "Image Downloaded")
                .addBody("For Word:").addLine()
                .addBody("\(word)").addLine(2)
                .addBody("\(flickrImage)")
                .send()
        }
        
        let openInSafari = UIAlertAction(title: "View", style: .default) { [weak self] action in
            
            guard let `self` = self else { return }
            
            self.showImage(atIndexPath: indexPath)
        }
        
        let shareImage = UIAlertAction(title: "Share", style: .default) { [weak self] action in
            guard let `self` = self else { return }
            
            self.shareImage(atIndexPath: indexPath)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(download)
        sheet.addAction(openInSafari)
        sheet.addAction(shareImage)
        sheet.addAction(cancel)
        
        //For the iPad
        if let popover = sheet.popoverPresentationController, let sourceView = cell.photoImageView
        {
            popover.sourceView = sourceView
            
            let sourceRect = sourceView.bounds
            let center = CGPoint(x: sourceRect.midX, y: sourceRect.midY)
            popover.sourceRect = CGRect(origin: center, size: CGSize.zero)
        }
        
        AromaClient.sendLowPriorityMessage(withTitle: "Action Sheet Created", withBody: "For: \(image)")
        
        return sheet
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

//MARK: Sharing Images
fileprivate extension WordViewController
{
    func shareImage(atCell cell: ImageCell, indexPath: IndexPath)
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
    
    func createShareController(forImage image: UIImage, atURL url: URL) -> UIActivityViewController?
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
