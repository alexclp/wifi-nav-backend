import Vapor
import Foundation

final class PositionCalculator: NSObject {
    static let shared = PositionCalculator()
    private let baseURLAPI = "https://wifi-nav-api.herokuapp.com"

	private override init() { }

    func determinePosition(for measurementsCollection: MeasurementsJSONCollection, completion: @escaping (Bool, Int?) -> Void) {
        var locationsMarks = [Int: Int]()
        var minDiff = 99999999999999999
        var minLocationID = 0
        let measurementsSize = measurementsCollection.measurements.count
        var measurementCurrentCount = 0

        for currentScanMeasurement in measurementsCollection.measurements {
            let currentScanMac = currentScanMeasurement.macAddress
            let currentScanSignalStrength = currentScanMeasurement.signalStrength
          
            searchForOldMeasurements(for: currentScanMac, completion: { (success, oldMeasurements) in
                measurementCurrentCount = measurementCurrentCount + 1
                if success == true {
                    guard let oldMeasurements = oldMeasurements else { print("Nothing found"); return }
                    for oldMeasurement in oldMeasurements {
                        if let oldSignalStrength = oldMeasurement["signalStrength"] as? Int, let oldLocationID = oldMeasurement["locationID"] as? Int {
                            let diff = currentScanSignalStrength - oldSignalStrength
                            if diff < minDiff {
                                minDiff = diff
                                minLocationID = oldLocationID
                            }
                        }
                    }

                    if locationsMarks[minLocationID] != nil {
                        locationsMarks[minLocationID] = locationsMarks[minLocationID]! + 1
                    } else {
                        locationsMarks[minLocationID] = 1
                    }
                } else {

                }

                if measurementCurrentCount == measurementsSize {
                    var locationID = 0
                    var count = 0
                    for (key, value) in locationsMarks {
                        if value > count {
                            count = value
                            locationID = key
                        }
                    }
                    completion(true, locationID)
                }
            })
        }     
    }

    private func searchForOldMeasurements(for macAddress: String, completion: @escaping (Bool, [[String: Any]]?) -> Void) {
        HTTPClient.shared.request(urlString: baseURLAPI + "/measurements/address/\(macAddress)", method: "GET", parameters: nil) { (success, data) in
            if success == true {
                do {
                    guard let data = data else { 
                        completion(false, nil)
                        return 
                    }
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print(json)
                        completion(true, json)
                    } else {
                        completion(false, nil)
                    }
                    completion(false, nil)
                } catch {
					print(error.localizedDescription)
                    completion(false, nil)
				} 
            }  else {
                completion(false, nil)
            }
        }
    }
}
