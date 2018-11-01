//
//  SlackAuthController.swift
//  App
//
//  Created by Petro Rovenskyy on 10/31/18.
//

import Vapor
import HTTP
import Leaf
import Fluent

fileprivate let slackOauth: String = "https://slack.com/api/oauth.access"

final class SlackAuthController {
    func oauthAuthorize(_ req:Request) throws -> EventLoopFuture<View> {
        let slackClientID = Environment.slackClientID
        let slackClientSecret = Environment.slackClientSecret
        let code = try req.query.decode(SlackAuthCode.self)
        let access = SlackAuthAccess(clientId: slackClientID, clientSecret: slackClientSecret, code: code.code, redirectURI: nil)
        return try req.client().get(slackOauth) { (request) in
            try request.query.encode(access)
            }.flatMap { (response) -> EventLoopFuture<SlackAuthToken> in
                return try response.content.decode(SlackAuthToken.self)
            } .flatMap { (authToken) -> EventLoopFuture<BotRegistration> in
                return req.withPooledConnection(to: .sqlite) { (connection) -> EventLoopFuture<BotRegistration> in
                    return BotRegistration(with: authToken).create(on: connection).thenIfError { _ in
                        return BotRegistration(with: authToken).save(on: connection)
                    }
                }
            }.flatMap { botRegistration in
                let leaf = try req.make(LeafRenderer.self)
                let logger = try req.make(Logger.self)
                logger.verbose(botRegistration.teamName)
                logger.verbose(botRegistration.scope)
                return leaf.render("success", botRegistration)
        }
    }
}
