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

    private let INF = 99999999999999999

	private override init() { }

    func determinePosition(for measurementsCollection: MeasurementsJSONCollection) -> Location? {
        var locationsMarks = [Int: Int]()

        for currentScanMeasurement in measurementsCollection.measurements {
            let currentScanMacAddress = currentScanMeasurement.macAddress
            let currentScanSignalStrength = currentScanMeasurement.signalStrength

            guard let searchResults = searchForOldMeasurements(for: currentScanMacAddress)?.results else { print("Not found!"); continue }

            var minDiff = INF
            var minLocationID = 0
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
        var maxMatches = 0
        for (key, value) in locationsMarks {
            if value > maxMatches {
                maxMatches = value
                locationID = key
            }
        }

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
