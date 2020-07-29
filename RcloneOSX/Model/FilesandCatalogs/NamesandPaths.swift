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
    var rootpath: String?
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

    func setrootpath() {
        self.rootpath = (self.documentscatalog ?? "") + (self.configpath ?? "") + (self.macserialnumber ?? "")
    }

    func setnameandpath() {
        let config = (self.configpath ?? "") + (self.macserialnumber ?? "")
        let plist = (self.plistname ?? "")
        if let profile = self.profile {
            // Use profile
            let profilePath = CatalogProfile()
            profilePath.createprofilecatalog()
            self.filename = (self.documentscatalog ?? "") + config + "/" + profile + plist
            self.filepath = config + "/" + profile + "/"
        } else {
            // no profile
            let profilePath = CatalogProfile()
            profilePath.createprofilecatalog()
            self.filename = (self.documentscatalog ?? "") + config + plist
            self.filepath = config + "/"
        }
    }

    // Set preferences for which data to read or write
    func setpreferencesforreadingplist(whattoreadwrite: WhatToReadWrite) {
        self.whattoreadwrite = whattoreadwrite
        switch self.whattoreadwrite! {
        case .schedule:
            self.plistname = "/scheduleRsync.plist"
            self.key = "Schedule"
        case .configuration:
            self.plistname = "/configRsync.plist"
            self.key = "Catalogs"
        case .userconfig:
            self.plistname = "/config.plist"
            self.key = "config"
        case .none:
            self.plistname = nil
        }
    }

    init(configpath: String?) {
        self.configpath = configpath
        self.setrootpath()
    }

    init(whattoreadwrite: WhatToReadWrite, profile: String?, configpath: String?) {
        self.configpath = configpath
        self.profile = profile
        self.setpreferencesforreadingplist(whattoreadwrite: whattoreadwrite)
        self.setnameandpath()
    }
}
