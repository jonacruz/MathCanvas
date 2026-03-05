//
//  Token.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 04/03/26.
//

import Foundation

enum Token: Equatable {
    case number(Double)
    case variable(String)
    
    // Basic operator
    case plus       // +
    case minus      // -
    case multiply   // *
    case divide     // /
    case caret      // ^
    case equals     // =

    // Agrupation
    case leftParen  // (
    case rightParen // )
    case comma      // ,
    
    // functions
    case function(String) // sqrt, frac, sin, cos ...
    
    // Control
    case end
}
