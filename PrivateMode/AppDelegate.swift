//
//  AppDelegate.swift
//  PrivateMode
//
//  Created by 장영완 on 12/12/25.
//

import Cocoa
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate{
    
    private var statusItem: NSStatusItem!
    private var overlayWindows: [NSWindow] = []
    // 전역 단축키 변수
    private var hotKeyRef: EventHotKeyRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        registerGlobalHotKey()
    }
    
    // 메뉴바 아이콘 세팅
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.title = "P"
            button.action = #selector(toggleOverlay)
            button.target = self
            button.toolTip = "Privacy Mode 토글"
        }
    }
    
    // 아이콘 클릭 시 호출
    @objc func toggleOverlay() {
        if overlayWindows.isEmpty {
            showOverlayOnAllScreens()
        } else {
            hideOverlay()
        }
    }
    
    // 모든 화면 위에 오버레이 띄우기
    private func showOverlayOnAllScreens() {
        overlayWindows.removeAll()
        
        for screen in NSScreen.screens {
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
        )
        
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let overlayView = PrivacyOverlayView(frame: window.contentView?.bounds ?? .zero)
        overlayView.autoresizingMask = [.width, .height]
        window.contentView = overlayView
        
        window.makeKeyAndOrderFront(nil)
        overlayWindows.append(window)
            
        }
    }
    
    // 오버레이 제거
    private func hideOverlay() {
        overlayWindows.forEach { $0.orderOut(nil) }
        overlayWindows.removeAll()
    }
    
    private func registerGlobalHotKey() {
        let keyCode: UInt32 = UInt32(kVK_ANSI_P)
        let modifiers: UInt32 = UInt32(cmdKey | optionKey)
        
        var hotKeyID = EventHotKeyID(
            signature: OSType(UInt32(truncatingIfNeeded: "PRIV".hashValue)),
            id: UInt32(1)
        )
        
        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        InstallEventHandler(
            GetEventDispatcherTarget(),
            { (_, event, _) -> OSStatus in
                var hkID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hkID
                )
                
                if hkID.id == 1 {
                    DispatchQueue.main.async {
                        (NSApp.delegate as? AppDelegate)?.toggleOverlay()
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
    
}
