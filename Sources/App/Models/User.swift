//
//  User.swift
//  connectBootstrapVapor
//
//  Created by Paweł Szudrowicz on 01.11.2017.
//

import Foundation
import Vapor
import PostgreSQLProvider
import AuthProvider
import FluentProvider

//
final class User: Model, PasswordAuthenticatable, SessionPersistable {
    let storage = Storage()
    
    var name: String = ""
    var email: String = ""
    var password: String = ""
    
    
    public static var passwordVerifier: PasswordVerifier? {
        return BCryptHasher(cost: 8)
    }
    
    public var hashedPassword: String? {
        return password
    }
    
    init(name:String, email:String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("email", email)
        try row.set("password", password)
        return row
    }
    
    required init(row: Row) throws {
        name = try row.get("name")
        email = try row.get("email")
        password = try row.get("password")
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("email")
            builder.string("password")
        }
    }
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(name: json.get("name"), email: json.get("email"), password: json.get("password"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("email", email)
        try json.set("password", password)
        try json.set("created_at", createdAt)
        try json.set("updated_at", updatedAt)
        return json
    }
}

extension User: ResponseRepresentable { }
extension User: Timestampable {}
