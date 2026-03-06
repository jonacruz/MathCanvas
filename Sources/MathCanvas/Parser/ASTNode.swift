//
//  ASTNode.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import Foundation

indirect enum ASTNode: Equatable {
    // Sheet values
    case number (Double)
    case variable (String)
    
    // Binary operations
    case add(ASTNode, ASTNode)
    case subtract(ASTNode, ASTNode)
    case multiply(ASTNode, ASTNode)
    case divide(ASTNode, ASTNode)
    case power(ASTNode, ASTNode)
    case equals(ASTNode, ASTNode)
    
    // Unit
    case negate(ASTNode)
    
    // Functions
    case sqrt(ASTNode)
    case frac(numerator: ASTNode, denominator: ASTNode)
    case mixedFrac(whole: ASTNode, numerator: ASTNode, denominator: ASTNode)
    case sin(ASTNode)
    case cos(ASTNode)
    case tan(ASTNode)
    case log(ASTNode)
    
    static func == (lhs: ASTNode, rhs: ASTNode) -> Bool {
        switch (lhs, rhs) {
        case (.number(let a), .number(let b)):
            return a == b
        case (.variable(let a), .variable(let b)):
            return a == b
        case (.add(let l1, let r1), .add(let l2, let r2)):
            return l1 == l2 && r1 == r2
        case (.subtract(let l1, let r1), .subtract(let l2, let r2)):
            return l1 == l2 && r1 == r2
        case (.multiply(let l1, let r1), .multiply(let l2, let r2)):
            return l1 == l2 && r1 == r2
        case (.divide(let l1, let r1), .divide(let l2, let r2)):
            return l1 == l2 && r1 == r2
        case (.power(let l1, let r1), .power(let l2, let r2)):
            return l1 == l2 && r1 == r2
        case (.equals(let l1, let r1), .equals(let l2, let r2)):
            return l1 == l2 && r1 == r2
        case (.negate(let a), .negate(let b)):
            return a == b
        case (.sqrt(let a), .sqrt(let b)):
            return a == b
        case (.sin(let a), .sin(let b)):
            return a == b
        case (.cos(let a), .cos(let b)):
            return a == b
        case (.tan(let a), .tan(let b)):
            return a == b
        case (.log(let a), .log(let b)):
            return a == b
        case (.frac(let n1, let d1), .frac(let n2, let d2)):
            return n1 == n2 && d1 == d2
        case (.mixedFrac(let w1, let n1, let d1), .mixedFrac(let w2, let n2, let d2)):
            return w1 == w2 && n1 == n2 && d1 == d2
        default:
            return false
        }
    }
}
