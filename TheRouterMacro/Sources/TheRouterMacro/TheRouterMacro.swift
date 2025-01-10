// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(extension, conformances: TheRouterable, names: named(patternString))
public macro RouterPage(_ value: [String]) = #externalMacro(module: "TheRouterMacroMacros", type: "TheRouterPageMacro")
