import UCgorgeous
import SwiftUI

@GetColor
enum ColorSet {
    case red
    case green
    case blue
    case megaCustomColorInAsset
}
@ClassCopy
final class MainState {
    var onlineStatus: String? = "online"
    var chats: [String] = []
    var chatsDict: [String:String] = [:]
    var chatsCount: Int {
        return chats.count
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
