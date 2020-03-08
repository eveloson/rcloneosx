//
//  ViewControllerCopyFiles.swift
//  RcloneOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable type_body_length line_length

import Cocoa
import Foundation

protocol Updateremotefilelist: AnyObject {
    func updateremotefilelist()
}

class ViewControllerRestore: NSViewController, SetConfigurations, Delay, VcMain, Checkforrclone, Abort, Remoterclonesize, Setcolor {
    var restorefiles: Restorefiles?
    var remotefilelist: Remotefilelist?
    var restoretask: RestoreTask?
    var index: Int?
    var restoretabledata: [String]?
    var diddissappear: Bool = false
    var outputprocess: OutputProcess?
    var maxcount: Int = 0
    weak var sendprocess: SendProcessreference?
    var process: Process?

    @IBOutlet var numberofrows: NSTextField!
    @IBOutlet var info: NSTextField!
    @IBOutlet var restoretableView: NSTableView!
    @IBOutlet var rclonetableView: NSTableView!
    @IBOutlet var commandstring: NSTextField!
    @IBOutlet var remotesource: NSTextField!
    @IBOutlet var restorepath: NSTextField!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var search: NSSearchField!
    @IBOutlet var estimatebutton: NSButton!
    @IBOutlet var restorebutton: NSButton!
    @IBOutlet var fullrestorebutton: NSButton!
    @IBOutlet var restorefilesbutton: NSButton!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

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

    // Abort button
    @IBAction func abort(_: NSButton) {
        self.working.stopAnimation(nil)
        self.estimatebutton.isEnabled = true
        self.restorebutton.isEnabled = false
        self.restoretask = nil
        self.restorefiles = nil
        self.process?.terminate()
        self.abort()
    }

