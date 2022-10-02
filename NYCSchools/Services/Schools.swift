//
//  Schools.swift
//  Services
//
//  Created by M1Pro on 9/30/22.
//

import Foundation
import Combine
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

public class Schools {
    public static let shared = Schools()
    public private(set) var schools: [School] = []
    private init() {
        
    }
    
    public func fetch() -> PassthroughSubject<Void, Error> {
        let subject = PassthroughSubject<Void, Error>()
        let url = URL(string: "https://data.cityofnewyork.us/resource/s3k6-pzi2.json")!
        let request: AnyPublisher<[School],Error> = Network.default.fetch(url)
        var cancellable: AnyCancellable?

        func complete(_ error: Error? = nil) {
            if let e = error {
                subject.send(completion: .failure(e))
            } else {
                subject.send(completion: .finished)
            }
            cancellable = nil
        }

        cancellable = request.sink { failure in
            switch failure {
            case .failure(let error):
                print("Failed=\(failure)")
                complete(error)
            default:
                complete()
            }
        } receiveValue: { [weak self] schools in
            print("\(schools)")
            self?.schools = schools
            subject.send(())
        }
        return subject
    }
}

extension Schools {
    public func bestGraduationRate() -> [School] {
        return schools.sorted(by: { school1, school2 in
            guard school1.graduationRate.isEmpty == false else { return false }
            guard school2.graduationRate.isEmpty == false else { return true }
            guard let rate1 = Float(school1.graduationRate), let rate2 = Float(school2.graduationRate) else {
                return false
            }
            return rate1 > rate2
        })
    }
    
    public func worsttGraduationRate() -> [School] {
        return schools.sorted(by: { school1, school2 in
            guard school1.graduationRate.isEmpty == false else { return false }
            guard school2.graduationRate.isEmpty == false else { return true }
            guard let rate1 = Float(school1.graduationRate), let rate2 = Float(school2.graduationRate) else {
                return false
            }
            return rate1 < rate2
        })
    }
    
    public func mostNumberOfStudents() -> [School] {
        return schools.sorted(by: { school1, school2 in
            guard school1.totalStudents.isEmpty == false else { return false }
            guard school2.totalStudents.isEmpty == false else { return true }
            guard let num1 = Int(school1.totalStudents), let num2 = Int(school2.totalStudents) else {
                return false
            }
            return num1 > num2
        })
    }
    
    public func leastNumberOfStudents() -> [School] {
        return schools.sorted(by: { school1, school2 in
            guard school1.totalStudents.isEmpty == false else { return false }
            guard school2.totalStudents.isEmpty == false else { return true }
            guard let num1 = Int(school1.totalStudents), let num2 = Int(school2.totalStudents) else {
                return false
            }
            return num1 < num2
        })
    }
}

public struct SchoolDetails {
    @DecodableDefault.EmptyString var dbn: String
    @DecodableDefault.EmptyString var name: String
    @DecodableDefault.EmptyString var satTakers: String
    @DecodableDefault.EmptyString var satCriticalReadingAverage: String
    @DecodableDefault.EmptyString var satMathAverage: String
    @DecodableDefault.EmptyString var satWritingAverage: String
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

extension School {
    func fetchDetails() -> PassthroughSubject<SchoolDetails?, Error> {
        let subject = PassthroughSubject<SchoolDetails?, Error>()
        var cancellables: [AnyCancellable] = []
        
        func complete(_ error: Error? = nil) {
            if let e = error {
                subject.send(completion: .failure(e))
            } else {
                subject.send(completion: .finished)
            }
            cancellables.removeAll()
        }
        
        guard !self.dbn.isEmpty else {
            subject.send(nil)
            complete()
            return subject
        }
        let url = URL(string: "https://data.cityofnewyork.us/resource/f9bf-2cp4.json?dbn=\(dbn)")!
        let request: AnyPublisher<[SchoolDetails],Error> = Network.default.fetch(url)
        
        let fetchTest = request.sink { failure in
            switch failure {
            case .failure(let error):
                print("Failed=\(failure)")
                complete(error)
            default: break
            }
        } receiveValue: { details in
            print("\(details)")
            subject.send(details.first)
            complete()
        }
        cancellables.append(fetchTest)
        return subject
    }
}
