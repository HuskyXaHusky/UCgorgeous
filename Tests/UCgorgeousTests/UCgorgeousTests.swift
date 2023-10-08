import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(UCgorgeousMacros)
import UCgorgeousMacros

let testMacros: [String: Macro.Type] = [
    "GetColor": GetColorMacro.self,
    "GetCaseName": GetCaseNameMacro.self,
    "ClassImplicitCopy": ClassImplicitCopyMacro.self,
    "ClassExplicitCopy": ClassExplicitCopyMacro.self,
    "StructCopy": StructCopyMacro.self
]
#endif

final class UCgorgeousTests: XCTestCase {
    func testGetColorMacro() {
        #if canImport(UCgorgeousMacros)
        assertMacroExpansion(
        """
        @GetColor
        enum ColorSet {
            case red
            case green
            case blue
        }
        """,
        expandedSource: """
        enum ColorSet {
            case red
            case green
            case blue
        
            var color: Color {
                switch self {
                case .red:
                    return Color("Red")
                case .green:
                    return Color("Green")
                case .blue:
                    return Color("Blue")
                }
            }
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testGetCaseNameMacro() {
        #if canImport(UCgorgeousMacros)
        assertMacroExpansion(
        """
        @GetCaseName
        enum ComplexEnum {
            case colors( ColorSet )
            case main( MainState )
            case subState( SubState )
            case settings( Settings )
        }
        """,
        expandedSource: """
        enum ComplexEnum {
            case colors( ColorSet )
            case main( MainState )
            case subState( SubState )
            case settings( Settings )
        
            var caseName: Name {
                switch self {
                case .colors:
                    return Name.colors
                case .main:
                    return Name.main
                case .subState:
                    return Name.subState
                case .settings:
                    return Name.settings
                }
            }
            enum Name {
                case colors, main, subState, settings
            }
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testClassImplicitCopyMacro() {
        #if canImport(UCgorgeousMacros)
        assertMacroExpansion(
        """
        @ClassImplicitCopy
        final class MainState {
            var onlineStatus: String? = "online"
            var chats: [String] = []
            var chatsDict: [String:String] = [:]
            var chatsCount: Int {
                return chats.count
            }
            }
        """, expandedSource:
        """
        final class MainState {
            var onlineStatus: String? = "online"
            var chats: [String] = []
            var chatsDict: [String:String] = [:]
            var chatsCount: Int {
                return chats.count
            }
        
            func copy(onlineStatus: String?? = .none, chats: [String]? = .none, chatsDict: [String: String]? = .none) -> MainState {
                let result = MainState()
                result.onlineStatus = onlineStatus ?? self.onlineStatus
                result.chats = chats ?? self.chats
                result.chatsDict = chatsDict ?? self.chatsDict
                return result
                }
            }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testClassExplicitCopyMacro() {
        #if canImport(UCgorgeousMacros)
        assertMacroExpansion(
        """
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
        """, expandedSource:
        """
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
        
            func copy(onlineStatus: String?? = .none, chats: [String]? = .none, chatsDict: [String: String]? = .none) -> SubState {
                SubState(
                    onlineStatus: onlineStatus ?? self.onlineStatus,
                    chats: chats ?? self.chats,
                    chatsDict: chatsDict ?? self.chatsDict
                )
            }
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testStructCopyMacro() {
        #if canImport(UCgorgeousMacros)
        assertMacroExpansion(
        """
        @StructCopy
        struct Settings: Equatable, Hashable {
            let pinned: [ String ]
            let customNames: [ String : String ]
            let id: Int?
            var pinsCount: Int {
                return pinned.count
            }
        }
        """, expandedSource:
        """
        struct Settings: Equatable, Hashable {
            let pinned: [ String ]
            let customNames: [ String : String ]
            let id: Int?
            var pinsCount: Int {
                return pinned.count
            }
        
            func copy(pinned: [ String ]? = .none, customNames: [ String : String ]? = .none, id: Int?? = .none) -> Settings {
                Settings(pinned: pinned ?? self.pinned, customNames: customNames ?? self.customNames, id: id ?? self.id)
            }
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
}
