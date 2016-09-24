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
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if Settings.instance.isFirstTime
        {
            LOG.info("First time running this App.")
            
            AromaClient.beginMessage(withTitle: "First Time User")
                .addBody("Showing them the welcome screen")
                .withPriority(.medium)
                .send()
            
            goToWelcomeScreen()
            
            Settings.instance.isFirstTime = false
        }
        else
        {
            LOG.info("This is not the first time this app has run.")
            goToWordOfTheDay()
        }
    }
    
    private func goToWelcomeScreen()
    {
        self.performSegue(withIdentifier: "ToWelcome", sender: self)
        
        initializeDictionary()
        {
            
        }
    }
    
    private func goToWordOfTheDay()
    {
        initializeDictionary()
        {
            self.performSegue(withIdentifier: "ToWordOfTheDay", sender: nil)
        }
    }
    
    private func initializeDictionary(_ callback: @escaping () -> Void) {
        
        progressIndicator.startAnimating()
        
        self.async.addOperation
        {
            let begin = Date()
            LOG.info("Initializing")
            LexisDatabase.instance.initialize()
            
            let delay = abs(begin.timeIntervalSinceNow)
            LOG.info("Database initialization took \(delay) seconds")
            let threshold = 4.0
            
            let message = AromaClient.beginMessage(withTitle: "LexisDatabase Initialized")
                .addBody("Operation took \(delay.asString(withDecimalPoints: 2)) seconds")
                .withPriority(.low)
            
            if delay > threshold
            {
                message.withPriority(.high).send()
            }
            else
            {
                message.withPriority(.medium).send()
            }
            
            self.main.addOperation
            {
                self.progressIndicator.stopAnimating()
                callback()
            }
        }

    }
    
}
