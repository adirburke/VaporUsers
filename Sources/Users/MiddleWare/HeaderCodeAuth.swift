//  Created by Adir Burke on 5/1/2024.
//

import Vapor


public final class HeaderCodeAuth : Middleware {
    let authCode : String
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let header = request.headers.first(name: "auth") else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        guard header == authCode else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        return next.respond(to: request)
    }
    
    public init(_ authCode : String) {
        self.authCode = authCode
    }
}
