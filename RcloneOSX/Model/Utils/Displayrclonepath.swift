//
//  Verifyrclonepath.swift
//
//  Created by Thomas Evensen on 22.07.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

enum RclonecommandDisplay {
    case sync
    case restore
}

protocol Setinfoaboutrclone: class {
    func setinfoaboutrclone()
}

final class Displayrclonepath: SetConfigurations {

    weak var verifyrcloneDelegate: Setinfoaboutrclone?
    var rclonepath: String?

    init(index: Int, display: RclonecommandDisplay) {
        self.verifyrcloneDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
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
