import UCgorgeous
import SwiftUI

@GetColor
enum ColorSet {
    case red
    case green
    case blue
    case megaCustomColorInAsset
}

@ClassImplicitCopy
final class MainState {
    var onlineStatus: String? = "online"
    var chats: [String] = []
    var chatsDict: [String:String] = [:]
    var chatsCount: Int {
        return chats.count
    }
}

@ClassExplicitCopy
final class SubState {
    var onlineStatus: String? = "online"
    var chats: [String] = []
    var chatsDict: [String:String] = [:]
    var chatsCount: Int {
        return chats.count
    }
    init(onlineStatus: String? = nil, chats: [String], chatsDict: [String : String]) {
        self.onlineStatus = onlineStatus
        self.chats = chats
        self.chatsDict = chatsDict
    }
}

@StructCopy
struct Settings: Equatable, Hashable {
    let pinned: [ String ]
    let customNames: [ String : String ]
    let id: Int?
    var pinsCount: Int {
        return pinned.count
    }
}

@GetCaseName
enum ComplexEnum {
    case colors( ColorSet )
    case main( MainState )
    case subState( SubState )
    case settings( Settings )
}
