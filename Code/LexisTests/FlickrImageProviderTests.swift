//
//  FlickrImageProviderTests.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AlchemyGenerator
import Foundation
@testable import Lexis
import LexisDatabase
import XCTest

class FlickrImageProviderTests: XCTestCase
{
    let link = "http://static1.comicvine.com/uploads/original/8/81965/1753719-kingdomcomehd.jpg".asURL!
    
    let instance = FlickrImageProvider()
    var word: LexisWord = LexisDatabase.instance.anyWord
    
    let popularTerms =
    [
        "Deadmau5",
        "Rome",
        "Mass Effect",
        "Coffee"
    ]
    
    override func setUp()
    {
        word = LexisDatabase.instance.anyWord
    }
    
    func testSearchAPopularTerm()
    {
        let term = AlchemyGenerator.stringFromList(popularTerms)
        
        let results = instance.searchForImages(withTerm: term)
        
        XCTAssertFalse(results.isEmpty)
        
        XCTAssertTrue(results.count > 1)
    }
    
    func testSearchAWord()
    {
        let results = instance.searchForImages(withWord: word)
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.count > 1)
    }
    
    func testSearchResultsIncludeImages()
    {
        let term = AlchemyGenerator.stringFromList(popularTerms)
        let results = instance.searchForImages(withTerm: term)
        
        guard results.notEmpty else { return }
        
        let anyURL = results.first!
        
        let image = anyURL.downloadToImage()
        
        XCTAssertFalse(image == nil)
        
    }
    
}
