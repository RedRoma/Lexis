//
//  MainViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import LexisDatabase
import Sulcus
import UIKit

class MainViewController: UIViewController
{
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    private let main = OperationQueue.main
    private let async: OperationQueue =
    {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if Settings.instance.isFirstTime
        {
            LOG.info("First time running this app")
            Settings.instance.isFirstTime = false
        }
        else
        {
            LOG.info("This is not the first time running this App")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if Settings.instance.isFirstTime
        {
            
            AromaClient.beginMessage(withTitle: "First Time User")
                .addBody("Showing them the welcome screen")
                .withPriority(.medium)
                .send()
            
            goToWelcomeScreen()
        }
        else
        {
            goToWordOfTheDay()
        }
    }
    
    private func goToWelcomeScreen()
    {
        self.performSegue(withIdentifier: "ToWelcome", sender: self)
    }
    
    private func goToWordOfTheDay()
    {
        progressIndicator.startAnimating()
        
        self.async.addOperation
        {
            let begin = Date()
            LOG.info("Initializing")
            LexisDatabase.instance.initialize()
            
            let delay = abs(begin.timeIntervalSinceNow)
            LOG.info("Database initialization took \(delay) seconds")
            
            AromaClient.beginMessage(withTitle: "LexisDatabase Initialized")
                .addBody("Operation took \(delay) seconds")
                .withPriority(.low)
                .send()
            
            self.main.addOperation
            {
                self.progressIndicator.stopAnimating()
                self.performSegue(withIdentifier: "ToWordOfTheDay", sender: nil)
            }
        }
        
       
    }
    
}
