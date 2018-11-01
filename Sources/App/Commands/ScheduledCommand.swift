//
//  ScheduledCommand.swift
//  App
//
//  Created by Petro Rovenskyy on 10/29/18.
//

import Vapor
import Console
import HTTP

struct ScheduledCommand: Command {
    var help: [String] = [
        "This command will run every time envirment unavailbe"
    ]
    var arguments: [CommandArgument] = [.argument(name: "message")]
    var options: [CommandOption] = []
    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let text: String = try context.argument("message")
        let client: Client = try context.container.client()
        let _ = try context.container.make(APIKeyStorage.self)
        return .done(on: context.container)
    }
}
