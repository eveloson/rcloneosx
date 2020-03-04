//
//  RestoreTask.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 09.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class RestoreTask: SetConfigurations {
    var arguments: [String]?
    init(index: Int, outputprocess: OutputProcess?, dryrun: Bool, updateprogress: UpdateProgress?) {
        weak var setprocessDelegate: SendProcessreference?
        setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        if dryrun {
            self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .argdryrun)
            // We have to check if remote (offsite) catalog is empty or not
            // let config = self.configurations?.getConfigurations()[index]
            /*
             if (config?.offsiteCatalog ?? "").isEmpty {
                 self.arguments?.insert(ViewControllerReference.shared.restorefilespath ?? "", at: 2)
             }
             */
        } else {
            self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
            // let config = self.configurations!.getConfigurations()[index]
            /*
             if config.offsiteCatalog.isEmpty {
                 self.arguments?.insert(ViewControllerReference.shared.restorefilespath ?? "", at: 2)
             }
             */
        }
        guard arguments != nil else { return }
        let process = Rclone(arguments: self.arguments)
        process.setdelegate(object: updateprogress!)
        process.executeProcess(outputprocess: outputprocess)
        setprocessDelegate?.sendprocessreference(process: process.getProcess()!)
    }
}
