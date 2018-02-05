import Vapor
import Foundation

final class PositionCalculator: NSObject {
    static let shared = PositionCalculator()
    private let baseURLAPI = "https://wifi-nav-api.herokuapp.com"

	private override init() { }

    func determinePosition(for measurementsCollection: MeasurementsJSONCollection) {
        for measurement in measurementsCollection.measurements {
            let currentScanMac = measurement.macAddress
            print(currentScanMac)
            searchForOldMeasurements(for: currentScanMac, completion: { (success, oldMeasurements) in
                if success == true {
                    guard let m = oldMeasurements else { print("Nothing found"); return }
                    print(m)
                }
            })
        }
    }

    private func searchForOldMeasurements(for macAddress: String, completion: @escaping (Bool, [MeasurementElement]?) -> Void) {
        var toReturn = [MeasurementElement]()
        HTTPClient.shared.request(urlString: baseURLAPI + "/measurements/address/\(macAddress)", method: "GET", parameters: nil) { (success, data) in
            if success == true {
                do {
                    print("Succesfully got the measurements for address \(macAddress)")
                    guard let data = data else { 
                        completion(false, nil)
                        return 
                    }
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        print(json)
                        for network in json {
                            if let signal = network["signalStrength"] as? Int {
                                toReturn.append(MeasurementElement(signalStrength: signal, name: "Current", macAddress: macAddress))
                            }  
                        }
                    } else {
                        completion(false, nil)
                    }
                    completion(false, nil)
                } catch {
					print(error.localizedDescription)
                    completion(false, nil)
				} 
            }  else {
                print("Failed to get the measurements for address \(macAddress)")
                completion(false, nil)
            }
        }
    }
}