//
//  EstimateRemoteInformationTask.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 30.04.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class EstimateremoteInformationOnetask: SetConfigurations {
    init(index: Int, outputprocess: OutputProcess?, updateprogress: UpdateProgress) {
        let outDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        let arguments = self.configurations!.arguments4rclone(index: index, argtype: .argdryrun)
        let process = Rclone(arguments: arguments)
        process.setdelegate(object: updateprogress)
        process.executeProcess(outputprocess: outputprocess)
        outDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
    }
}
