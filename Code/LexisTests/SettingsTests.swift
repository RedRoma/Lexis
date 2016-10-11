//
//  SettingsTests.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/9/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AlchemyGenerator
import Archeota
import Foundation
@testable import Lexis
import LexisDatabase
import XCTest

class SettingsTests: XCTestCase
{
    
    fileprivate let instance = Settings.instance
    
    fileprivate var word: LexisWord!
    
    fileprivate static var wordsBeforeTest: [LexisWord] = []
    
    
    override func setUp()
    {
        word = LexisDatabase.instance.anyWord
    }
    
    override class func setUp()
    {
        wordsBeforeTest = Settings.instance.favoriteWords
    }
    
    override class func tearDown()
    {
        Settings.instance.favoriteWords = wordsBeforeTest
    }
    
    
    func testFavoriteWords()
    {
        let randomWords = AlchemyGenerator.array() { return LexisDatabase.instance.anyWord }
        Settings.instance.favoriteWords = randomWords
        
        XCTAssertTrue(Settings.instance.favoriteWords == randomWords)
    }
    
    func testAddWord()
    {
        Settings.instance.addFavoriteWord(word)
        let words = Settings.instance.favoriteWords
        XCTAssertTrue(words.contains(word))
    }
    
    func testRemoveWord()
    {
        var words = Settings.instance.favoriteWords
        words.append(word)
        Settings.instance.favoriteWords = words
        
        Settings.instance.removeFavoriteWord(word)
        let wordsAfter = Settings.instance.favoriteWords
        
        XCTAssertFalse(wordsAfter.contains(word))
        XCTAssertEqual(wordsAfter.count, words.count - 1)
    }
}
