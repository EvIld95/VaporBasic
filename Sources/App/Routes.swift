import Vapor
import AuthProvider
import Sessions

final class Routes: RouteCollection {
    let view: ViewRenderer
    let authRoutes : RouteBuilder
    let loginRouteBuilder : RouteBuilder
    let mc: MainController
    
    init(_ view: ViewRenderer, drop: Droplet) {
        self.view = view
        mc = MainController(drop: drop)
        let passwordMiddleware = PasswordAuthenticationMiddleware(User.self)
        let memory = MemorySessions()
        let persistMiddleware = PersistMiddleware(User.self)
        let sessionsMiddleware = SessionsMiddleware(memory)
        self.authRoutes = drop.grouped([sessionsMiddleware, persistMiddleware, passwordMiddleware])
        self.loginRouteBuilder = drop.grouped([sessionsMiddleware, persistMiddleware])
    }

    func build(_ builder: RouteBuilder) throws {
        
        let groupedMain = authRoutes.grouped("")
        groupedMain.get(handler: mc.index)
        groupedMain.get("index", handler: mc.index)
        groupedMain.get("categories", handler: mc.categories)
        groupedMain.get("details", handler: mc.details)
        groupedMain.get("posts", handler: mc.posts)
        groupedMain.get("profile", handler: mc.profile)
        groupedMain.get("settings", handler: mc.settings)
        groupedMain.get("users", handler: mc.users)
        groupedMain.post("createCategory", handler: mc.createCategory)
        groupedMain.post("createPost", handler: mc.createPost)
        
        builder.get("login", handler: mc.login)
        builder.get("register", handler: mc.register)
        loginRouteBuilder.post("login") { (req) -> ResponseRepresentable in
            guard let email = req.formURLEncoded?["email"]?.string, let password = req.formURLEncoded?["password"]?.string else {
                return "Bad Credentials"
            }
            
            let credentials = Password(username: email, password: password)
            let user = try User.authenticate(credentials)
            req.auth.authenticate(user)
            
            return Response(redirect: "/")
        }
        
        loginRouteBuilder.post("register") { (req) -> ResponseRepresentable in
            guard let name = req.formURLEncoded?["name"]?.string, let email = req.formURLEncoded?["email"]?.string, !email.isEmpty, let password = req.formURLEncoded?["password"]?.string, !password.isEmpty else {
                return "Bad Credentials"
            }
            
            let bcrypt = BCryptHasher(cost: 8)
            let hash = try! bcrypt.make(password)
            //let correct = try! bcrypt.check(password.makeBytes(), matchesHash: hash)
            
            
            let user = User(name: name, email: email, password: hash.makeString())
            try user.save()
            
            req.auth.authenticate(user)
            
            return Response(redirect: "/")
        }
        
        builder.get("postInfo", Post.parameter) { (req) -> ResponseRepresentable in
            let post = try req.parameters.next(Post.self)
            let email = try! post.author.get()?.email
            let category = try! post.category.get()?.categoryName
            return "Post \(post.title) , \(email!), \(category!)"
        }
        
        builder.get("info") { req in
            return req.description
        }
        
    }
}
