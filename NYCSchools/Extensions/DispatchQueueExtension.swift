//
//  DispatchQueueExtension.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import Foundation


extension DispatchQueue {
    static func executeInMain(_ completion: @escaping () -> Void) {
        guard !Thread.isMainThread else {
            completion()
            return
        }
        DispatchQueue.main.async {
            completion()
        }
    }
}
