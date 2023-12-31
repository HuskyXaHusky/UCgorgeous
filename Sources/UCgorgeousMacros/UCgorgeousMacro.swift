import SwiftCompilerPlugin
import SwiftUI
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

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

public struct GetCaseNameMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
 
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw EnumInitError.onlyApplicableToEnum
        }
        let members = enumDeclaration.memberBlock.members
        let caseDeclaration = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let cases = caseDeclaration.compactMap { $0.elements.first?.name.text }
        var res =
        """
        var caseName: Name {
            switch self {
        """
        
        for caseName in cases {
            res += "\ncase .\(caseName): return Name.\(caseName)"
        }
        
        res += """
            }
        }
        enum Name {
            
        """
        
        for caseName in cases {
            res += "\(isFirst(cases, caseName) ? "case " : ", ")\(caseName)"
        }
        res +=
        """
        
        }
        """
        return [DeclSyntax(stringLiteral: res)]
    }
}

public struct ClassImplicitCopyMacro: MemberMacro {
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

public struct ClassExplicitCopyMacro: MemberMacro {
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
        let filtered = filterByAccessorBlock(arr2)
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
        ext += "\(className.description.trimmingCharacters(in: .whitespaces))("
        for (member, name) in arr2 {
            if hasAccessorBlock(member) == false {
                ext += "\n\(name): \(name) ?? self.\(name)\(isLast(filtered, name) ? "" : ", ")"
            }
        }
        ext += "\n)"
        ext +=
        """
        }
        """
        return [DeclSyntax(stringLiteral: ext)]
    }
}

public struct StructCopyMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
       guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
           throw StructInitError.onlyApplicableToStruct
        }
        let structName = structDeclaration.name
        let membersDeclaration = structDeclaration.memberBlock.members.compactMap{$0.decl.as(VariableDeclSyntax.self)}
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
        ext += ") -> \(structName){"
        ext += "\(structName)("
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
        GetCaseNameMacro.self,
        ClassImplicitCopyMacro.self,
        ClassExplicitCopyMacro.self,
        StructCopyMacro.self
    ]
}

//Utility
public func zip3<A, B, C>(_ a: A, _ b: B, _ c: C) -> [(A.Element, B.Element, C.Element)] where A: Sequence, B: Sequence, C: Sequence {
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

func filterByAccessorBlock(_ zip: Zip2Sequence<[VariableDeclSyntax], [String]> ) -> [String] {
    var arr: [String] = []
    for (member, name) in zip {
        if hasAccessorBlock(member) == false {
            arr.append(name)
        }
    }
    return arr
}

func isFirst(_ elementsArr: [String], _ elementName: String ) -> Bool {
    elementsArr.first == elementName
}
func isLast(_ elementsArr: [String], _ elementName: String ) -> Bool {
    elementsArr.last == elementName
}
