//
//  ChatService.swift
//  More
//
//  Created by Luko Gjenero on 11/08/2019.
//  Copyright © 2019 More Technologies. All rights reserved.
//

import Firebase

class ChatService {

    struct Notifications {
        static let ChatsLoaded = NSNotification.Name(rawValue: "com.more.chat.loaded")
        static let ChatChanged = NSNotification.Name(rawValue: "com.more.chat.changed")
        static let ChatRemoved = NSNotification.Name(rawValue: "com.more.chat.removed")
        static let ChatTyping = NSNotification.Name(rawValue: "com.more.chat.typing")
        static let ChatMessage = NSNotification.Name(rawValue: "com.more.chat.message")
    }
    
    static let shared = ChatService()
    
    private var chats: [Chat] = []
    private var chatMessages: [String: [Message]] = [:]
    
    init() {
        // App to foregrounsd / background
        NotificationCenter.default.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // User login / logout
        NotificationCenter.default.addObserver(self, selector: #selector(login), name: ProfileService.Notifications.ProfileLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: ProfileService.Notifications.ProfileLogout, object: nil)
        
        // user data changed
        NotificationCenter.default.addObserver(self, selector: #selector(updateAllChatDataIfNecessary), name: ProfileService.Notifications.ProfileLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAllChatDataIfNecessary), name: ProfileService.Notifications.ProfilePhotos, object: nil)
        
        login()
    }
    
    @objc private func toForeground() {
        login()
    }
    
    @objc private func toBackground() {
        // remove typing from all chats
        for chat in chats {
            setTyping(typing: false, in: chat.id)
        }
        
        // stop traking
        logout()
    }
    
    // MARK: - server refresh
    
    @objc private func login() {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        Firestore.firestore().collection("chats")
            .whereField("memberIds.\(myId)", isEqualTo: true)
            .addSnapshotListener({ [weak self] (snapshot, error) in
                guard let snapshot = snapshot else { return }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added || diff.type == .modified) {
                        if let chat = Chat.fromSnapshot(diff.document) {
                            self?.updateChat(chat)
                        }
                    }
                    if (diff.type == .removed) {
                        if let chat = Chat.fromSnapshot(diff.document) {
                            self?.removeChat(chat)
                        }
                    }
                }
            })
    }
    
    @objc private func logout() {
        stopTracking()
        chats = []
        chatMessages = [:]
    }
    
    // MARK: - accesors
    
    func getChats() -> [Chat] {
        return chats.map { $0.chatWithMessages(chatMessages[$0.id] ?? []) }
    }
    
    func getChat(for userId: String) -> Chat? {
        if let chat = chats.filter({ !($0.type == .group) && $0.memberIds.count == 2 }).first(where: { $0.other().id == userId }) {
            return chat.chatWithMessages(chatMessages[chat.id] ?? [])
        }
        return nil
    }
    
    func getChat(for memberIds: [String]) -> Chat? {
        if let chat = chats.filter({ $0.memberIds.count == memberIds.count })
            .first(where: { $0.members.filter { !memberIds.contains($0.id) }.count == 0 }) {
            return chat.chatWithMessages(chatMessages[chat.id] ?? [])
        }
        return nil
    }
    
    func getChat(for userId: String, load: Bool = false, complete:((_ chat: Chat?)->())?)  {
        if let chat = getChat(for: userId) {
            complete?(chat.chatWithMessages(chatMessages[chat.id] ?? []))
            return
        }
        
        if load, let myId = ProfileService.shared.profile?.getId() {
            Firestore.firestore().collection("chats")
                .whereField("memberIds.\(myId)", isEqualTo: true)
                .whereField("memberIds.\(userId)", isEqualTo: true)
                .getDocuments(completion: { (snapshot, error) in
                    if let snapshot = snapshot {
                        for chatRef in snapshot.documents {
                            if let chat = Chat.fromSnapshot(chatRef),
                                chat.members.count == 2, !(chat.type == .group) {
                                complete?(chat)
                            }
                        }
                    }
                    complete?(nil)
                })
            return
        }
        
        complete?(nil)
    }
    
