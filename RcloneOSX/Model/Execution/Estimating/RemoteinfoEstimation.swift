//
//  RemoteInfoTaskWorkQueue.swift
//  RcloneOSX
//
//  Created by Thomas Evensen on 31.12.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

protocol SetRemoteInfo: class {
    func setremoteinfo(remoteinfotask: RemoteinfoEstimation?)
    func getremoteinfo() -> RemoteinfoEstimation?
}

final class RemoteinfoEstimation: SetConfigurations, Remoterclonesize {
    // (hiddenID, index)
    // row 0, 2, 4 number of files
    // row 1, 3, 5 remote size
    typealias Row = (Int, Int)
    var stackoftasktobeestimated: [Row]?
    var outputprocess: OutputProcess?
    var records: [NSMutableDictionary]?
    weak var updateprogressDelegate: UpdateProgress?
    weak var reloadtableDelegate: Reloadandrefresh?
    weak var enablebackupbuttonDelegate: EnableQuicbackupButton?
    weak var startstopProgressIndicatorDelegate: StartStopProgressIndicator?
    var index: Int?
    var maxnumber: Int?
    var count: Int?
    var inbatch: Bool?
    var estimatefiles: Bool = true

    private func prepareandstartexecutetasks() {
        self.stackoftasktobeestimated = [Row]()
        for i in 0 ..< self.configurations!.getConfigurations().count {
            if self.configurations!.getConfigurations()[i].task == ViewControllerReference.shared.sync {
                if self.inbatch ?? false {
                    if self.configurations!.getConfigurations()[i].batch == 1 {
                        self.stackoftasktobeestimated?.append((self.configurations!.getConfigurations()[i].hiddenID, i))
                        self.stackoftasktobeestimated?.append((self.configurations!.getConfigurations()[i].hiddenID, i))
                    }
                } else {
                    self.stackoftasktobeestimated?.append((self.configurations!.getConfigurations()[i].hiddenID, i))
                    self.stackoftasktobeestimated?.append((self.configurations!.getConfigurations()[i].hiddenID, i))
                }
            }
        }
        self.maxnumber = self.stackoftasktobeestimated?.count
    }

    func selectalltaskswithnumbers(deselect: Bool) {
        guard self.records != nil else { return }
        for i in 0 ..< self.records!.count {
            let number = (self.records![i].value(forKey: "transferredNumber") as? String) ?? "0"
            let delete = (self.records![i].value(forKey: "deletefiles") as? String) ?? "0"
            if Int(number)! > 0 || Int(delete)! > 0 {
                if deselect {
                    self.records![i].setValue(0, forKey: "select")
                } else {
                    self.records![i].setValue(1, forKey: "select")
                }
            }
        }
    }

    func setbackuplist(list: [NSMutableDictionary]) {
        self.configurations?.quickbackuplist = [Int]()
        for i in 0 ..< list.count {
            self.configurations?.quickbackuplist!.append((list[i].value(forKey: "hiddenID") as? Int)!)
        }
    }

    func setbackuplist() {
        guard self.records != nil else { return }
        for i in 0 ..< self.records!.count {
            if self.records![i].value( forKey: "select") as? Int == 1 {
                if self.configurations?.quickbackuplist == nil {
                    self.configurations?.quickbackuplist = [Int]()
                }
                self.configurations?.quickbackuplist!.append((self.records![i].value(forKey: "hiddenID") as? Int)!)
            }
        }
    }

    private func startestimation() {
        guard self.stackoftasktobeestimated!.count > 0 else { return }
        self.outputprocess = OutputProcess()
        self.index = self.stackoftasktobeestimated?.remove(at: 0).1
        self.startstopProgressIndicatorDelegate?.start()
        _ = EstimateremoteInformationOnetask(index: self.index!, outputprocess: self.outputprocess, updateprogress: self)
    }

    init(viewcontroller: NSViewController?) {
        self.inbatch = false
        self.updateprogressDelegate = viewcontroller as? UpdateProgress
        self.startstopProgressIndicatorDelegate = viewcontroller as? StartStopProgressIndicator
        if viewcontroller == ViewControllerReference.shared.getvcref(viewcontroller: .vcbatch) as? ViewControllerBatch {
            self.inbatch = true
        }
        self.prepareandstartexecutetasks()
        self.records = [NSMutableDictionary]()
        self.configurations!.estimatedlist = [NSMutableDictionary]()
        self.startestimation()
    }
}

