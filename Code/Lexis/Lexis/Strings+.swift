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
    
    func removingFirstCharacterIfWhitespace() -> String
    {
        guard self.notEmpty else { return self }
        
        let firstCharacter: String = "\(self[startIndex])"
        
        let isWhitespace = firstCharacter.rangeOfCharacter(from: .whitespaces) != nil
        
        if !isWhitespace
        {
            return self
        }
        else
        {
            return self.substring(from: self.index(after: self.startIndex))
        }
        
    }
}
