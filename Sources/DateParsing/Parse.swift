//
//  File.swift
//  swift-date-parsing
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Foundation
import Parsing

// Pull request to get this from URLRouting into Parsing https://github.com/pointfreeco/swift-parsing/pull/379
extension Parse {
  @inlinable
  init<Downstream>(
    _ conversion: Downstream
  ) where Parsers == Parsing.Parsers.MapConversion<Rest<Downstream.Input>, Downstream> {
    self.init { Rest().map(conversion) }
  }
}
