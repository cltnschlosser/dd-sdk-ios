/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation

internal struct UserInfo: Codable {
    /// User ID, if any.
    internal let id: String?
    /// Name representing the user, if any.
    internal let name: String?
    /// User email, if any.
    internal let email: String?
    /// User custom attributes, if any.
    internal var extraInfo: [AttributeKey: AttributeValue]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
    }

    init(
        id: String? = nil,
        name: String? = nil,
        email: String? = nil,
        extraInfo: [AttributeKey: AttributeValue] = [:]
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.extraInfo = extraInfo
    }

    func encode(to encoder: Encoder) throws {
        // Encode static properties:
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(email, forKey: .email)

        // Encode dynamic properties:
        var dynamicContainer = encoder.container(keyedBy: DynamicCodingKey.self)
        try extraInfo.forEach {
            let key = DynamicCodingKey($0)
            try dynamicContainer.encode(CodableValue($1), forKey: key)
        }
    }

    init(from decoder: Decoder) throws {
        // Decode static properties:
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)

        // Decode other properties into [String: Codable] dictionary:
        let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        self.extraInfo = try dynamicContainer.allKeys
            .filter { CodingKeys(stringValue: $0.stringValue) == nil }
            .reduce(into: [:]) {
                $0[$1.stringValue] = try dynamicContainer.decode(CodableValue.self, forKey: $1)
            }
    }
}

extension UserInfo {
    internal static var empty: Self { .init() }
}
