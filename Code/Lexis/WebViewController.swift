//
//  WebViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/29/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import Sulcus
import UIKit

class WebViewController: UIViewController
{
    
    @IBOutlet weak var webView: UIWebView!
    var link: URL!
    
    private let main = OperationQueue.main
    private let async = OperationQueue()
    
    override func viewDidLoad()
    {
        guard link != nil else { return }
        
        loadLink()
    }
    
    private func loadLink()
    {
        LOG.info("Loading \(link)")
        
        let request = URLRequest(url: link)
        webView.loadRequest(request)
        
        AromaClient.sendMediumPriorityMessage(withTitle: "Opened Link", withBody: link.absoluteString)
        
    }
}

extension WebViewController: UIWebViewDelegate
{
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        hideNetworkIndicator()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        LOG.error("Failed to load: \(link)")
        
        AromaClient.sendHighPriorityMessage(withTitle: "Failed To Load Link", withBody: "\(link)")
        
        hideNetworkIndicator()
    }
}
