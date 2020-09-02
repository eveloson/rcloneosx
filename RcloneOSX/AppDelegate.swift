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
    func applicationDidFinishLaunching(_: Notification) {}

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool { return true }
}
