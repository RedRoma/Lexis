//
//  ImageProviderTests.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AlchemyTest
import Foundation
@testable import Lexis
import XCTest

class ImageProviderTests: AlchemyTest
{
    let link = "http://static1.comicvine.com/uploads/original/8/81965/1753719-kingdomcomehd.jpg".asURL!
    
    private func testImageLoads()
    {
        let image = link.downloadToImage()
        assertNil(image)
    }
}
