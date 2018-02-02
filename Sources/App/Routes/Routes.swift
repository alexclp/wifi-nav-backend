import Vapor
import Foundation

extension Droplet {
    func setupRoutes() throws {
        post("determinePosition") { req in 
            return req.description 
        }
    }
}
