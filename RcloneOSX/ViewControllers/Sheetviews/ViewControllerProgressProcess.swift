//
//  ViewControllerProgressProcess.swift
//  rcloneOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Cocoa

// Protocol for progress indicator
protocol Count: class {
    func maxCount() -> Int
    func inprogressCount() -> Int
}

class ViewControllerProgressProcess: NSViewController, SetConfigurations, SetDismisser, Abort {

    var count: Double = 0
    var maxcount: Double = 0
    var calculatedNumberOfFiles: Int?
    weak var countDelegate: Count?
    @IBOutlet weak var abort: NSButton!

    @IBAction func abort(_ sender: NSButton) {
        switch self.countDelegate {
        case is ViewControllerMain:
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        case is ViewControllerCopyFiles:
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        case is ViewControllerRestore:
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        default:
            return
        }
        self.abort()
    }

    @IBOutlet weak var progress: NSProgressIndicator!

    override func viewDidAppear() {
        super.viewDidAppear()
        ViewControllerReference.shared.setvcref(viewcontroller: .vcprogressview, nsviewcontroller: self)
        if let pvc = (self.presentingViewController as? ViewControllerMain)?.singletask {
            self.countDelegate = pvc
        } else if (self.presentingViewController as? ViewControllerCopyFiles) != nil {
            self.countDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vccopyfiles) as? ViewControllerCopyFiles
        } else if (self.presentingViewController as? ViewControllerRestore) != nil {
            self.countDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcrestore) as? ViewControllerRestore
        }
        self.initiateProgressbar()
        self.abort.isEnabled = true
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.stopProgressbar()
    }

    private func stopProgressbar() {
        self.progress.stopAnimation(self)
    }

    // Progress bars
    private func initiateProgressbar() {
        self.progress.maxValue = Double(self.countDelegate?.maxCount() ?? 0)
        self.progress.minValue = 0
        self.progress.doubleValue = 0
        self.progress.startAnimation(self)
    }

    private func updateProgressbar(_ value: Double) {
        self.progress.doubleValue = value
    }
}

extension ViewControllerProgressProcess: UpdateProgress {

    func processTermination() {
        self.stopProgressbar()
        switch self.countDelegate {
        case is ViewControllerMain:
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        case is ViewControllerCopyFiles:
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        default:
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        }
    }

    func fileHandler() {
        guard self.countDelegate != nil else { return }
        self.updateProgressbar(Double(self.countDelegate!.inprogressCount()))
    }

}
