//
//  Norclone.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 12/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Norclone {
    init() {
        if let rclone = ViewControllerReference.shared.rclonePath {
            Alerts.showInfo("ERROR: no rclone in " + rclone)
        } else {
            Alerts.showInfo("ERROR: no rclone in /usr/local/bin")
        }
    }
}
