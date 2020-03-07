//
//  rcloneParameters.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 03/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity
import Foundation

class RcloneParameters {
    var arguments: [String]?
    var localCatalog: String?
    var offsiteCatalog: String?
    var offsiteUsername: String?
    var offsiteServer: String?
    var remoteargs: String?

    // Brute force, check every parameter, not special elegant, but it works
    func rclonecommand(config: Configuration, dryRun _: Bool, forDisplay: Bool) {
        if config.parameter1 != nil {
            self.appendparameter(parameter: config.parameter1!, forDisplay: forDisplay)
        }
    }

    func rclonecommandrestore(dryRun _: Bool, forDisplay: Bool) {
        self.appendparameter(parameter: ViewControllerReference.shared.copy, forDisplay: forDisplay)
    }

    func setParameters2To14(config: Configuration, dryRun _: Bool, forDisplay: Bool) {
        if config.parameter2 != nil {
            self.appendparameter(parameter: config.parameter2!, forDisplay: forDisplay)
        }
        if config.parameter3 != nil {
            self.appendparameter(parameter: config.parameter3!, forDisplay: forDisplay)
        }
        if config.parameter4 != nil {
            self.appendparameter(parameter: config.parameter4!, forDisplay: forDisplay)
        }
        if config.parameter5 != nil {
            self.appendparameter(parameter: config.parameter5!, forDisplay: forDisplay)
        }
        if config.parameter6 != nil {
            self.appendparameter(parameter: config.parameter6!, forDisplay: forDisplay)
        }
        if config.parameter8 != nil {
            self.appendparameter(parameter: config.parameter8!, forDisplay: forDisplay)
        }
        if config.parameter9 != nil {
            self.appendparameter(parameter: config.parameter9!, forDisplay: forDisplay)
        }
        if config.parameter10 != nil {
            self.appendparameter(parameter: config.parameter10!, forDisplay: forDisplay)
        }
        if config.parameter11 != nil {
            self.appendparameter(parameter: config.parameter11!, forDisplay: forDisplay)
        }
        if config.parameter12 != nil {
            self.appendparameter(parameter: config.parameter12!, forDisplay: forDisplay)
        }
        if config.parameter13 != nil {
            self.appendparameter(parameter: config.parameter13!, forDisplay: forDisplay)
        }
        if config.parameter14 != nil {
            if config.parameter14! == SuffixstringsRcloneParameters().suffixstringdate {
                self.appendparameter(parameter: self.setdatesuffixlocalhost(), forDisplay: forDisplay)
            } else {
                self.appendparameter(parameter: config.parameter14!, forDisplay: forDisplay)
            }
        }
    }

    func remoteparameter(config: Configuration, dryRun _: Bool, forDisplay _: Bool) {
        self.localCatalog = config.localCatalog
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            if config.localCatalog.isEmpty == true {
                self.remoteargs = self.offsiteServer! + ":"
            } else {
                self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
            }
        }
    }

    func offsiteparameter(config: Configuration, forDisplay: Bool) {
        if self.offsiteServer!.isEmpty {
            if forDisplay { self.arguments!.append(" ") }
            self.arguments!.append(self.offsiteCatalog!)
        } else {
            if forDisplay { self.arguments!.append(" ") }
            self.arguments!.append(remoteargs!)
            if config.localCatalog.isEmpty == true {
                if forDisplay { self.arguments!.append(" ") }
                self.arguments!.append(self.offsiteCatalog ?? "")
            }
            if forDisplay { self.arguments!.append(" ") }
        }
    }

    func setdatesuffixlocalhost() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "-yyyy-MM-dd"
        return "--suffix=" + formatter.string(from: Date())
    }

    func dryrunparameter(config: Configuration, forDisplay: Bool) {
        let dryrun: String = config.dryrun
        if forDisplay { self.arguments!.append(" ") }
        self.arguments!.append(dryrun)
        if forDisplay { self.arguments!.append(" ") }
    }

    func appendparameter(parameter: String?, forDisplay: Bool) {
        if parameter != nil {
            guard parameter?.count ?? -1 > 0 else { return }
            self.arguments?.append(parameter!)
            if forDisplay {
                self.arguments?.append(" ")
            }
        }
    }

    init() {
        self.arguments = [String]()
    }
}
