//
//  Getrclonepath.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 12/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct Getrclonepath {
    var rclonepath: String?

    init() {
        if ViewControllerReference.shared.rcloneopt {
            if ViewControllerReference.shared.rclonePath == nil {
                self.rclonepath = ViewControllerReference.shared.usrlocalbinrclone
            } else {
                self.rclonepath = ViewControllerReference.shared.rclonePath! + ViewControllerReference.shared.rclone
            }
        } else {
            self.rclonepath = ViewControllerReference.shared.usrbinrclone
        }
    }
}
