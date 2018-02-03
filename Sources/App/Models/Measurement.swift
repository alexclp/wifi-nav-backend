import Vapor
import HTTP
import FluentProvider

final class Measurement: Model {
    let storage = Storage()
    
    static let idType: IdentifierType = .int
    var signalStrength: Int
    var macAddress: String 
    var networkName: String

    struct Keys {
        static let id = "id"
        static let signalStrength = "signalStrength"
        static let macAddress = "macAddress"
        static let networkName = "networkName"
    }

    init(row: Row) throws {
        signalStrength = try row.get("signalStrength")
        macAddress = try row.get("macAddress")
        networkName = try row.get("networkName")
    }

    init(signalStrength: Int, macAddress: String, networkName: String) {
        self.signalStrength = signalStrength
        self.macAddress = macAddress
        self.networkName = networkName
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("signalStrength", signalStrength)
        try row.set("macAddress", macAddress)
        try row.set("networkName", networkName)
        return row
    }
}

extension Measurement: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { measurement in
            measurement.id()
            measurement.int("signalStrength")
            measurement.string("macAddress")
            measurement.string("networkName")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Measurement: ResponseRepresentable { }

extension Measurement: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(Measurement.Keys.id, id)
        try toReturn.set(Measurement.Keys.signalStrength, signalStrength)
        try toReturn.set(Measurement.Keys.macAddress, macAddress)
        try toReturn.set(Measurement.Keys.networkName, networkName)

        return toReturn
    }
}

extension Measurement: JSONInitializable {
    convenience init(json: JSON) throws {
        let signalStrength: Int = try json.get(Measurement.Keys.signalStrength)
        let macAddress: String = try json.get(Measurement.Keys.macAddress)
        let networkName: String = try json.get(Measurement.Keys.networkName)
        self.init(signalStrength: signalStrength, macAddress: macAddress, networkName: networkName)
    }
}