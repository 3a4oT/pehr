//
//  EnvHealthBot.swift
//  App
//
//  Created by Petro Rovenskyy on 10/31/18.
//

import Vapor
import Fluent
import FluentSQL
import FluentSQLite

enum EnvHealthBotError: Error {
    case notRegister
    case slackWebApiError
}

protocol EnvHealthBotFeature {
    var event: SlackEvent { get }
    func execute(on container: Container) -> EventLoopFuture<[EnvHealthBotMessage]>
}

extension EnvHealthBot {
    static let slackChatPostMessageURL = "https://slack.com/api/chat.postMessage"
    static let color = "#DAE55C"
}

extension EnvHealthBot {
    func sendMessage(messages: [EnvHealthBotMessage], channel: String,  on container: Container) -> EventLoopFuture<[HTTPResponse]> {
        let slackMessages = messages.map { self.createMessage(message: $0, channel: channel) }
        return self.askToken(channel: channel, on: container).flatMap { (token) -> EventLoopFuture<[HTTPResponse]> in
            return slackMessages.map { self.sendSlackMessage(message: $0, token: token, container: container) }.flatten(on: container)
        }
    }
    
    func sendSlackMessage(message: SlackConversMessage, token: String, container: Container) -> EventLoopFuture<HTTPResponse> {
        do {
            return try container.client().post(EnvHealthBot.slackChatPostMessageURL) {
                try $0.content.encode(message)
                $0.http.headers.add(name: .authorization, value: "Bearer \(token)")
                $0.http.headers.add(name: .keepAlive, value: "timeout=2, max=1000")
                }.map { $0.http }
        } catch {
            return container.future(error: error)
        }
    }
    
}


extension EnvHealthBot {
    fileprivate func askToken(channel: String, on container: Container) -> EventLoopFuture<String> {
        return container.withPooledConnection(to: .sqlite) { (connection) -> EventLoopFuture<String> in
            return BotRegistration
                .query(on: connection)
                .filter(\BotRegistration.webHook.channel == channel)
                .first().map { $0?.botAccessToken }
                .unwrap(or: EnvHealthBotError.notRegister)
        }
    }
    
    fileprivate func createMessage(message: EnvHealthBotMessage, channel: String) -> SlackConversMessage {
        let attachments = message.attachments?.compactMap { SlackConversAttachment(attachment: $0) }
        return SlackConversMessage(channel: channel, text: message.text, attachments: attachments)
    }
}


fileprivate extension SlackConversAttachment {
    fileprivate init(attachment: EnvHealthBotAttachment) {
        self.text = attachment.text ?? ""
        self.title = attachment.title ?? ""
        self.color = EnvHealthBot.color
        self.fields = attachment.fields?.compactMap { SlackConversAttachmentField(field: $0) }
    }
}

fileprivate extension SlackConversAttachmentField {
    fileprivate init(field: EnvHealthBotAttachmentField) {
        self.short = field.short
        self.title = field.title
        self.value = field.value
    }
}

struct EnvHealthBotAttachmentField {
    public let title: String
    public let value: String
    public let short: Bool
}

struct EnvHealthBotAttachment {
    public let title: String?
    public let text: String?
    public let fields: [EnvHealthBotAttachmentField]?
}

struct EnvHealthBotMessage {
    let text: String
    let attachments: [EnvHealthBotAttachment]?
}

struct EnvHealthBot: ServiceType {
    static func makeService(for worker: Container) throws -> EnvHealthBot { return EnvHealthBot() }
}

