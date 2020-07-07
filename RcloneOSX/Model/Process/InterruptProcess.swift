//
//  InterruptProcess.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 07/07/2020.
//  Copyright © 2020 Thomas Evensen. All rights reserved.
//

import Foundation

struct InterruptProcess {
    init() {
        guard ViewControllerReference.shared.process != nil else { return }
        let output = OutputProcess()
        let formatter = DateFormatter()
        formatter.dateFormat = "-yyyy-MM-dd"
        let string = "Interrupted: " + formatter.string(from: Date())
        output.addlinefromoutput(string)
        _ = Logging(output, true)
        ViewControllerReference.shared.process?.interrupt()
        ViewControllerReference.shared.process = nil
    }

    init(output: OutputProcess?) {
        guard ViewControllerReference.shared.process != nil, output != nil else { return }
        _ = Logging(output, true)
        ViewControllerReference.shared.process?.interrupt()
        ViewControllerReference.shared.process = nil
    }
}
