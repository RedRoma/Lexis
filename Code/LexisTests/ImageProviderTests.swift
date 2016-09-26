//
//  ImageProviderTests.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
@testable import Lexis
import XCTest

class ImageProviderTests: XCTestCase
{
    let link = "http://static1.comicvine.com/uploads/original/8/81965/1753719-kingdomcomehd.jpg".asUrl!
    
    override func setUp()
    {
        
    }
    
    private func testImageLoads()
    {
        let image = link.downloadToImage()
        XCTAssertFalse(image == nil)
    }
}
