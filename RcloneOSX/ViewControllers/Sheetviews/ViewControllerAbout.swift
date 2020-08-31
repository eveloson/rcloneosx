//
//  ViewControllerAbout.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 18/11/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerAbout: NSViewController, SetDismisser {
    @IBOutlet var version: NSTextField!
    @IBOutlet var downloadbutton: NSButton!
    @IBOutlet var thereisanewversion: NSTextField!
    @IBOutlet var rcloneversionstring: NSTextField!
    @IBOutlet var copyright: NSTextField!
    @IBOutlet var iconby: NSTextField!
    @IBOutlet var configpath: NSTextField!

    var copyrigthstring: String = "Copyright © 2019 Thomas Evensen"
    var iconbystring: String = "Icon by: Zsolt Sándor"

    // External resources as documents, download
    private var resource: Resources?

    @IBAction func changelog(_: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func download(_: NSButton) {
        guard ViewControllerReference.shared.URLnewVersion != nil else {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
            return
        }
        NSWorkspace.shared.open(URL(string: ViewControllerReference.shared.URLnewVersion!)!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.copyright.stringValue = self.copyrigthstring
        self.iconby.stringValue = self.iconbystring
        ViewControllerReference.shared.setvcref(viewcontroller: .vcabout, nsviewcontroller: self)
        self.resource = Resources()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.downloadbutton.isEnabled = false
        if let version = Checkfornewversion().rcloneOSXversion() {
            self.version.stringValue = "RcloneOSX ver: " + version
        }
        self.thereisanewversion.stringValue = "You have the latest ..."
        self.rcloneversionstring.stringValue = ViewControllerReference.shared.rcloneversionstring ?? ""
        self.configpath.stringValue = NamesandPaths().fullroot ?? ""
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.downloadbutton.isEnabled = false
    }
}

extension ViewControllerAbout: NewVersionDiscovered {
    // Notifies if new version is discovered
    func notifyNewVersion() {
        globalMainQueue.async { () -> Void in
            self.downloadbutton.isEnabled = true
            self.thereisanewversion.stringValue = "New version available: "
        }
    }
}
