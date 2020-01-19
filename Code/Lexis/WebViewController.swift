//
//  WebViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/29/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AromaSwiftClient
import Foundation
import LexisDatabase
import UIKit

class WebViewController: UIViewController
{
    @IBOutlet weak var navBarTitleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    var link: URL!
    var word: LexisWord!
    
    private let main = OperationQueue.main
    private let async = OperationQueue()
    
    
    override func viewDidLoad()
    {
        guard link != nil else { return }
        
        webView.delegate = self
        webView.allowsLinkPreview = true
        
        let wordName = word?.forms.first ?? ""
        navBarTitleLabel.text = wordName
        
        loadLink()
    }
    
    private func loadLink()
    {
        LOG.info("Loading [\(link)]")
        showNetworkIndicator()
        
        let request = URLRequest(url: link)
        webView.loadRequest(request)
        
        AromaClient.sendMediumPriorityMessage(withTitle: "Opened Link", withBody: link.absoluteString)
    }
    
    @IBAction func onOpenLink(_ sender: AnyObject)
    {
        guard let link = link else { return }
        
        let app = UIApplication.shared
        app.open(link, options: [:], completionHandler: nil)
        
        AromaClient.sendMediumPriorityMessage(withTitle: "Link Opened In Safari", withBody: "\(link)")
        
        LOG.info("Opening Link in Safari: \(link)")
    }
}

extension WebViewController: UIWebViewDelegate
{
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        hideNetworkIndicator()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool
    {
        
        guard let link = request.url, let scheme = link.scheme else { return true }
        
        let app = UIApplication.shared
        
        let isFlickerLink = link.absoluteString.hasPrefix("https://m.flickr.com") || scheme.hasPrefix("flickr")
        
        if isFlickerLink
        {
            app.open(link)
            return false
        }
        
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        LOG.error("Failed to load: \(link), \(error)")
        
        AromaClient.sendHighPriorityMessage(withTitle: "Failed To Load Link", withBody: "[\(link)] | [\(error)]")
        
        hideNetworkIndicator()
    }
}
