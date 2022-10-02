//
//  SchoolDetails.swift
//  NYCSchools
//
//  Created by M1Pro on 10/2/22.
//

import Foundation

public struct SchoolDetails {
    @DecodableDefault.EmptyString var dbn: String
    @DecodableDefault.EmptyString var name: String
    @DecodableDefault.EmptyString var satTakers: String
    @DecodableDefault.EmptyString var satCriticalReadingAverage: String
    @DecodableDefault.EmptyString var satMathAverage: String
    @DecodableDefault.EmptyString var satWritingAverage: String
    var satRanking: Schools.SATRankings?
    
    mutating func setRanking(_ ranking: Schools.SATRankings) {
        satRanking = ranking
    }
}

extension SchoolDetails: Decodable {
    enum CodingKeys: String, CodingKey {
        case dbn = "dbn"
        case name = "school_name"
        case satTakers = "num_of_sat_test_takers"
        case satCriticalReadingAverage = "sat_critical_reading_avg_score"
        case satMathAverage = "sat_math_avg_score"
        case satWritingAverage = "sat_writing_avg_score"
    }
}
