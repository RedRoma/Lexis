//
//  ImageProvider.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import AromaSwiftClient
import Foundation
import LexisDatabase
import Sulcus
import UIKit

protocol ImageProvider
{
    func searchForImage(withWord word: LexisWord) -> URL?
}

extension ImageProvider
{
    func searchForImages(withWord word: LexisWord, numberOfImages number: Int) -> [URL]
    {
        guard number > 0 else { return [] }
        
        let urls = number.times() {
            return self.searchForImage(withWord: word)
        }.flatMap() { return $0 }
        
        LOG.info("Loaded \(urls.count) URLs for word \(word.forms)")
        return urls
    }
    
}

extension UIImage
{
    static func fromURL(url: URL) -> UIImage?
    {
        
        let data: Data
        do
        {
            data = try Data(contentsOf: url)
        }
        catch
        {
            LOG.error("Failed to download Data at \(url): \(error)")
            return nil
        }
        
        guard let image = UIImage(data: data)
        else
        {
            LOG.warn("Failed to convert data at URL \(url) into an Image")
            return nil
        }
        LOG.debug("Successfully downloaded image at \(url)")
        
        return image
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
