//
//  WelcomePageTemplateViewController.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import Sulcus
import UIKit


class WelcomePageTemplateViewController : UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var decorativeDivider: UIView!
    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    
    var pageInfo: WelcomePage!
    var index = 0
    var onDoneCallback: ((WelcomePageTemplateViewController) -> (Void))?
    
    override func viewDidLoad()
    {
        guard pageInfo != nil
        else
        {
            LOG.error("Welcome Page info is unset")
            self.dismiss()
            return
        }
        
        setInfo()
    }
    
    private func dismiss()
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func clearInfo()
    {
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    private func setInfo()
    {
        titleLabel.text = pageInfo.title
        subtitleLabel.text = pageInfo.subtitle
        decorativeDivider.backgroundColor = pageInfo.lineColor
        artImageView.image = pageInfo.image
        
        doneButton.isHidden = !pageInfo.isLast
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        onDoneCallback?(self)
        
    }
}
