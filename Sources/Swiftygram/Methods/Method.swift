//
// Created by Zap on 07.08.2018.
//

import Foundation

enum APIMethodError: Error {
    case baseUrlCompositionFailure
}

struct APIMethod {

    struct GetUpdates: Endpoint, Encodable {
        let offset:         Update.ID?
        let limit:          Int?
        let timeout:        Int?
        let allowedUpdates: [String]?

        init(
            offset:         Update.ID? = nil,
            limit:          Int?       = nil,
            timeout:        Int?       = nil,
            allowedUpdates: [String]?  = nil
        ) {
            self.offset         = offset
            self.limit          = limit
            self.timeout        = timeout
            self.allowedUpdates = allowedUpdates
        }
    }

    struct GetMe: Endpoint, Encodable {}

    struct SendMessage: Endpoint, Encodable {

        let chatId: Receiver
        let text:   String

        let parseMode:             ParseMode?
        let disableWebPagePreview: Bool?
        let disableNotification:   Bool?
        let replyToMessageId:      Message.ID?
        let replyMarkup:           ReplyMarkup?
    }

    struct SendDocument: Endpoint {

        let chatId:   Receiver
        let document: DocumentToSend

		let thumb:   DocumentToSend?
        let caption: String?

        let parseMode:           ParseMode?
        let disableNotification: Bool?
        let replyToMessageId:    Message.ID?
        let replyMarkup:         ReplyMarkup?
    }
}

public enum DocumentToSend {
    case data(Data)
    case reference(String)
}

/// https://core.telegram.org/bots/api#replymarkup
public enum ReplyMarkup: Encodable {
    case inlineKeyboard(InlineKeyboardMarkup)
    case replyKeyboard(ReplyKeyboardMarkup)
    case replyKeyboardRemove(ReplyKeyboardRemove)
    case forceReply(ForceReply)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .forceReply(let reply):             try container.encode(reply)
        case .inlineKeyboard(let keyboard):      try container.encode(keyboard)
        case .replyKeyboard(let keyboard):       try container.encode(keyboard)
        case .replyKeyboardRemove(let keyboard): try container.encode(keyboard)
        }
    }
}

public enum ParseMode: String, Encodable {
    case markdown
    case html
}

/// https://core.telegram.org/bots/api#inlinekeyboardmarkup
public struct InlineKeyboardMarkup: Encodable {

    public let inlineKeyboard: [[InlineKeyboardButton]]

    public struct InlineKeyboardButton: Encodable {

        public let text: String

        public let url:          String?
        public let callbackData: String?

        public let switchInlineQuery:            String?
        public let switchInlineQueryCurrentChat: String?

        public let callbackGame: String?

        public let pay: Bool?
    }
}

/// https://core.telegram.org/bots/api#replykeyboardmarkup
public struct ReplyKeyboardMarkup: Encodable {
    public let keyboard:        [[KeyboardButton]]
    public let resizeKeyboard:  Bool?
    public let oneTimeKeyboard: Bool?
    public let selective:       Bool?
}

/// https://core.telegram.org/bots/api#keyboardbutton
public struct KeyboardButton: Encodable {
    public let text:            String
    public let requestContact:  Bool?
    public let requestLocation: Bool?
}

/// https://core.telegram.org/bots/api#replykeyboardremove
public struct ReplyKeyboardRemove: Encodable {
    public let removeKeyboard: Bool = true
    public let selective:      Bool?
}

/// https://core.telegram.org/bots/api#forcereply
public struct ForceReply: Encodable {
    public let forceReply: Bool = true
    public let selective:  Bool?
}


internal extension APIMethod.SendMessage {
    init(chatId: Receiver, text: String) {
        self.init(
            chatId:                chatId,
            text:                  text,
            parseMode:             nil,
            disableWebPagePreview: nil,
            disableNotification:   nil,
            replyToMessageId:      nil,
            replyMarkup:           nil
        )
    }
}

internal extension APIMethod.SendDocument {
    init(chatId: Receiver, document: DocumentToSend) {
        self.init(
            chatId:              chatId,
            document:            document,
            thumb:               nil,
            caption:             nil,
            parseMode:           nil,
            disableNotification: nil,
            replyToMessageId:    nil,
            replyMarkup:         nil
        )
    }
}
