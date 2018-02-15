import Vapor
import HTTP
import Foundation

/// Here we have a controller that helps facilitate
/// creating typical REST patterns
final class MainController {
    let drop: Droplet
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("index", [], for: req)
    }
    
    /// GET /login
    func login(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    
    /// GET /register
    func register(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("registration")
    }
    
    /// GET /categories
    func categories(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("categories")
    }
    
    /// GET /details
    func details(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("details")
    }
    
    /// GET /posts
    func posts(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("posts")
    }
    
    /// GET /profile
    func profile(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("profile")
    }
    
    /// GET /settings
    func settings(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("settings")
    }
    
    /// GET /users
    func users(req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("users")
    }
    
    func createCategory(req: Request) throws -> ResponseRepresentable {
        guard let categoryName = req.formURLEncoded?["title"]?.string, !categoryName.isEmpty else {
            throw Abort.badRequest
        }
        
        let category = Category(categoryName: categoryName)
        var success = false
        if let _ = (try? category.save()) {
            success = true
        } else {
            success = false
        }
 
        return try drop.view.make("index", ["success": success, "name": "Category"])
    }
    
    func createPost(req: Request) throws -> ResponseRepresentable {
        guard let title = req.formData?["title"]?.string, let category = req.formData?["category"]?.string,
             let text = req.formData?["editor1"]?.string, !title.isEmpty else {
                return try drop.view.make("index", ["success": 0, "name": "Post"])
        }
        let file = req.formData?["file"]?.bytes
        let data = Data(bytes: (file)!)
        let fileName = UUID().uuidString + ".png"
        try data.write(to: URL(fileURLWithPath: "/Users/pawelszudrowicz/Desktop/images/\(fileName)"))
        
        let categoryId = Identifier(.string(category))
        let post = Post(title: title, text: text, fileName: fileName, category: categoryId, user: req.auth.authenticated(User.self)!.id!)
        
        var success = 0
        if let _ = (try? post.save()) {
            success = 1
        } else {
            success = 0
        }
        
        return try drop.view.make("index", ["success": success, "name": "Post"])
    }
    
    
}
