import SwiftUI

struct WaterfallLayout: Layout {
    var columns: Int = 2
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let columnWidth = (width - CGFloat(columns - 1) * spacing) / CGFloat(columns)

        // Reset column heights
        cache.columnHeights = Array(repeating: 0, count: columns)
        cache.frames = []

        for subview in subviews {
            // Find shortest column
            let minColumnIndex = cache.columnHeights.enumerated().min(by: { $0.element < $1.element })!.offset

            // Calculate subview size
            let subviewSize = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))

            // Calculate frame
            let x = CGFloat(minColumnIndex) * (columnWidth + spacing)
            let y = cache.columnHeights[minColumnIndex]

            cache.frames.append(CGRect(x: x, y: y, width: columnWidth, height: subviewSize.height))

            // Update column height
            cache.columnHeights[minColumnIndex] += subviewSize.height + spacing
        }

        // Total height is the tallest column
        let maxHeight = cache.columnHeights.max() ?? 0
        return CGSize(width: width, height: maxHeight - spacing)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        for (index, subview) in subviews.enumerated() {
            let frame = cache.frames[index]
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }

    func makeCache(subviews: Subviews) -> Cache {
        Cache(columnHeights: Array(repeating: 0, count: columns), frames: [])
    }

    struct Cache {
        var columnHeights: [CGFloat]
        var frames: [CGRect]
    }
}
