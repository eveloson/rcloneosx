//
//  ViewControllerInformation.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerInformation: NSViewController, SetDismisser, OutPut {

    @IBOutlet weak var detailsTable: NSTableView!

    var output: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        detailsTable.delegate = self
        detailsTable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.output = self.getinfo(viewcontroller: .vctabmain)
        globalMainQueue.async(execute: { () -> Void in
            self.detailsTable.reloadData()
        })
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

}

extension ViewControllerInformation: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.output?.count ?? 0
    }
}

extension ViewControllerInformation: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "outputID"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = self.output?[row] ?? ""
            return cell
        } else {
            return nil
        }
    }
}
