import Vapor
import Foundation
@testable import Vapor
@testable import App

final class MockHTTPClient: NetworkingHelper {
    var locations: [Location]!
    var edges: [Edge]!
    var coordinates = [
        (38.1156879, 13.361267099999964),
        (29.4241219, -98.49362819999999),
        (6.1167855, 102.27768379999998),
        (46.9479739, 7.447446799999966)
    ]

    // 1 to 2 is 8988.885 km
    // 1 to 3 is 9496.686 km
    // 2 to 3 is 15487.246 km
    // 3 to 4 is 9878.702 km
    // all values are approximate

    override init() {
        super.init()
        locations = [Location]()
        edges = [Edge]()
        self.generateMockData()
    }

    // TO IMPLEMENT: getEdges, fetchAllLocations, fetchLocation

    private func generateMockData() {
        for index in 0...3 {
            var location = Location.init()
            location.id = index
            location.latitude = coordinates[index].0
            location.longitude = coordinates[index].1
            locations.append(location)
        }

        var firstEdgeOne = Edge.init()
        firstEdgeOne.rootLocationID = 0
        firstEdgeOne.childLocationID = 1

        var firstEdgeRev = Edge.init()
        firstEdgeRev.rootLocationID = 1
        firstEdgeRev.childLocationID = 0

        var secondEdgeOne = Edge.init()
        secondEdgeOne.rootLocationID = 1
        secondEdgeOne.childLocationID = 2

        var secondEdgeRev = Edge.init()
        secondEdgeRev.rootLocationID = 2
        secondEdgeRev.childLocationID = 1

        var thirdEdgeOne = Edge.init()
        thirdEdgeOne.rootLocationID = 0
        thirdEdgeOne.childLocationID = 2

        var thirdEdgeRev = Edge.init()
        thirdEdgeRev.rootLocationID = 2
        thirdEdgeRev.childLocationID = 0

        var fourthEdgeOne = Edge.init()
        fourthEdgeOne.rootLocationID = 2
        fourthEdgeOne.childLocationID = 3

        var fourthEdgeOneRev = Edge.init()
        fourthEdgeOneRev.rootLocationID = 3
        fourthEdgeOneRev.childLocationID = 2

        edges.append(firstEdgeOne)
        edges.append(firstEdgeRev)
        edges.append(secondEdgeOne)
        edges.append(secondEdgeRev)
        edges.append(thirdEdgeOne)
        edges.append(thirdEdgeRev)
        edges.append(fourthEdgeOne)
        edges.append(fourthEdgeOneRev)
    }

    // The implementation for this method was taken from https://stackoverflow.com/a/40375860/1464828
    private func randomNumber(range: ClosedRange<Int> = 1...6) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }

    override func fetchAllLocations() -> [Location]? {
        return locations
    }

    override func fetchLocation(with id: Int) -> Location? {
        return locations[id]
    }

    override func getEdges(for locationID: Int) -> [Edge]? {
        var toReturn = [Edge]()
        for edge in edges {
            if edge.rootLocationID == locationID || edge.childLocationID == locationID {
                toReturn.append(edge)
            }
        }
        return toReturn
    }
}