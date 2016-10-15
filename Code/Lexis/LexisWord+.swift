//
//  LexisWord+.swift
//  Lexis
//
//  Created by Wellington Moreno on 9/17/16.
//  Copyright © 2016 RedRoma, Inc. All rights reserved.
//

import Foundation
import LexisDatabase


extension Conjugation
{
    var shortNumber: String
    {
        let numbers: [Conjugation: String] =
        [
            .First : "1st",
            .Second: "2nd",
            .Third: "3rd",
            .Fourth: "4th",
            .Irregular: "Irreg.",
            .Unconjugated: "Unconjugated"
        ]
        
        return numbers[self] ?? ""
    }
}

extension Gender
{
    var letter: String
    {
        let characters = Array(name.characters)
        
        guard let letter = characters.first else { return "" }
        
        return "\(letter)"
    }
}

extension VerbType
{
    var shortName: String
    {
        let shorts: [VerbType: String] =
        [
            .Deponent: "Dep",
            .Impersonal: "Impers",
            .Intransitive: "Intrans",
            .PerfectDefinite: "Perf. Defin",
            .SemiDeponent: "Semi Dep",
            .Transitive: "Trans",
            .Unknown: "Unkwn"
        ]
        
        return shorts[self] ?? ""
    }
}


extension LexisWord
{
    var wordTypeInfo: String
    {
        let type = self.wordType
        
        switch type
        {
            case .Adjective :
                return "Adjective"
            case .Adverb:
                return "Adverb"
            case .Conjunction:
                return "Conjunction"
            case .Interjection:
                return "Conjunction"
            case let .Noun(declension, gender):
                return "Noun, \(declension.shortForm) (\(gender.name))"
            case .Numeral:
                return "Numeral"
            case .PersonalPronoun:
                return "Personal Pronoun"
            case let .Preposition(declension):
                return "Preposition \(declension.name)"
            case let .Verb(conjugation, verbType):
                return "Verb \(conjugation.shortNumber) \(verbType.name)"
            default:
                break
        }
        
        
        return ""
    }
}
