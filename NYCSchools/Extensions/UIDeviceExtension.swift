//
//  UIDeviceExtension.swift
//  NYCSchools
//
//  Created by M1Pro on 10/2/22.
//

import Foundation
import UIKit


extension UIDevice {
    var defaultTableCellHeight: CGFloat {
        if userInterfaceIdiom == .pad {
            return 55.0
        }
        return 44.0
    }
}
