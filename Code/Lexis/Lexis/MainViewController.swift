//
//  MainViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import Sulcus
import UIKit

class MainViewController: UIViewController
{
    
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
        self.performSegue(withIdentifier: "ToWordOfTheDay", sender: self)
    }
}
