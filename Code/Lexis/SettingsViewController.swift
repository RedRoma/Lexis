//
//  SettingsViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AromaSwiftClient
import Foundation
import RedRomaColors
import SafariServices
import UIKit

class SettingsViewController: UITableViewController
{
    
    fileprivate let links: [IndexPath: String] =
    [
        IndexPath(row: 1, section: 0) : "http://redroma.tech/",
        IndexPath(row: 1, section: 1) : "http://lexis.redroma.tech/",
        IndexPath(row: 2, section: 1) : "http://github.com/RedRoma/Lexis/"
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        AromaClient.sendLowPriorityMessage(withTitle: "Settings Viewed")
    }
    
}

//MARK: Delegate methods
extension SettingsViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let link = links[indexPath]?.asURL
        {
            openLink(at: link)
        }
        
    }
    
    private func openLink(at url: URL)
    {
        openInternally(url: url)
    }
    
    private func openInternally(url: URL)
    {
        let safari = SFSafariViewController(url: url)
        safari.preferredBarTintColor = RedRomaColors.redPrimary
        safari.preferredControlTintColor = RedRomaColors.white
        safari.tabBarController?.tabBar.isTranslucent = false
        safari.navigationController?.navigationBar.isTranslucent = false
        
        present(safari, animated: true, completion: nil)
        
        AromaClient.sendMediumPriorityMessage(withTitle: "Settings Link Clicked", withBody: "\(url)")
    }
    
    private func openExternally(url: URL)
    {
        let app = UIApplication.shared
        LOG.info("Opening URL at \(url)")
        app.open(url, options: [:], completionHandler: nil)
        
        AromaClient.sendMediumPriorityMessage(withTitle: "Settings Link Clicked", withBody: "\(url)")
    }
}
