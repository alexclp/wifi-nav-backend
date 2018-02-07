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
            let measurementsCollection = try req.decodeJSONBody(MeasurementsJSONCollection.self)
            let locationID = PositionCalculator.shared.determinePosition(for: measurementsCollection)
            var responseJSON = JSON()
            try responseJSON.set("success", true)
            try responseJSON.set("locationID", locationID)
            return responseJSON
        }
    }
}
