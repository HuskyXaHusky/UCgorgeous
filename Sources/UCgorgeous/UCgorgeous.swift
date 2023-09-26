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

/// A macro that adding  method `copy` to a class.
/// The `copy` method allows creating a new instance of the class with customized property values while retaining the original
/// instance's other values. For example,
///
///     @ClassCopy
///     final class MainState {
///        var onlineStatus: String? = "online"
///        var chats: [String] = []
///        var chatsDict: [String:String] = [:]
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

@attached(member, names: arbitrary)
public macro ClassCopy() = #externalMacro(module: "UCgorgeousMacros", type: "ClassCopyMacro")
