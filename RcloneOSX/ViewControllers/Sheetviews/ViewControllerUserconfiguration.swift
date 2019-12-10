//
//  ViewControllerUserconfiguration.swift
//  rcloneOSXver30
//
//  Created by Thomas Evensen on 30/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerUserconfiguration: NSViewController, NewRclone, SetDismisser, Delay, ChangeTemporaryRestorePath {
    var dirty: Bool = false
    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
    var oldmarknumberofdayssince: Double?
    var reload: Bool = false

    @IBOutlet var version143rclone: NSButton!
    @IBOutlet var rclonePath: NSTextField!
    @IBOutlet var detailedlogging: NSButton!
    @IBOutlet var noRclone: NSTextField!
    @IBOutlet var restorePath: NSTextField!
    @IBOutlet var minimumlogging: NSButton!
    @IBOutlet var fulllogging: NSButton!
    @IBOutlet var nologging: NSButton!
    @IBOutlet var marknumberofdayssince: NSTextField!
    @IBOutlet var savebutton: NSButton!

    @IBAction func toggleDetailedlogging(_: NSButton) {
        if self.detailedlogging.state == .on {
            ViewControllerReference.shared.detailedlogging = true
        } else {
            ViewControllerReference.shared.detailedlogging = false
        }
        self.setdirty()
    }

    @IBAction func close(_: NSButton) {
        if self.dirty {
            // Before closing save changed configuration
            _ = Setrclonepath(path: self.rclonePath.stringValue)
            self.setRclonePath()
            self.setRestorePath()
            self.setmarknumberofdayssince()
            _ = PersistentStorageUserconfiguration().saveuserconfiguration()
            if self.reload {
                self.reloadconfigurationsDelegate?.createandreloadconfigurations()
            }
            self.changetemporaryrestorepath()
        }
        if (self.presentingViewController as? ViewControllerMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (self.presentingViewController as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        } else if (self.presentingViewController as? ViewControllerRestore) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        }
        _ = RcloneVersionString()
    }

    @IBAction func logging(_: NSButton) {
        if self.fulllogging.state == .on {
            ViewControllerReference.shared.fulllogging = true
            ViewControllerReference.shared.minimumlogging = false
        } else if self.minimumlogging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = true
        } else if self.nologging.state == .on {
            ViewControllerReference.shared.fulllogging = false
            ViewControllerReference.shared.minimumlogging = false
        }
        self.setdirty()
    }

    @IBAction func setversion143rclone(_: NSButton) {
        if self.version143rclone.state == .on {
            ViewControllerReference.shared.rclone143 = true
        } else {
            ViewControllerReference.shared.rclone143 = nil
        }
        self.setdirty()
    }

    private func setdirty() {
        self.dirty = true
        self.savebutton.title = "Save"
    }

    private func setmarknumberofdayssince() {
        if let marknumberofdayssince = Double(self.marknumberofdayssince.stringValue) {
            self.oldmarknumberofdayssince = ViewControllerReference.shared.marknumberofdayssince
            ViewControllerReference.shared.marknumberofdayssince = marknumberofdayssince
            if self.oldmarknumberofdayssince != marknumberofdayssince {
                self.reload = true
            }
        }
    }

    private func setRclonePath() {
        if self.rclonePath.stringValue.isEmpty == false {
            if rclonePath.stringValue.hasSuffix("/") == false {
                rclonePath.stringValue += "/"
                ViewControllerReference.shared.rclonePath = rclonePath.stringValue
            }
        } else {
            ViewControllerReference.shared.rclonePath = nil
        }
        self.dirty = true
    }

    private func verifyrclone() {
        let rclonepath: String?
        let fileManager = FileManager.default
        if self.rclonePath.stringValue.isEmpty == false {
            if self.rclonePath.stringValue.hasSuffix("/") == false {
                rclonepath = self.rclonePath.stringValue + "/" + ViewControllerReference.shared.rclone
            } else {
                rclonepath = self.rclonePath.stringValue + ViewControllerReference.shared.rclone
            }
        } else {
            rclonepath = nil
        }
        guard rclonepath != nil else {
            self.noRclone.isHidden = true
            _ = Setrclonepath()
            return
        }
        if fileManager.fileExists(atPath: rclonepath!) {
            self.noRclone.isHidden = true
            ViewControllerReference.shared.norclone = false
        } else {
            self.noRclone.isHidden = false
            ViewControllerReference.shared.norclone = true
        }
    }

    private func setRestorePath() {
        if self.restorePath.stringValue.isEmpty == false {
            if restorePath.stringValue.hasSuffix("/") == false {
                restorePath.stringValue += "/"
                ViewControllerReference.shared.restorePath = restorePath.stringValue
            } else {
                ViewControllerReference.shared.restorePath = restorePath.stringValue
            }
        } else {
            ViewControllerReference.shared.restorePath = nil
        }
        self.dirty = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rclonePath.delegate = self
        self.restorePath.delegate = self
        self.marknumberofdayssince.delegate = self
        self.nologging.state = .on
        self.reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.dirty = false
        self.checkUserConfig()
        self.verifyrclone()
        self.marknumberofdayssince.stringValue = String(ViewControllerReference.shared.marknumberofdayssince)
    }

    // Function for check and set user configuration
    private func checkUserConfig() {
        if ViewControllerReference.shared.detailedlogging {
            self.detailedlogging.state = .on
        } else {
            self.detailedlogging.state = .off
        }
        if ViewControllerReference.shared.rclonePath != nil {
            self.rclonePath.stringValue = ViewControllerReference.shared.rclonePath!
        } else {
            self.rclonePath.stringValue = ""
        }
        if ViewControllerReference.shared.restorePath != nil {
            self.restorePath.stringValue = ViewControllerReference.shared.restorePath!
        } else {
            self.restorePath.stringValue = ""
        }
        if ViewControllerReference.shared.minimumlogging {
            self.minimumlogging.state = .on
        }
        if ViewControllerReference.shared.fulllogging {
            self.fulllogging.state = .on
        }
        if ViewControllerReference.shared.rclone143 ?? false {
            self.version143rclone.state = .on
        } else {
            self.version143rclone.state = .off
        }
    }
}

extension ViewControllerUserconfiguration: NSTextFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        delayWithSeconds(0.5) {
            self.setdirty()
            switch (notification.object as? NSTextField)! {
            case self.rclonePath:
                self.verifyrclone()
                self.newrclone()
            case self.restorePath:
                return
            default:
                return
            }
        }
    }
}
