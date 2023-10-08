// The Swift Programming Language
// https://docs.swift.org/swift-book

/// `@GetColor`
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

/// `@GetCaseName`
/// A macro that adding  computed property `caseName`and `Name` enumeration within `enum`.
/// `Name` enumeration is used to represent the names of the cases in the `enum`.
/// Overall, macro adds functionality to easily get the name of the current case in the complex  enumeration,  each case of which contains other enumerations,
/// complex classes or structures, which is extremely useful in many situations and simply irreplaceable when you need to know which case is currently being used
/// in order to set a condition without unnecessary clarification of the parameters of the object contained in this case.
/// For example ,
///
///     // Examples of objects designated in enum can be examined in detail in the file - main.swift
///
///     @GetCaseName
///     enum ComplexEnum {
///         case colors( ColorSet )   // enum
///         case main( MainState )    // class
///         case subState( SubState ) // class
///         case settings( Settings ) // struct
///     }
/// produce:
///
///     var caseName: Name {
///         switch self {
///         case .colors:
///             return Name.colors
///         case .main:
///             return Name.main
///         case .subState:
///             return Name.subState
///         case .settings:
///             return Name.settings
///         }
///     }
///     enum Name {
///         case colors, main, subState, settings
///     }
///
/// Usage:
///
///     let state: ComplexEnum = .subState(SubState(onlineStatus: "away", chats: ["foo", "bar"],
///         chatsDict: ["foo":"p2p", "bar":"group"]))
///
///     if state.caseName == .subState {
///         // Do something
///     }

///
@attached(member, names: arbitrary)
public macro GetCaseName() = #externalMacro(module: "UCgorgeousMacros", type: "GetCaseNameMacro")

/// `@ClassImplicitCopy`
/// A macro that adding  method `copy` to a `class`.
/// The `copy` method allows creating a new instance of the `class` with customized property values while retaining the original
/// instance's other values.
/// This way, you don't have to create a new instance of a `class` and fill out its "fields" if you want to change one or a couple values.
/// The more values there are in the `class`, the more useful the method provided by the macro will be.
/// Please note that computed properties are ignored!
/// This is suitable if you want `to use the current property values if they were not passed as parameters`.
/// For example,
///
///     @ClassImplicitCopy
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
public macro ClassImplicitCopy() = #externalMacro(module: "UCgorgeousMacros", type: "ClassImplicitCopyMacro")

/// `@ClassExplicitCopy`
/// A macro that adding  method `copy` to a `class`.
/// The `copy` method allows creating a new instance of the `class` with customized property values while retaining the original
/// instance's other values.
/// This way, you don't have to create a new instance of a `class` and fill out its "fields" if you want to change one or a couple values.
/// The more values there are in the `class`, the more useful the method provided by the macro will be.
/// Please note that computed properties are ignored!
/// This is suitable if you want `to explicitly specify values for all properties`.
/// Keep in mind that for the macro to be used correctly, the `properties must be initialized` properly.
/// If properties are declared in a class in one order, and in the initializer in another, then the precompiler will throw an error.
/// To avoid this, you should to initialize the properties in the same order in which they were declared.
/// For example,
///
///     @ClassExplicitCopy
///     final class SubState {
///        var onlineStatus: String? = "online"
///        var chats: [String] = []
///        var chatsDict: [String:String] = [:]
///        var chatsCount: Int {
///            return chats.count
///        }
///        init(onlineStatus: String? = nil, chats: [String], chatsDict: [String : String]) {
///            self.onlineStatus = onlineStatus
///            self.chats = chats
///            self.chatsDict = chatsDict
///        }
///     }
/// produce method:
///
///     func copy(onlineStatus: String?? = .none, chats: [String]? = .none, chatsDict: [String: String]? = .none) -> SubState {
///         SubState(
///             onlineStatus: onlineStatus ?? self.onlineStatus,
///             chats: chats ?? self.chats,
///             chatsDict: chatsDict ?? self.chatsDict
///         )
///     }
///
/// Usage:
///
///     let oldState = SubState(chats: [], chatsDict: [:])
///     let newState = oldState.copy(onlineStatus: "offline", chats: ["P2PChat", "HolyWarPublicChat"])
///
@attached(member, names: arbitrary)
public macro ClassExplicitCopy() = #externalMacro(module: "UCgorgeousMacros", type: "ClassExplicitCopyMacro")

/// `@StructCopy`
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