extension RemoteinfoEstimation: CountRemoteEstimatingNumberoftasks {
    func maxCount() -> Int {
        return self.maxnumber ?? 0
    }

    func inprogressCount() -> Int {
        return self.stackoftasktobeestimated?.count ?? 0
    }
}

extension RemoteinfoEstimation: UpdateProgress {

    func processTermination() {
        guard self.inbatch == false else {
            self.processTermination_inbatch()
            return
        }
        self.count = self.stackoftasktobeestimated?.count
        if self.estimatefiles {
            let record = RemoteinfonumbersOnetask(outputprocess: self.outputprocess).record()
            record.setValue(self.configurations?.getConfigurations()[self.index!].localCatalog, forKey: "localCatalog")
            record.setValue(self.configurations?.getConfigurations()[self.index!].offsiteCatalog, forKey: "offsiteCatalog")
            record.setValue(self.configurations?.getConfigurations()[self.index!].hiddenID, forKey: "hiddenID")
            record.setValue(self.configurations?.getConfigurations()[self.index!].offsiteServer, forKey: "offsiteServer")
            self.records?.append(record)
            self.configurations?.estimatedlist?.append(record)
        } else {
            guard self.outputprocess?.getOutput()?.count ?? 0 > 0 else { return }
            let size = self.remoterclonesize(input: self.outputprocess!.getOutput()![0])
            NumberFormatter.localizedString(from: NSNumber(value: size?.count ?? 0), number: NumberFormatter.Style.decimal)
            let totalNumber = String(NumberFormatter.localizedString(from: NSNumber(value: size?.count ?? 0), number: NumberFormatter.Style.decimal))
            let totalNumberSizebytes = String(NumberFormatter.localizedString(from: NSNumber(value: size?.bytes ?? 0/1024), number: NumberFormatter.Style.decimal))
            let index = self.records!.count - 1
            self.records![index].setValue(totalNumber, forKey: "totalNumber")
            self.records![index].setValue(totalNumberSizebytes, forKey: "totalNumberSizebytes")
        }
        guard self.stackoftasktobeestimated?.count ?? 0 > 0 else {
            self.selectalltaskswithnumbers(deselect: false)
            self.setbackuplist()
            self.startstopProgressIndicatorDelegate?.stop()
            return
        }
        self.updateprogressDelegate?.processTermination()
        self.outputprocess = OutputProcess()
        self.index = self.stackoftasktobeestimated?.remove(at: 0).1
        if self.estimatefiles {
            self.estimatefiles = false
            _ = RcloneSize(index: self.index!, outputprocess: self.outputprocess, updateprogress: self)
        } else {
            self.estimatefiles = true
            _ = EstimateremoteInformationOnetask(index: self.index!, outputprocess: self.outputprocess, updateprogress: self)
        }
    }

    func processTermination_inbatch() {
        self.count = self.stackoftasktobeestimated?.count
        let record = RemoteinfonumbersOnetask(outputprocess: self.outputprocess).record()
        record.setValue(self.configurations?.getConfigurations()[self.index!].localCatalog, forKey: "localCatalog")
        record.setValue(self.configurations?.getConfigurations()[self.index!].offsiteCatalog, forKey: "offsiteCatalog")
        record.setValue(self.configurations?.getConfigurations()[self.index!].hiddenID, forKey: "hiddenID")
        record.setValue(self.configurations?.getConfigurations()[self.index!].offsiteServer, forKey: "offsiteServer")
        self.records?.append(record)
        self.configurations?.estimatedlist?.append(record)
        guard self.stackoftasktobeestimated?.count ?? 0 > 0 else {
            self.selectalltaskswithnumbers(deselect: false)
            self.setbackuplist()
            self.startstopProgressIndicatorDelegate?.stop()
            return
        }
        self.updateprogressDelegate?.processTermination()
        self.outputprocess = OutputProcess()
        self.index = self.stackoftasktobeestimated?.remove(at: 0).1
        _ = EstimateremoteInformationOnetask(index: self.index!, outputprocess: self.outputprocess, updateprogress: self)
    }

    func fileHandler() {
        weak var outputeverythingDelegate: ViewOutputDetails?
        outputeverythingDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        if outputeverythingDelegate?.appendnow() ?? false {
            outputeverythingDelegate?.reloadtable()
        }
    }
}
