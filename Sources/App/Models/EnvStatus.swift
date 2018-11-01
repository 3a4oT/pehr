//
//  EnvStatus.swift
//  App
//
//  Created by Petro Rovenskyy on 11/1/18.
//

import Vapor
import FluentSQLite

public extension Formatter {
    static let iso8601DateTimeWithoutZ: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}


struct EnvStatus: Content, Model {
    typealias ID = String
    typealias Database = SQLiteDatabase
    static var idKey: WritableKeyPath<EnvStatus, String?> { return \.check }
    var check: String?
    var isAlive: Bool
    var checkDate: Date? {
        guard let lastCheck: String = self.check else {
            return nil
        }
        return Formatter.iso8601DateTimeWithoutZ.date(from: lastCheck)
    }
    init(check at: Date = Date(), isAlive: Bool = true ) {
        let ftm = Formatter.iso8601DateTimeWithoutZ
        self.check = ftm.string(from: at)
        self.isAlive = isAlive
    }
}

extension EnvStatus: Migration {}
