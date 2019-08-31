//
//  completeScheduledOperation.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

final class CompleteQuickbackupTask: SetConfigurations, SetSchedules {

    private var index: Int?
    private var hiddenID: Int?
    // Function for update result of quickbacuptask the job
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(outputprocess: OutputProcess?) {
        guard self.index ?? -1 > -1 else { return }
        self.configurations?.setCurrentDateonConfiguration(index: self.index!, outputprocess: outputprocess)
        self.schedulesDelegate?.reloadschedulesobject()
    }

    init (dict: NSDictionary) {
        self.hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
        self.index = self.configurations!.getIndex(hiddenID ?? -1)
    }
}
