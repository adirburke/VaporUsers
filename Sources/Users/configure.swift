//  Created by Adir Burke on 5/1/2024.
//

import Foundation
import Vapor

public func configure(_ app: Application) async throws {
    if !app.databases.ids().contains(.psql) {
        let hostname = Environment.get("DATABASE_HOST") ?? "localhost"
        let port = Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432
        let username = Environment.get("DATABASE_USERNAME") ?? "app"
        let database = Environment.get("DATABASE_NAME") ?? "users"
        
        app.databases.use(.postgres(configuration: .init(
            hostname: hostname,
            port: port,
            username: username,
            password: Environment.get("DATABASE_PASSWORD") ?? "qwerty",
            database: database, tls: .disable
        )), as: .psql)
    }

    app.migrations.add(CreateUser())
    app.migrations.add(UserToken.Migration())
    

}
