//
//  extensionRestore.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 02/03/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Cocoa
import Foundation

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
                self.commandstring.stringValue = self.restorefiles?.getcommandrestorefiles(remotefile: self.remotesource.stringValue, localCatalog: self.restorepath.stringValue) ?? ""
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
    func removework() -> Work? {
        // Initialize
        guard self.workqueue != nil else {
            self.workqueue = [Work]()
            self.workqueue?.append(.setremotenumbers)
            self.workqueue?.append(.getremotenumbers)
            self.workqueue?.append(.localinfoandnumbertosync)
            return nil
        }
        guard (self.workqueue?.count ?? 0) > 1 else {
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
            self.setnumbers(outputprocess: self.outputprocess)
            self.getremotenumbers()
        case .setremotenumbers:
            self.setremoteinfo()
        case .localinfoandnumbertosync:
            self.setnumbers(outputprocess: self.outputprocess)
            guard ViewControllerReference.shared.restorefilespath != nil else { return }
            self.working.stopAnimation(nil)
            self.restorebutton.isEnabled = true
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Got it..."
        case .restore:
            if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
                vc.processTermination()
            }
            self.info.textColor = setcolor(nsviewcontroller: self, color: .green)
            self.info.stringValue = "Got it..."
        }
    }

    func fileHandelerrestorefiles() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
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
            self.rclonetableView.reloadData()
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