    func info(num: Int) {
        switch num {
        case 1:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            self.info.stringValue = "...Set it in user config..."
        case 2:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            self.info.stringValue = "Choose a remote resource..."
        case 3:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Getting info, please wait..."
        case 4:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Executing restore..."
        case 5:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Restore completed..."
        case 6:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            self.info.stringValue = "Select a restore type..."
        case 7:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .red)
            self.info.stringValue = "Wait, in process of getting remote filelist..."
        case 8:
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Getting remote filelist..."
        default:
            self.info.stringValue = ""
        }
    }

    @IBAction func restore(_: NSButton) {
        guard self.fullrestorebutton.state == .on || self.restorefilesbutton.state == .on else { return }
        self.restorebutton.isEnabled = false
        switch self.fullrestorebutton.state {
        case .on:
            let answer = Alerts.dialogOKCancel("Do you REALLY want to start a RESTORE ?", text: "Cancel or OK")
            if answer {
                if let index = self.index {
                    self.info(num: 4)
                    self.restorebutton.isEnabled = false
                    self.estimatebutton.isEnabled = false
                    self.outputprocess = OutputProcess()
                    globalMainQueue.async { () -> Void in
                        self.presentAsSheet(self.viewControllerProgress!)
                    }
                    self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
                    self.restoretask = RestoreTask(index: index, outputprocess: self.outputprocess, updateprogress: self)
                    self.commandstring.stringValue = self.restoretask?.getcommandfullrestore() ?? ""
                }
            }
        case .off:
            guard self.remotesource.stringValue.isEmpty == false,
                self.restorepath.stringValue.isEmpty == false else {
                self.info(num: 2)
                return
            }
            self.working.startAnimation(nil)
            self.presentAsSheet(self.viewControllerProgress!)
            self.restorefiles?.executecopyfiles(remotefile: remotesource!.stringValue, localCatalog: restorepath!.stringValue, dryrun: false, updateprogress: self)
            self.process = self.restorefiles?.getProcess()
        default:
            return
        }
    }

    @IBAction func estimate(_: NSButton) {
        guard self.fullrestorebutton.state == .on || self.restorefilesbutton.state == .on else { return }
        self.estimatebutton.isEnabled = false
        switch self.fullrestorebutton.state {
        case .on:
            if self.index != nil, ViewControllerReference.shared.restorefilespath != nil {
                self.info(num: 3)
                self.estimatebutton.isEnabled = false
                self.working.startAnimation(nil)
                self.restoretask = nil
                self.getremotenumbers()
            }
        case .off:
            if self.index != nil, self.restorepath.stringValue.isEmpty == false, self.remotesource.stringValue.isEmpty == false {
                self.working.startAnimation(nil)
                self.restorefiles?.executecopyfiles(remotefile: self.remotesource.stringValue, localCatalog: self.restorepath.stringValue, dryrun: true, updateprogress: self)
                self.outputprocess = self.restorefiles?.outputprocess
                self.process = self.restorefiles?.getProcess()
            } else {
                self.info(num: 2)
            }
        default:
            return
        }
    }

    @IBAction func togglefullrestore(_: NSButton) {
        if let index = self.index {
            if self.restorefilesbutton.state == .on {
                if let hiddenID = self.configurations?.getConfigurationsSyncandCopy()?[index].value(forKey: "hiddenID") as? Int {
                    guard self.restorefilesbutton.state == .on else { return }
                    self.getremotefilelist(hiddenID: hiddenID)
                }
            } else {
                self.estimatebutton.isEnabled = true
            }
        } else {
            self.reset()
        }
    }

    func reset() {
        self.estimatebutton.isEnabled = false
        self.restorebutton.isEnabled = false
        self.commandstring.stringValue = ""
        self.info.stringValue = ""
        self.restorefiles = nil
        self.remotefilelist = nil
        self.restoretask = nil
        self.index = nil
        self.restoretabledata = nil
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcrestore, nsviewcontroller: self)
        self.restoretableView.delegate = self
        self.restoretableView.dataSource = self
        self.rclonetableView.delegate = self
        self.rclonetableView.dataSource = self
        self.working.usesThreadedAnimation = true
        self.search.delegate = self
        self.restorepath.delegate = self
        self.remotesource.delegate = self
        self.restoretableView.doubleAction = #selector(self.tableViewDoubleClick(sender:))
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else {
            globalMainQueue.async { () -> Void in
                self.rclonetableView.reloadData()
            }
            return
        }
        self.restorebutton.isEnabled = false
        self.fullrestorebutton.state = .off
        self.setrestorepath()
        globalMainQueue.async { () -> Void in
            self.rclonetableView.reloadData()
        }
        self.initpopupbutton(button: self.profilepopupbutton)
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        guard self.remotesource.stringValue.isEmpty == false else { return }
        guard self.restorepath.stringValue.isEmpty == false else { return }
        let answer = Alerts.dialogOKCancel("Copy single files or directory", text: "Start restore?")
        if answer {
            self.estimatebutton.isEnabled = false
            self.working.startAnimation(nil)
            self.restorefiles?.executecopyfiles(remotefile: self.remotesource.stringValue, localCatalog: self.restorepath.stringValue, dryrun: false, updateprogress: self)
            self.process = self.restorefiles?.getProcess()
        }
    }

    func inprogress() -> Bool {
        guard self.restorefiles != nil else { return false }
        if self.restorefiles?.process != nil {
            return true
        } else {
            return false
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        if myTableViewFromNotification == self.restoretableView {
            self.info(num: 0)
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                guard self.restoretabledata != nil else { return }
                self.remotesource.stringValue = self.restoretabledata?[index] ?? ""
                self.estimatebutton.isEnabled = true
                guard self.remotesource.stringValue.isEmpty == false, self.restorepath.stringValue.isEmpty == false else { return }
                self.commandstring.stringValue = (Getrclonepath().rclonepath ?? "") + " " + (self.restorefiles?.getcommandrestorefiles(remotefile: self.remotesource.stringValue, localCatalog: self.restorepath.stringValue) ?? "")
            }
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                guard self.inprogress() == false else {
                    self.info(num: 7)
                    return
                }
                self.index = index
                if let hiddenID = self.configurations?.getConfigurationsSyncandCopy()?[index].value(forKey: "hiddenID") as? Int {
                    guard self.restorefilesbutton.state == .on else {
                        self.estimatebutton.isEnabled = true
                        return
                    }
                    self.getremotefilelist(hiddenID: hiddenID)
                }
            } else {
                self.reset()
            }
        }
    }

    private func getremotefilelist(hiddenID: Int) {
        self.info(num: 8)
        self.restorefiles = Restorefiles(hiddenID: hiddenID)
        self.remotefilelist = Remotefilelist(hiddenID: hiddenID)
        self.process = self.remotefilelist?.getProcess()
        self.working.startAnimation(nil)
    }

    func setremoteinfo() {
        guard self.outputprocess?.getOutput()?.count ?? 0 > 0 else { return }
        let size = self.remoterclonesize(input: self.outputprocess!.getOutput()![0])
        self.maxcount = size?.count ?? 0
        let numberoffiles = String(NumberFormatter.localizedString(from: NSNumber(value: size?.count ?? 0), number: NumberFormatter.Style.decimal))
        let sizeoffiles = String(NumberFormatter.localizedString(from: NSNumber(value: size?.bytes ?? 0 / 1024), number: NumberFormatter.Style.decimal))
        self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
        self.info.stringValue = "Number of files: " + numberoffiles + " wiht size (Kb): " + sizeoffiles
        self.working.stopAnimation(nil)
        self.restorebutton.isEnabled = true
    }

    func getremotenumbers() {
        if let index = self.index {
            self.outputprocess = OutputProcess()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            _ = RcloneSize(index: index, outputprocess: self.outputprocess, updateprogress: self)
        }
    }

    private func initpopupbutton(button: NSPopUpButton) {
        var profilestrings: [String]?
        profilestrings = CatalogProfile().getDirectorysStrings()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        button.removeAllItems()
        button.addItems(withTitles: profilestrings ?? [])
        button.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        var profile = self.profilepopupbutton.titleOfSelectedItem
        if profile == NSLocalizedString("Default profile", comment: "default profile") {
            profile = nil
        }
        _ = Selectprofile(profile: profile)
    }
}
