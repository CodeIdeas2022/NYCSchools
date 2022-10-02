//
//  UIViewExtension.swift
//  NYCSchools
//
//  Created by M1Pro on 10/2/22.
//

import Foundation
import UIKit


extension UIView {
    func alignCenterWithSuperview(upOffset: CGFloat = 0.0) {
        guard let s = superview else { return }
        centerXAnchor.constraint(equalTo: s.safeAreaLayoutGuide.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: s.safeAreaLayoutGuide.centerYAnchor, constant: upOffset).isActive = true
    }
}
