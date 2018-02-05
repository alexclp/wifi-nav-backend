import Vapor
import Foundation

struct MeasurementElement: Decodable {
    let signalStrength: Int
    let name: String
    let macAddress: String

    init(signalStrength: Int, name: String, macAddress: String) {
        self.signalStrength = signalStrength
        self.name = name
        self.macAddress = macAddress
    }
}

struct MeasurementsJSONCollection: Decodable {
    let measurements: [MeasurementElement]
}

extension Droplet {
    func setupRoutes() throws {
        post("determinePosition") { req in 
            return try Response.async { portal in
                _ = try background {
                    do {
                        let measurementsCollection = try req.decodeJSONBody(MeasurementsJSONCollection.self)
                        PositionCalculator.shared.determinePosition(for: measurementsCollection) { (success, id) in
                            do {
                                if success == true {
                                    if let id = id {
                                        var responseJSON = JSON()
                                        try responseJSON.set("success", true)
                                        try responseJSON.set("locationID", id)
                                        portal.close(with: try Response(status: .ok, json: responseJSON))
                                    }
                                } else {
                                    var responseJSON = JSON()
                                    try responseJSON.set("success", false)
                                    portal.close(with: try Response(status: .badRequest, json: responseJSON))
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    } catch {
                        portal.close(with: error)
                    }
                }
            }
        }
    }
}
