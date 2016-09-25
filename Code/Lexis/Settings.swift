//
//  Settings.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit


class Settings
{
    static let instance = Settings()
    
    
    private let userDefaults = UserDefaults()
    
    var isFirstTime: Bool
    {
        get
        {
            return (userDefaults.object(forKey: Keys.isFirstTime) as? Bool) ?? true
        }
        set(value)
        {
            userDefaults.set(value, forKey: Keys.isFirstTime)
        }
    }
    
    private init()
    {
        
    }
    
    
    
}


private class Keys
{
    static let domain = "tech.redroma.Lexis"
    
    static let isFirstTime = domain + ".firstTime"

}
