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
    weak var restoreProfileDelegate: NewProfile?
    weak var loggdataProfileDelegate: NewProfile?

    init(profile: String?, selectedindex: Int?) {
        self.profile = profile
        self.newProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
        self.restoreProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        self.loggdataProfileDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata) as? ViewControllerLoggData
        if self.profile == "Default profile" {
            newProfileDelegate?.newProfile(profile: nil, selectedindex: selectedindex)
        } else {
            newProfileDelegate?.newProfile(profile: self.profile, selectedindex: selectedindex)
        }
        self.restoreProfileDelegate?.newProfile(profile: nil, selectedindex: selectedindex)
        self.loggdataProfileDelegate?.newProfile(profile: nil, selectedindex: selectedindex)
        // Close edit and parameters view if open
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcrcloneparameters) as? ViewControllerRcloneParameters {
            weak var closeview: ViewControllerRcloneParameters?
            closeview = view
            closeview?.closeview()
        }
        if let view = ViewControllerReference.shared.getvcref(viewcontroller: .vcedit) as? ViewControllerEdit {
            weak var closeview: ViewControllerEdit?
            closeview = view
            closeview?.closeview()
        }
    }
}
