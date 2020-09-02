//
//  NamesandPaths.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 29/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

enum WhatToReadWrite {
    case schedule
    case configuration
    case userconfig
    case none
}

enum Fileerrortype {
    case writelogfile
    case profilecreatedirectory
    case profiledeletedirectory
    case filesize
}

class NamesandPaths {
    // rootpath without macserialnumber
    var fullrootnomacserial: String?
    // rootpath with macserianlnumer
    var fullroot: String?
    // Name set for schedule, configuration or config
    var plistname: String?
    // key in objectForKey, e.g key for reading what
    var key: String?
    // Which profile to read
    var profile: String?
    // task to do
    var whattoreadwrite: WhatToReadWrite?
    // Path for configuration files
    var filepath: String?
    // Set which file to read
    var filename: String?
    // config path either
    // ViewControllerReference.shared.configpath or RcloneReference.shared.configpath
    var configpath: String?

    // Documentscatalog
    var documentscatalog: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        return (paths.firstObject as? String)
    }

    // Mac serialnumber
    var macserialnumber: String? {
        if ViewControllerReference.shared.macserialnumber == nil {
            ViewControllerReference.shared.macserialnumber = Macserialnumber().getMacSerialNumber() ?? ""
        }
        return ViewControllerReference.shared.macserialnumber
    }

    var userHomeDirectoryPath: String? {
        let pw = getpwuid(getuid())
        if let home = pw?.pointee.pw_dir {
            let homePath = FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
            return homePath
        } else {
            return nil
        }
    }

    func setrootpath() {
        if ViewControllerReference.shared.usenewconfigpath == true {
            self.fullroot = (self.userHomeDirectoryPath ?? "") + (self.configpath ?? "") + (self.macserialnumber ?? "")
            self.fullrootnomacserial = (self.userHomeDirectoryPath ?? "") + (self.configpath ?? "")
        } else {
            self.fullroot = (self.documentscatalog ?? "") + (self.configpath ?? "") + (self.macserialnumber ?? "")
            self.fullrootnomacserial = (self.documentscatalog ?? "") + (self.configpath ?? "")
        }
    }

    // Set path and name for reading plist.files
    func setnameandpath() {
        let config = (self.configpath ?? "") + (self.macserialnumber ?? "")
        let plist = (self.plistname ?? "")
        if let profile = self.profile {
            // Use profile
            if ViewControllerReference.shared.usenewconfigpath == true {
                self.filename = (self.userHomeDirectoryPath ?? "") + config + "/" + profile + plist
            } else {
                self.filename = (self.documentscatalog ?? "") + config + "/" + profile + plist
            }
            self.filepath = config + "/" + profile + "/"
        } else {
            if ViewControllerReference.shared.usenewconfigpath == true {
                self.filename = (self.userHomeDirectoryPath ?? "") + config + plist
            } else {
                self.filename = (self.documentscatalog ?? "") + config + plist
            }
            self.filepath = config + "/"
        }
    }

    // Set preferences for which data to read or write
    func setpreferencesforreadingplist(whattoreadwrite: WhatToReadWrite) {
        self.whattoreadwrite = whattoreadwrite
        switch self.whattoreadwrite ?? .none {
        case .schedule:
            self.plistname = ViewControllerReference.shared.scheduleplist
            self.key = ViewControllerReference.shared.schedulekey
        case .configuration:
            self.plistname = ViewControllerReference.shared.configurationsplist
            self.key = ViewControllerReference.shared.configurationskey
        case .userconfig:
            self.plistname = ViewControllerReference.shared.userconfigplist
            self.key = ViewControllerReference.shared.userconfigkey
        case .none:
            self.plistname = nil
            self.key = nil
        }
    }

    init() {
        self.configpath = Configpath().configpath
        self.setrootpath()
    }

    init(whattoreadwrite: WhatToReadWrite, profile: String?) {
        self.configpath = Configpath().configpath
        self.profile = profile
        self.setpreferencesforreadingplist(whattoreadwrite: whattoreadwrite)
        self.setnameandpath()
    }
}
