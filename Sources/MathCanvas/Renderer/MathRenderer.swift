//
//  MathRenderer.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import SwiftUI

 struct MathRenderer {
     let fontSize: CGFloat
     let color: Color

     init(fontSize: CGFloat = 24, color: Color = .primary) {
         self.fontSize = fontSize
         self.color = color
     }

     // MARK: - Entry point

     func layout(_ node: ASTNode) -> MathLayout {
         switch node {
         case .number(let val):
             return layoutText(formatNumber(val))

         case .variable(let name):
             return layoutText(name, italic: true)

         case .add(let l, let r):
             return layoutBinary(l, op: "+", r)

         case .subtract(let l, let r):
             return layoutBinary(l, op: "−", r)

         case .multiply(let l, let r):
             return layoutBinary(l, op: "·", r)

         case .divide(let l, let r):
             return layoutFrac(l, r)

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

     private func layoutText(_ text: String, size: CGFloat? = nil, italic: Bool = false) -> MathLayout {
         let resolvedSize = size ?? fontSize
         let font = italic
             ? Font.custom("Georgia-Italic", size: resolvedSize)
             : Font.custom("Georgia", size: resolvedSize)

         let attrs: [NSAttributedString.Key: Any] = [
             .font: platformFont(size: resolvedSize, italic: italic)
         ]
         let textSize = (text as NSString).size(withAttributes: attrs)

         return MathLayout(
             width: textSize.width,
             height: textSize.height,
             baseline: textSize.height * 0.8
         ) { ctx, origin in
             ctx.draw(
                 Text(text).font(font).foregroundColor(self.color),
                 at: CGPoint(x: origin.x + textSize.width / 2, y: origin.y + textSize.height / 2),
                 anchor: .center
             )
         }
     }

     private func layoutBinary(_ left: ASTNode, op: String, _ right: ASTNode) -> MathLayout {
         let l = layout(left)
         let r = layout(right)
         let opLayout = layoutText(" \(op) ")

         let totalWidth = l.width + opLayout.width + r.width
         let totalHeight = max(l.height, opLayout.height, r.height)
         let baseline = max(l.baseline, opLayout.baseline, r.baseline)

         return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
             let lY = origin.y + (baseline - l.baseline)
             let opY = origin.y + (baseline - opLayout.baseline)
             let rY = origin.y + (baseline - r.baseline)

             l.draw(&ctx, CGPoint(x: origin.x, y: lY))
             opLayout.draw(&ctx, CGPoint(x: origin.x + l.width, y: opY))
             r.draw(&ctx, CGPoint(x: origin.x + l.width + opLayout.width, y: rY))
         }
     }

     private func layoutPower(_ base: ASTNode, _ exp: ASTNode) -> MathLayout {
         let baseLayout = layout(base)
         let expSize = fontSize * 0.65
         let expLayoutSmall = relayout(exp, size: expSize)

         let totalWidth = baseLayout.width + expLayoutSmall.width
         let totalHeight = baseLayout.height + expLayoutSmall.height * 0.5
         let baseline = baseLayout.baseline + expLayoutSmall.height * 0.5

         return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
             baseLayout.draw(&ctx, CGPoint(x: origin.x, y: origin.y + expLayoutSmall.height * 0.5))
             expLayoutSmall.draw(&ctx, CGPoint(x: origin.x + baseLayout.width, y: origin.y))
         }
     }

     private func layoutFrac(_ num: ASTNode, _ den: ASTNode) -> MathLayout {
         let numLayout = layout(num)
         let denLayout = layout(den)
         let padding: CGFloat = 4
         let lineHeight: CGFloat = 1.5

         let totalWidth = max(numLayout.width, denLayout.width) + padding * 2
         let totalHeight = numLayout.height + lineHeight + denLayout.height + padding * 2
         let baseline = numLayout.height + padding + lineHeight / 2

         return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
             let numX = origin.x + (totalWidth - numLayout.width) / 2
             numLayout.draw(&ctx, CGPoint(x: numX, y: origin.y + padding))

             // línea horizontal
             let linePath = Path(CGRect(
                 x: origin.x,
                 y: origin.y + numLayout.height + padding,
                 width: totalWidth,
                 height: lineHeight
             ))
             ctx.fill(linePath, with: .color(self.color))

             let denX = origin.x + (totalWidth - denLayout.width) / 2
             denLayout.draw(&ctx, CGPoint(x: denX, y: origin.y + numLayout.height + padding + lineHeight + padding))
         }
     }

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
             let sqrtLayout = self.layoutText("√", size: self.fontSize * 1.1)
             sqrtLayout.draw(&ctx, CGPoint(x: origin.x, y: origin.y + padding * 0.5))

             // overline
             let linePath = Path(CGRect(
                 x: origin.x + symbolWidth,
                 y: origin.y,
                 width: innerLayout.width + padding,
                 height: overlineHeight
             ))
             ctx.fill(linePath, with: .color(self.color))

             innerLayout.draw(&ctx, CGPoint(
                 x: origin.x + symbolWidth,
                 y: origin.y + overlineHeight + padding * 0.5
             ))
         }
     }

     private func layoutFunction(_ name: String, _ inner: ASTNode) -> MathLayout {
         let nameLayout = layoutText(name)
         let innerLayout = layout(inner)
         let parenOpen = layoutText("(")
         let parenClose = layoutText(")")

         let totalWidth = nameLayout.width + parenOpen.width + innerLayout.width + parenClose.width
         let totalHeight = max(nameLayout.height, innerLayout.height)
         let baseline = max(nameLayout.baseline, innerLayout.baseline)

         return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
             var x = origin.x
             nameLayout.draw(&ctx, CGPoint(x: x, y: origin.y)); x += nameLayout.width
             parenOpen.draw(&ctx, CGPoint(x: x, y: origin.y)); x += parenOpen.width
             innerLayout.draw(&ctx, CGPoint(x: x, y: origin.y)); x += innerLayout.width
             parenClose.draw(&ctx, CGPoint(x: x, y: origin.y))
         }
     }

     private func layoutUnary(_ op: String, _ inner: ASTNode) -> MathLayout {
         let opLayout = layoutText(op)
         let innerLayout = layout(inner)
         let totalWidth = opLayout.width + innerLayout.width
         let totalHeight = max(opLayout.height, innerLayout.height)
         let baseline = max(opLayout.baseline, innerLayout.baseline)

         return MathLayout(width: totalWidth, height: totalHeight, baseline: baseline) { ctx, origin in
             opLayout.draw(&ctx, origin)
             innerLayout.draw(&ctx, CGPoint(x: origin.x + opLayout.width, y: origin.y))
         }
     }

     // MARK: - Utilities

     private func relayout(_ node: ASTNode, size: CGFloat) -> MathLayout {
         let smallRenderer = MathRenderer(fontSize: size, color: color)
         return smallRenderer.layout(node)
     }

     private func platformFont(size: CGFloat, italic: Bool) -> Any {
         #if canImport(UIKit)
         return italic
             ? UIFont(name: "Georgia-Italic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
             : UIFont(name: "Georgia", size: size) ?? UIFont.systemFont(ofSize: size)
         #elseif canImport(AppKit)
         return italic
             ? NSFont(name: "Georgia-Italic", size: size) ?? NSFont.systemFont(ofSize: size)
             : NSFont(name: "Georgia", size: size) ?? NSFont.systemFont(ofSize: size)
         #endif
     }

     private func formatNumber(_ val: Double) -> String {
         val.truncatingRemainder(dividingBy: 1) == 0
             ? String(Int(val))
             : String(val)
     }
 }
