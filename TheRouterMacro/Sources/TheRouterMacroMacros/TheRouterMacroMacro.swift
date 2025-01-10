import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum TheRouterPageMacroError: Error, CustomStringConvertible {
    case onlyApplicableToViewController
    case onlyStringName

    var description: String {
        switch self {
        case .onlyApplicableToViewController:
            return "@TheRouterPageMacro can only be applied to a ViewController"
        case .onlyStringName:
            return "@TheRouterPageMacro can only be applied to a String name"
        }
    }
}

public struct TheRouterPageMacro: ExtensionMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw TheRouterPageMacroError.onlyApplicableToViewController
        }
        guard let paths = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression else {
            throw TheRouterPageMacroError.onlyStringName
        }
        let patternBindingList = PatternBindingListSyntax([
            PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier("patternString")),
                typeAnnotation: TypeAnnotationSyntax(
                    colon: .colonToken(),
                    type: ArrayTypeSyntax(element: IdentifierTypeSyntax(name: .identifier("String")))
                ),
                accessorBlock: AccessorBlockSyntax(
                    accessors: .getter(CodeBlockItemListSyntax([
                        CodeBlockItemSyntax(item: .expr(paths))
                    ]))
                )
            )
        ])
        let members = MemberBlockItemListSyntax([
            MemberBlockItemSyntax(decl: VariableDeclSyntax(
                modifiers: DeclModifierListSyntax([DeclModifierSyntax(name: .keyword(.static))]),
                bindingSpecifier: .keyword(.var),
                bindings: patternBindingList
            ))
        ])
        return [
            ExtensionDeclSyntax(
                extensionKeyword: .keyword(.extension),
                extendedType: type.trimmed,
                inheritanceClause: InheritanceClauseSyntax(
                    inheritedTypes: InheritedTypeListSyntax(protocols.map({
                        InheritedTypeSyntax(type: $0)
                    }))
                ),
                memberBlock: MemberBlockSyntax(
                    leftBrace: .leftBraceToken(),
                    members: members,
                    rightBrace: .rightBraceToken()
                )
            )
        ]
    }
}

@main
struct TheRouterMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TheRouterPageMacro.self
    ]
}
