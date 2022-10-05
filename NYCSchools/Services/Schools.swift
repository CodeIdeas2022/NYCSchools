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
                        guard let self = self else { return }
                        self.schoolsDetail = details.sorted(by: { school1, school2 in
                            return school1.dbn > school2.dbn
                        })
                        let count = self.schools.count
                        for index in 0..<count {
                            var school = self.schools[index]
                            guard  let detailIndex = self.indexOfDetailsForSchool(school) else {
                                continue
                            }
                            var details = self.schoolsDetail[detailIndex]
                            if let ranking = self.satRankingForSchool(details) {
                                details.setRanking(ranking)
                            }
                            self.schoolsDetail[detailIndex] = details
                            
                            school.setSchoolDetails(details)
                            self.schools[index] = school
                        }
                        subject.send(())
                    })
                    
            }
        } receiveValue: { [weak self] schools in
            self?.schools = schools.sorted(by: { school1, school2 in
                return school1.dbn > school2.dbn
            })
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
    
    public func indexOfDetailsForSchool(_ school: School) -> Int? {
        let schoolsDetails = self.schoolsDetail
        return schoolsDetail.indices.filter({ schoolsDetails[$0].dbn == school.dbn }).first
    }
    
    public func satRankingForSchool(_ details: SchoolDetails) -> SATRankings? {
        guard Int(details.satTakers) != nil else {
            return nil
        }
        let schoolsDetailReading = self.schoolsDetail.filter({ Int($0.satCriticalReadingAverage) != nil })
        let reading = schoolsDetailReading.sorted { detail1, detail2 in
            return detail1.satCriticalReadingAverage > detail2.satCriticalReadingAverage
        }
        let schoolsDetailWriting = self.schoolsDetail.filter({ Int($0.satWritingAverage) != nil })
        let writing = schoolsDetailWriting.sorted { detail1, detail2 in
            return detail1.satWritingAverage > detail2.satWritingAverage
        }
        let schoolsDetailMath = self.schoolsDetail.filter({ Int($0.satMathAverage) != nil })
        let math = schoolsDetailMath.sorted { detail1, detail2 in
            return detail1.satMathAverage > detail2.satMathAverage
        }
        
        let readingRank = reading.firstIndex(where: {$0.dbn == details.dbn }) ?? -1
        let writingRank = writing.firstIndex(where: {$0.dbn == details.dbn }) ?? -1
        let mathRank = math.firstIndex(where: {$0.dbn == details.dbn }) ?? -1
        return SATRankings(reading: readingRank != -1 ? (readingRank + 1): -1, writing: writingRank != -1 ? (writingRank + 1): -1, math: mathRank != -1 ? (mathRank + 1): -1, totalSchoolsWithReadingScores: reading.count, totalSchoolsWithWritingScores: writing.count, totalSchoolsWithMathScores: math.count)
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
    
    public func satReadingRank(_ isBest: Bool = true) -> [School] {
        return schools.sorted(by: { school1, school2 in
            guard let ranking1 = school1.details?.satRanking?.reading else { return false }
            guard let ranking2 = school2.details?.satRanking?.reading else { return true }
            guard ranking1 >= 0 else { return false }
            guard ranking2 >= 0 else { return true }

            return  (ranking1 < ranking2) == isBest
        })
    }
    
    public func satWritingRank(_ isBest: Bool = true) -> [School] {
        return schools.sorted(by: { school1, school2 in
            guard let ranking1 = school1.details?.satRanking?.writing else { return false }
            guard let ranking2 = school2.details?.satRanking?.writing else { return true }
            guard ranking1 >= 0 else { return false }
            guard ranking2 >= 0 else { return true }

            return  (ranking1 < ranking2) == isBest
        })
    }
    
    public func satMathRank(_ isBest: Bool = true) -> [School] {
        return schools.sorted(by: { school1, school2 in
            guard let ranking1 = school1.details?.satRanking?.math else { return false }
            guard let ranking2 = school2.details?.satRanking?.math else { return true }
            guard ranking1 >= 0 else { return false }
            guard ranking2 >= 0 else { return true }

            return  (ranking1 < ranking2) == isBest
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


public extension Schools {
    public struct SATRankings {
        let reading: Int
        let writing: Int
        let math: Int
        let totalSchoolsWithReadingScores: Int
        let totalSchoolsWithWritingScores: Int
        let totalSchoolsWithMathScores: Int
    }
}
