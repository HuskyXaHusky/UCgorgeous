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
}
@StructCopy
struct Settings: Equatable, Hashable {
    let pinned: [ String ]
    let customNames: [ String : String ]
    let id: Int?
}
