//
//  TimeIntervals+.swift
//  Lexis
//
//  Created by Wellington Moreno on 11/1/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation

extension TimeInterval
{
    var seconds: Double { return self }
    var minutes: Double { return self * 60 }
    var hours: Double { return minutes * 60 }
    var days: Double { return hours * 24 }
}
