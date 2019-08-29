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

final class CopyFiles: SetConfigurations {

    private var index: Int?
    private var config: Configuration?
    private var commandDisplay: String?
    var process: ProcessCmd?
    var outputprocess: OutputProcess?
    weak var sendprocess: SendProcessreference?

    func getOutput() -> [String] {
        return self.outputprocess?.getOutput() ?? []
    }

    func abort() {
        guard self.process != nil else { return }
        self.process!.abortProcess()
    }

    func executecopyfiles(remotefile: String, localCatalog: String, dryrun: Bool, updateprogress: UpdateProgress) {
        var arguments: [String]?
        guard self.config != nil else { return }
        if dryrun {
            arguments = CopyFilesArguments(task: .restorerclone, config: self.config!, remotefile: remotefile, localCatalog: localCatalog).getArgumentsdryRun()
        } else {
            arguments = CopyFilesArguments(task: .restorerclone, config: self.config!, remotefile: remotefile, localCatalog: localCatalog).getArguments()
        }
        self.outputprocess = OutputProcess()
        self.process = ProcessCmd(command: nil, arguments: arguments)
        self.sendprocess?.sendoutputprocessreference(outputprocess: self.outputprocess)
        self.process?.setupdateDelegate(object: updateprogress)
        self.process!.executeProcess(outputprocess: self.outputprocess)
    }

    func getCommandDisplayinView(remotefile: String, localCatalog: String) -> String {
        guard self.config != nil else { return "" }
        guard self.index != nil else { return "" }
        self.commandDisplay = CopyFilesArguments(task: .restorerclone, config: self.config!, remotefile: remotefile, localCatalog: localCatalog).getcommandDisplay()
        return self.commandDisplay ?? " "
    }

    init (hiddenID: Int) {
        self.sendprocess = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.index = self.configurations?.getIndex(hiddenID)
        self.config = self.configurations!.getConfigurations()[self.index!]
    }

  }
