//  Created by Adir Burke on 5/1/2024.
//

import Vapor


public final class HeaderCodeAuth : Middleware {
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let header = request.headers.first(name: "auth") else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        guard header == "J1VD9qLE7kw;EU?t^z\"=Q36aajK" else {
            return request.eventLoop.makeFailedFuture(Abort(.unauthorized))
        }
        return next.respond(to: request)
    }
    
    public init() {}
}
