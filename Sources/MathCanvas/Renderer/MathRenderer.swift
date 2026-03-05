//
//  MathRenderer.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CoreGraphics

struct MathRenderer {
    let fontSize: CGFloat
    let color: PlatformColor

    init(fontSize: CGFloat = 24, color: PlatformColor = .labelColor) {
        self.fontSize = fontSize
        self.color = color
    }

    // MARK: - Entry point

    func layout(_ node: ASTNode) -> MathLayout {
        switch node {
        case .number(let val):
            return layoutText(formatNumber(val), size: fontSize)

        case .variable(let name):
            return layoutText(name, size: fontSize, italic: true)

        case .add(let l, let r):
            return layoutBinary(l, op: "+", r)

        case .subtract(let l, let r):
            return layoutBinary(l, op: "−", r)

        case .multiply(let l, let r):
            return layoutBinary(l, op: "·", r)

        case .divide(let l, let r):
            return layoutFrac(l, r)  // división se renderiza como fracción

        case .power(let base, let exp):
            return layoutPower(base, exp)

        case .equals(let l, let r):
            return layoutBinary(l, op: "=", r)

        case .negate(let inner):
            return layoutUnary("−", inner)

        case .sqrt(let inner):
            return layoutSqrt(inner)

        case .frac(let num, let den):
            return layoutFrac(num, den)

        case .sin(let inner):
            return layoutFunction("sin", inner)

        case .cos(let inner):
            return layoutFunction("cos", inner)
        }
    }

    // MARK: - Layout helpers

    private func layoutText(_ text: String, size: CGFloat, italic: Bool = false) -> MathLayout {
        let attrs = textAttributes(size: size, italic: italic)
        let nsText = text as NSString
        let textSize = nsText.size(withAttributes: attrs)

        return MathLayout(
            width: textSize.width,
            height: textSize.height,
            baseline: textSize.height * 0.8
        ) { ctx, origin in
            nsText.draw(at: origin, withAttributes: attrs)
        }
    }

