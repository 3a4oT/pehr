//
//  APIKeyStorage.swift
//  App
//
//  Created by Petro Rovenskyy on 10/30/18.
//

import Vapor

extension Environment {
    fileprivate static func valueForKey(key: String) -> String {
        guard let value = Environment.get(key)
            else { fatalError("\(key) not set in environment variable") }
        return value
    }
}

extension Environment {
    static var slackClientID: String {
        return valueForKey(key: "SLACK_CLIENT_ID")
    }
    static var slackClientSecret: String {
        return valueForKey(key: "SLACK_CLIENT_SECRET")
    }
    static var envURL: String {
        return valueForKey(key: "ENV_URL")
    }
    static var envPath: String {
        return valueForKey(key: "ENV_PATH")
    }
}

struct EnvHealthConfig: Service, Content {
    let url: URL
    init(url: URL) {
        self.url = url
    }
}

struct APIKeyStorage: Service, Codable {
    let clientId: String
    let clientSecret: String
    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
}
