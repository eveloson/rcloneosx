//
//  RestoreTask.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 09.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class FullrestoreTask: SetConfigurations {
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
        self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
        guard (self.arguments?.count ?? 0) > 3 else { return }
        if (self.arguments?[2] ?? "") == ViewControllerReference.shared.tmprestore {
            self.arguments?[2] = ViewControllerReference.shared.restorefilespath ?? ""
        }
        let process = Rclone(arguments: self.arguments)
        process.setdelegate(object: updateprogress)
        process.executeProcess(outputprocess: outputprocess)
    }

    init(index: Int) {
        self.arguments = self.configurations?.arguments4tmprestore(index: index, argtype: .arg)
        guard (self.arguments?.count ?? 0) > 3 else { return }
        if (self.arguments?[2] ?? "") == ViewControllerReference.shared.tmprestore {
            self.arguments?[2] = ViewControllerReference.shared.restorefilespath ?? ""
        }
    }
}
