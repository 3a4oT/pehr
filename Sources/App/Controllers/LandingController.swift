//
//  LandingController.swift
//  App
//
//  Created by Petro Rovenskyy on 10/31/18.
//

import Vapor
import Async
import Leaf

final class LandingController {
    func index(_ req: Request) throws -> Future<View> {
        let leaf = try req.make(LeafRenderer.self)
        let storage = try req.sharedContainer.make(APIKeyStorage.self)
        let config = try req.sharedContainer.make(EnvHealthConfig.self)
        let context:[String: String] = ["slack_client_id": storage.clientId,
                                        "env": config.url.absoluteString]
        return leaf.render("index", context)
    }
}
