//
//  ReportController.swift
//  App
//
//  Created by Petro Rovenskyy on 11/1/18.
//

import Vapor
import HTTP
import Leaf
import Fluent

final class ReportController {
    func index(_ req: Request) throws -> Future<[String]> {
        return BotRegistration.query(on: req).all().map(to: [String].self, { (registered) -> [String] in
            return registered.map({$0.webHook.channel})
        })
    }
    func report(status req: Request) throws -> EventLoopFuture<HTTPResponse> {
        return BotRegistration.query(on: req).all().flatMap { (registered) -> EventLoopFuture<HTTPResponse> in
            return try req.content.decode(EnvStatus.self).flatMap({ (newStatus) -> EventLoopFuture<HTTPResponse> in
                return  EnvStatus.query(on: req).first().flatMap({ (lastStatus) -> EventLoopFuture<HTTPResponse> in
                    let wasAlive: Bool = lastStatus?.isAlive ?? true
                    if newStatus.isAlive == wasAlive {
                        return  req.next().newSucceededFuture(result: HTTPResponse(status: .noContent))
                    }
                    let registered: BotRegistration = registered.first!
                    let msg = SlackConversMessage(channel: registered.webHook.channel, text: "Redeploy Vasa", attachments: nil)
                    let bot: EnvHealthBot = try req.sharedContainer.make(EnvHealthBot.self)
                    return newStatus.save(on: req).flatMap({ (_) -> EventLoopFuture<HTTPResponse> in
                        return bot.sendSlackMessage(message: msg, token: registered.botAccessToken, container: req)
                    })
                })
            })
        }
    }
}
