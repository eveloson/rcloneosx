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
                        if let index = self.index {
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
        if let index = self.index {
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
        if self.restoretask == nil {
            self.setremoteinfo()
            self.working.stopAnimation(nil)
            self.restorebutton.isEnabled = true
        } else {
            if let vc = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess {
                vc.processTermination()
            }
            self.info(num: 5)
            self.restoretask = nil
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
    func setrestorepath() -> Bool {
        self.restorepath.stringValue = ViewControllerReference.shared.restorefilespath ?? "...Set in user config..."
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.restorepath.stringValue) == false {
            self.info(num: 1)
            return false
        } else {
            self.info(num: 0)
            return true
        }
    }
}

extension ViewControllerRestore: NewProfile {
    func newProfile(profile _: String?, selectedindex _: Int?) {
        self.restoretabledata = nil
        self.reset()
        globalMainQueue.async { () -> Void in
            self.restoretableView.reloadData()
            self.rclonetableView.reloadData()
        }
    }

    func reloadprofilepopupbutton() {
        //
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
        switch self.fullrestorebutton.state {
        case .on:
            return self.outputprocess?.count() ?? 0
        case .off:
            return self.restorefiles?.outputprocess?.count() ?? 0
        default:
            return 0
        }
    }
}
