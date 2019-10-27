//
//  ArgumentsOther.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

final class ArgumentsOther: RcloneParameters {

    var config: Configuration?
    
    func argumentsrclonelistfile() -> [String] {
        self.localCatalog = nil
        self.offsiteCatalog = self.config!.offsiteCatalog
        self.offsiteServer = self.config!.offsiteServer
        self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
        self.appendParameter(parameter: "ls", forDisplay: false)
        self.appendParameter(parameter: self.remoteargs!, forDisplay: false)
        return self.arguments!
    }

    func argumentsrclonerestore(dryRun: Bool, forDisplay: Bool) -> [String] {
        self.localCatalog = nil
        self.offsiteCatalog = self.config!.offsiteCatalog
        self.offsiteServer = self.config!.offsiteServer
        self.remoteargs = self.offsiteServer! + ":" + self.offsiteCatalog!
        self.appendParameter(parameter: ViewControllerReference.shared.copy, forDisplay: forDisplay)
        self.appendParameter(parameter: self.remoteargs!, forDisplay: forDisplay)
        self.appendParameter(parameter: "--verbose", forDisplay: forDisplay)
        if dryRun {
            self.dryrunparameter(config: self.config!, forDisplay: forDisplay)
        }
        return self.arguments!
    }
    
    init(config: Configuration?) {
        super.init()
        self.config = config
    }
}
