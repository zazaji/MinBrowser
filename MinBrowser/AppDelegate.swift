import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var webViewManager = WebViewManager()

    static func quit() {
        NSApplication.shared.terminate(nil)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        preloadWebsites()

        let preferencesView = PreferencesView(webViewManager: webViewManager, isPresented: .constant(false))

        // Load the saved window frame, or use the default size
        let defaultFrame = NSMakeRect(0, 0, 360, NSScreen.main?.visibleFrame.height ?? 800)
        var windowFrame = UserDefaults.standard.string(forKey: "windowFrame").flatMap(NSRectFromString) ?? defaultFrame

        if let screenIndex = UserDefaults.standard.value(forKey: "windowScreenIndex") as? Int,
           screenIndex < NSScreen.screens.count {
            let targetScreen = NSScreen.screens[screenIndex]
            windowFrame.origin.x += targetScreen.frame.minX
            windowFrame.origin.y += targetScreen.frame.minY
        }
        // Create the window
        window = NSWindow(
                    contentRect: windowFrame,
                    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
                    backing: .buffered, defer: false)
                window.setFrameAutosaveName("Main Window")
                window.contentView = NSHostingController(rootView: preferencesView).view

        // Configure the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem.button {
            button.title = "M"
            button.action = #selector(toggleWindow(_:))
        }

        // Set initial window position if no saved state
        if UserDefaults.standard.string(forKey: "windowFrame") == nil {
                    positionWindowOnTopRight()
                }
                NotificationCenter.default.addObserver(self, selector: #selector(self.windowWillClose(_:)), name: NSWindow.willCloseNotification, object: window)

    }
    
    private func preloadWebsites() {
        let (websites, userAgent) = loadWebsiteList()
        webViewManager.customUserAgent = userAgent
        for website in websites {
            if let url = URL(string: website.url) {
                webViewManager.loadWebView(url: url)
            }
        }
    }

    
    @objc func toggleWindow(_ sender: AnyObject?) {
        // 检测当前鼠标所在的屏幕
        let mouseLocation = NSEvent.mouseLocation
        let screenWithMouse = NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }

        if window.isVisible {
            window.orderOut(sender)
        } else {
            // 如果鼠标所在屏幕存在，则调整窗口位置
            if let screen = screenWithMouse {
                let screenHeight = screen.visibleFrame.height
                let screenWidth = screen.visibleFrame.width
                window.setFrame(NSRect(x: screenWidth - window.frame.width, y: screenHeight - window.frame.height, width: window.frame.width, height: screenHeight), display: true)
            }

            window.makeKeyAndOrderFront(sender)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc func windowWillClose(_ notification: Notification) {
            let frameString = NSStringFromRect(window.frame)
            UserDefaults.standard.set(frameString, forKey: "windowFrame")
            // 保存窗口所在屏幕的索引
            if let screen = window.screen {
                let screenIndex = NSScreen.screens.firstIndex(of: screen) ?? 0
                UserDefaults.standard.set(screenIndex, forKey: "windowScreenIndex")
            }
            NSApplication.shared.terminate(nil)
        }
    
    func positionWindowOnTopRight() {
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowRect = window.frame
            let newOrigin = NSPoint(x: screenRect.maxX - windowRect.width, y: screenRect.maxY - windowRect.height)
            window.setFrameOrigin(newOrigin)
        }
    }
}
