//
//  outputProcess.swift
//
//  Created by Thomas Evensen on 11/01/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

protocol RcloneError: AnyObject {
    func rcloneerror()
}

enum Trim {
    case one
    case two
    case three
}

final class OutputProcess {
    private var output: [String]?
    private var trimmedoutput: [String]?
    private var startIndex: Int?
    private var endIndex: Int?
    private var maxNumber: Int = 0
    weak var errorDelegate: ViewControllerMain?

    func getMaxcount() -> Int {
        if self.trimmedoutput == nil {
            _ = self.trimoutput(trim: .two)
        }
        return self.maxNumber
    }

    func count() -> Int {
        return self.output?.count ?? 0
    }

    func getrawOutput() -> [String]? {
        return self.output
    }

    func getOutput() -> [String]? {
        if self.trimmedoutput != nil {
            return self.trimmedoutput
        } else {
            return self.output
        }
    }

    // Add line from output
    func addlinefromoutput(_ str: String) {
        if self.startIndex == nil {
            self.startIndex = 0
        } else {
            self.startIndex = self.output!.count + 1
        }
        str.enumerateLines { line, _ in
            self.output!.append(line)
        }
    }

    func trimoutput(trim: Trim) -> [String]? {
        let whitespace: String = "\\ "
        var out = [String]()
        guard self.output != nil else { return nil }
        switch trim {
        case .one:
            for i in 0 ..< self.output!.count {
                let substr = String(self.output![i].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: whitespace))
                let split = substr.components(separatedBy: whitespace).dropFirst()
                out.append(split.joined(separator: " "))
            }
        case .two:
            for i in 0 ..< self.output!.count {
                out.append(self.output![i])
                let error = self.output![i].contains("ERROR")
                if error {
                    self.errorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                    self.errorDelegate?.rcloneerror()
                    _ = Logging(self, true)
                }
            }
            self.endIndex = out.count
            self.maxNumber = self.endIndex!
        case .three:
            let services = self.output!.filter { $0.contains("[") && $0.contains("]") }
            guard services.count > 0 else {
                return [""]
            }
            for i in 0 ..< services.count {
                let service = String(services[i].dropLast().dropFirst())
                out.append(service)
            }
        }
        self.trimmedoutput = out
        return out
    }

    init() {
        self.output = [String]()
    }
}
