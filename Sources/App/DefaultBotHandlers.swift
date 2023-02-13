//
//  File.swift
//
//
//  Created by  on 17.06.2021.
//
import Vapor
import telegram_vapor_bot

struct T: Decodable {
    let text: String
 
}

final class DefaultBotHandlers {
    
    static func addHandlers(app: Vapor.Application, bot: TGBotPrtcl) {
        defaultHandler(app: app, bot: bot)
        commandPingHandler(app: app, bot: bot)
//        commandCatHandler(app: app, bot: bot)
        commandStartHandler(app: app, bot: bot)
        commandPidrHandler(app: app, bot: bot)
    }
    
    
    private static func commandCatHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: ["/cat"]) { update, bot in
            app.http.client.shared.get(url: "https://cat-fact.herokuapp.com/facts").whenSuccess { result in
                guard let body = result.body, let data = body.getData(at: 0, length: body.readableBytes) else {
                    return
                }
                let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonArray = jsonResponse as? [[String: Any]],
                      let title = jsonArray.randomElement()?["text"] as? String else {
                      return
                }
                try? update.message?.reply(text: title, bot: bot)
            }
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func commandPidrHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: ["/pidr"]) { update, bot in
            try? update.message?.reply(text: "Сам пидор) ", bot: bot)
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func commandStartHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: ["/start"]) { update, bot in
            try? update.message?.reply(text: startText, bot: bot)
        }
        bot.connection.dispatcher.add(handler)
    }
    
    
    
    private static func defaultHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGMessageHandler(filters: (.all && !.command.names(["/ping"]))) { update, bot in
            guard update.message?.chat.id != -1001769149464 else { return }
            let message = "@\(update.message?.from?.username ?? "хз"), сообщение: \(update.message?.text ?? "ошибка какая-то...")"
            try? bot.sendMessage(params: .init(chatId: .chat(-1001769149464), text: message))
            print(update.message?.text)
        }
        bot.connection.dispatcher.add(handler)
    }
    
    private static func commandPingHandler(app: Vapor.Application, bot: TGBotPrtcl) {
        let handler = TGCommandHandler(commands: ["/ping"]) { update, bot in
            try update.message?.reply(text: "pong", bot: bot)
        }
        bot.connection.dispatcher.add(handler)
    }
}

let startText = """
Дорогие друзья, для того чтобы рассказать свою историю и получить бесплатный кофе необходимо
▪️нажать кнопку старт
▪️написать вашу историю
▪️мы проверим ее на плагиат
▪️Если она уникальна мы ее опубликуем и оплатим рассказ ;)
Для прохождения плагиата необходимо, чтобы Ваша история была размещена впервые в сети интернет и была уникальной.
Не забывайте в конце подписать свой номер телефона или номер карты, чтобы мы могли направить вам ваше вознаграждение🤑
"""
