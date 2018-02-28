import Vapor
import HTTP
import Foundation

struct Location: Decodable {
    let x: Double
    let y: Double
    let latitude: Double
    let longitude: Double
    let standardWidth: Double
    let standardHeight: Double
    let roomID: Int
    let id: Int

    init() {
        x = 0.0
        y = 0.0
        latitude = 0.0
        longitude = 0.0
        standardWidth = 0.0
        standardHeight = 0.0
        roomID = 0
        id = 0
    }
}

struct Edge: Decodable {
    let rootLocationID: Int
    let childLocationID: Int
}

public struct Queue<T> {
    fileprivate var array = [T]()

    public var isEmpty: Bool {
        return array.isEmpty
    }

    public var count: Int {
        return array.count
    }

    public mutating func enqueue(_ element: T) {
        array.append(element)
    }

    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }

    public var front: T? {
        return array.first
    }
}

final class NavigationEngine: NSObject {
    static let shared = NavigationEngine()

    private override init() { }

    private let baseURLAPI = "https://wifi-nav-api.herokuapp.com"
    private var edges = [Int: [Int]]()
    private var locations = [Location]()

    func createGraph() {
        guard let locations = fetchAllLocations() else { return }
        self.locations = locations
        for location in locations {
            guard let currentEdges = getEdges(for: location.id) else { continue }

            for edge in currentEdges {
                if edges[edge.rootLocationID] == nil {
                    edges[edge.rootLocationID] = [Int]()
                }

                edges[edge.rootLocationID]!.append(edge.childLocationID)
            }
        }
    }

    func getMinimumDistanceElement(in array: [Int], with distances: [Int: Double]) -> (Int, Int) {
        var minimumElement = 0
        var minimumDist = 9999999999999999999.0
        for element in array {
            if minimumDist > distances[element]! {
                minimumDist = distances[element]!
                minimumElement = element
            }
        }
        let index = array.index(of: minimumElement)
        return (minimumElement, index!)
    }

    func shortestPath(start: Int, finish: Int) -> [String: Any]? {
        createGraph()
        print(edges)
        var prev = [Int: Int]()
        var visited = [Int: Bool]()
        var distance = [Int: Double]()

        for location in locations {
            let id = location.id
            distance[id] = 9999999999999999999
            prev[id] = 0
        }

        guard let startLocation = fetchLocation(with: start) else { return nil }
        guard let finishLocation = fetchLocation(with: finish) else { return nil }

        var q = [Int]()
        distance[startLocation.id] = 0
        visited[startLocation.id] = true
        q.append(start)

        while(q.count != 0) {
            let currentPair = getMinimumDistanceElement(in: q, with: distance)
            let node = currentPair.0
            q.remove(at: currentPair.1)

            visited[node] = false
            for neighbour in edges[node]! {
                let alt = distance[node]! + getDistance(from: node, to: neighbour)
                if alt < distance[neighbour]! {
                    distance[neighbour] = alt
                    prev[neighbour] = node
                    q.append(neighbour)
                }
            }
        }

        print(prev)
        print(distance)
        return createPath(parentsList: prev, distances: distance, start: startLocation.id, finish: finishLocation.id)
    }

    func createPath(parentsList: [Int: Int], distances: [Int: Double], start: Int, finish: Int) -> [String: Any]? {
        var path = [Int]()
        var currentNode = finish
        path.append(currentNode)
        while (currentNode != start) {
            path.append(parentsList[currentNode]!)
            currentNode = parentsList[currentNode]!
        }

        if path[path.count - 1] != start {
            return nil
        }
        
        return [
            "distance": distances[finish]!,
            "path": path.reversed() as [Int]
        ] as [String: Any]
    }

    func getDistance(from id1: Int, to id2: Int) -> Double {
        var firstLocation = Location()
        var secondLocation = Location()
        
        for location in locations {
            if location.id == id1 {
                firstLocation = location
            }
        }

        for location in locations {
            if location.id == id2 {
                secondLocation = location
            }
        }

        return Utils.haversineDinstance(la1: firstLocation.latitude, lo1: firstLocation.longitude, la2: secondLocation.latitude, lo2: secondLocation.longitude)
    }

    func getEdges(for locationID: Int) -> [Edge]? {
        do {
            let config = try Config()
            try config.setup()

            let drop = try Droplet(config)
            try drop.setup()

            let urlString = "\(baseURLAPI)/locationConnections/id/\(locationID)"
            let response = try drop.client.get(urlString)
            print(response)
            if response.status == Status.ok {
                let locations = try response.decodeJSONBody([Edge].self)
                print(locations)
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
