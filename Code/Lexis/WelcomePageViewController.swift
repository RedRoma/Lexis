//
//  WelcomePageViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import Archeota
import RedRomaColors
import UIKit

class WelcomePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource
{
    let pages = WelcomePage.pages
    
    private dynamic var currentIndex = 0
    private let minIndex = 0
    private var maxIndex: Int { return pages.count }
    
    override func viewDidLoad()
    {
        self.dataSource = self
        self.delegate = self
        
        guard let firstPage = createViewController(atIndex: currentIndex) else { return }
        self.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
    }
    
    
    //MARK: Page View Controller conformance
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as? WelcomePageTemplateViewController)?.index ?? currentIndex
        index += 1
        
        if index >= maxIndex
        {
            return nil
        }
        
        return createViewController(atIndex: index)
     
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as? WelcomePageTemplateViewController)?.index ?? currentIndex
        index -= 1
        
        if index < minIndex
        {
            return nil
        }
        
        return createViewController(atIndex: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int
    {
        return pages.count
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    {
        if let viewController = pendingViewControllers.first as? WelcomePageTemplateViewController
        {
            self.currentIndex = viewController.index
        }
    }
}

//MARK: Creating View Controllers
private extension WelcomePageViewController
{
    
    func createViewController(atIndex index: Int) -> UIViewController?
    {
        guard index >= 0 else { return nil }
        guard index <= 3 else { return nil }
        
        let pageInfo = pages[index]
        
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WelcomePageTemplate") as? WelcomePageTemplateViewController
        {
            viewController.pageInfo = pageInfo
            viewController.index = index
            
            viewController.onDoneCallback = { _ in
                LOG.info("Dimissing Welcome screens.")
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            
            return viewController
        }
        
        LOG.warn("Failed to load Welcome Page at index \(index)")
        return nil
    }

}

