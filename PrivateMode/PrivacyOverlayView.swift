//
//  PrivacyOverlayView.swift
//  PrivateMode
//
//  Created by 장영완 on 12/12/25.
//

import Cocoa

class PrivacyOverlayView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // 화면 전체 어둡게 (검정 + 80% 불투명)
        let overlayColor = NSColor.black.withAlphaComponent(0.8)
        overlayColor.setFill()
        dirtyRect.fill()
        
        // 중앙에 안내 텍스트
        let text = "Privacy Mode"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 28, weight: .semibold),
            .foregroundColor: NSColor.white.withAlphaComponent(0.9)
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = NSRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
    }
}
