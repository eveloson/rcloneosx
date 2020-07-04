//
//  ViewControllerEdit.swift
//  rcloneOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa
import Foundation

class ViewControllerEdit: NSViewController, SetConfigurations, SetDismisser, Index, Delay {
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var cloudService: NSComboBox!
    @IBOutlet var backupID: NSTextField!

    var index: Int?
    var outputprocess: OutputProcess?
    var services: GetCloudServices?

    // Close and dismiss view
    @IBAction func close(_: NSButton) {
        // self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        self.view.window?.close()
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_: NSButton) {
        if let index = self.index() {
            var config: [Configuration] = self.configurations?.getConfigurations() ?? []
            guard config.count > 0 else {
                self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
                return
            }
            config[index].localCatalog = self.localCatalog.stringValue
            config[index].offsiteCatalog = self.offsiteCatalog.stringValue
            config[index].offsiteServer = self.cloudService.stringValue
            config[index].backupID = self.backupID.stringValue
            self.configurations?.updateConfigurations(config: config[index], index: index)
        }
        // self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        self.view.window?.close()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.backupID.stringValue = ""
        if let index = self.index() {
            self.index = index
            if let config = self.configurations?.getConfigurations()[index] {
                self.localCatalog.stringValue = config.localCatalog
                self.offsiteCatalog.stringValue = config.offsiteCatalog
                self.cloudService.stringValue = config.offsiteServer
                self.backupID.stringValue = config.backupID
            }
        }
        self.loadCloudServices()
    }

    private func loadCloudServices() {
        self.services = GetCloudServices(reloadclass: self)
        self.cloudService.removeAllItems()
    }
}

extension ViewControllerEdit: Reloadcloudservices {
    func reloadcloudservices() {
        self.cloudService.addItems(withObjectValues: self.services?.cloudservices ?? [""])
        self.services = nil
    }
}
