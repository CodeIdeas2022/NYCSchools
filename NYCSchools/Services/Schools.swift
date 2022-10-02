//
//  Schools.swift
//  Services
//
//  Created by M1Pro on 9/30/22.
//

import Foundation
import Combine


public class Schools {
    public static let shared = Schools()
    public private(set) var schools: [School] = []
    public private(set) var schoolsDetail: [SchoolDetails] = []
    
    private init() {
        
    }
    
    public func fetch() -> PassthroughSubject<Void, Error> {
        let subject = PassthroughSubject<Void, Error>()
        let url = URL(string: "https://data.cityofnewyork.us/resource/s3k6-pzi2.json")!
        let request: AnyPublisher<[School],Error> = Network.default.fetch(url)
        var cancellable1: AnyCancellable?
        var cancellable2: AnyCancellable?

        func complete(_ error: Error? = nil) {
            if let e = error {
                subject.send(completion: .failure(e))
            } else {
                subject.send(completion: .finished)
            }
            cancellable1 = nil
            cancellable2 = nil
        }

        cancellable1 = request.sink { [weak self] failure in
            switch failure {
            case .failure(let error):
                print("Failed=\(failure)")
                complete(error)
            default:
                cancellable2 = self?.fetchDetails()
                    .sink(receiveCompletion: { result in
                        switch result {
                        case .failure(let error):
                            complete(error)
                        case .finished:
                            complete()
                        }
                    }, receiveValue: { [weak self] details in
                        self?.schoolsDetail = details
                        subject.send(())
                    })
                    
            }
        } receiveValue: { [weak self] schools in
            self?.schools = schools
            subject.send(())
        }
        return subject
    }
    
    public func fetchDetails() -> PassthroughSubject<[SchoolDetails], Error> {
        let subject = PassthroughSubject<[SchoolDetails], Error>()
        var cancellable: AnyCancellable?
        
        func complete(_ error: Error? = nil) {
            if let e = error {
                subject.send(completion: .failure(e))
            } else {
                subject.send(completion: .finished)
            }
            cancellable = nil
        }
        
        let url = URL(string: "https://data.cityofnewyork.us/resource/f9bf-2cp4.json")!
        let request: AnyPublisher<[SchoolDetails],Error> = Network.default.fetch(url)
        
        cancellable = request.sink { failure in
            switch failure {
            case .failure(let error):
                print("Failed=\(failure)")
                complete(error)
            default: break
            }
        } receiveValue: { details in
            subject.send(details)
            complete()
        }
        return subject
    }
    
    public func detailsForSchool(_ school: School) -> SchoolDetails? {
        return schoolsDetail.filter({ $0.dbn == school.dbn }).first
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
    
    public func searchSchools(_ schools: [School], string: String) -> PassthroughSubject<[School], Error> {
        let subject = PassthroughSubject<[School], Error>()
        
        func complete(_ error: Error? = nil) {
            if let e = error {
                subject.send(completion: .failure(e))
            } else {
                subject.send(completion: .finished)
            }
        }
        DispatchQueue.global().async {
            let filteredSchools = schools.filter { school in
                return school.searchString.range(of: string, options: .caseInsensitive) != nil
            }
            subject.send(filteredSchools)
            complete()
        }
        return subject
    }
}

extension School {
    var searchString: String {
        var strings:[String] = []
        strings.append(dbn)
        strings.append(name)
        strings.append(borough)
        strings.append(addressLine1)
        strings.append(city)
        strings.append(zip)
        strings.append(overview)
        strings.append(phone)
        strings.append(email)
        strings.append(graduationRate)
        return strings.joined(separator: ",")
    }
    public func fetchDetails() -> PassthroughSubject<SchoolDetails?, Error> {
        let subject = PassthroughSubject<SchoolDetails?, Error>()
        var cancellable: AnyCancellable?
        
        func complete(_ error: Error? = nil) {
            if let e = error {
                subject.send(completion: .failure(e))
            } else {
                subject.send(completion: .finished)
            }
            cancellable = nil
        }
        
        guard !self.dbn.isEmpty else {
            subject.send(nil)
            complete()
            return subject
        }
        let url = URL(string: "https://data.cityofnewyork.us/resource/f9bf-2cp4.json?dbn=\(dbn)")!
        let request: AnyPublisher<[SchoolDetails],Error> = Network.default.fetch(url)
        
        cancellable = request.sink { failure in
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
        return subject
    }
}
