//
//  MathLayout.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import SwiftUI

struct MathLayout {
    var width: CGFloat
    var height: CGFloat
    var baseline: CGFloat  // distancia desde top hasta la línea base del texto
    var draw: (inout GraphicsContext, CGPoint) -> Void
}
