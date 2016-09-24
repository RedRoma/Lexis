//
//  WordViewController+Sharing.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import LexisDatabase
import Sulcus
import UIKit

extension WordViewController
{
    
    private var isPhone: Bool
    {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    private var isPad: Bool
    {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    func share(word: LexisWord, in tableView: UITableView, expanded: Bool = false)
    {
        
        LOG.info("Sharing word: \(word)")
        
        AromaClient.beginMessage(withTitle: "Sharing Word")
            .addBody("Word:").addLine()
            .addBody("\(word)")
            .withPriority(.medium)
            .send()
        
        guard let image = tableView.screenshot()
        else
        {
            LOG.error("Failed to take screenshot of UITableView")
            AromaClient.sendHighPriorityMessage(withTitle: "Screenshot Failed", withBody: "Could not take screenshot of Table View")
            return
        }
        
        
        guard let controller = createShareController(word: word, andImage: image, expanded: expanded) else { return }
        
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
            
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
    
    private func createShareController(word: LexisWord, andImage image: UIImage, expanded: Bool) -> UIActivityViewController?
    {
        
        let text: String
        if expanded
        {
            text = word.forms.map() { return $0.capitalizingFirstCharacter() }.joined(separator: ", ")
        }
        else
        {
            text = (word.forms.first?.capitalizingFirstCharacter()) ?? ""
        }
        
        // let's add a String and an NSURL
        let activityViewController = UIActivityViewController(
            activityItems: [text, image],
            applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            
            let activity =  activity?.rawValue ?? ""
            
            if success
            {
                AromaClient.beginMessage(withTitle:"Lexis Shared")
                    .withPriority(.high)
                    .addBody("Word:").addLine()
                    .addBody(word.description).addLine(2)
                    .addBody("To Activity: ").addLine()
                    .addBody("\(activity)")
                    .send()
            }
            else if let error = error
            {
                AromaClient.beginMessage(withTitle:"Lexis Share Failed")
                    .withPriority(.high)
                    .addBody("Word:").addLine()
                    .addBody(word.description).addLine(3)
                    .addBody("\(error)")
                    .send()
            }
            else
            {
                AromaClient.beginMessage(withTitle:"Lexis Share Canceled")
                    .withPriority(.low)
                    .addBody("Word:").addLine()
                    .addBody(word.description).addLine(3)
                    .addBody("\(error)")
                    .send()
            }
        }
        
        return activityViewController
    }

}

fileprivate extension UIView
{
    func screenshot() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, 0.0)
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
