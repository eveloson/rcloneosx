//
//  CopySingleFiles.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

final class Restorefiles: SetConfigurations {
    var config: Configuration?
    var commandDisplay: String?
    var process: ProcessCmd?
    var outputprocess: OutputProcess?
    weak var sendprocess: SendOutputProcessreference?

    func getOutput() -> [String] {
        return self.outputprocess?.getOutput() ?? []
    }

    func executecopyfiles(remotefile: String, localCatalog: String, dryrun: Bool, updateprogress: UpdateProgress) {
        var arguments: [String]?
        guard self.config != nil else { return }
        if dryrun {
            arguments = RestorefilesArguments(task: .restorerclone, config: self.config, remotefile: remotefile, localCatalog: localCatalog).getArgumentsdryRun()
        } else {
            arguments = RestorefilesArguments(task: .restorerclone, config: self.config, remotefile: remotefile, localCatalog: localCatalog).getArguments()
        }
        self.outputprocess = OutputProcess()
        self.process = ProcessCmd(command: nil, arguments: arguments)
        self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
        self.process?.setupdateDelegate(object: updateprogress)
        self.process?.executeProcess(outputprocess: self.outputprocess)
    }

    func getcommandrestorefiles(remotefile: String, localCatalog: String) -> String {
        guard self.config != nil else { return "" }
        self.commandDisplay = RestorefilesArguments(task: .restorerclone, config: self.config, remotefile: remotefile, localCatalog: localCatalog).getcommandDisplay()
        return self.commandDisplay ?? " "
    }

    init(hiddenID: Int) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if let index = self.configurations?.getIndex(hiddenID: hiddenID) {
            self.config = self.configurations?.getConfigurations()[index]
        }
    }
}
