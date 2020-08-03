//
//  ArgumentsOther.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsListFiles: RcloneParameters {
    var config: Configuration?

    func argumentsrclonelistfile() -> [String]? {
        if let config = self.config {
            self.localCatalog = nil
            self.offsiteCatalog = config.offsiteCatalog
            self.offsiteServer = config.offsiteServer
            self.remoteargs = (self.offsiteServer ?? "") + ":" + (self.offsiteCatalog ?? "")
            self.appendparameter(parameter: "ls", forDisplay: false)
            self.appendparameter(parameter: self.remoteargs ?? "", forDisplay: false)
            return self.arguments
        }
        return nil
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
