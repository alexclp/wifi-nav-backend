import Vapor
import Foundation



struct MeasurementsJSONArray: Decodable {
    struct MeasurementElement: Decodable {
        let signalStrength: Int
        let name: String
        let macAddress: String
    }
    let measurements: [MeasurementElement]
}

extension Droplet {
    
    func setupRoutes() throws {
        post("determinePosition") { req in 
            print(try req.decodeJSONBody(MeasurementsJSONArray.self))
            return "Response"
        }
    }
}
