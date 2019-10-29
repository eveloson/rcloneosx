//
//  rcloneosxTests.swift
//  rcloneosxTests
//
//  Created by Thomas Evensen on 29/10/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//

import XCTest

@testable import rcloneosx

class RcloneosxTests: XCTestCase, SetConfigurations {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        _ = Selectprofile(profile: "XCTest")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testnumberofargumentstorsync() {
        let count = self.configurations?.arguments4rclone(index: 0, argtype: .argdryRun).count
        XCTAssertEqual(count, 6, "Should be equal to 6")
    }

    func testnumberofconfigurations() {
        let count = self.configurations?.getConfigurations().count
        XCTAssertEqual(count, 4, "Should be equal to 4")
    }

    func testargumentsdryrun0() {
        let arguments = ["sync", "/Users/thomas/Documents", "localencrypt:",
                         "--dry-run", "--verbose",
                         "--exclude-from=/Users/thomas/excludersync/exclude_rclone.txt"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rclone(index: 0, argtype: .argdryRun),
                       "Arguments should be equal")
    }

    func testargumentsrealrun0() {
        let arguments = ["sync", "/Users/thomas/Documents", "localencrypt:",
                         "--verbose", "--exclude-from=/Users/thomas/excludersync/exclude_rclone.txt"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rclone(index: 0, argtype: .arg),
                       "Arguments should be equal")
    }

    func testargumentsrealrun1() {
        let arguments = ["sync", "/Users/thomas/GitHub", "dropbox:GitHub", "--verbose",
                         "--exclude-from=/Users/thomas/excludersync/exclude_rclone.txt",
                         "--backup-dir=dropbox:GitHuB_backup"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rclone(index: 1, argtype: .arg),
                       "Arguments should be equal")
    }

    func testargumentsdryrun3() {
        let arguments = ["sync", "/Users/thomas/Source", "local:/Users/thomas/Destination",
                         "--dry-run", "--verbose"]
        XCTAssertEqual(arguments, self.configurations?.arguments4rclone(index: 3, argtype: .argdryRun),
                       "Arguments should be equal")
    }
}
