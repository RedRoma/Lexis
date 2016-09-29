//
//  Integers+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/29/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import UIKit

extension Int
{
    func isValidIndexFor<T>(array: [T]) -> Bool
    {
        guard array.notEmpty else { return false }
        
        let index = self
        
        return index >= 0 && index < array.count
    }
}
