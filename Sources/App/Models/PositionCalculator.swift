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

    func determinePosition(for measurementsCollection: MeasurementsJSONCollection) -> Location? {
        var locationsMarks = [Int: Int]()

        for currentScanMeasurement in measurementsCollection.measurements {
            let currentScanMac = currentScanMeasurement.macAddress
            let currentScanSignalStrength = currentScanMeasurement.signalStrength
            
            var minDiff = 99999999999999999
            var minLocationID = 0

            guard let searchResults = searchForOldMeasurements(for: currentScanMac)?.results else { print("Not found!"); continue }
            for result in searchResults {
                let diff = abs((currentScanSignalStrength * -1) - (result.signalStrength * -1))
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
        print(locationsMarks)
        guard let location = getLocationDetails(for: locationID) else { return nil }
        return location 
    }

    private func getLocationDetails(for locationID: Int) -> Location? {
        do {
            let config = try Config()
            try config.setup()
    
            let drop = try Droplet(config)
            try drop.setup()

            let urlString = "\(baseURLAPI)/locations/\(locationID)"
            let response = try drop.client.get(urlString)
            if response.status == Status.ok {
                let location = try response.decodeJSONBody(Location.self)
                return location
            }
        } catch {
            print(error)
            print(error.localizedDescription)
        }
        return nil
    }
    
    private func searchForOldMeasurements(for macAddress: String) -> MeasurementsSearchResult? {
        do {
            let config = try Config()
            try config.setup()
    
            let drop = try Droplet(config)
            try drop.setup()

            let urlString = "\(baseURLAPI)/measurements/address/\(macAddress)"
            let response = try drop.client.get(urlString)
            if response.status == Status.ok {
                let measurementResults = try response.decodeJSONBody(MeasurementsSearchResult.self)
                return measurementResults
            }
        } catch {
            print(error)
            print(error.localizedDescription)
        }
        return nil
    }
}
