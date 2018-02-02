import Vapor
import FluentProvider

final class Location: Model {
    let storage = Storage()
    
    static let idType: IdentifierType = .int
    var x: Double
    var y: Double
    var roomID: Int

    struct Keys {
        static let id = "id"
        static let x = "x"
        static let y = "y"
        static let roomID = "roomID"
    }

    init(row: Row) throws {
        x = try row.get("x")
        y = try row.get("y")
        roomID = try row.get("roomID")
    }

    init(x: Double, y: Double, roomID: Int) {
        self.x = x
        self.y = y
        self.roomID = roomID
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("x", x)
        try row.set("y", y)
        try row.set("roomID", roomID)
        return row
    }
}

extension Location: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { locations in
            locations.id()
            locations.double("x")
            locations.double("y")
            locations.int("roomID")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Location: ResponseRepresentable { }

extension Location: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(Location.Keys.id, id)
        try toReturn.set(Location.Keys.x, x)
        try toReturn.set(Location.Keys.y, y)
        try toReturn.set(Location.Keys.roomID, roomID)

        return toReturn
    }
}

extension Location: JSONInitializable {
    convenience init(json: JSON) throws {
        let x: Double = try json.get(Location.Keys.x)
        let y: Double = try json.get(Location.Keys.y)
        let roomID: Int = try json.get(Location.Keys.roomID)
        self.init(x: x, y: y, roomID: roomID)
    }
}