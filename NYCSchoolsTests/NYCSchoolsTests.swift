//
//  NYCSchoolsTests.swift
//  NYCSchoolsTests
//
//  Created by M1Pro on 9/30/22.
//

import XCTest
@testable import NYCSchools
import Combine

class NYCSchoolsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            let expectation = self.expectation(description: "Fetch will return with a result. Performance is measured")
            var cancellable = Schools.shared.fetch()
                .sink { result in
                    switch result {
                    case .finished:
                        XCTAssertTrue(true)
                    case .failure(let error):
                        XCTFail("Schools.shared.fetch return error. error=\(error.localizedDescription)")
                    }
                    expectation.fulfill()
                } receiveValue: { _ in
                    
                }
            waitForExpectations(timeout: 10) { error in
                guard let e = error else { return }
                XCTFail("Schools.shared.fetch timedout.error=\(e.localizedDescription)")
            }
        }
    }

}
