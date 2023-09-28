// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that adding  method that returns the `color` associated with the `capitalized` enum `case`.
/// When the method is called on an instance of the enum, it returns the corresponding color object.
/// This allows for easy access to a set of predefined colors in the application. For example,
///
///     @GetColor
///     enum ColorSet {
///         case red
///         case green
///         case megaCustomColorInAsset
///     }
/// produce method:
///
///     var color: Color {
///         switch self {
///         case .red:
///             return Color("Red")
///         case .green:
///             return Color("Green")
///         case .megaCustomColorInAsset:
///             return Color("MegaCustomColorInAsset")
///         }
///     }
/// when need color:
///
///     Color(ColorSet.megaCustomColorInAsset.color)
///
@attached(member, names: named(color))
public macro GetColor() = #externalMacro(module: "UCgorgeousMacros", type: "GetColorMacro")

/// A macro that adding  method `copy` to a `class`.
/// The `copy` method allows creating a new instance of the `class` with customized property values while retaining the original
/// instance's other values.
/// This way, you don't have to create a new instance of a `class` and fill out its "fields" if you want to change one or a couple values.
/// The more values there are in the `class`, the more useful the method provided by the macro will be.
/// Please note that computed properties are ignored!
/// For example,
///
///     @ClassCopy
///     final class MainState {
///        var onlineStatus: String? = "online"
///        var chats: [String] = []
///        var chatsDict: [String:String] = [:]
///        var chatsCount: Int {
///            return chats.count
///        }
///     }
/// produce method:
///
///     func copy(onlineStatus: String?? = .none, chats: [String]? = .none, chatsDict: [String: String]? = .none) -> MainState {
///         let result = MainState()
///         result.onlineStatus = onlineStatus ?? self.onlineStatus
///         result.chats = chats ?? self.chats
///         result.chatsDict = chatsDict ?? self.chatsDict
///         return result
///     }
///
/// Usage:
///
///     let oldState = MainState()
///     let newState = oldState.copy(chats: ["MainChat", "P2PChat", "HolyWarPublicChat"])
///
@attached(member, names: arbitrary)
public macro ClassCopy() = #externalMacro(module: "UCgorgeousMacros", type: "ClassCopyMacro")


/// A macro that adding  method `copy` to a `struct`.
/// The `copy` method allows creating a new `struct` with customized property values while retaining the original
/// other values. 
/// This way, you don't have to create a new `struct` and fill out its "fields" if you want to change one or a couple values.
/// The more values there are in the `struct`, the more useful the method provided by the macro will be.
/// Please note that computed properties are ignored!
/// For example,
///
///     @StructCopy
///     struct Settings: Equatable, Hashable {
///         let pinned: [ String ]
///         let customNames: [ String : String ]
///         let id: Int?
///         var pinsCount: Int {
///             return pinned.count
///         }
///     }
///
/// produce method:
///
///     func copy(pinned: [ String ]? = .none, customNames: [ String : String ]? = .none, id: Int?? = .none) -> Settings {
///         Settings(pinned: pinned ?? self.pinned, customNames: customNames ?? self.customNames, id: id ?? self.id)
///     }
///
/// Usage:
///
///     let oldSettings = Settings(pinned: ["1", "2"], customNames: ["07245724": "Rofl"], id: nil)
///     let newSetting = oldSettings.copy(id: 120)
///
@attached(member, names: arbitrary)
public macro StructCopy() = #externalMacro(module: "UCgorgeousMacros", type: "StructCopyMacro")
