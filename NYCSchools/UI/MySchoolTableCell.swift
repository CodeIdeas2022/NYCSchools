//
//  MySchoolTableCell.swift
//  NYCSchools
//
//  Created by M1Pro on 10/1/22.
//

import UIKit

class MySchoolCell: UITableViewCell {
    static let id = "cell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.textLabel?.numberOfLines = 0
        self.textLabel?.lineBreakMode = .byWordWrapping
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fillData(_ school: SchoolInfo, highlightField: SchoolsListViewController.Sort) {
        textLabel?.text = school.name
        var detail: [String] = [school.dbn ?? ""]
        switch highlightField {
        case .bestGraduationRate, .worstGraduationRate:
            if school.graduationRate != -1.0 {
                detail.append(String(format: "%.1f", school.graduationRate * 100.0) + "%")
            } else {
                detail.append("Graduation rate NA")
            }
        case .mostNumberOfStudents, .leastNumberOfStudents:
            if school.totalStudents != -1 {
                detail.append("\(school.totalStudents) students")
            } else {
                detail.append("Student count rate NA")
            }
        }
        detail.append(school.borough ?? "NA")
        detailTextLabel?.text = detail.joined(separator: ", ")
    }
}
