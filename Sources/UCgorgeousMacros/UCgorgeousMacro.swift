import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

enum EnumInitError: CustomStringConvertible, Error {
    case onlyApplicableToEnum
    var description: String {
        switch self {
        case .onlyApplicableToEnum: return "This macro can only be applied to a enum."
        }
    }
}
enum ClassInitError: CustomStringConvertible, Error {
    case onlyApplicableToClass
    var description: String {
        switch self {
        case .onlyApplicableToClass: return "This macro can only be applied to a Class."
        }
    }
}
enum StructInitError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "This macro can only be applied to a Struct."
        }
    }
}

public struct GetColorMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
 
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw EnumInitError.onlyApplicableToEnum
        }
        let members = enumDeclaration.memberBlock.members
        let caseDeclaration = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let cases = caseDeclaration.compactMap { $0.elements.first?.name.text }
        var color = """
        var color: Color {
            switch self {
        """
        
        for colorName in cases {
            color += "case .\(colorName): return Color(\"\(colorName.prefix(1).capitalized + colorName.dropFirst())\")"
        }
        
        color += """
            }
        }
        """
        return [DeclSyntax(stringLiteral: color)]
    }
}

public struct ClassCopyMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
       guard let classDeclaration = declaration.as(ClassDeclSyntax.self) else {
            throw ClassInitError.onlyApplicableToClass
        }
        let className = classDeclaration.name
        let membersDeclaration = classDeclaration.memberBlock.members.compactMap{$0.decl.as(VariableDeclSyntax.self)}
        let varName = membersDeclaration.compactMap { $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
        let varType = membersDeclaration.compactMap {
            $0.bindings.first?.typeAnnotation?.as(TypeAnnotationSyntax.self)}
        let arr1 = zip3(membersDeclaration, varName, varType)
        let arr2 = zip(membersDeclaration,varName)
        
        var ext =
        """
        func copy(
        """
        for (member, name, type) in arr1 {
            if hasAccessorBlock(member) == false {
                ext += "\(isFirst(varName, name) ? "" : ", ")\(name)\(type.description.trimmingCharacters(in: .whitespaces) + "?") = .none"
            }
        }
        ext += ") -> \(className){"
        ext += "let result = \(className.description.trimmingCharacters(in: .whitespaces))()"
        for (member, name) in arr2 {
            if hasAccessorBlock(member) == false {
                ext += "\nresult.\(name) = \(name) ?? self.\(name)"
            }
        }
        ext += """
    
    return result
        }
    """
        return [DeclSyntax(stringLiteral: ext)]
    }
}

public struct StructCopyMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
       guard let classDeclaration = declaration.as(StructDeclSyntax.self) else {
           throw StructInitError.onlyApplicableToStruct
        }
        let className = classDeclaration.name
        let membersDeclaration = classDeclaration.memberBlock.members.compactMap{$0.decl.as(VariableDeclSyntax.self)}
        let varName = membersDeclaration.compactMap { $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
        let varType = membersDeclaration.compactMap {
            $0.bindings.first?.typeAnnotation?.as(TypeAnnotationSyntax.self)}
        let arr1 = zip3(membersDeclaration, varName, varType)
        let arr2 = zip(membersDeclaration,varName)
        var ext =
        """
        func copy(
        """
        for (member, name, type) in arr1 {
            if hasAccessorBlock(member) == false {
                ext += "\(isFirst(varName, name) ? "" : ", ")\(name)\(type.description.trimmingCharacters(in: .whitespaces) + "?") = .none"
            }
        }
        ext += ") -> \(className){"
        ext += "\(className)("
        for (member, name) in arr2 {
            if hasAccessorBlock(member) == false {
                ext += "\(isFirst(varName, name) ? "" : ", ")\(name): \(name) ?? self.\(name)"
            }
        }
        ext += ")"
        ext += """
        }
    """
        return [DeclSyntax(stringLiteral: ext)]
    }
}

@main
struct UCgorgeousPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GetColorMacro.self,
        ClassCopyMacro.self,
        StructCopyMacro.self
    ]
}

//Utility
func zip3<A, B, C>(_ a: A, _ b: B, _ c: C) -> [(A.Element, B.Element, C.Element)] where A: Sequence, B: Sequence, C: Sequence {
    let zipped = zip(a, zip(b, c))
    return zipped.reduce(into: []) { result, tuple in
        let (e1, (e2, e3)) = tuple
        result.append((e1, e2, e3))
    }
}

func hasAccessorBlock(_ variable: VariableDeclSyntax) -> Bool {
    return variable.bindings.contains { binding in
        guard binding.accessorBlock != nil else {  return false }
        return true
    }
}

func isFirst(_ elementsArr: [String], _ elementName: String ) -> Bool {
    elementsArr.first == elementName
}
