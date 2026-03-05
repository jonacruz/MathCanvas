//
//  ParserError.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import Foundation

enum ParserError: Error, CustomStringConvertible {
    case expected(Token, got: Token)
    case unexpectedToken(Token)
    case unknownFunction(String)

    var description: String {
        switch self {
        case .expected(let exp, let got):
            return "Se esperaba \(exp), se obtuvo \(got)"
        case .unexpectedToken(let t):
            return "Token inesperado: \(t)"
        case .unknownFunction(let name):
            return "Función desconocida: \(name)"
        }
    }
}
