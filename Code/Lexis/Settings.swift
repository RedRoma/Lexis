//
//  Settings.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/6/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import LexisDatabase
import UIKit


class Settings
{
    static let instance = Settings()
    
    
    private let userDefaults = UserDefaults()
    
    var isFirstTime: Bool
    {
        get
        {
            return (userDefaults.object(forKey: Keys.isFirstTime) as? Bool) ?? true
        }
        set(value)
        {
            userDefaults.set(value, forKey: Keys.isFirstTime)
        }
    }
    
    var favoriteWords: [LexisWord]
    {
        get
        {
            guard let favoritesArray = userDefaults.array(forKey: Keys.favoriteWords) as? NSArray
            else
            {
                return []
            }
            
            return favoritesArray
                .flatMap() { $0 as? NSDictionary }
                .flatMap() { LexisWord(json: $0) }
            
        }
        set(favorites)
        {
            let favoritesArray: [NSDictionary] = favorites.flatMap() { $0.json }
            let favoritesNSArray = NSArray(array: favoritesArray)
            userDefaults.set(favoritesNSArray, forKey: Keys.favoriteWords)
        }
    }
    
    func addFavoriteWord(_ word: LexisWord)
    {
        var words = favoriteWords
        words.prepend(word)
        
        self.favoriteWords = words
    }
    
    func removeFavoriteWord(_ word: LexisWord)
    {
        var words = favoriteWords
        
        if let index = words.index(of: word)
        {
            words.remove(at: index)
        }
        
        self.favoriteWords = words
    }
    
    func isFavorite(word: LexisWord) -> Bool
    {
        return favoriteWords.contains(word)
    }
    
    private init()
    {
        
    }
    
    func clear()
    {
        userDefaults.removeObject(forKey: Keys.isFirstTime)
        userDefaults.removeObject(forKey: Keys.favoriteWords)
    }
    
}


private class Keys
{
    static let domain = "tech.redroma.Lexis"
    
    static let isFirstTime = domain + ".firstTime"
    
    static let favoriteWords = domain + ".favoriteWords"

}
