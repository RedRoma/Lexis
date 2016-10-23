//
//  Strings+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import Archeota

extension String
{
    var firstCharacter: String
    {
        return "\(self[startIndex])"
    }
    
    var notEmpty: Bool
    {
        return !isEmpty
    }
    
    func isEmpty() -> Bool
    {
        return notEmpty
    }
    
    var asURL: URL?
    {
        return URL(string: self)
    }
    
    var urlEncoded: String?
    {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed.union(CharacterSet.urlQueryAllowed))
    }
    
    func toURL() -> URL?
    {
        return self.asURL
    }
    
    func removingFirstCharacterIfWhitespace() -> String
    {
        guard self.notEmpty else { return self }
        
        let isWhitespace = firstCharacter.rangeOfCharacter(from: .whitespaces) != nil
        
        if !isWhitespace
        {
            return self
        }
        else
        {
            return self.substring(from: self.index(after: self.startIndex))
        }
        
    }
    
    func capitalizingFirstCharacter() -> String
    {
        guard notEmpty else { return self }
        guard characters.count > 1 else { return firstCharacter.capitalized }
        
        let restOfString = substring(from: self.index(after: startIndex))
        
        return firstCharacter.capitalized + restOfString
    }
    
}


//MARK: JSON Conversion
extension String
{
    func asJSONDictionary() -> NSDictionary?
    {
        do
        {
            guard let data = self.data(using: .utf8) else { return nil }
            
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            return json as? NSDictionary
        }
        catch
        {
            LOG.error("Failed to convert JSON String to dictionary: \(self): \(error)")
            return nil
        }
    }
    
    func asJSONArray() -> NSArray?
    {
        do
        {
            guard let data = self.data(using: .utf8) else { return nil }
            
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json as? NSArray
        }
        catch
        {
            LOG.error("Failed to convert JSON String to array: \(self) : \(error)")
            return nil
        }
    }
}
