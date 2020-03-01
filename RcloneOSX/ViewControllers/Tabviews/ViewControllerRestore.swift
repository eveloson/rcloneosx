//
//  ViewControllerRestore.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 09.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

enum Work {
    case localinfoandnumbertosync
    case getremotenumbers
    case setremotenumbers
    case restore
}

class ViewControllerRestore: NSViewController, SetConfigurations, Remoterclonesize, Setcolor, VcMain, Checkforrclone, Abort {
    @IBOutlet var restoretable: NSTableView!
    @IBOutlet var working: NSProgressIndicator!
    @IBOutlet var gotit: NSTextField!

    @IBOutlet var transferredNumber: NSTextField!
    @IBOutlet var totalNumber: NSTextField!
    @IBOutlet var totalNumberSizebytes: NSTextField!
    @IBOutlet var restorebutton: NSButton!
    @IBOutlet var tmprestore: NSTextField!
    @IBOutlet var estimatebutton: NSButton!

    var outputprocess: OutputProcess?
    weak var sendprocess: SendProcessreference?
    var diddissappear: Bool = false
    var workqueue: [Work]?
    var index: Int?
    var maxcount: Int = 0

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
        self.workqueue = nil
        self.abort()
    }

    @IBAction func restore(_: NSButton) {
        let answer = Alerts.dialogOKCancel("Do you REALLY want to start a RESTORE ?", text: "Cancel or OK")
        if answer {
            if let index = self.index {
                self.workqueue = [Work]()
                self.workqueue?.append(.restore)
                self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
                self.gotit.stringValue = "Executing restore..."
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
    }

    private func getremotenumbers() {
        if let index = self.index {
            self.outputprocess = OutputProcess()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            _ = RcloneSize(index: index, outputprocess: self.outputprocess, updateprogress: self)
        }
    }

    private func setremoteinfo() {
        guard self.outputprocess?.getOutput()?.count ?? 0 > 0 else { return }
        let size = self.remoterclonesize(input: self.outputprocess!.getOutput()![0])
        guard size != nil else { return }
        self.totalNumber.stringValue = String(NumberFormatter.localizedString(from: NSNumber(value: size!.count), number: NumberFormatter.Style.decimal))
        self.totalNumberSizebytes.stringValue = String(NumberFormatter.localizedString(from: NSNumber(value: size!.bytes / 1024), number: NumberFormatter.Style.decimal))
        self.working.stopAnimation(nil)
        self.restorebutton.isEnabled = true
        self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
        self.gotit.stringValue = "Got it..."
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoretable.delegate = self
        self.restoretable.dataSource = self
        ViewControllerReference.shared.setvcref(viewcontroller: .vcrestore, nsviewcontroller: self)
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.gotit.isHidden = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        guard self.diddissappear == false else { return }
        self.restorebutton.isEnabled = false
        self.estimatebutton.isEnabled = false
        self.setrestorepath()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.diddissappear = true
    }

    private func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async { () -> Void in
            let infotask = RemoteinfonumbersOnetask(outputprocess: outputprocess)
            self.transferredNumber.stringValue = infotask.transferredNumber!
        }
    }

    @IBAction func prepareforrestore(_: NSButton) {
        if let index = self.index {
            _ = self.removework()
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .white)
            self.gotit.stringValue = "Getting info, please wait..."
            self.gotit.isHidden = false
            self.estimatebutton.isEnabled = false
            self.working.startAnimation(nil)
            self.outputprocess = OutputProcess()
            self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
            if ViewControllerReference.shared.restorePath != nil {
                _ = self.removework()
                _ = RestoreTask(index: index, outputprocess: self.outputprocess, dryrun: true, updateprogress: self)
            }
        }
    }

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

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.estimatebutton.isEnabled = true
            self.index = index
        } else {
            self.estimatebutton.isEnabled = false
            self.index = nil
        }
        self.setrestorepath()
        self.workqueue = nil
        self.gotit.isHidden = true
    }
}

extension ViewControllerRestore: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.configurations?.getConfigurationsSyncandCopy()?.count ?? 0
    }
}

extension ViewControllerRestore: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsSyncandCopy()!.count else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsSyncandCopy()![row]
        return object[tableColumn!.identifier] as? String
    }
}

extension ViewControllerRestore: UpdateProgress {
    func processTermination() {
        switch self.removework() ?? .localinfoandnumbertosync {
        case .getremotenumbers:
            self.maxcount = self.outputprocess?.getMaxcount() ?? 0
            self.setNumbers(outputprocess: self.outputprocess)
            self.getremotenumbers()
        case .setremotenumbers:
            self.setremoteinfo()
        case .localinfoandnumbertosync:
            self.setNumbers(outputprocess: self.outputprocess)
            guard ViewControllerReference.shared.restorePath != nil else { return }
            self.working.stopAnimation(nil)
            self.restorebutton.isEnabled = true
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.gotit.stringValue = "Got it..."
        case .restore:
            if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
                vc.processTermination()
            }
            self.gotit.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.gotit.stringValue = "Got it..."
        }
    }

    func fileHandler() {
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
        globalMainQueue.async { () -> Void in
            self.restoretable.reloadData()
        }
    }
}

extension ViewControllerRestore: Count {
    func maxCount() -> Int {
        return self.maxcount
    }

    func inprogressCount() -> Int {
        return self.outputprocess?.count() ?? 0
    }
}

extension ViewControllerRestore: Setrestorepath {
    func setrestorepath() {
        let setuserconfig: String = NSLocalizedString(" ... set in User configuration ...", comment: "Restore")
        self.tmprestore.stringValue = ViewControllerReference.shared.restorePath ?? setuserconfig
        if (ViewControllerReference.shared.restorePath ?? "").isEmpty == true {
            self.restorebutton.isEnabled = false
            self.estimatebutton.isEnabled = false
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
