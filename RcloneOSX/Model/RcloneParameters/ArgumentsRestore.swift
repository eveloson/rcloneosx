//
//  ArgumentsRestore.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

final class ArgumentsRestore: RcloneParameters {
    var config: Configuration?

    func argumentsrestore(dryRun: Bool, forDisplay: Bool, tmprestore: Bool) -> [String]? {
        if let config = self.config {
            self.rclonecommandrestore(dryRun: dryRun, forDisplay: forDisplay)
            self.remoteparameter(config: config, dryRun: dryRun, forDisplay: forDisplay)
            if tmprestore {
                self.localCatalog = ViewControllerReference.shared.restorefilespath ?? ViewControllerReference.shared.tmprestore
            }
            self.offsiteparameter(config: config, forDisplay: forDisplay)
            self.appendparameter(parameter: self.localCatalog, forDisplay: forDisplay)
            if dryRun {
                self.dryrunparameter(config: config, forDisplay: forDisplay)
            }
            self.setParameters2To14(config: config, dryRun: dryRun, forDisplay: forDisplay)
            return self.arguments
        }
        return nil
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
