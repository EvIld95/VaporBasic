//
//  Post.swift
//  connectBootstrapVapor
//
//  Created by Paweł Szudrowicz on 03.11.2017.
//

import Foundation
import Vapor
import PostgreSQLProvider
import FluentProvider

final class Post: Model {
    let storage = Storage()
    
    var title: String = ""
    var text: String = ""
    var fileName: String? = nil
    
    private var categoryId: Identifier = 0
    private var userId: Identifier = 0
    
    var author: Parent<Post, User> {
        return parent(id: userId)
    }
    
    var category: Parent<Post, Category> {
        return parent(id: categoryId)
    }
    
    init(title: String, text: String, fileName: String?, category: Identifier, user: Identifier) {
        self.title = title
        self.text = text
        self.fileName = fileName
        self.categoryId = category
        self.userId = user
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("text", text)
        try row.set("fileName", fileName)
        try row.set("category_id", categoryId)
        try row.set("user_id", userId)
        return row
    }
    
    required init(row: Row) throws {
        title = try row.get("title")
        text = try row.get("text")
        fileName = try row.get("fileName")
        
        categoryId = try row.get("category_id")
        userId = try row.get("user_id")
    }
}

extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("title")
            builder.string("text")
            builder.bytes("fileName", optional: true)
            builder.foreignId(for: Category.self)
            builder.foreignId(for: User.self)
        }
    }
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Post: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(title: json.get("title"), text: json.get("text"), fileName: nil, category: json.get("category_id"), user: json.get("user_id"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("title", title)
        try json.set("text", text)
        try json.set("category_id", categoryId)
        try json.set("user_id", userId)
        try json.set("created_at", createdAt)
        try json.set("updated_at", updatedAt)
        return json
    }
}

extension Post: ResponseRepresentable { }
extension Post: Timestampable { }
