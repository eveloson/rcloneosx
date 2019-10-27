//
//  ViewControllerExtensions.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 28.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol VcMain {
    var storyboard: NSStoryboard? { get }
    var viewControllerInformation: NSViewController? { get }
    var viewControllerProgress: NSViewController? { get }
    var viewControllerBatch: NSViewController? { get }
    var viewControllerUserconfiguration: NSViewController? { get }
    var viewControllerRcloneParams: NSViewController? { get }
    var newVersionViewController: NSViewController? { get }
    var viewControllerProfile: NSViewController? { get }
    var editViewController: NSViewController? { get }
    var viewControllerAbout: NSViewController? { get }
}

extension VcMain {
    var storyboard: NSStoryboard? {
        return NSStoryboard(name: "Main", bundle: nil)
    }

    // Information about rclone output
    // self.presentViewControllerAsSheet(self.ViewControllerInformation)
    var viewControllerInformation: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardInformationID")
            as? NSViewController)
    }

    // Progressbar process
    // self.presentViewControllerAsSheet(self.ViewControllerProgress)
    var viewControllerProgress: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardProgressID")
            as? NSViewController)
    }

    // Batch process
    // self.presentViewControllerAsSheet(self.ViewControllerBatch)
    var viewControllerBatch: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardBatchID")
            as? NSViewController)
    }

    // Userconfiguration
    // self.presentViewControllerAsSheet(self.ViewControllerUserconfiguration)
    var viewControllerUserconfiguration: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardUserconfigID")
            as? NSViewController)
    }

    // Rclone userparams
    // self.presentViewControllerAsSheet(self.viewControllerRcloneParams)
    var viewControllerRcloneParams: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardRcloneParamsID")
            as? NSViewController)
    }

    // New version window
    // self.presentViewControllerAsSheet(self.newVersionViewController)
    var newVersionViewController: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardnewVersionID")
            as? NSViewController)
    }

    // Edit
    // self.presentViewControllerAsSheet(self.editViewController)
    var editViewController: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardEditID")
            as? NSViewController)
    }

    // Profile
    // self.presentViewControllerAsSheet(self.ViewControllerProfile)
    var viewControllerProfile: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "ProfileID")
            as? NSViewController)
    }

    // About
    // self.presentViewControllerAsSheet(self.ViewControllerAbout)
    var viewControllerAbout: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "AboutID")
            as? NSViewController)
    }

    // Quick backup process
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerQuickBackup: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardQuickBackupID")
            as? NSViewController)
    }

    // Remote Info
    // self.presentViewControllerAsSheet(self.viewControllerQuickBackup)
    var viewControllerRemoteInfo: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardRemoteInfoID")
            as? NSViewController)
    }

    // Estimating
    // self.presentViewControllerAsSheet(self.viewControllerEstimating)
    var viewControllerEstimating: NSViewController? {
        return (self.storyboard?.instantiateController(withIdentifier: "StoryboardEstimatingID")
            as? NSViewController)
    }
}

// Protocol for dismissing a viewcontroller
protocol DismissViewController: class {
    func dismiss_view(viewcontroller: NSViewController)
}
protocol SetDismisser {
    var dismissDelegateMain: DismissViewController? { get }
    var dismissDelegateNewConfigurations: DismissViewController? { get }
    var dismissDelegateCopyFiles: DismissViewController? { get }
    var dismissDelegateLoggData: DismissViewController? { get }
    var dismissDelegateRestore: DismissViewController? { get }
}

