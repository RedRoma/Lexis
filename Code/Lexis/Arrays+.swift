
//
//  Arrays+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/17/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation


extension Array
{
    var notEmpty: Bool
    {
        return !isEmpty
    }
    
    func first(numberOfElements number: Int) -> [Element]
    {
        guard number < count else { return self }
        
        let subArray = Array(self[0..<number])
        
        return subArray
    }
    
    mutating func prepend(_ element: Element)
    {
        self.insert(element, at: 0)
    }
}

extension Array where Element: Equatable
{
   mutating  func removeObject(_ object: Element)
    {
        if let index = self.index(of: object)
        {
            self.remove(at: index)
        }
    }
}
