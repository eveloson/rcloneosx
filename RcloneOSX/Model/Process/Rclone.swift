//
//  Rclone.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 10.03.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017

import Foundation

final class Rclone: ProcessCmd {

    func setdelegate(object: UpdateProgress) {
        self.updateDelegate = object
    }

    init (arguments: [String]?) {
        super.init(command: nil, arguments: arguments)
    }
}
