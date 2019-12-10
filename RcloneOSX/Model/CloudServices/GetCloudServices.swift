//
//  GetCloudServices.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 09.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

protocol Reloadcloudservices: class {
    func reloadcloudservices()
}

final class GetCloudServices: ProcessCmd {
    private var outputprocess: OutputProcess?
    var cloudservices: [String]?
    weak var reloadcloudservicesDelegate: Reloadcloudservices?

    init(reloadclass: Reloadcloudservices) {
        super.init(command: nil, arguments: ["config", "show"])
        self.reloadcloudservicesDelegate = reloadclass
        self.outputprocess = OutputProcess()
        if ViewControllerReference.shared.norclone == false {
            guard ViewControllerReference.shared.norclone == false else { return }
            self.updateDelegate = self
            self.executeProcess(outputprocess: outputprocess)
        }
    }
}

extension GetCloudServices: UpdateProgress {
    func processTermination() {
        guard self.outputprocess?.getOutput() != nil else { return }
        guard self.outputprocess!.getOutput()!.count > 0 else { return }
        self.cloudservices = self.outputprocess!.trimoutput(trim: .three)!
        self.reloadcloudservicesDelegate?.reloadcloudservices()
    }

    func fileHandler() {
        //
    }
}