extension SetDismisser {
    var dismissDelegateMain: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }
    var dismissDelegateCopyFiles: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
    }
    var dismissDelegateNewConfigurations: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations) as? ViewControllerNewConfigurations
    }
    var dismissDelegateLoggData: DismissViewController? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
    }
    var dismissDelegateRestore: DismissViewController? {
           return ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
    }

    func dismissview(viewcontroller: NSViewController, vcontroller: ViewController) {
        if vcontroller == .vctabmain {
            self.dismissDelegateMain?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vccopyfiles {
            self.dismissDelegateCopyFiles?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcnewconfigurations {
            self.dismissDelegateNewConfigurations?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcloggdata {
            self.dismissDelegateLoggData?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        } else if vcontroller == .vcrestore {
            self.dismissDelegateRestore?.dismiss_view(viewcontroller: (self as? NSViewController)!)
        }
    }
}

// Protocol for deselecting rowtable
protocol DeselectRowTable: class {
    func deselect()
}

protocol Deselect {
    var deselectDelegateMain: DeselectRowTable? {get}
}

extension Deselect {
    var deselectDelegateMain: DeselectRowTable? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func deselectrowtable() {
        self.deselectDelegateMain?.deselect()
    }
}

protocol Index {
     func index() -> Int?
}

extension Index {
    func index() -> Int? {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        return view?.getindex()
    }
}

protocol Delay {
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void)
}

extension Delay {

    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

protocol Abort {
    func abort()
}

extension Abort {
    func abort() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        view?.abortOperations()
    }
}

protocol GetOutput: class {
    func getoutput () -> [String]
}

protocol OutPut {
    var informationDelegateMain: GetOutput? { get }
}

extension OutPut {
    var informationDelegateMain: GetOutput? {
        return ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    func getinfo() -> [String] {
        return self.informationDelegateMain?.getoutput() ?? [""]
    }
}

protocol RcloneIsChanged: class {
    func rcloneischanged()
}

protocol NewRclone {
    func newrclone()
}

extension NewRclone {
    func newrclone() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        view?.rcloneischanged()
    }
}

protocol TemporaryRestorePath: class {
    func temporaryrestorepath()
}

protocol ChangeTemporaryRestorePath {
    func changetemporaryrestorepath()
}

extension ChangeTemporaryRestorePath {
    func changetemporaryrestorepath() {
        let view = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        view?.temporaryrestorepath()
    }
}

protocol Createandreloadconfigurations: class {
    func createandreloadconfigurations()
}
// Protocol for sorting
protocol Sorting {
    func sortbydate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]?
    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter, sortdirection: Bool) -> [NSMutableDictionary]?
}

extension Sorting {
    func sortbydate(notsortedlist: [NSMutableDictionary]?, sortdirection: Bool) -> [NSMutableDictionary]? {
        let dateformatter = Dateandtime().setDateformat()
        let sorted = notsortedlist?.sorted { (dict1, dict2) -> Bool in
            let date1localized = dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String) ?? "")
            if let date2localized = dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String) ?? "") {
                if date1localized?.timeIntervalSince(date2localized) ?? -1 > 0 {
                    return sortdirection
                } else {
                    return !sortdirection
                }
            } else {
                return !sortdirection
            }
        }
        return sorted
    }

    func sortbystring(notsortedlist: [NSMutableDictionary]?, sortby: Sortandfilter, sortdirection: Bool) -> [NSMutableDictionary]? {
        let sortstring = self.filterbystring(filterby: sortby)
        let sorted = notsortedlist?.sorted { (dict1, dict2) -> Bool in
            if (dict1.value(forKey: sortstring) as? String) ?? "" > (dict2.value(forKey: sortstring) as? String) ?? "" {
                return sortdirection
            } else {
                return !sortdirection
            }
        }
        return sorted
    }

    func filterbystring(filterby: Sortandfilter) -> String {
        switch filterby {
        case .localcatalog:
            return "localCatalog"
        case .profile:
            return "profile"
        case .offsitecatalog:
            return "offsiteCatalog"
        case .offsiteserver:
            return "offsiteServer"
        case .task:
            return "task"
        case .backupid:
            return "backupID"
        case .numberofdays:
            return "daysID"
        case .executedate:
            return "dateExecuted"
        }
    }
}

protocol Remoterclonesize: class {
    func remoterclonesize(input: String) -> Size?
}

extension Remoterclonesize {
    func remoterclonesize(input: String) -> Size? {
        let data: Data = input.data(using: String.Encoding.utf8)!
        guard let size = try? JSONDecoder().decode(Size.self, from: data) else { return nil}
        return size
    }
}
