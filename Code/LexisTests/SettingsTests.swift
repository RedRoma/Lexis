//
//  SettingsTests.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/9/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AlchemyGenerator
import AlchemyTest
import Archeota
import Foundation
@testable import Lexis
import LexisDatabase

class SettingsTests: AlchemyTest
{
    
    fileprivate let instance = Settings.instance
    
    fileprivate var word: LexisWord!
    
    fileprivate static var wordsBeforeTest: [LexisWord] = []
    

    override func beforeEachTest()
    {
        word = LexisDatabase.instance.anyWord
    }

    override class func beforeTests()
    {
        wordsBeforeTest = Settings.instance.favoriteWords
    }

    override class func afterTests()
    {
        Settings.instance.favoriteWords = wordsBeforeTest
    }
    
    func testFavoriteWords()
    {
        let randomWords = AlchemyGenerator.array() { return LexisDatabase.instance.anyWord }
        Settings.instance.favoriteWords = randomWords
        
        assertEquals(Settings.instance.favoriteWords, randomWords)
    }
    
    func testAddWord()
    {
        Settings.instance.addFavoriteWord(word)
        let words = Settings.instance.favoriteWords
        assertThat(words.contains(word))
    }
    
    func testRemoveWord()
    {
        var words = Settings.instance.favoriteWords
        words.append(word)
        Settings.instance.favoriteWords = words
        
        Settings.instance.removeFavoriteWord(word)
        let wordsAfter = Settings.instance.favoriteWords
        
        assertThat(wordsAfter.doesNotContain(word))
        assertEquals(wordsAfter.count, words.count - 1)
    }
}
