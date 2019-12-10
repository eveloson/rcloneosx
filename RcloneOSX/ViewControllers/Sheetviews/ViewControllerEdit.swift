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
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_: NSButton) {
        var config: [Configuration] = self.configurations!.getConfigurations()
        config[self.index!].localCatalog = self.localCatalog.stringValue
        config[self.index!].offsiteCatalog = self.offsiteCatalog.stringValue
        config[self.index!].offsiteServer = self.cloudService.stringValue
        config[self.index!].backupID = self.backupID.stringValue
        self.configurations!.updateConfigurations(config: config[self.index!], index: self.index!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.backupID.stringValue = ""
        self.index = self.index()
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        self.localCatalog.stringValue = config.localCatalog
        self.offsiteCatalog.stringValue = config.offsiteCatalog
        self.cloudService.stringValue = config.offsiteServer
        self.backupID.stringValue = config.backupID
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
