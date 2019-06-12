//
//  Rclonepath.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 12/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct Setrclonepath {

    weak var setinfoaboutrcloneDelegate: Setinfoaboutrclone?

    init() {
        self.setinfoaboutrcloneDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        let fileManager = FileManager.default
        let path: String?
        // If not in /usr/bin or /usr/local/bin, rclonePath is set if none of the above
        if let rclonePath = ViewControllerReference.shared.rclonePath {
            path = rclonePath + ViewControllerReference.shared.rclone
        } else if ViewControllerReference.shared.rcloneopt {
            path = "/usr/local/bin/" + ViewControllerReference.shared.rclone
        } else {
            path = "/usr/bin/" + ViewControllerReference.shared.rclone
        }
        if fileManager.fileExists(atPath: path!) == false {
            ViewControllerReference.shared.norclone = true
        } else {
            ViewControllerReference.shared.norclone = false
        }
        self.setinfoaboutrcloneDelegate?.setinfoaboutrclone()
    }

    init(path: String) {
        var path = path
        if path.isEmpty == false {
            if path.hasSuffix("/") == false {
                path += "/"
                ViewControllerReference.shared.rclonePath = path
            } else {
                ViewControllerReference.shared.rclonePath = path
            }
        } else {
            ViewControllerReference.shared.rclonePath = nil
        }
    }
}