    func getChat(for members: [String], load: Bool = false, complete:((_ chat: Chat?)->())?)  {
        if let chat = getChat(for: members) {
            complete?(chat)
            return
        }
        
        if load {
            let ref = Firestore.firestore().collection("chats")
            var query: Query? = nil
            for memberId in members {
                if query == nil {
                    query = ref.whereField("memberIds.\(memberId)", isEqualTo: true)
                } else {
                    query = query?.whereField("memberIds.\(memberId)", isEqualTo: true)
                }
            }
            query?.getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    for chatRef in snapshot.documents {
                        if let chat = Chat.fromSnapshot(chatRef), chat.members.count == members.count {
                            complete?(chat)
                        }
                    }
                }
                complete?(nil)
            })
            return
        }
        
        complete?(nil)
    }
    
    func getChat(chatId: String, load: Bool = false, complete:((_ chat: Chat?)->())?)  {
        if let chat = chats.first(where: { $0.id == chatId }) {
            complete?(chat.chatWithMessages(chatMessages[chat.id] ?? []))
            return
        }
        
        if load {
            Firestore.firestore().document("chats/\(chatId)")
                .getDocument(completion: { (snapshot, error) in
                    if let snapshot = snapshot, snapshot.exists,
                        let chat = Chat.fromSnapshot(snapshot) {
                        complete?(chat)
                    }
                    complete?(nil)
                })
            return
        }
        
        complete?(nil)
    }
    
    func createChat(chat: Chat, complete:((_ chatId: String?, _ errorMsg: String?)->())?) {
        guard let _ = ProfileService.shared.profile?.getId(),
            let data = chat.json else {
                complete?(nil, "Not logged in")
                return
        }
        
        let newChat = Firestore.firestore().collection("chats").document()
        newChat.setData(data) { (error) in
            if let error = error {
                complete?(nil, error.localizedDescription)
                return
            }
            
            let chatId = newChat.documentID
            complete?(chatId, nil)
        }
    }
    
    func deleteChat(chatId: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let _ = ProfileService.shared.profile?.getId() else {
                complete?(false, "Not logged in")
                return
        }
        
        Firestore.firestore().document("chats/\(chatId)").delete { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                return
            }
            complete?(true, nil)
        }
    }
    
    func removeFromChat(chatId: String, user: ShortUser, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let _ = ProfileService.shared.profile?.getId(),
            let userInChat = user.json else {
                complete?(false, "Not logged in")
                return
        }
        
        var update: [String: Any] = [:]
        update["members"] = FieldValue.arrayRemove([userInChat])
        update["memberIds.\(user.id)"] = FieldValue.delete()
        
        Firestore.firestore().document("chats/\(chatId)").updateData(update) { (error) in
            if let error = error {
                complete?(false, error.localizedDescription)
                return
            }
            complete?(true, nil)
        }
    }
    
    func addVideoCall(to chat: Chat, id: String, sessionId: String, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let me = ProfileService.shared.profile?.shortUser,
            let myData = me.json else {
            complete?(false, "Not logged in")
            return
        }
        
        let videoCall = VideoCall(id: id, sessionId: sessionId, createdAt: Date(), members: [me])
        guard let data = videoCall.json else {
            complete?(false, "Data issue")
            return
        }
        
        Firestore.firestore().runTransaction({ [weak self] (transaction, errorPointer) -> Any? in
            
            let path = Firestore.firestore().document("chats/\(chat.id)")
            let experienceDoc: DocumentSnapshot
            do {
                try experienceDoc = transaction.getDocument(path)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if let call = experienceDoc.data()?["videoCall"] as? [String: Any] {
                var addMe = true
                if let members = call["members"] as? [[String: Any]] {
                    
                    if members.count >= Config.Experience.virtualSpots {
                        errorPointer?.pointee = MoreError.callFull()
                        return nil
                    }
                    
                    for member in members {
                        if let id = member["id"] as? String, id == me.id {
                            addMe = false
                            break
                        }
                    }
                    
                    if addMe {
                        transaction.updateData(["videoCall.members": FieldValue.arrayUnion([myData])], forDocument: path)
                    }
                }
            } else {
                transaction.updateData(["videoCall": data], forDocument: path)
                transaction.updateData(["videoCall.tick": Date().timeIntervalSinceReferenceDate], forDocument: path)
                
                let text = "\(me.name) started a call"
                let messageId = "\(me.id.hashValue)-\(Date().hashValue)"
                let message = Message(id: messageId, createdAt: Date(), sender: me, type: .startCall, text: text, deliveredAt: nil, readAt: nil)
                ChatService.shared.sendMessage(chatId: chat.id, message: message)
            }
            
            return nil
        },
        completion: { (postId, error) in
            if let error = error {
                complete?(false, error.localizedDescription)
            } else {
                complete?(true, nil)
            }
        })
    }
    
/*
    private func addMeToVideoCall(to chat: Chat, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let me = ProfileService.shared.profile?.shortUser, let data = me.json else {
            complete?(false, "Not logged in")
            return
        }
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            
            let path = Firestore.firestore().document("chats/\(chat.id)")
            let experienceDoc: DocumentSnapshot
            do {
                try experienceDoc = transaction.getDocument(path)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var addMe = true
            if let call = experienceDoc.data()?["videoCall"] as? [String: Any],
                let members = call["members"] as? [[String: Any]] {
                
                if members.count >= Config.Experience.virtualSpots {
                    errorPointer?.pointee = MoreError.callFull()
                    return nil
                }
                
                for member in members {
                    if let id = member["id"] as? String, id == me.id {
                        addMe = false
                        break
                    }
                }
                
                if addMe {
                    transaction.updateData(["videoCall.members": FieldValue.arrayUnion([data])], forDocument: path)
                }
            }
            return nil
        },
        completion: { (postId, error) in
            if let error = error {
                complete?(false, error.localizedDescription)
            } else {
                complete?(true, nil)
            }
        })
    }
*/
    
    func removeMeFromVideoCall(chat: Chat, complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        guard let me = ProfileService.shared.profile?.shortUser else {
            complete?(false, "Not logged in")
            return
        }
        removeFromVideoCall(me, chat, complete)
    }
    
    func removeFromVideoCall(_ user: ShortUser, _ chat: Chat, _ complete:((_ success: Bool, _ errorMsg: String?)->())?) {
        
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            
            let path = Firestore.firestore().document("chats/\(chat.id)")
            let experienceDoc: DocumentSnapshot
            do {
                try experienceDoc = transaction.getDocument(path)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if let call = experienceDoc.data()?["videoCall"] as? [String: Any],
                var members = call["members"] as? [[String: Any]] {
                
                members.removeAll(where: { ($0["id"] as? String) == user.id })
                
                if members.isEmpty {
                    transaction.updateData(["videoCall": FieldValue.delete()], forDocument: path)
                } else {
                    transaction.updateData(["videoCall.members": members], forDocument: path)
                }
            }
                        
            return nil
        },
        completion: { (postId, error) in
            if let error = error {
                complete?(false, error.localizedDescription)
            } else {
                complete?(true, nil)
            }
        })
    }
    
    func videoCallTick(for chat: Chat) {
        Firestore.firestore().document("chats/\(chat.id)").updateData(["videoCall.tick": Date().timeIntervalSinceReferenceDate])
    }
    
    // MARK: - chat tracking
    
    private var trackedChats: [String: [ListenerRegistration]] = [:]
    
    private func track(chatId: String) {
        stopTracking(chatId: chatId)
        
        trackedChats[chatId] = [
            Firestore.firestore().collection("chats/\(chatId)/messageList").addSnapshotListener { [weak self] (snapshot, error) in
                guard let snapshot = snapshot else { return }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        if let message = Message.fromSnapshot(diff.document) {
                            self?.newMessage(message, in: chatId)
                        }
                    }
                    if (diff.type == .modified) {
                        if let message = Message.fromSnapshot(diff.document) {
                            self?.updatedMessage(message, in: chatId)
                        }
                    }
                    if (diff.type == .removed) {
                        if let message = Message.fromSnapshot(diff.document) {
                            self?.removedMessage(message, in: chatId)
                        }
                    }
                }
            }
        ]
    }
    
    private func stopTracking(chatId: String) {
        if let listeners = trackedChats[chatId] {
            for listener in listeners {
                listener.remove()
            }
        }
    }
    
    private func stopTracking() {
        for listeners in trackedChats.values {
            for listener in listeners {
                listener.remove()
            }
        }
        trackedChats.removeAll()
    }
    
    // MARK: - chat update
    
    private func updateChat(_ newChat: Chat) {
        if let oldChat = chats.first(where: { $0.id == newChat.id }) {
            replaceChat(newChat)
            checkTyping(oldChat: oldChat, newChat: newChat)
            NotificationCenter.default.post(
                name: Notifications.ChatChanged,
                object: self,
                userInfo: ["chat": newChat.chatWithMessages(chatMessages[newChat.id] ?? [])])
        } else {
            chats.append(newChat)
            NotificationCenter.default.post(
                name: Notifications.ChatsLoaded,
                object: self,
                userInfo: nil)
            track(chatId: newChat.id)
        }
        
        updateChatDataIfNecessary(newChat)
    }
    
    private func updateChatDataIfNecessary(_ chat: Chat) {
        guard let me = ProfileService.shared.profile?.shortUser else { return }
        
        if let meInChat = chat.members.first(where: { $0.isMe() }) {
            if meInChat.name != me.name || meInChat.avatar != me.avatar {
                
                guard let meData = me.json else { return }
                guard let meInChatData = meInChat.json else { return }
                
                Firestore.firestore().document("chats/\(chat.id)").updateData(["members": FieldValue.arrayRemove([meInChatData])]) { (error) in
                    if error == nil {
                    Firestore.firestore().document("chats/\(chat.id)").updateData(["members": FieldValue.arrayUnion([meData])])
                    }
                }
            }
        }
    }
    
    @objc private func updateAllChatDataIfNecessary() {
        for chat in chats {
            updateChatDataIfNecessary(chat)
        }
    }
    
    private func replaceChat(_ chat: Chat) {
        chats.removeAll(where: { $0.id == chat.id })
        chats.append(chat)
    }
    
    private func removeChat(_ chat: Chat) {
        chats.removeAll(where: { $0.id == chat.id })
        NotificationCenter.default.post(
            name: Notifications.ChatRemoved,
            object: self,
            userInfo: [ "chatId": chat.id ])
    }
    
    private func checkTyping(oldChat: Chat, newChat: Chat) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        
        let notTypingAnymore = oldChat.typing.filter { !newChat.typing.contains($0) && $0 != myId }
        let startedTyping = newChat.typing.filter { !oldChat.typing.contains($0) && $0 != myId }
        
        for id in notTypingAnymore {
            NotificationCenter.default.post(
                name: Notifications.ChatTyping,
                object: self,
                userInfo: [ "chatId": newChat.id, "userId": id, "typing": false ])
        }
        
        for id in startedTyping {
            NotificationCenter.default.post(
                name: Notifications.ChatTyping,
                object: self,
                userInfo: [ "chatId": newChat.id, "userId": id, "typing": true ])
        }
    }
    
    private func newMessage(_ message: Message, in chatId: String) {
        if chatMessages[chatId]?.first(where: { $0.id == message.id }) == nil {
            
            var messages = chatMessages[chatId] ?? []
            messages.append(message)
            chatMessages[chatId] = messages
            
            if !message.isMine(), !message.haveRead(), !message.wasDelivered() {
                setMessageDelivered(chatId: chatId, messageId: message.id)
            }
            
            NotificationCenter.default.post(
                name: Notifications.ChatMessage,
                object: self,
                userInfo: [ "chatId": chatId, "message": message, "update": "new" ])
        }
    }
    
    private func updatedMessage(_ message: Message, in chatId: String) {
        if let oldMessage = chatMessages[chatId]?.first(where: { $0.id == message.id }) {
           
            var newMessages = chatMessages[chatId] ?? []
            newMessages.removeAll(where: { $0.id == message.id })
            newMessages.append(message)
            chatMessages[chatId] = newMessages
            
            var oldReadAt: [String] = []
            if let keys = oldMessage.readAt?.keys {
                oldReadAt = Array(keys).sorted()
            }
            var newReadAt: [String] = []
            if let keys = message.readAt?.keys {
                newReadAt = Array(keys).sorted()
            }
            var oldDeliveredAt: [String] = []
            if let keys = oldMessage.deliveredAt?.keys {
                oldDeliveredAt = Array(keys).sorted()
            }
            var newDeliveredAt: [String] = []
            if let keys = message.deliveredAt?.keys {
                newDeliveredAt = Array(keys).sorted()
            }
             
            if !oldReadAt.elementsEqual(newReadAt) ||
                !oldDeliveredAt.elementsEqual(newDeliveredAt) ||
                oldMessage.text != message.text {
                
                NotificationCenter.default.post(
                    name: Notifications.ChatMessage,
                    object: self,
                    userInfo: [ "chatId": chatId, "message": message, "update": "data" ])
            }
        }
    }
    
    private func removedMessage(_ message: Message, in chatId: String) {
        if chatMessages[chatId]?.first(where: { $0.id == message.id }) != nil {
            
            var newMessages = chatMessages[chatId] ?? []
            newMessages.removeAll(where: { $0.id == message.id })
            chatMessages[chatId] = newMessages
            
            // guard !message.isMine() else { return }
            
            NotificationCenter.default.post(
                name: Notifications.ChatMessage,
                object: self,
                userInfo: [ "chatId": chatId, "message": message, "update": "delete" ])
        }
    }
    
    func sendMessage(chatId: String, message: Message) {
        guard let data = message.json else { return }
        newMessage(message, in: chatId)
        Firestore.firestore().document("chats/\(chatId)/messageList/\(message.id)").setData(data)
    }
    
    func setMessageDelivered(chatId: String, messageId: String) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        let update = ["deliveredAt.\(myId)": Date().timeIntervalSinceReferenceDate]
        Firestore.firestore().document("chats/\(chatId)/messageList/\(messageId)").updateData(update)
    }
    
    func setMessageRead(chatId: String, messageId: String) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        let update = ["readAt.\(myId)": Date().timeIntervalSinceReferenceDate]
        Firestore.firestore().document("chats/\(chatId)/messageList/\(messageId)").updateData(update)
    }
    
    func deleteMessage(chatId: String, messageId: String) {
        Firestore.firestore().document("chats/\(chatId)/messageList/\(messageId)").delete()
    }
    
    func setTyping(typing: Bool, in chatId: String) {
        guard let myId = ProfileService.shared.profile?.getId() else { return }
        
        let value = typing ? FieldValue.arrayUnion([myId]) : FieldValue.arrayRemove([myId])
        Firestore.firestore().document("chats/\(chatId)").updateData(["typing": value])
    }
}
