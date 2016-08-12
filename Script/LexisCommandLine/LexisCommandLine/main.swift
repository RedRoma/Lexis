//
//  main.swift
//  LexisCommandLine
//
//  Created by Wellington Moreno on 8/5/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation


let manager = FileManager.default
let bundle = Bundle.main

let files = bundle.pathsForResources(ofType: nil, inDirectory: nil)
print("Resources:\n")
files.forEach() { print($0) }
print()



func loadDictionary() -> String?
{
    let dictionaryName = "LatinDictionary"
    let ext = "txt"

    do
    {
        guard let url = bundle.urlForResource(dictionaryName, withExtension: ext)
        else
        {
            print("Failed to load Dictionary")
            return nil
        }
        
        return try String(contentsOf: url, encoding: .utf8)
    }
    catch let ex
    {
        print("Failed to load Dictionary: \(ex)")
    }
    
    return nil
}

func splitLines(file: String) -> [String]
{
    return file.components(separatedBy: "\n")
}

print("Loading Dictionary")

if let dictionary = loadDictionary()
{
    print("Loaded Dictionary")
    
    let lines = splitLines(file: dictionary)
    print("Found \(lines.count) lines in Dictionary")
}

