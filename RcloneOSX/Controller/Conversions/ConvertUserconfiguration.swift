//
//  ConvertUserconfiguration.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 26/04/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable function_body_length trailing_comma

import Foundation

struct ConvertUserconfiguration {
    var userconfiguration: [NSMutableDictionary]?

    init() {
        var optionalpathrclone: Int?
        var detailedlogging: Int?
        var minimumlogging: Int?
        var fulllogging: Int?
        var rclonePath: String?
        var restorePath: String?
        var marknumberofdayssince: String?
        var rclone143: Int?

        if ViewControllerReference.shared.rcloneopt {
            optionalpathrclone = 1
        } else {
            optionalpathrclone = 0
        }
        if ViewControllerReference.shared.detailedlogging {
            detailedlogging = 1
        } else {
            detailedlogging = 0
        }
        if ViewControllerReference.shared.minimumlogging {
            minimumlogging = 1
        } else {
            minimumlogging = 0
        }
        if ViewControllerReference.shared.fulllogging {
            fulllogging = 1
        } else {
            fulllogging = 0
        }
        if ViewControllerReference.shared.rclonePath != nil {
            rclonePath = ViewControllerReference.shared.rclonePath!
        }
        if ViewControllerReference.shared.restorefilespath != nil {
            restorePath = ViewControllerReference.shared.restorefilespath!
        }
        if ViewControllerReference.shared.rclone143 != nil {
            rclone143 = 1
        } else {
            rclone143 = 0
        }
        var array = [NSMutableDictionary]()
        marknumberofdayssince = String(ViewControllerReference.shared.marknumberofdayssince)
        let dict: NSMutableDictionary = [
            "optionalpathrclone": optionalpathrclone! as Int,
            "detailedlogging": detailedlogging! as Int,
            "minimumlogging": minimumlogging! as Int,
            "fulllogging": fulllogging! as Int,
            "marknumberofdayssince": marknumberofdayssince ?? "5.0",
            "rclone143": rclone143! as Int,
        ]

        if rclonePath != nil {
            dict.setObject(rclonePath!, forKey: "rclonePath" as NSCopying)
        }
        if restorePath != nil {
            dict.setObject(restorePath!, forKey: "restorePath" as NSCopying)
        } else {
            dict.setObject("", forKey: "restorePath" as NSCopying)
        }
        array.append(dict)
        self.userconfiguration = array
    }
}
