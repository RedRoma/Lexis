//
//  ImageProvider.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AromaSwiftClient
import Foundation
import LexisDatabase
import UIKit

protocol ImageProvider
{
    func searchForImages(withTerm searchTerm: String) -> [URL]
}

extension ImageProvider
{
    
    func searchForImages(withWord word: LexisWord, limitTo limit: Int = 0) -> [URL]
    {
        guard limit >= 0 else { return [] }
        guard let searchTerm = word.forms.first else { return [] }
        
        let urls = self.searchForImages(withTerm: searchTerm)
        
        LOG.info("Loaded \(urls.count) URLs for word \(word.forms)")
        
        if limit == 0 || urls.count <= limit
        {
            return urls
        }
        else
        {
            return Array(urls[0..<limit])
        }
    }
    
}

extension Int
{
    func times<T>(function: () -> (T)) -> [T]
    {
        guard self > 0 else { return [] }
        guard self > 1 else { return [function()] }
        
        return (1...self).flatMap() { _ in
            return function()
        }
    }
}
