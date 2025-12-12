//
//  PrivateModeApp.swift
//  PrivateMode
//
//  Created by 장영완 on 12/12/25.
//

import SwiftUI

@main
struct PrivateModeApp: App {
    
    
    // AppDelegate 와 연결 (AppKit 기능 사용)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
