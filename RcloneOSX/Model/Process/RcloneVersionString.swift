//
//  RcloneVersionString.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class RcloneVersionString: ProcessCmd {

    var outputprocess: OutputProcess?

    init () {
        super.init(command: nil, arguments: ["--version"])
        self.outputprocess = OutputProcess()
        if ViewControllerReference.shared.norclone == false {
            self.updateDelegate = self
            self.executeProcess(outputprocess: outputprocess)
        }
    }
}

extension RcloneVersionString: UpdateProgress {
    func processTermination() {
        guard self.outputprocess?.getOutput() != nil else { return }
        guard self.outputprocess!.getOutput()!.count > 0 else { return }
        ViewControllerReference.shared.rcloneversionshort = self.outputprocess!.getOutput()![0]
        ViewControllerReference.shared.rcloneversionstring = self.outputprocess!.getOutput()!.joined(separator: "\n")
        weak var shortstringDelegate: RcloneIsChanged?
        shortstringDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        shortstringDelegate?.rcloneischanged()
    }

    func fileHandler() {
        // none
    }
}
