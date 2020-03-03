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

enum Work {
    case localinfoandnumbertosync
    case getremotenumbers
    case setremotenumbers
    case restore
}

class ViewControllerRestore: NSViewController, SetConfigurations, Delay, VcMain, Checkforrclone, Abort, Remoterclonesize, Setcolor {
    var restorefiles: Restorefiles?
    var remotefilelist: Remotefilelist?
    var rcloneindex: Int?
    var restoretabledata: [String]?
    var diddissappear: Bool = false
    var outputprocess: OutputProcess?
    var maxcount: Int = 0
    var workqueue: [Work]?
    weak var sendprocess: SendProcessreference?

    @IBOutlet var numberofrows: NSTextField!
    @IBOutlet var server: NSTextField!
    @IBOutlet var rcatalog: NSTextField!
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
        self.restorefiles?.abort()
        self.estimatebutton.isEnabled = true
        self.restorebutton.isEnabled = false
        self.workqueue = nil
        self.abort()
    }

    func info(num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "...Set it in user config..."
        case 2:
            self.info.stringValue = "Choose a remote resource..."
        default:
            self.info.stringValue = ""
        }
    }

    @IBAction func restore(_: NSButton) {
        self.restorebutton.isEnabled = false
        switch self.fullrestorebutton.state {
        case .on:
            let answer = Alerts.dialogOKCancel("Do you REALLY want to start a RESTORE ?", text: "Cancel or OK")
            if answer {
                if let index = self.rcloneindex {
                    self.workqueue = [Work]()
                    self.workqueue?.append(.restore)
                    self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
                    self.info.stringValue = "Executing restore..."
                    self.restorebutton.isEnabled = false
                    self.estimatebutton.isEnabled = false
                    self.outputprocess = OutputProcess()
                    globalMainQueue.async { () -> Void in
                        self.presentAsSheet(self.viewControllerProgress!)
                    }
                    self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
                    _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: false, updateprogress: self)
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
        default:
            return
        }
    }

    @IBAction func estimate(_: NSButton) {
        self.estimatebutton.isEnabled = false
        switch self.fullrestorebutton.state {
        case .on:
            if let index = self.rcloneindex {
                _ = self.removework()
                self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
                self.info.stringValue = "Getting info, please wait..."
                self.estimatebutton.isEnabled = false
                self.working.startAnimation(nil)
                self.outputprocess = OutputProcess()
                self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
                if ViewControllerReference.shared.restorefilespath != nil {
                    _ = self.removework()
                    _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: true, updateprogress: self)
                }
            }
        case .off:
            guard self.remotesource.stringValue.isEmpty == false,
                self.restorepath.stringValue.isEmpty == false else {
                self.info(num: 2)
                return
            }
            self.working.startAnimation(nil)
            self.restorefiles?.executecopyfiles(remotefile: remotesource!.stringValue, localCatalog: restorepath!.stringValue, dryrun: true, updateprogress: self)
            self.outputprocess = self.restorefiles?.outputprocess
        default:
            return
        }
    }

    @IBAction func togglefullrestore(_: NSButton) {
        self.estimatebutton.isEnabled = true
        self.restorebutton.isEnabled = false
    }

    private func displayRemoteserver(index: Int?) {
        guard index != nil else {
            self.server.stringValue = ""
            self.rcatalog.stringValue = ""
            return
        }
        let hiddenID = self.configurations!.gethiddenID(index: index!)
        globalMainQueue.async { () -> Void in
            self.server.stringValue = self.configurations!.getResourceConfiguration(hiddenID: hiddenID, resource: .offsiteServer)
            self.rcatalog.stringValue = self.configurations!.getResourceConfiguration(hiddenID: hiddenID, resource: .remoteCatalog)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerReference.shared.setvcref(viewcontroller: .vccopyfiles, nsviewcontroller: self)
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
                self.commandstring.stringValue = self.restorefiles?.getCommandDisplayinView(remotefile: self.remotesource.stringValue, localCatalog: self.restorepath.stringValue) ?? ""
            }
        } else {
            let indexes = myTableViewFromNotification.selectedRowIndexes
            if let index = indexes.first {
                guard self.inprogress() == false else {
                    self.working.stopAnimation(nil)
                    guard self.restorefiles != nil else { return }
                    self.restorefiles?.abort()
                    return
                }
                self.rcloneindex = index
                if let hiddenID = self.configurations?.getConfigurationsSyncandCopy()?[index].value(forKey: "hiddenID") as? Int {
                    self.restorefiles = Restorefiles(hiddenID: hiddenID)
                    self.remotefilelist = Remotefilelist(hiddenID: hiddenID)
                    self.working.startAnimation(nil)
                    self.displayRemoteserver(index: index)
                }
            } else {
                self.rcloneindex = nil
                self.restoretabledata = nil
                globalMainQueue.async { () -> Void in
                    self.restoretableView.reloadData()
                }
            }
        }
    }

    func setremoteinfo() {
        guard self.outputprocess?.getOutput()?.count ?? 0 > 0 else { return }
        let size = self.remoterclonesize(input: self.outputprocess!.getOutput()![0])
        guard size != nil else { return }
        self.info.stringValue = String(NumberFormatter.localizedString(from: NSNumber(value: size!.count), number: NumberFormatter.Style.decimal)) + " " + String(NumberFormatter.localizedString(from: NSNumber(value: size!.bytes / 1024), number: NumberFormatter.Style.decimal))
        self.working.stopAnimation(nil)
        self.restorebutton.isEnabled = true
        self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
        self.info.stringValue = "Got it..."
    }

    func getremotenumbers() {
        if let index = self.rcloneindex {
            self.outputprocess = OutputProcess()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            _ = RcloneSize(index: index, outputprocess: self.outputprocess, updateprogress: self)
        }
    }

    func setnumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async { () -> Void in
            let infotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
            self.info.stringValue = infotask.transferredNumber ?? "0"
        }
    }
}
