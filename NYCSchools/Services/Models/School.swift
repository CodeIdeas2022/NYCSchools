//
//  School.swift
//  NYCSchools
//
//  Created by M1Pro on 10/2/22.
//

import Foundation

public struct School {
    @DecodableDefault.EmptyString var dbn: String
    @DecodableDefault.EmptyString var name: String
    @DecodableDefault.EmptyString var borough: String
    @DecodableDefault.EmptyString var addressLine1: String
    @DecodableDefault.EmptyString var city: String
    @DecodableDefault.EmptyString var zip: String
    @DecodableDefault.EmptyString var overview: String
    @DecodableDefault.EmptyString var neighborhood: String
    @DecodableDefault.EmptyString var phone: String
    @DecodableDefault.EmptyString var email: String
    @DecodableDefault.EmptyString var website: String
    @DecodableDefault.EmptyString var totalStudents: String
    @DecodableDefault.EmptyString var graduationRate: String
    @DecodableDefault.EmptyString var latitude: String
    @DecodableDefault.EmptyString var longitude: String
}

extension School: Decodable {
    enum CodingKeys: String, CodingKey {
        case dbn = "dbn"
        case name = "school_name"
        case borough = "borough"
        case addressLine1 = "primary_address_line_1"
        case city = "city"
        case zip = "zip"
        case overview = "overview_paragraph"
        case neighborhood = "neighborhood"
        case phone = "phone"
        case email = "school_email"
        case website = "website"
        case totalStudents = "total_students"
        case graduationRate = "graduation_rate"
        case latitude = "latitude"
        case longitude = "longitude"
    }
}
