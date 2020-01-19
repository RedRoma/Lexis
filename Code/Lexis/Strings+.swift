//
//  Strings+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AlchemySwift
import Foundation

extension String
{

    var urlEncoded: String?
    {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed.union(CharacterSet.urlQueryAllowed))
    }

    func removingFirstCharacterIfWhitespace() -> String
    {
        guard self.notEmpty else { return self }
        guard let firstLetter = self.firstLetter else { return self }
        
        let isWhitespace = firstLetter.rangeOfCharacter(from: .whitespaces) != nil
        if !isWhitespace
        {
            return self
        }
        else
        {
            return self.withoutFirstLetter() ?? self
        }
    }
    
    func capitalizingFirstCharacter() -> String
    {
        return self.titlecased()
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
