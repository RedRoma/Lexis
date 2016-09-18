//
//  MainViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

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
            LOG.info("Initializing")
            LexisDatabase.instance.initialize()
            LOG.info("Database initialized")
            
            self.main.addOperation
            {
                self.progressIndicator.stopAnimating()
                self.performSegue(withIdentifier: "ToWordOfTheDay", sender: nil)
            }
        }
        
       
    }
    
}
