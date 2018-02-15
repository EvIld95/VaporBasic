@_exported import Vapor

extension Droplet {
    public func setup() throws {
        let routes = Routes(view, drop: self)
        try collection(routes)
    }
}

