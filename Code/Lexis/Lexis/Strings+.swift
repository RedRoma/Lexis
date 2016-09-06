//
//  Strings+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation


extension String
{
    var notEmpty: Bool
    {
        return !isEmpty
    }
    
    func isEmpty() -> Bool
    {
        return notEmpty
    }
    
    var asUrl: URL?
    {
        return URL(string: self)
    }
    
    func toURL() -> URL?
    {
        return self.asUrl
    }
}
