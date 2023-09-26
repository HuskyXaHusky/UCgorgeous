import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(UCgorgeousMacros)
import UCgorgeousMacros

let testMacros: [String: Macro.Type] = [
    "GetColor": GetColorMacro.self,
    "ClassCopy": ClassCopyMacro.self
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
    
    func testClassCopyMacro() {
        #if canImport(UCgorgeousMacros)
        assertMacroExpansion(
        """
        @ClassCopy
        final class MainState {
            var onlineStatus: String? = "online"
            var chats: [String] = []
            var chatsDict: [String:String] = [:]
            }
        """, expandedSource:
        """
        final class MainState {
            var onlineStatus: String? = "online"
            var chats: [String] = []
            var chatsDict: [String:String] = [:]
        
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
    
}
