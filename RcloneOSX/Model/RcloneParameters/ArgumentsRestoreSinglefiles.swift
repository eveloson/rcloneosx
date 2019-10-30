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

    func argumentsrclonerestore(dryRun: Bool, forDisplay: Bool) -> [String] {
        self.localCatalog = nil
        self.offsiteCatalog = self.config!.offsiteCatalog
        self.offsiteServer = self.config!.offsiteServer
        self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
        self.appendparameter(parameter: ViewControllerReference.shared.copy, forDisplay: forDisplay)
        self.appendparameter(parameter: self.remoteargs!, forDisplay: forDisplay)
        self.appendparameter(parameter: "--verbose", forDisplay: forDisplay)
        if dryRun {
            self.dryrunparameter(config: self.config!, forDisplay: forDisplay)
        }
        return self.arguments ?? [""]
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
