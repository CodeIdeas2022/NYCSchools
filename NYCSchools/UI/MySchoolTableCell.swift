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
    
    func fillData(_ school: School, highlightField: SchoolsListViewController.Sort) {
        textLabel?.text = school.name
        var detail: [String] = [school.dbn]
        switch highlightField {
        case .bestGraduationRate, .worstGraduationRate:
            if school.graduationRate.isEmpty == false, let rate = Float(school.graduationRate) {
                detail.append(String(format: "%.1f", rate * 100.0) + "%")
            } else {
                detail.append("Graduation rate NA")
            }
        case .mostNumberOfStudents, .leastNumberOfStudents:
            if school.totalStudents.isEmpty == false {
                detail.append("\(school.totalStudents) students")
            } else {
                detail.append("Student count rate NA")
            }
        case .topSATReading, .bottomSATReading:
            if let ranking = school.details?.satRanking, ranking.reading >= 0 {
                detail.append("SAT reading rank \(ranking.reading)/\(ranking.totalSchoolsWithReadingScores)")
            } else {
                detail.append("SSAT reading rank NA")
            }
        case .topSATWriting, .bottomSATWriting:
            if let ranking = school.details?.satRanking, ranking.writing >= 0 {
                detail.append("SAT writing rank \(ranking.writing)/\(ranking.totalSchoolsWithWritingScores)")
            } else {
                detail.append("SSAT writing rank NA")
            }
        case .topSATMath, .bottomSATMath:
            if let ranking = school.details?.satRanking, ranking.math >= 0 {
                detail.append("SAT math rank \(ranking.math)/\(ranking.totalSchoolsWithMathScores)")
            } else {
                detail.append("SSAT math rank NA")
            }
        }
        detail.append(school.borough)
        detailTextLabel?.text = detail.joined(separator: ", ")
    }
}
