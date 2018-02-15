//
//  Category.swift
//  connectBootstrapVaporPackageDescription
//
//  Created by Paweł Szudrowicz on 03.11.2017.
//

import Foundation
import Vapor
import PostgreSQLProvider
import FluentProvider

final class Category: Model {
    let storage = Storage()
    
    var categoryName: String = ""
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("categoryName", categoryName)
        return row
    }
    
    required init(row: Row) throws {
        categoryName = try row.get("categoryName")
    }
}

extension Category: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("categoryName")
        }
    }
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Category: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(categoryName: json.get("categoryName"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("categoryName", categoryName)
        return json
    }
}

extension Category: ResponseRepresentable { }
