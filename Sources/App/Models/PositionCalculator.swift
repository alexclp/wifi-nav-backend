import Vapor
import Foundation
import HTTP

struct SearchResultElement: Decodable {
    let apID: Int
    let id: Int
    let signalStrength: Int
    let locationID: Int
}

struct MeasurementsSearchResult: Decodable {
    let results: [SearchResultElement]
}

final class PositionCalculator: NSObject {
    static let shared = PositionCalculator()
    private let baseURLAPI = "https://wifi-nav-api.herokuapp.com"

	private override init() { }

    func determinePosition(for measurementsCollection: MeasurementsJSONCollection) -> Int? {
        // print(searchForOldMeasurements(for: "00:62:EC:FD:E9:10"))
        var locationsMarks = [Int: Int]()
        var minDiff = 99999999999999999
        var minLocationID = 0

        for currentScanMeasurement in measurementsCollection.measurements {
            let currentScanMac = currentScanMeasurement.macAddress
            let currentScanSignalStrength = currentScanMeasurement.signalStrength

            guard let searchResults = searchForOldMeasurements(for: currentScanMac)?.results else { continue }
            for result in searchResults {
                let diff = currentScanSignalStrength - result.signalStrength
                if diff < minDiff {
                    minDiff = diff
                    minLocationID = result.locationID
                }
            }

            if locationsMarks[minLocationID] != nil {
                locationsMarks[minLocationID] = locationsMarks[minLocationID]! + 1
            } else {
                locationsMarks[minLocationID] = 1
            }
        }

        var locationID = 0
        var count = 0
        for (key, value) in locationsMarks {
            if value > count {
                count = value
                locationID = key
            }
        }
        return locationID
        //     searchForOldMeasurements(for: currentScanMac, completion: { (success, oldMeasurements) in
        //         measurementCurrentCount = measurementCurrentCount + 1
        //         if success == true {
        //             guard let oldMeasurements = oldMeasurements else { print("Nothing found"); return }
        //             for oldMeasurement in oldMeasurements {
        //                 if let oldSignalStrength = oldMeasurement["signalStrength"] as? Int, let oldLocationID = oldMeasurement["locationID"] as? Int {
        //                     let diff = currentScanSignalStrength - oldSignalStrength
        //                     if diff < minDiff {
        //                         minDiff = diff
        //                         minLocationID = oldLocationID
        //                     }
        //                 }
        //             }

        //             if locationsMarks[minLocationID] != nil {
        //                 locationsMarks[minLocationID] = locationsMarks[minLocationID]! + 1
        //             } else {
        //                 locationsMarks[minLocationID] = 1
        //             }
        //         } else {

        //         }

        //         if measurementCurrentCount == measurementsSize {
        //             var locationID = 0
        //             var count = 0
        //             for (key, value) in locationsMarks {
        //                 if value > count {
        //                     count = value
        //                     locationID = key
        //                 }
        //             }
        //             completion(true, locationID)
        //         }
        //     })
        // }     
    }
    
    private func searchForOldMeasurements(for macAddress: String) -> MeasurementsSearchResult? {
        do {
            let config = try Config()
            try config.setup()
    
            let drop = try Droplet(config)
            try drop.setup()

            let urlString = "\(baseURLAPI)/measurements/address/\(macAddress)"
            print(urlString)
            let response = try drop.client.get(urlString)
            print(response)
            // if response.status == Status.ok {
                let measurementResults = try response.decodeJSONBody(MeasurementsSearchResult.self)
                print("aaaaaaaa")
                print(measurementResults)
                return measurementResults
            // }

            

        } catch {
            print(error)
            print(error.localizedDescription)
        }
        return nil
    }
}
