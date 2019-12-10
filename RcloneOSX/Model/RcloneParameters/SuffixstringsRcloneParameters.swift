//
//  SuffixstringsRcloneParameters.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 27/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import Foundation

struct SuffixstringsRcloneParameters {
    let suffixstringdate = "--suffix=date"
    // Tuple for rclone argument and value
    typealias Argument = (String, Int)
    // Static initial arguments, DO NOT change order
    let rcloneArguments: [Argument] = [
        ("user", 1),
        ("delete", 0),
        ("--backup-dir", 1),
        ("--bwlimit", 1),
        ("--transfers", 1),
        ("--exclude", 1),
        ("--exclude-from", 1),
        ("--no-traverse", 0),
        ("--no-gzip-encoding", 0),
        ("--suffix", 1),
    ]
}
