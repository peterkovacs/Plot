/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal protocol AnyNode: Sendable {
    func render(into renderer: inout Renderer)
}
