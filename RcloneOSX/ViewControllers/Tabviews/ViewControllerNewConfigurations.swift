//
//  ViewControllerNew.swift
//
//  Created by Thomas Evensen on 13/02/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable trailing_comma

import Cocoa
import Foundation

class ViewControllerNewConfigurations: NSViewController, SetConfigurations, Delay, VcMain, Checkforrclone {
    var newconfigurations: NewConfigurations?
    var tabledata: [NSMutableDictionary]?
    let copycommand: String = ViewControllerReference.shared.copy
    let movecommand: String = ViewControllerReference.shared.move
    let synccommand: String = ViewControllerReference.shared.sync
    let verbose: String = "--verbose"
    let dryrun: String = "--dry-run"
    let checkcommand: String = ViewControllerReference.shared.check
    var outputprocess: OutputProcess?
    var rclonecommand: String?
    var diddissappear: Bool = false
    var services: GetCloudServices?

    @IBOutlet var viewParameter4: NSTextField!
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var backupID: NSTextField!
    @IBOutlet var empty: NSTextField!
    @IBOutlet var profilInfo: NSTextField!
    @IBOutlet var newTableView: NSTableView!
    @IBOutlet var cloudService: NSComboBox!

    @IBAction func totinfo(_: NSButton) {
        guard self.checkforrclone() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        }
    }

    @IBAction func quickbackup(_: NSButton) {
        guard self.checkforrclone() == false else { return }
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }

    @IBAction func information(_: NSToolbarItem) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerInformation!)
        }
    }

    // Userconfig
    @IBAction func userconfiguration(_: NSToolbarItem) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        }
    }

    // Selecting profiles
    @IBAction func profiles(_: NSButton) {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        }
    }

    // Selecting About
    @IBAction func about(_: NSButton) {
        self.presentAsModalWindow(self.viewControllerAbout!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup(_: NSButton) {
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func cleartable(_: NSButton) {
        self.newconfigurations = nil
        self.newconfigurations = NewConfigurations()
        globalMainQueue.async { () -> Void in
            self.newTableView.reloadData()
            self.setFields()
        }
    }

    @IBOutlet var copyradio: NSButton!
    @IBOutlet var syncradio: NSButton!
    @IBOutlet var moveradio: NSButton!
    @IBOutlet var checkradio: NSButton!

    @IBAction func choosecommand(_: NSButton) {
        if self.copyradio.state == .on {
            self.rclonecommand = self.copycommand
        } else if self.syncradio.state == .on {
            self.rclonecommand = self.synccommand
        } else if self.moveradio.state == .on {
            self.rclonecommand = self.movecommand
        } else if self.checkradio.state == .on {
            self.rclonecommand = self.checkcommand
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.newconfigurations = NewConfigurations()
        self.newTableView.delegate = self
        self.newTableView.dataSource = self
        self.localCatalog.toolTip = "By using Finder drag and drop filepaths."
        self.offsiteCatalog.toolTip = "By using Finder drag and drop filepaths."
        ViewControllerReference.shared.setvcref(viewcontroller: .vcnewconfigurations, nsviewcontroller: self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else { return }
        self.setFields()
        self.rclonecommand = self.synccommand
        self.syncradio.state = .on
        self.loadCloudServices()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func loadCloudServices() {
        self.services = GetCloudServices(reloadclass: self)
        self.cloudService.removeAllItems()
    }

    private func setFields() {
        self.viewParameter4.stringValue = self.verbose
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.cloudService.stringValue = ""
        self.backupID.stringValue = ""
        self.empty.isHidden = true
        self.syncradio.state = .on
    }

    @IBAction func addConfig(_: NSButton) {
        guard self.cloudService.stringValue.isEmpty == false else {
            self.empty.isHidden = false
            return
        }
        let dict: NSMutableDictionary = [
            "task": self.rclonecommand ?? "",
            "backupID": self.backupID.stringValue,
            "localCatalog": self.localCatalog.stringValue,
            "offsiteCatalog": self.offsiteCatalog.stringValue,
            "offsiteServer": self.cloudService.stringValue,
            "parameter1": self.rclonecommand ?? ViewControllerReference.shared.copy,
            "parameter2": self.verbose,
            "dryrun": self.dryrun,
            "dateRun": "",
            "batch": 0,
        ]
        dict.setValue(self.localCatalog.stringValue, forKey: "localCatalog")
        dict.setValue(self.offsiteCatalog.stringValue, forKey: "offsiteCatalog")
        self.configurations!.addNewConfigurations(dict: dict)
        self.newconfigurations?.appendnewConfigurations(dict: dict)
        self.tabledata = self.newconfigurations!.getnewConfigurations()
        globalMainQueue.async { () -> Void in
            self.newTableView.reloadData()
        }
        self.setFields()
    }
}

extension ViewControllerNewConfigurations: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.newconfigurations?.newConfigurationsCount() ?? 0
    }
}

extension ViewControllerNewConfigurations: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard self.newconfigurations?.getnewConfigurations() != nil else {
            return nil
        }
        let object: NSMutableDictionary = self.newconfigurations!.getnewConfigurations()![row]
        return object[tableColumn!.identifier] as? String
    }

    func tableView(_: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        self.tabledata![row].setObject(object!, forKey: (tableColumn?.identifier)! as NSCopying)
    }
}

extension ViewControllerNewConfigurations: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}

extension ViewControllerNewConfigurations: SetProfileinfo {
    func setprofile(profile: String, color: NSColor) {
        globalMainQueue.async { () -> Void in
            self.profilInfo.stringValue = profile
            self.profilInfo.textColor = color
        }
    }
}

extension ViewControllerNewConfigurations: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerNewConfigurations: Reloadcloudservices {
    func reloadcloudservices() {
        self.cloudService.addItems(withObjectValues: self.services?.cloudservices ?? [""])
        self.services = nil
    }
}
