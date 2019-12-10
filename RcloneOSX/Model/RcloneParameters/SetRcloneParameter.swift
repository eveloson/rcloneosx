//
//  SetRcloneParameter.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct SetRcloneParameter {
    // Tuple for rclone argument and value
    typealias Argument = (String, Int)
    var rcloneArguments: [Argument]?

    func setrcloneparameter(indexComboBox: Int, value: String?) -> String {
        guard indexComboBox < self.rcloneArguments!.count, indexComboBox > -1 else { return "" }
        switch self.rcloneArguments![indexComboBox].1 {
        case 0:
            if self.rcloneArguments![indexComboBox].0 == self.rcloneArguments![1].0 {
                return ""
            } else {
                return self.rcloneArguments![indexComboBox].0
            }
        case 1:
            guard value != nil else { return "" }
            if self.rcloneArguments![indexComboBox].0 != self.rcloneArguments![0].0 {
                return self.rcloneArguments![indexComboBox].0 + "=" + value!
            } else {
                return value!
            }
        default:
            return ""
        }
    }

    init() {
        self.rcloneArguments = SuffixstringsRcloneParameters().rcloneArguments
    }
}
