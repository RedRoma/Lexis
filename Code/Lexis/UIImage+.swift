//
//  UIImage+.swift
//  Lexis
//
//  Created by Wellington Moreno on 10/31/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Archeota
import AromaSwiftClient
import Foundation
import UIKit

extension UIImage
{
    
    private var nowAsString: String
    {
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        
        return formatter.string(from: now)
    }
    
    func saveImage()
    {
        UIImageWriteToSavedPhotosAlbum(self, self, #selector(self.onSaveComplete(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc
    private func onSaveComplete(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let error = error
        {
            LOG.error("Failed to save image: \(error)")
            AromaClient.sendHighPriorityMessage(withTitle: "Image Save Failed", withBody: "\(error)")
        }
        else
        {
            LOG.info("Image successfully saved")
        }
    }
}
