//
//  Slack.swift
//  App
//
//  Created by Petro Rovenskyy on 10/29/18.
//

import Vapor

struct SlackAuthAccess: Content  {
    let clientId: String
    let clientSecret: String
    let code: String
    let redirectURI: String?
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case code = "code"
        case redirectURI = "redirect_uri"
    }
}

struct SlackAuthCode: Content {
    let code: String
    let state: String
}

struct SlackAuthTokenBot: Content  {
    let botUserId: String
    let botAccessToken: String
    
    enum CodingKeys: String, CodingKey {
        case botUserId = "bot_user_id"
        case botAccessToken = "bot_access_token"
    }
}

struct IncomingWebHook: Content {
    let channel: String
    let channelId: String
    let configurationURL: String
    let url: String
    enum CodingKeys: String, CodingKey {
        case channel = "channel"
        case channelId = "channel_id"
        case configurationURL = "configuration_url"
        case url = "url"
    }
}


struct SlackAuthToken: Content  {
    let accessToken: String
    let scope: String
    let teamName: String
    let teamId: String
    let webHook: IncomingWebHook
    let bot: SlackAuthTokenBot
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope = "scope"
        case teamName = "team_name"
        case teamId = "team_id"
        case webHook = "incoming_webhook"
        case bot = "bot"
    }
}

struct SlackChallenge: Content {
    let token: String
    let challenge: String
    let type: String
}


public struct SlackConversAttachmentField: Content {
    public let title: String
    public let value: String
    public let short: Bool
}

public struct SlackConversAttachment: Content {
    public let color: String
    public let title: String
    public let text: String
    public let fields: [SlackConversAttachmentField]?
}


struct SlackConversMessage: Content {
    let channel: String
    let text: String
    let attachments: [SlackConversAttachment]?
    let mrkdwn: Bool = true
    let asUser: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case channel = "channel"
        case text = "text"
        case attachments = "attachments"
        case mrkdwn = "mrkdwn"
        case asUser = "as_user"
    }
}

struct SlackEvent: Content {
    let token: String
    let teamId: String
    let apiAppId: String
    let event: SlackEventMessage
    let type: String
    let eventId: String
    let eventTime: Int
    let authedUsers: [String]
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case teamId = "team_id"
        case apiAppId = "api_app_id"
        case event = "event"
        case type = "type"
        case eventId = "event_id"
        case eventTime = "event_time"
        case authedUsers = "authed_users"
    }
}

struct SlackEventMessage: Content {
    let type: String
    let channel: String
    let user: String
    let text: String
    let ts: String
    let eventTs: String
    let channelType: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case channel = "channel"
        case user = "user"
        case text = "text"
        case ts = "ts"
        case eventTs = "event_ts"
        case channelType = "channel_type"
    }
}


