//
//  MTLTexture+Identifiable.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 23.01.23.
//

import Foundation

struct Identifiable<T> {
    var id: UUID
    var element: T
}

extension Sequence {
    func identifiable() -> any Sequence<Identifiable<Element>> {
        self.map { element in
            return Identifiable(id: UUID(), element: element)
        }
    }
}
