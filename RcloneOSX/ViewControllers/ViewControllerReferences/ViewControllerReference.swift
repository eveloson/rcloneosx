//
//  ViewControllerReference.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 05.09.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity

import Cocoa
import Foundation

enum ViewController {
    case vctabmain
    case vcloggdata
    case vcnewconfigurations
    case vcabout
    case vcprogressview
    case vcrestore
    case vcquickbackup
    case vcallprofiles
    case vcestimatingtasks
    case vcremoteinfo
    case vcalloutput
    case vcedit
    case vcrcloneparameters
}

class ViewControllerReference {
    // Creates a singelton of this class
    class var shared: ViewControllerReference {
        enum Singleton {
            static let instance = ViewControllerReference()
        }
        return Singleton.instance
    }

    // Reference to the quick backup task
    var quickbackuptask: NSDictionary?
    // Download URL if new version is avaliable
    var URLnewVersion: String?
    // True if rclone in /usr/local/bin
    var rcloneopt: Bool = true
    // Optional path to rclone
    var rclonePath: String?
    // No valid rclonePath - true if no valid rclone is found
    var norclone: Bool = false
    // Detailed logging
    var detailedlogging: Bool = true
    // Path for restore
    var restorefilespath: String?
    // Placeholder for tmp restore
    var tmprestore: String = "tobereplaced"
    // Reference to the Operation object
    // Reference is set in when Scheduled task is executed
    var completeoperation: CompleteQuickbackupTask?
    // rclone command
    var rclone: String = "rclone"
    var usrbinrclone: String = "/usr/bin/rclone"
    var usrlocalbinrclone: String = "/usr/local/bin/rclone"
    var configpath: String = "/Rclone/"
    // New RcloneOSX config files and path
    var newconfigpath: String = "/.rcloneosx/"
    var usenewconfigpath: Bool = true
    // Plistnames and key
    var scheduleplist: String = "/scheduleRsync.plist"
    var schedulekey: String = "Schedule"
    var configurationsplist: String = "/configRsync.plist"
    var configurationskey: String = "Catalogs"
    var userconfigplist: String = "/config.plist"
    var userconfigkey: String = "config"
    // String commands
    var sync: String = "sync"
    var move: String = "move"
    var copy: String = "copy"
    var check: String = "check"
    // Loggfile
    var minimumlogging: Bool = false
    var fulllogging: Bool = false
    var logname: String = "rclonelog"
    var fileURL: URL?
    // Mark number of days since last backup
    var marknumberofdayssince: Double = 5
    // Rclone version string
    var rcloneversionstring: String?
    // Rclone version short
    var rcloneversionshort: String?
    // If rclone version 1.43 or more
    var rclone143: Bool?
    // filsize logfile warning
    var logfilesize: Int = 100_000
    // Mac serialnumer
    var macserialnumber: String?
    // Reference to main View
    // Initial start
    var initialstart: Int = 0
    // Reference to the active process
    var process: Process?

    private var viewControllertabMain: NSViewController?
    // Reference to the New tasks
    private var viewControllerNewConfigurations: NSViewController?
    // Which profile to use, if default nil
    private var viewControllerLoggData: NSViewController?
    // Reference to About
    private var viewControllerAbout: NSViewController?
    // ProgressView single task
    private var viewControllerProgressView: NSViewController?
    // Quick batch
    private var viewControllerQuickBatch: NSViewController?
    // All profiles
    private var viewControllerAllProfiles: NSViewController?
    // Estimating tasks
    private var viewControllerEstimatingTasks: NSViewController?
    // Remote info
    private var viewControllerRemoteInfo: NSViewController?
    // Restore
    private var viewControllerRestore: NSViewController?
    // Alloutput
    private var viewControllerAlloutput: NSViewController?
    // Edit
    private var viewControllerEdit: NSViewController?
    // Rclone parameters
    private var viewControllerRcloneParameters: NSViewController?

    func getvcref(viewcontroller: ViewController) -> NSViewController? {
        switch viewcontroller {
        case .vctabmain:
            return self.viewControllertabMain
        case .vcloggdata:
            return self.viewControllerLoggData
        case .vcnewconfigurations:
            return self.viewControllerNewConfigurations
        case .vcabout:
            return self.viewControllerAbout
        case .vcprogressview:
            return self.viewControllerProgressView
        case .vcquickbackup:
            return self.viewControllerQuickBatch
        case .vcallprofiles:
            return self.viewControllerAllProfiles
        case .vcestimatingtasks:
            return self.viewControllerEstimatingTasks
        case .vcremoteinfo:
            return self.viewControllerRemoteInfo
        case .vcrestore:
            return self.viewControllerRestore
        case .vcalloutput:
            return self.viewControllerAlloutput
        case .vcedit:
            return self.viewControllerEdit
        case .vcrcloneparameters:
            return self.viewControllerRcloneParameters
        }
    }

    func setvcref(viewcontroller: ViewController, nsviewcontroller: NSViewController?) {
        switch viewcontroller {
        case .vctabmain:
            self.viewControllertabMain = nsviewcontroller
        case .vcloggdata:
            self.viewControllerLoggData = nsviewcontroller
        case .vcnewconfigurations:
            self.viewControllerNewConfigurations = nsviewcontroller
        case .vcabout:
            self.viewControllerAbout = nsviewcontroller
        case .vcprogressview:
            self.viewControllerProgressView = nsviewcontroller
        case .vcquickbackup:
            self.viewControllerQuickBatch = nsviewcontroller
        case .vcallprofiles:
            self.viewControllerAllProfiles = nsviewcontroller
        case .vcestimatingtasks:
            self.viewControllerEstimatingTasks = nsviewcontroller
        case .vcremoteinfo:
            self.viewControllerRemoteInfo = nsviewcontroller
        case .vcrestore:
            self.viewControllerRestore = nsviewcontroller
        case .vcalloutput:
            self.viewControllerAlloutput = nsviewcontroller
        case .vcedit:
            self.viewControllerEdit = nsviewcontroller
        case .vcrcloneparameters:
            self.viewControllerRcloneParameters = nsviewcontroller
        }
    }
}
