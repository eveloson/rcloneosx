//
//  rcloneParameters.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

class RcloneParameters {

    var arguments: [String]?
    var localCatalog: String?
    var offsiteCatalog: String?
    var offsiteUsername: String?
    var offsiteServer: String?
    var remoteargs: String?
    let suffixstringdate = "--suffix=date"

    // Brute force, check every parameter, not special elegant, but it works
    func rclonecommand(config: Configuration, dryRun: Bool, forDisplay: Bool) {
        if config.parameter1 != nil {
            self.appendParameter(parameter: config.parameter1!, forDisplay: forDisplay)
        }
    }

    func setParameters2To14(_ config: Configuration, dryRun: Bool, forDisplay: Bool) {
        if config.parameter2 != nil {
            self.appendParameter(parameter: config.parameter2!, forDisplay: forDisplay)
        }
        if config.parameter3 != nil {
            self.appendParameter(parameter: config.parameter3!, forDisplay: forDisplay)
        }
        if config.parameter4 != nil {
            self.appendParameter(parameter: config.parameter4!, forDisplay: forDisplay)
        }
        if config.parameter5 != nil {
            self.appendParameter(parameter: config.parameter5!, forDisplay: forDisplay)
        }
        if config.parameter6 != nil {
            self.appendParameter(parameter: config.parameter6!, forDisplay: forDisplay)
        }
        if config.parameter8 != nil {
            self.appendParameter(parameter: config.parameter8!, forDisplay: forDisplay)
        }
        if config.parameter9 != nil {
            self.appendParameter(parameter: config.parameter9!, forDisplay: forDisplay)
        }
        if config.parameter10 != nil {
            self.appendParameter(parameter: config.parameter10!, forDisplay: forDisplay)
        }
        if config.parameter11 != nil {
            self.appendParameter(parameter: config.parameter11!, forDisplay: forDisplay)
        }
        if config.parameter12 != nil {
            self.appendParameter(parameter: config.parameter12!, forDisplay: forDisplay)
        }
        if config.parameter13 != nil {
            self.appendParameter(parameter: config.parameter13!, forDisplay: forDisplay)
        }
        if config.parameter14 != nil {
            if config.parameter14! == self.suffixstringdate {
                self.appendParameter(parameter: self.setdatesuffixlocalhost(), forDisplay: forDisplay)
            } else {
                 self.appendParameter(parameter: config.parameter14!, forDisplay: forDisplay)
            }
        }
    }

    func setdatesuffixlocalhost() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "-yyyy-MM-dd"
        return  "--suffix=" + formatter.string(from: Date())
    }

    func dryrunparameter(_ config: Configuration, forDisplay: Bool) {
        let dryrun: String = config.dryrun
        self.arguments!.append(dryrun)
        if forDisplay {self.arguments!.append(" ")}
    }

    func appendParameter (parameter: String, forDisplay: Bool) {
        if parameter.count > 1 {
            self.arguments!.append(parameter)
            if forDisplay {
                self.arguments!.append(" ")
            }
        }
    }

    func argumentsRclonerestore(_ config: Configuration, dryRun: Bool, forDisplay: Bool) -> [String] {
        self.localCatalog = nil
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteServer = config.offsiteServer
        self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
        self.appendParameter(parameter: ViewControllerReference.shared.copy, forDisplay: forDisplay)
        self.appendParameter(parameter: self.remoteargs!, forDisplay: forDisplay)
        self.appendParameter(parameter: "--verbose", forDisplay: forDisplay)
        if dryRun {
           self.dryrunparameter(config, forDisplay: forDisplay)
        }
        return self.arguments!
    }

    func argumentsRclonelistfile(_ config: Configuration) -> [String] {
        self.localCatalog = nil
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteServer = config.offsiteServer
        self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
        self.appendParameter(parameter: "ls", forDisplay: false)
        self.appendParameter(parameter: self.remoteargs!, forDisplay: false)
        return self.arguments!
    }

    init () {
        self.arguments = [String]()
    }
}
