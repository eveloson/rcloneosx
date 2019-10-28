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

    // Brute force, check every parameter, not special elegant, but it works
    func rclonecommand(config: Configuration, dryRun: Bool, forDisplay: Bool) {
        if config.parameter1 != nil {
            self.appendParameter(parameter: config.parameter1!, forDisplay: forDisplay)
        }
    }

    func setParameters2To14(config: Configuration, dryRun: Bool, forDisplay: Bool) {
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
            if config.parameter14! == SuffixstringsRcloneParameters().suffixstringdate {
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

    func dryrunparameter(config: Configuration, forDisplay: Bool) {
        let dryrun: String = config.dryrun
        if forDisplay {self.arguments!.append(" ")}
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

    init () {
        self.arguments = [String]()
    }
}
