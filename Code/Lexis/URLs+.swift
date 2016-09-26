//
//  URLs+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/25/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import Sulcus


extension URL
{
    var string: String? { return downloadToString() }
    var data: Data? { return downloadToData() }
    
    func downloadToString() -> String?
    {
        do
        {
            return try String(contentsOf: self)
        }
        catch
        {
            LOG.error("Failed to download string from \(self): \(error)")
            return nil
        }
    }
    
    func downloadToData() -> Data?
    {
        do
        {
            return try Data(contentsOf: self)
        }
        catch
        {
            LOG.error("Failed to download data from \(self): \(error)")
            return nil
        }
    }
    
    func downloadToImage() -> UIImage?
    {
        guard let data = downloadToData() else { return nil }
        
        if let image = UIImage(data: data)
        {
            return image
        }
        else
        {
            LOG.error("Failed to download image from: \(self)")
            return nil
        }
    }
}
