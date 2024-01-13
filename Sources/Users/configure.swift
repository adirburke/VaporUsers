//  Created by Adir Burke on 5/1/2024.
//

import Foundation
import Vapor

public func configure(_ app: Application) async throws {
    app.migrations.add(CreateUser())
    app.migrations.add(UserToken.Migration())
}
