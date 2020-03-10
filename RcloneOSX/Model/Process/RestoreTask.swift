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

    func getcommandfullrestore() -> String? {
        var arguments: String?
        arguments = Getrclonepath().rclonepath ?? "" + " "
        for i in 0 ..< (self.arguments?.count ?? 0) {
            arguments = arguments! + " " + self.arguments![i]
        }
        return arguments
    }

    init(index: Int, outputprocess: OutputProcess?, updateprogress: UpdateProgress?) {
        weak var setprocessDelegate: SendProcessreference?
        setprocessDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
        let config = self.configurations?.getConfigurations()[index]
        if (config?.offsiteCatalog ?? "").isEmpty {
            self.arguments?.insert(ViewControllerReference.shared.restorefilespath ?? "", at: 2)
        }
        let process = Rclone(arguments: self.arguments)
        process.setdelegate(object: updateprogress)
        process.executeProcess(outputprocess: outputprocess)
        setprocessDelegate?.sendprocessreference(process: process.getProcess())
    }

    init(index: Int) {
        self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
        let config = self.configurations?.getConfigurations()[index]
        if (config?.offsiteCatalog ?? "").isEmpty {
            self.arguments?.insert(ViewControllerReference.shared.restorefilespath ?? "", at: 2)
        }
    }
}
