//
//  Doubles+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/24/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation


extension Double
{
    
    func asString(withDecimalPoints points: Int = 2) -> String
    {
        return String.init(format: "%0.\(points)f", self)
    }
}