    // a + b, a = b, etc.
    private func layoutBinary(_ left: ASTNode, op: String, _ right: ASTNode) -> MathLayout {
        let l = layout(left)
        let r = layout(right)
        let opLayout = layoutText(" \(op) ", size: fontSize)

        let totalWidth = l.width + opLayout.width + r.width
        let totalHeight = max(l.height, opLayout.height, r.height)
        let baseline = max(l.baseline, opLayout.baseline, r.baseline)

        return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
            // alinea cada elemento por baseline
            let lY = origin.y + (baseline - l.baseline)
            let opY = origin.y + (baseline - opLayout.baseline)
            let rY = origin.y + (baseline - r.baseline)

            l.draw(ctx, CGPoint(x: origin.x, y: lY))
            opLayout.draw(ctx, CGPoint(x: origin.x + l.width, y: opY))
            r.draw(ctx, CGPoint(x: origin.x + l.width + opLayout.width, y: rY))
        }
    }

    // x^2
    private func layoutPower(_ base: ASTNode, _ exp: ASTNode) -> MathLayout {
        let baseLayout = layout(base)
        let expSize = fontSize * 0.65  // superíndice más pequeño
        let expLayoutSmall = relayout(exp, size: expSize)

        let totalWidth = baseLayout.width + expLayoutSmall.width
        let totalHeight = baseLayout.height + expLayoutSmall.height * 0.5
        let baseline = baseLayout.baseline + expLayoutSmall.height * 0.5

        return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
            baseLayout.draw(ctx, CGPoint(x: origin.x, y: origin.y + expLayoutSmall.height * 0.5))
            expLayoutSmall.draw(ctx, CGPoint(x: origin.x + baseLayout.width, y: origin.y))
        }
    }

    // frac(a, b)
    private func layoutFrac(_ num: ASTNode, _ den: ASTNode) -> MathLayout {
        let numLayout = layout(num)
        let denLayout = layout(den)
        let padding: CGFloat = 4
        let lineHeight: CGFloat = 1.5

        let totalWidth = max(numLayout.width, denLayout.width) + padding * 2
        let totalHeight = numLayout.height + lineHeight + denLayout.height + padding * 2
        let baseline = numLayout.height + padding + lineHeight / 2

        return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
            // numerador centrado
            let numX = origin.x + (totalWidth - numLayout.width) / 2
            numLayout.draw(ctx, CGPoint(x: numX, y: origin.y + padding))

            // línea horizontal
            ctx.setFillColor(self.color.cgColor)
            ctx.fill(CGRect(
                x: origin.x,
                y: origin.y + numLayout.height + padding,
                width: totalWidth,
                height: lineHeight
            ))

            // denominador centrado
            let denX = origin.x + (totalWidth - denLayout.width) / 2
            denLayout.draw(ctx, CGPoint(x: denX, y: origin.y + numLayout.height + padding + lineHeight + padding))
        }
    }

    // sqrt(x)
    private func layoutSqrt(_ inner: ASTNode) -> MathLayout {
        let innerLayout = layout(inner)
        let padding: CGFloat = 4
        let symbolWidth: CGFloat = fontSize * 0.7
        let overlineHeight: CGFloat = 1.5

        let totalWidth = symbolWidth + innerLayout.width + padding
        let totalHeight = innerLayout.height + overlineHeight + padding

        return MathLayout(
            width: totalWidth,
            height: totalHeight,
            baseline: innerLayout.baseline + overlineHeight + padding * 0.5
        ) { ctx, origin in
            // símbolo √
            let sqrtAttrs = self.textAttributes(size: self.fontSize * 1.1)
            ("√" as NSString).draw(
                at: CGPoint(x: origin.x, y: origin.y + padding * 0.5),
                withAttributes: sqrtAttrs
            )

            // línea superior (overline)
            ctx.setFillColor(self.color.cgColor)
            ctx.fill(CGRect(
                x: origin.x + symbolWidth,
                y: origin.y,
                width: innerLayout.width + padding,
                height: overlineHeight
            ))

            // contenido
            innerLayout.draw(ctx, CGPoint(
                x: origin.x + symbolWidth,
                y: origin.y + overlineHeight + padding * 0.5
            ))
        }
    }

    // sin(x), cos(x)
    private func layoutFunction(_ name: String, _ inner: ASTNode) -> MathLayout {
        let nameLayout = layoutText(name, size: fontSize)
        let innerLayout = layout(inner)
        let parenOpen = layoutText("(", size: fontSize)
        let parenClose = layoutText(")", size: fontSize)

        let totalWidth = nameLayout.width + parenOpen.width + innerLayout.width + parenClose.width
        let totalHeight = max(nameLayout.height, innerLayout.height)
        let baseline = max(nameLayout.baseline, innerLayout.baseline)

        return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
            var x = origin.x
            nameLayout.draw(ctx, CGPoint(x: x, y: origin.y)); x += nameLayout.width
            parenOpen.draw(ctx, CGPoint(x: x, y: origin.y)); x += parenOpen.width
            innerLayout.draw(ctx, CGPoint(x: x, y: origin.y)); x += innerLayout.width
            parenClose.draw(ctx, CGPoint(x: x, y: origin.y))
        }
    }

    private func layoutUnary(_ op: String, _ inner: ASTNode) -> MathLayout {
        let opLayout = layoutText(op, size: fontSize)
        let innerLayout = layout(inner)
        let totalWidth = opLayout.width + innerLayout.width
        let totalHeight = max(opLayout.height, innerLayout.height)
        let baseline = max(opLayout.baseline, innerLayout.baseline)

        return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
            opLayout.draw(ctx, origin)
            innerLayout.draw(ctx, CGPoint(x: origin.x + opLayout.width, y: origin.y))
        }
    }

    // MARK: - Utilities

    // Re-layoutea un nodo con un font size diferente (para superíndices)
    private func relayout(_ node: ASTNode, size: CGFloat) -> MathLayout {
        let smallRenderer = MathRenderer(fontSize: size, color: color)
        return smallRenderer.layout(node)
    }

    private func textAttributes(size: CGFloat, italic: Bool = false) -> [NSAttributedString.Key: Any] {
        let font: PlatformFont = italic
            ? PlatformFont(name: "Georgia-Italic", size: size) ?? .systemFont(ofSize: size)
            : PlatformFont(name: "Georgia", size: size) ?? .systemFont(ofSize: size)
        return [.font: font, .foregroundColor: color]
    }

    private func formatNumber(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(val))
            : String(val)
    }
}
