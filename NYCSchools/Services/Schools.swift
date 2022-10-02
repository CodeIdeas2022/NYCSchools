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
    
    private init() {
        
    }
    
    public func fetchAndStore() -> PassthroughSubject<Void, Error> {
        let subject = PassthroughSubject<Void, Error>()
//        let url = URL(string: "https://data.cityofnewyork.us/resource/s3k6-pzi2.json?$limit=5000")!
//        let request: AnyPublisher<[School],Error> = Network.default.fetch(url)
        var cancellables: [AnyCancellable] = []

        func complete(_ error: Error? = nil) {
            if let e = error {
                subject.send(completion: .failure(e))
            } else {
                subject.send(completion: .finished)
            }
            cancellables.removeAll()
        }
//
//        let fetchTest = request.sink { failure in
//            switch failure {
//            case .failure(let error):
//                print("Failed=\(failure)")
//                complete(error)
//            default: break
//            }
//        } receiveValue: { schools in
//            print("\(schools)")
//            let insert = CDManager.shared.insert(schools: schools)
//                .sink { result in
//                    switch result {
//                    case .failure(let error):
//                        print("Failed=\(error)")
//                        complete(error)
//                    default:
//                        complete()
//                    }
//                } receiveValue: { _ in
//
//                }
//            cancellables.append(insert)
//        }
//       cancellables.append(fetchTest)
        CDManager.shared.load { error in
            complete(error)
        }
        return subject
    }
}

extension Schools {
    public func bestGraduationRate() -> [SchoolInfo] {
        let schoolsList: [SchoolInfo] = CDManager.shared.fetch([], sortDescriptors: [NSSortDescriptor(key: "graduationRate", ascending: false)])
        return schoolsList
    }
    
    public func worsttGraduationRate() -> [SchoolInfo] {
        let schoolsList: [SchoolInfo] = CDManager.shared.fetch([], sortDescriptors: [NSSortDescriptor(key: "graduationRate", ascending: true)])
        return schoolsList
    }
    
    public func mostNumberOfStudents() -> [SchoolInfo] {
        let sortDescriptor = NSSortDescriptor(key: "totalStudents", ascending: false, selector: #selector(NSString.localizedStandardCompare(_:)))
        let schoolsList: [SchoolInfo] = CDManager.shared.fetch([], sortDescriptors: [sortDescriptor])
        return schoolsList
    }
    
    public func leastNumberOfStudents() -> [SchoolInfo] {
        let sortDescriptor = NSSortDescriptor(key: "totalStudents", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        let schoolsList: [SchoolInfo] = CDManager.shared.fetch([], sortDescriptors: [sortDescriptor])
        return schoolsList
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

extension SchoolInfo {
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
        
        guard let dbn = self.dbn else {
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
