//
//  PrivacyOverlayView.swift
//  PrivateMode
//
//  Created by 장영완 on 12/12/25.
//

import Cocoa

class PrivacyOverlayView: NSView {
    
    private let mode: PrivacyMode
    
    init(frame frameRect: NSRect, mode: PrivacyMode) {
        self.mode = mode
        super.init(frame: frameRect)
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        switch mode {
        case .none:
            return
        case .dark:
            drawDark(in: dirtyRect)
        case .stripes:
            drawStripes(in: dirtyRect)
        case .noise:
            drawNoise(in: dirtyRect)
        case .spotlight:
            drawDark(in: dirtyRect)     // 해당옵션은 잠시 보류
        }
    }
    
    private func drawDark(in rect: NSRect) {
        let overlayColor = NSColor.black.withAlphaComponent(0.8)
        overlayColor.setFill()
        bounds.fill()
        
        drawCenterText("Privacy Mode")
    }
    
    private func drawStripes(in rect: NSRect) {
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()
        
        // 미세 세로 줄무늬(난독화)
        let stripeWidth: CGFloat = 2
        let gap: CGFloat = 3
        let alpha: CGFloat = 0.12
        
        NSColor.black.withAlphaComponent(alpha).setFill()
        
        
        var x: CGFloat = 0
        while x < bounds.width {
            let r = NSRect(x: x, y: 0, width: stripeWidth, height: bounds.height)
            r.fill()
            x += stripeWidth + gap
        }
        
        drawCenterText("Stripes Mode")
    }
    
    private func drawNoise(in rect: NSRect) {
        
        // 바탕
        NSColor.black.withAlphaComponent(0.20).setFill()
        bounds.fill()
        
        // 간단 노이즈(점 찍기)
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        defer { ctx?.restoreGState() }
        
        ctx?.setFillColor((NSColor.black.withAlphaComponent(0.10).cgColor))
        
        // 무겁지 않게 일정 간격으로 점을 찍음.
        let step: CGFloat = 6
        var y: CGFloat = 0
        while y < bounds.height {
            var x: CGFloat = 0
            while x < bounds.width {
                // 약간 랜덤한 위치로 흔들림
                let dx = CGFloat(Int.random(in: -2...2))
                let dy = CGFloat(Int.random(in: -2...2))
                let dot = CGRect(x: x + dx, y: y + dy, width: 1, height: 1)
                ctx?.fill(dot)
                x += step
            }
            y += step
        }
        
        drawCenterText("Noise Mode")
    }
    
    private func drawCenterText(_ text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: NSColor.white.withAlphaComponent(0.9)
        ]
        let size = text.size(withAttributes: attributes)
        let rect = NSRect(
            x: (bounds.width - size.width) / 2,
            y: (bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        text.draw(in: rect, withAttributes: attributes)
    }
    
    
    
    
    
    
}
