//
//  BotRegistration.swift
//  App
//
//  Created by Petro Rovenskyy on 10/31/18.
//

import Vapor
import FluentSQLite

struct BotRegistration: Content, Model {
    typealias ID = String
    
    typealias Database = SQLiteDatabase
    static var idKey: WritableKeyPath<BotRegistration, String?> { return \.teamId }
    
    var teamId: String?
    var accessToken: String
    var scope: String
    var teamName: String
    var botUserId: String
    var botAccessToken: String
    var webHook: IncomingWebHook
    
    init(with authToken: SlackAuthToken) {
        self.accessToken = authToken.accessToken
        self.scope = authToken.scope
        self.teamName = authToken.teamName
        self.teamId = authToken.teamId
        self.botUserId = authToken.bot.botUserId
        self.botAccessToken = authToken.bot.botAccessToken
        self.webHook = authToken.webHook
    }
}

extension BotRegistration: Migration {}
