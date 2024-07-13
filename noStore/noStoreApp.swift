//
//  noStoreApp.swift
//  noStore
//
//  Created by Pranav Karthik on 2024-07-13.
//

import SwiftUI
import AppKit

@main
struct noTunesApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    let defaults = UserDefaults.standard
    var statusItem: NSStatusItem?
    var statusMenu: NSMenu!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        
        if defaults.bool(forKey: "hideIcon") {
            NSStatusBar.system.removeStatusItem(statusItem!)
        }
        
        appIsLaunched()
        createListener()
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(named: "StatusBarButtonImageActive")
            button.action = #selector(statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        statusMenu = NSMenu()
        statusMenu.addItem(NSMenuItem(title: "Hide Icon", action: #selector(hideIconClicked(_:)), keyEquivalent: "h"))
        statusMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quitClicked(_:)), keyEquivalent: "q"))
    }
    
    @objc func hideIconClicked(_ sender: NSMenuItem) {
        defaults.set(true, forKey: "hideIcon")
        NSStatusBar.system.removeStatusItem(statusItem!)
        appIsLaunched()
    }
    
    @objc func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp || (event.type == .leftMouseUp && event.modifierFlags.contains(.control)) {
            statusItem?.menu = statusMenu
            statusMenu.popUp(positioning: statusMenu.items.first, at: NSEvent.mouseLocation, in: nil)
            statusItem?.menu = nil
        } else {
            if statusItem?.button?.image == NSImage(named: "StatusBarButtonImage") {
                appIsLaunched()
                statusItem?.button?.image = NSImage(named: "StatusBarButtonImageActive")
            } else {
                statusItem?.button?.image = NSImage(named: "StatusBarButtonImage")
            }
        }
    }
    
    func createListener() {
        let workspaceNotificationCenter = NSWorkspace.shared.notificationCenter
        workspaceNotificationCenter.addObserver(self, selector: #selector(appWillLaunch(note:)), name: NSWorkspace.willLaunchApplicationNotification, object: nil)
    }
    
    func appIsLaunched() {
        let apps = NSWorkspace.shared.runningApplications
        for currentApp in apps {
            if currentApp.activationPolicy == .regular {
                if currentApp.bundleIdentifier == "com.apple.AppStore" {
                    currentApp.forceTerminate()
                }
            }
        }
    }
    
    @objc func appWillLaunch(note: Notification) {
        print("app will launch")
        if statusItem?.button?.image == NSImage(named: "StatusBarButtonImageActive") || defaults.bool(forKey: "hideIcon") {
            if let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
                if app.bundleIdentifier == "com.apple.AppStore" {
                    print("app store launched")
                    let success1 = app.terminate()
                    print(success1)
                    let success = app.forceTerminate()
                    print(success)
                    launchReplacement()
                }
            }
        }
    }
    
    func launchReplacement() {
        if let replacement = defaults.string(forKey: "replacement") {
            let task = Process()
            task.arguments = [replacement]
            task.launchPath = "/usr/bin/open"
            task.launch()
        }
    }
    
    func terminateProcessWith(_ processId: Int, _ processName: String) {
        if let process = NSRunningApplication(processIdentifier: pid_t(processId)) {
            process.forceTerminate()
        }
    }
}
