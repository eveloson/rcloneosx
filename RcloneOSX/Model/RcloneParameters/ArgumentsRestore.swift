//
//  ArgumentsRestore.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsRestore: RcloneParameters {

    var config: Configuration?

    func argumentsrestore(config: Configuration, dryRun: Bool, forDisplay: Bool, tmprestore: Bool) -> [String] {
        if tmprestore == false {
            self.localCatalog = config.localCatalog
        } else {
            self.localCatalog = ViewControllerReference.shared.restorePath ?? ""
        }
        self.offsiteCatalog = config.offsiteCatalog
        self.offsiteServer = config.offsiteServer
        if self.offsiteServer!.isEmpty == false {
            if config.localCatalog.isEmpty == true {
                self.remoteargs = self.offsiteServer! + ":"
            } else {
                self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
            }
        }
        self.rclonecommand(config: config, dryRun: dryRun, forDisplay: forDisplay)
        if self.offsiteServer!.isEmpty {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(self.offsiteCatalog!)
            if forDisplay {self.arguments!.append(" ")}
        } else {
            if forDisplay {self.arguments!.append(" ")}
            self.arguments!.append(remoteargs!)
            if config.localCatalog.isEmpty == true {
                if forDisplay {self.arguments!.append(" ")}
                self.arguments!.append(self.offsiteCatalog ?? "")
            }
            if forDisplay {self.arguments!.append(" ")}
        }
        if self.localCatalog?.isEmpty == false {
            self.arguments!.append(self.localCatalog!)
        }
        if dryRun {
            self.dryrunparameter(config, forDisplay: forDisplay)
        }
        self.setParameters2To14(config, dryRun: dryRun, forDisplay: forDisplay)
        return self.arguments!
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
