//
//  extensionVCMainSingletask.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 26/08/2019.
//  Copyright © 2019 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

extension ViewControllerMain: SingleTaskProcess {

    func getProcessReference(process: Process) {
        self.process = process
    }

    func presentViewProgress() {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerProgress!)
        })
    }

    func presentViewInformation(outputprocess: OutputProcess) {
        self.outputprocess = outputprocess
        if self.dynamicappend {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        } else {
            globalMainQueue.async(execute: { () -> Void in
                self.presentAsSheet(self.viewControllerInformation!)
            })
        }
    }

    func terminateProgressProcess() {
        weak var localprocessupdateDelegate: UpdateProgress?
        localprocessupdateDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcprogressview) as? ViewControllerProgressProcess
        localprocessupdateDelegate?.processTermination()
    }

    func seterrorinfo(info: String) {
        guard info != "" else {
            self.dryRunOrRealRun.isHidden = true
            return
        }
        self.dryRunOrRealRun.textColor = setcolor(nsviewcontroller: self, color: .red)
        self.dryRunOrRealRun.isHidden = false
        self.dryRunOrRealRun.stringValue = info
    }

    // Function for getting numbers out of output object updated when
    // Process object executes the job.
    func setNumbers(outputprocess: OutputProcess?) {
        globalMainQueue.async(execute: { () -> Void in
            guard outputprocess != nil else {
                self.totalNumber.stringValue = ""
                return
            }
            let number = Numbers(outputprocess: outputprocess)
            self.totalNumber.stringValue = number.stats()
        })
    }
}
