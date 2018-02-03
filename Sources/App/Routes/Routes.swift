import Vapor
import Foundation

extension Droplet {
    func setupRoutes() throws {
        post("determinePosition") { req in 
            // req.body = json
            let mirror = Mirror(reflecting: req)
            print(mirror.subjectType)
            return "AA"
        }
    }
}
