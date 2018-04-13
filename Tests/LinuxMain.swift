#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppTests
    testCase(PositionCalculatorTests.allTests),
    testCase(NavigationEngineTests.allTests)
])

#endif
