//
//  Selectprofile.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 21/06/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

final class Selectprofile {

    var profile: String?
    weak var newProfileDelegate: NewProfile?
    weak var copyfilesnewProfileDelegate: NewProfile?
    weak var reloadloggdataDelegate: ReadLoggdata?

    init(profile: String?) {
        self.profile = profile
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.copyfilesnewProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        self.reloadloggdataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        if self.profile == "Default profile" {
            newProfileDelegate?.newProfile(profile: nil)
        } else {
            newProfileDelegate?.newProfile(profile: self.profile)
        }
        self.copyfilesnewProfileDelegate?.newProfile(profile: nil)
        self.reloadloggdataDelegate?.readloggdata()
    }

}
