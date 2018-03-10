import Vapor
import HTTP
import Foundation

final class NetworkingHelper: NSObject {
    static let shared = NetworkingHelper()

    private override init() { }

    private let baseURLAPI = "https://wifi-nav-api.herokuapp.com"

    func getEdges(for locationID: Int) -> [Edge]? {
        do {
            let config = try Config()
            try config.setup()

            let drop = try Droplet(config)
            try drop.setup()

            let urlString = "\(baseURLAPI)/locationConnections/id/\(locationID)"
            let response = try drop.client.get(urlString)
            if response.status == Status.ok {
                let locations = try response.decodeJSONBody([Edge].self)
                return locations
            }
        } catch {
            print(error)
            print(error.localizedDescription)
        }
        return nil
    }

    func fetchAllLocations() -> [Location]? {
        do {
            let config = try Config()
            try config.setup()

            let drop = try Droplet(config)
            try drop.setup()

            let urlString = "\(baseURLAPI)/locations"
            let response = try drop.client.get(urlString)
            if response.status == Status.ok {
                let locations = try response.decodeJSONBody([Location].self)
                return locations
            }
        } catch {
            print(error)
            print(error.localizedDescription)
        }
        return nil
    }

    func fetchLocation(with id: Int) -> Location? {
        do {
            let config = try Config()
            try config.setup()
    
            let drop = try Droplet(config)
            try drop.setup()

            let urlString = "\(baseURLAPI)/locations/\(id)"
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
}