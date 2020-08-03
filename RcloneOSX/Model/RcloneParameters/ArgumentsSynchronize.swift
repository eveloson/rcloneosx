//
//  ArgumentsRclone.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsSynchronize: RcloneParameters {
    var config: Configuration?

    func argumentssynchronize(dryRun: Bool, forDisplay: Bool) -> [String]? {
        if let config = self.config {
            self.rclonecommand(config: config, dryRun: dryRun, forDisplay: forDisplay)
            self.remoteparameter(config: config, dryRun: dryRun, forDisplay: forDisplay)
            self.appendparameter(parameter: self.localCatalog, forDisplay: forDisplay)
            self.offsiteparameter(config: config, forDisplay: forDisplay)
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
