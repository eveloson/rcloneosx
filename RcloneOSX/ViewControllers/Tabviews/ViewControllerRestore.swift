//
//  ViewControllerCopyFiles.swift
//  RcloneOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length file_length

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

class ViewControllerRestore: NSViewController, SetConfigurations, Delay, VcMain, Checkforrclone {
    var restorefiles: Restorefiles?
    var remotefilelist: Remotefilelist?
    var rcloneindex: Int?
    private var restoretabledata: [String]?
    var diddissappear: Bool = false
    var outputprocess: OutputProcess?
    private var maxcount: Int = 0
    var workqueue: [Work]?

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
        guard self.restorefiles != nil else { return }
        self.estimatebutton.isEnabled = true
        self.restorefiles!.abort()
    }

    private func info(num: Int) {
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
            return
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
            return
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

    private func inprogress() -> Bool {
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
}

extension ViewControllerRestore: NSSearchFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        if (notification.object as? NSTextField)! == self.search {
            self.delayWithSeconds(0.25) {
                if self.search.stringValue.isEmpty {
                    globalMainQueue.async { () -> Void in
                        if let index = self.rcloneindex {
                            if let hiddenID = self.configurations!.getConfigurationsSyncandCopy()![index].value(forKey: "hiddenID") as? Int {
                                self.remotefilelist = Remotefilelist(hiddenID: hiddenID)
                            }
                        }
                    }
                } else {
                    globalMainQueue.async { () -> Void in
                        self.restoretabledata = self.restoretabledata!.filter { $0.contains(self.search.stringValue) }
                        self.restoretableView.reloadData()
                    }
                }
            }
        } else {
            self.delayWithSeconds(0.25) {
                guard self.remotesource.stringValue.count > 0 else { return }
                self.commandstring.stringValue = self.restorefiles?.getCommandDisplayinView(remotefile: self.remotesource.stringValue, localCatalog: self.restorepath.stringValue) ?? ""
            }
        }
    }

    func searchFieldDidEndSearching(_: NSSearchField) {
        if let index = self.rcloneindex {
            if self.configurations!.getConfigurationsSyncandCopy()![index].value(forKey: "hiddenID") as? Int != nil {
                self.working.startAnimation(nil)
            }
        }
    }
}

extension ViewControllerRestore: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == self.restoretableView {
            self.numberofrows.stringValue = "Number of remote files: " + String(self.restoretabledata?.count ?? 0)
            return self.restoretabledata?.count ?? 0
        } else {
            return self.configurations?.getConfigurationsSyncandCopy()?.count ?? 0
        }
    }
}

extension ViewControllerRestore: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == self.restoretableView {
            guard self.restoretabledata != nil else { return nil }
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "files"), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = self.restoretabledata?[row] ?? ""
                return cell
            }
        } else {
            guard row < self.configurations!.getConfigurationsSyncandCopy()!.count else { return nil }
            let object: NSDictionary = self.configurations!.getConfigurationsSyncandCopy()![row]
            let cellIdentifier: String = tableColumn!.identifier.rawValue
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = object.value(forKey: cellIdentifier) as? String ?? ""
                return cell
            }
        }
        return nil
    }
}

extension ViewControllerRestore: UpdateProgress {
    private func removework() -> Work? {
        // Initialize
        guard self.workqueue != nil else {
            self.workqueue = [Work]()
            self.workqueue?.append(.setremotenumbers)
            self.workqueue?.append(.getremotenumbers)
            self.workqueue?.append(.localinfoandnumbertosync)
            return nil
        }
        guard self.workqueue!.count > 1 else {
            let work = self.workqueue?[0] ?? .restore
            return work
        }
        let index = self.workqueue!.count - 1
        let work = self.workqueue!.remove(at: index)
        return work
    }

    func processTermination() {
        switch self.fullrestorebutton.state {
        case .on:
            self.processTerminationfullrestore()
        case .off:
            self.processTerminationrestorefiles()
        default:
            return
        }
    }

    func fileHandler() {
        switch self.fullrestorebutton.state {
        case .on:
            self.fileHandlerfullrestore()
        case .off:
            self.fileHandelerrestorefiles()
        default:
            return
        }
    }

    func processTerminationrestorefiles() {
        self.maxcount = self.outputprocess?.getMaxcount() ?? 0
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.processTermination()
            self.estimatebutton.isEnabled = false
            self.restorebutton.isEnabled = true
        } else {
            self.estimatebutton.isEnabled = false
            self.restorebutton.isEnabled = true
        }
        self.working.stopAnimation(nil)
    }

    func processTerminationfullrestore() {
        switch self.removework() ?? .localinfoandnumbertosync {
        case .getremotenumbers:
            self.maxcount = self.outputprocess?.getMaxcount() ?? 0
        // self.setNumbers(outputprocess: self.outputprocess)
        // self.getremotenumbers()
        case .setremotenumbers:
            return
        // self.setremoteinfo()
        case .localinfoandnumbertosync:
            // self.setNumbers(outputprocess: self.outputprocess)
            guard ViewControllerReference.shared.restorefilespath != nil else { return }
            self.working.stopAnimation(nil)
            self.restorebutton.isEnabled = true
        // self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
        // self.gotit.stringValue = "Got it..."
        case .restore:
            if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
                vc.processTermination()
            }
            // self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            // self.gotit.stringValue = "Got it..."
        }
    }

    func fileHandelerrestorefiles() {
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.fileHandler()
        }
    }

    func fileHandlerfullrestore() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
        if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
            vc.fileHandler()
        }
    }
}

extension ViewControllerRestore: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}

extension ViewControllerRestore: Setrestorepath {
    func setrestorepath() {
        self.restorepath.stringValue = ViewControllerReference.shared.restorefilespath ?? "...Set in user config..."
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.restorepath.stringValue) == false {
            self.info(num: 1)
        } else {
            self.info(num: 0)
        }
    }
}

extension ViewControllerRestore: NewProfile {
    func newProfile(profile _: String?) {
        self.restoretabledata = nil
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
        }
    }
}

extension ViewControllerRestore: OpenQuickBackup {
    func openquickbackup() {
        globalMainQueue.async { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        }
    }
}

extension ViewControllerRestore: Updateremotefilelist {
    func updateremotefilelist() {
        self.restoretabledata = self.remotefilelist?.remotefilelist
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
        }
        self.working.stopAnimation(nil)
        self.remotefilelist = nil
    }
}

extension ViewControllerRestore: Count {
    func maxCount() -> Int {
        return self.maxcount
    }

    func inprogressCount() -> Int {
        return self.restorefiles?.outputprocess?.count() ?? 0
    }
}
