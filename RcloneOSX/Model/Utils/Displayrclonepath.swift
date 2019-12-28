//
//  Verifyrclonepath.swift
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017

import Foundation

enum RclonecommandDisplay {
    case sync
    case restore
}

protocol Setinfoaboutrclone: AnyObject {
    func setinfoaboutrclone()
}

final class Displayrclonepath: SetConfigurations {
    var rclonepath: String?

    init(index: Int, display: RclonecommandDisplay) {
        var str: String?
        let config = self.configurations!.getargumentAllConfigurations()[index]
        str = Getrclonepath().rclonepath ?? ""
        str = str! + " "
        switch display {
        case .sync:
            if let count = config.argdryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.argdryRunDisplay![i]
                }
            }
        case .restore:
            if let count = config.restoredryRunDisplay?.count {
                for i in 0 ..< count {
                    str = str! + config.restoredryRunDisplay![i]
                }
            }
        }
        self.rclonepath = str
    }
}
