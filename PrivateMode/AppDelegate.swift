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
    private let modeKey = "privacy.mode"
    private var currentMode: PrivacyMode = .none
    private let presenceDetector = PresenceDetector()
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 단일 인스턴스화
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let running = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        
        if running.count > 1 {
            NSApp.terminate(nil)
            return
        }
        
        presenceDetector.onUserPresent = { [weak self] in
            guard let self = self else { return }
            if self.currentMode != .none {
                self.currentMode = .none
                self.hideOverlay()
                self.statusItem.menu = self.buildMenu()
            }
        }

        presenceDetector.onUserAbsent = { [weak self] in
            guard let self = self else { return }
            if self.currentMode == .none {
                self.currentMode = .dark   // 또는 lastSelectedMode
                self.showOverlayOnAllScreens()
                self.statusItem.menu = self.buildMenu()
            }
        }

        presenceDetector.start()
        
        loadMode()
        setupStatusItem()
        registerGlobalHotKey()
    }
    
    // 메뉴바 아이콘 세팅
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem.button {
            button.title = "P"
            button.toolTip = "PrivacyMode"
        }
        
        statusItem.menu = buildMenu()
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
        // None이면 아무 것도 하지 않음.
        guard currentMode != .none else {
            hideOverlay()
            return
        }
        
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
        
        let overlayView = PrivacyOverlayView(frame: window.contentView?.bounds ?? .zero, mode: currentMode)
        overlayView.autoresizingMask = [.width, .height]
        window.contentView = overlayView
        
        window.orderFrontRegardless()
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
    
    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        
        let modeHeader = NSMenuItem(title: "Mode", action: nil, keyEquivalent: "")
        modeHeader.isEnabled = false
        menu.addItem(modeHeader)
        
        for mode in PrivacyMode.allCases {
            let item = NSMenuItem(title: mode.title, action: #selector(selectMode(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode.rawValue
            item.state = (mode == currentMode) ? .on : .off
            menu.addItem(item)
        }
        
        menu.addItem(.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    private func loadMode() {
        if let raw = UserDefaults.standard.string(forKey: modeKey),
            let mode = PrivacyMode(rawValue: raw) {
            currentMode = mode
        } else {
            currentMode = .none
        }
        currentMode = .none
        saveMode()
    }
    
    private func saveMode() {
        UserDefaults.standard.set(currentMode.rawValue, forKey: modeKey)
    }
    
    @objc private func selectMode(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let mode = PrivacyMode(rawValue: raw) else { return }
        currentMode = mode
        saveMode()
        
        // 메뉴 체크 표시 업데이트
        statusItem.menu = buildMenu()
        
        if mode == .none {
            hideOverlay()
            return
        }
        
        hideOverlay()
        showOverlayOnAllScreens()
    }
    
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
}
