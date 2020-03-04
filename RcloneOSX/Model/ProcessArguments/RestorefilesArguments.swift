//
//  scpNSTaskArguments.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 27/06/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

enum Enumrestorefiles {
    case restorerclone
    case listrclone
}

final class RestorefilesArguments: SetConfigurations {
    private var arguments: [String]?
    private var argdisplaydryrun: [String]?
    private var argdryrun: [String]?
    private var remotefile: String?
    private var localCatalog: String?

    func getArguments() -> [String]? {
        guard (self.arguments?.count ?? 0) > 2 else { return self.arguments }
        self.arguments![1] = self.arguments![1] + "/" + self.remotefile!
        self.arguments?.insert(self.localCatalog!, at: 2)
        return self.arguments
    }

    func getArgumentsdryRun() -> [String]? {
        self.argdryrun![1] = self.argdryrun![1] + "/" + self.remotefile!
        self.argdryrun?.insert(self.localCatalog!, at: 2)
        return self.argdryrun
    }

    func getcommandDisplay() -> String {
        guard self.argdisplaydryrun != nil else { return "" }
        var arguments: String = ""
        for i in 0 ..< (self.argdisplaydryrun?.count ?? 0) {
            if i == 2 {
                arguments += self.argdisplaydryrun![i] + "/" + self.remotefile!
                arguments += " " + self.localCatalog! + " "
            } else {
                arguments += self.argdisplaydryrun![i]
            }
        }
        return arguments
    }

    init(task: Enumrestorefiles, config: Configuration?, remotefile: String?, localCatalog: String?) {
        if let config = config {
            self.remotefile = remotefile
            self.localCatalog = localCatalog
            if let index = self.configurations?.getIndex(hiddenID: config.hiddenID) {
                switch task {
                case .restorerclone:
                    self.arguments = self.configurations?.arguments4rclone(index: index, argtype: .argrestore)
                    self.argdryrun = self.configurations?.arguments4rclone(index: index, argtype: .argrestoredryrun)
                    self.argdisplaydryrun = self.configurations?.arguments4rclone(index: index, argtype: .argrestoredisplaydryrun)
                case .listrclone:
                    self.arguments = self.configurations?.arguments4rclone(index: index, argtype: .arglistfiles)
                }
            }
        }
    }
}
