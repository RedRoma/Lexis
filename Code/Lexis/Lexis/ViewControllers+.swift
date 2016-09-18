//
//  ViewControllers+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/17/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController
{
    
    func hideNetworkIndicator()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func showNetworkIndicator()
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}
