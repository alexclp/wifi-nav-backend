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

struct NavigationRequestJSON: Decodable {
    let startLocationID: Int
    let finishLocationID: Int 
}

extension Droplet {
    func setupRoutes() throws {
        post("determinePosition") { req in 
            let measurementsCollection = try req.decodeJSONBody(MeasurementsJSONCollection.self)
            let location = PositionCalculator.shared.determinePosition(for: measurementsCollection)
            if let location = location {
                var responseJSON = JSON()
                try responseJSON.set("success", true)
                try responseJSON.set("id", location.id)
                try responseJSON.set("x", location.x)
                try responseJSON.set("y", location.y)
                try responseJSON.set("roomID", location.roomID)
                return responseJSON
            } else {
                var responseJSON = JSON()
                try responseJSON.set("success", false)
                return responseJSON
            }
            
        }

        post("calculateRoute") { req in  
            let requestJSON = try req.decodeJSONBody(NavigationRequestJSON.self)
            if let result = NavigationEngine.shared.shortestPath(start: requestJSON.startLocationID, finish: requestJSON.finishLocationID) {
                var responseJSON = JSON()
                try responseJSON.set("success", true)
                try responseJSON.set("path", result["path"] as! [Int])
                try responseJSON.set("distance", result["distance"] as! Double)
                return responseJSON
            } else {
                var responseJSON = JSON()
                try responseJSON.set("success", false)
                return responseJSON
            }
        }
    } 
}
