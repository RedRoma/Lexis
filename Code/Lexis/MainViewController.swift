//
//  MainViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AlchemyGenerator
import AromaSwiftClient
import Foundation
import LexisDatabase
import LTMorphingLabel
import NVActivityIndicatorView
import RedRomaColors
import Archeota
import UIKit

class MainViewController: UIViewController
{
    
    @IBOutlet weak var progressIndicator: NVActivityIndicatorView!
    @IBOutlet weak var messageLabel: LTMorphingLabel!
    
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
        prepareUI()
    }
    
    private func prepareUI()
    {
        self.messageLabel?.morphingDuration = 4.0
        self.messageLabel?.text = nil
        
        let animations: [NVActivityIndicatorType] =
        [
            .ballScale,
            .ballScaleMultiple,
            .ballScaleRipple,
            .ballScaleRippleMultiple,
            .ballClipRotatePulse,
            .ballClipRotateMultiple
        ]
        
        self.progressIndicator.type = AlchemyGenerator.anyOf(animations) ?? .ballScaleRippleMultiple
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if Settings.instance.isFirstTime
        {
            LOG.info("First time running this App.")
            Settings.instance.isFirstTime = false
            
            AromaClient.beginMessage(withTitle: "First Time User")
                .addBody("Showing them the welcome screen")
                .withPriority(.medium)
                .send()
            
            self.startInitializingDictionary { _ in }
            
            goToWelcomeScreen()
            
           return
        }
        
        self.startInitializingDictionary
        { word in
            self.goToApp(with: word)
        }
    
    }
 
    
    private func startInitializingDictionary(_ callback: @escaping (LexisWord) -> Void)
    {
        progressIndicator.startAnimating()
        messageLabel?.text = "Loading Dictionary..."
        
        self.async.addOperation
        {
            let begin = Date()
            LOG.info("Initializing Dictionary")
            
            LexisDatabase.instance.initialize()
            let word = LexisDatabase.instance.anyWord
            
            let delay = abs(begin.timeIntervalSinceNow)
            LOG.info("Database initialization took \(delay) seconds")
            
            let message = AromaClient.beginMessage(withTitle: "LexisDatabase Initialized")
                .addBody("Operation took \(delay.asString(withDecimalPoints: 2)) seconds")
                .withPriority(.low)
            
            let threshold = 3.0
            if delay > threshold
            {
                message.withPriority(.high).send()
            }
            else
            {
                message.withPriority(.low).send()
            }
            
            self.main.addOperation
            {
                self.messageLabel?.text = "Ready."
                self.progressIndicator.stopAnimating()
                callback(word)
            }
        }

    }
}

//MARK: Segues
extension MainViewController
{
    fileprivate func goToWelcomeScreen()
    {
        self.performSegue(withIdentifier: "ToWelcome", sender: self)
    }
    
    fileprivate func goToApp(with word: LexisWord)
    {
        self.performSegue(withIdentifier: "ToApp", sender: word)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let tabBar = segue.destination as? UITabBarController,
           let navBar = tabBar.viewControllers?.first as? UINavigationController,
           let wordVC = navBar.topViewController as? WordViewController,
           let word = sender as? LexisWord
        {
            wordVC.word = word
        }
    }
}
