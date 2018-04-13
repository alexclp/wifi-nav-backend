import XCTest
import Testing
@testable import Vapor
@testable import App

class PositionCalculatorTests: TestCase {
    func createInputForPositioning() throws -> MeasurementsJSONCollection {
        let json = """
        {
   "measurements":[
      {
         "macAddress":"00:62:EC:FD:E9:10",
         "signalStrength":-73,
         "name":"eduroam"
      },
      {
         "macAddress":"00:62:EC:FD:E9:12",
         "signalStrength":-72,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:62:EC:FD:E9:13",
         "signalStrength":-71,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:E9:14",
         "signalStrength":-71,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:62:EC:FD:EA:03",
         "signalStrength":-81,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:EA:04",
         "signalStrength":-80,
         "name":"PLOCAL"
      },
      {
         "macAddress":"00:62:EC:FD:EA:00",
         "signalStrength":-83,
         "name":"eduroam"
      },
      {
         "macAddress":"00:42:68:A6:A4:94",
         "signalStrength":-79,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:62:EC:FD:EF:90",
         "signalStrength":-64,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:62:EC:FD:ED:70",
         "signalStrength":-61,
         "name":"eduroam"
      },
      {
         "macAddress":"00:62:EC:FD:EF:91",
         "signalStrength":-60,
         "name":"PLOCAL"
      },
      {
         "macAddress":"58:AC:78:F1:86:C0",
         "signalStrength":-83,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:42:68:A6:A6:71",
         "signalStrength":-65,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:42:68:A6:A6:72",
         "signalStrength":-61,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:62:EC:FD:EC:A0",
         "signalStrength":-62,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:EC:A1",
         "signalStrength":-61,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:62:EC:FD:EC:A2",
         "signalStrength":-76,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"58:AC:78:F1:86:C2",
         "signalStrength":-77,
         "name":"The Cloud"
      },
      {
         "macAddress":"58:AC:78:F1:86:C3",
         "signalStrength":-78,
         "name":"PLOCAL"
      },
      {
         "macAddress":"00:42:68:A6:A4:90",
         "signalStrength":-79,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:42:68:A6:A4:91",
         "signalStrength":-53,
         "name":"eduroam"
      },
      {
         "macAddress":"00:42:68:A6:A4:92",
         "signalStrength":-55,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:F1:62",
         "signalStrength":-54,
         "name":"PLOCAL"
      },
      {
         "macAddress":"00:62:EC:FD:F1:63",
         "signalStrength":-52,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:EF:93",
         "signalStrength":-61,
         "name":"PLOCAL"
      },
      {
         "macAddress":"00:42:68:A6:A6:73",
         "signalStrength":-52,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:62:EC:FD:ED:73",
         "signalStrength":-59,
         "name":"PLOCAL"
      },
      {
         "macAddress":"00:62:EC:FD:ED:74",
         "signalStrength":-60,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:62:EC:FD:F1:60",
         "signalStrength":-61,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:42:68:A6:A6:74",
         "signalStrength":-64,
         "name":"eduroam"
      },
      {
         "macAddress":"00:42:68:A6:A6:70",
         "signalStrength":-64,
         "name":"eduroam"
      },
      {
         "macAddress":"00:62:EC:FD:ED:72",
         "signalStrength":-51,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:62:EC:FD:EB:11",
         "signalStrength":-68,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:EB:12",
         "signalStrength":-65,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:EB:13",
         "signalStrength":-63,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:62:EC:FD:EB:14",
         "signalStrength":-67,
         "name":"PLOCAL"
      },
      {
         "macAddress":"00:62:EC:FD:EC:52",
         "signalStrength":-62,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:EB:10",
         "signalStrength":-53,
         "name":"eduroam"
      },
      {
         "macAddress":"00:62:EC:FD:EC:50",
         "signalStrength":-63,
         "name":"eduroam"
      },
      {
         "macAddress":"00:62:EC:FD:EC:C1",
         "signalStrength":-53,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:62:EC:FD:EC:53",
         "signalStrength":-55,
         "name":"The Cloud"
      },
      {
         "macAddress":"00:62:EC:FD:EC:C3",
         "signalStrength":-56,
         "name":"PLOCAL"
      },
      {
         "macAddress":"00:62:EC:FD:EC:C4",
         "signalStrength":-55,
         "name":"SLaMFT"
      },
      {
         "macAddress":"00:62:EC:FD:EF:94",
         "signalStrength":-62,
         "name":"KINGSWAP"
      },
      {
         "macAddress":"00:62:EC:FD:EF:92",
         "signalStrength":-62,
         "name":"SLaMFT"
      }
   ]
}
"""
        let data = json.data(using: .utf8)
        let collection = try JSONDecoder().decode(MeasurementsJSONCollection.self, from: data!)
        return collection
    }

    func testDeterminePosition() throws {
        let measurements = try createInputForPositioning()
        let location = PositionCalculator.shared.determinePosition(for: measurements)
        XCTAssertNotNil(location)
        if let loc = location {
            XCTAssertEqual(loc.roomID, 1)
        }
    }
}

extension PositionCalculatorTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testDeterminePosition", testDeterminePosition),
    ]
}