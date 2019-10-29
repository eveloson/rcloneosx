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

    func argumentssynchronize(dryRun: Bool, forDisplay: Bool) -> [String] {
        self.rclonecommand(config: self.config!, dryRun: dryRun, forDisplay: forDisplay)
        self.remoteparameter(config: self.config!, dryRun: dryRun, forDisplay: forDisplay)
        if self.localCatalog?.isEmpty == false {
                   self.arguments!.append(self.localCatalog!)
               }
        self.offisteparameter(config: self.config!, forDisplay: forDisplay)
        if dryRun {
            self.dryrunparameter(config: self.config!, forDisplay: forDisplay)
        }
        self.setParameters2To14(config: self.config!, dryRun: dryRun, forDisplay: forDisplay)
        return self.arguments!
    }

    init(config: Configuration?) {
        super.init()
        self.config = config
    }

}
