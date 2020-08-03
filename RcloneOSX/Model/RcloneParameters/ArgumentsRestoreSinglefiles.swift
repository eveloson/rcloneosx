//
//  ArgumentsRestoreSinglefiles.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 30/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsRestoreSinglefiles: RcloneParameters {
    var config: Configuration?

    func argumentsrclonerestoresinglefiles(dryRun: Bool, forDisplay: Bool) -> [String]? {
        if let config = self.config {
            self.localCatalog = nil
            self.offsiteCatalog = config.offsiteCatalog
            self.offsiteServer = config.offsiteServer
            self.remoteargs = (self.offsiteServer ?? "") + ":" + (self.offsiteCatalog ?? "")
            self.appendparameter(parameter: ViewControllerReference.shared.copy, forDisplay: forDisplay)
            self.appendparameter(parameter: self.remoteargs ?? "", forDisplay: forDisplay)
            self.appendparameter(parameter: "--verbose", forDisplay: forDisplay)
            if dryRun {
                self.dryrunparameter(config: config, forDisplay: forDisplay)
            }
            return self.arguments
        }
        return nil
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
