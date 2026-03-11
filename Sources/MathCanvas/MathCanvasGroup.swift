//
//  MathCanvasGroup.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 11/03/26.
//

import SwiftUI

public struct MathCanvasGroup: View {
    private let expressions: [String]
    private var fontSize: CGFloat = 24
    private var color: Color = .primary
    private var spacing: CGFloat = 16
    private var separator: String? = nil

    public init(_ expressions: [String]) {
        self.expressions = expressions
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: spacing) {
                ForEach(Array(expressions.enumerated()), id: \.offset) { index, expr in
                    MathCanvas(expr)
                        .equationFont(size: fontSize)
                        .equationColor(color)

                    if let separator, index < expressions.count - 1 {
                        Text(separator)
                            .font(.system(size: fontSize * 0.7))
                            .foregroundColor(color)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    // MARK: - Modifiers

    public func equationFont(size: CGFloat) -> MathCanvasGroup {
        var copy = self; copy.fontSize = size; return copy
    }

    public func equationColor(_ color: Color) -> MathCanvasGroup {
        var copy = self; copy.color = color; return copy
    }

    public func equationSpacing(_ spacing: CGFloat) -> MathCanvasGroup {
        var copy = self; copy.spacing = spacing; return copy
    }

    /// Muestra un separador de texto entre cada ecuación (ej: ",", "·", "→")
    public func equationSeparator(_ text: String) -> MathCanvasGroup {
        var copy = self; copy.separator = text; return copy
    }
}
