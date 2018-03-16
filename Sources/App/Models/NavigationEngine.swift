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

final class NavigationEngine: NSObject {
    static let shared = NavigationEngine()

    private override init() { }

    private var edges = [Int: [Int]]()
    private var locations = [Location]()

    private var prev = [Int: Int]()
    private var visited = [Int: Bool]()
    private var distance = [Int: Double]()

    private let INF = 9999999999999999999.0

    func createGraph() {
        guard let locations = NetworkingHelper.shared.fetchAllLocations() else { return }
        self.locations = locations

        prev = [Int: Int]()
        visited = [Int: Bool]()
        distance = [Int: Double]()

        for location in locations {
            let id = location.id
            distance[id] = INF
            prev[id] = 0

            guard let currentEdges = NetworkingHelper.shared.getEdges(for: location.id) else { continue }

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
        var minimumDist = INF
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
        var prev = [Int: Int]()
        var visited = [Int: Bool]()
        var distance = [Int: Double]()

        print("Start: \(start)")
        print("Finish: \(finish)")

        guard let startLocation = NetworkingHelper.shared.fetchLocation(with: start) else { return nil }
        guard let finishLocation = NetworkingHelper.shared.fetchLocation(with: finish) else { return nil }

        distance[startLocation.id] = 0
        visited[startLocation.id] = true

        var queue = Heap.init { (a: Int, b: Int) -> Bool in
            var dist1 = 9999999999999999999.0
            var dist2 = 9999999999999999999.0

            if let unwrapped = distance[a] {
                dist1 = unwrapped
            }
            
            if let unwrapped = distance[b] {
                dist2 = unwrapped
            }

            return dist1 < dist2
        }
        queue.insert(start)

        while(!queue.isEmpty) {
            guard let node = queue.remove() else { break }
            visited[node] = false
            if let edges = edges[node] {
                for neighbour in edges {
                    if let dist = distance[node] {
                        let alt = dist + getDistance(from: node, to: neighbour)
                        if let neighbourDistance = distance[neighbour] {
                            if alt < neighbourDistance {
                                distance[neighbour] = alt
                                prev[neighbour] = node
                                queue.insert(neighbour)
                            }
                        } else {
                            distance[neighbour] = INF
                        }
                    } else {
                        distance[node] = 0
                    }
                }
            }
        }

        print(prev)
        print(distance)
        return createPath(parentsList: prev, distances: distance, start: startLocation.id, finish: finishLocation.id)
    }

    func createPath(parentsList: [Int: Int], distances: [Int: Double], start: Int, finish: Int) -> [String: Any]? {
        if distances[finish] == INF {
            return [
                "sucess": false
            ]
        }
        var path = [Int]()
        var currentNode = finish
        path.append(currentNode)
        while (currentNode != start) {
            if parentsList[currentNode] != nil {
                path.append(parentsList[currentNode]!)
                currentNode = parentsList[currentNode]!
            }
        }
        
        return [
            "success": true,
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
}
