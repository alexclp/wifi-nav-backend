import XCTest
import Testing
@testable import Vapor
@testable import App

class NavigationEngineTests: TestCase {
    func testShortestPath() {
        let mockHTTPClient = MockHTTPClient.init()
        NavigationEngine.shared.httpClient = mockHTTPClient
        let result = NavigationEngine.shared.shortestPath(start: 0, finish: 3)
        XCTAssertNotNil(result)
        print(result)
        if let result = result {
            if let path = result["path"] as? [Int] {
                XCTAssertEqual(path, [0, 2, 3])
            } 

            if let status = result["success"] as? Bool {
                XCTAssertTrue(status)
            }
        }
    }
}

extension NavigationEngineTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testShortestPath", testShortestPath),
    ]
}