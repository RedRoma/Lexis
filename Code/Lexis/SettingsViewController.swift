//
//  SettingsViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import Archeota
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
        let app = UIApplication.shared
        LOG.info("Opening URL at \(url)")
        app.open(url, options: [:], completionHandler: nil)
        
        AromaClient.sendMediumPriorityMessage(withTitle: "Settings Link Clicked", withBody: "\(url)")
    }
}
