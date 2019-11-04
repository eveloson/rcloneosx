//
//  AppDelegate.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 05.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Read user configuration
        if let userconfiguration = PersistentStorageUserconfiguration().readuserconfiguration() {
            _ = Userconfiguration(userconfigrcloneOSX: userconfiguration)
        } else {
            _ = RcloneVersionString()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
