import SwiftUI



struct StaticView: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGSize = CGSize(width: 50, height: 50)  // Dynamic size property
}

struct Line: Identifiable,Equatable {
    let id = UUID()
    let start: CGPoint
    let end: CGPoint
}

struct LineDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LineDemoView()
    }
}

struct LineDemoView: View {
    @State private var dragPosition = CGPoint(x: 100, y: 100)
    @State private var dragSize = CGSize(width: 50, height: 50) // Draggable view's size
    @State private var lines: [Line] = []
    
    // Predefined positions and sizes for static views
    @State var staticViews: [StaticView] = [
        StaticView(position: CGPoint(x: 50, y: 50), size: CGSize(width: 100, height: 50)),
        StaticView(position: CGPoint(x: 250, y: 50), size: CGSize(width: 50, height: 100)),
        StaticView(position: CGPoint(x: 50, y: 250), size: CGSize(width: 200, height: 50)),
        StaticView(position: CGPoint(x: 250, y: 250), size: CGSize(width: 50, height: 300)),
        StaticView(position: CGPoint(x: 150, y: 150), size: CGSize(width: 70, height: 80))
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background view
                Color.white
                
                // Static views
                ForEach(staticViews) { staticView in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: staticView.size.width, height: staticView.size.height)
                        .position(staticView.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if let index = staticViews.firstIndex(where: { $0.id == staticView.id }) {
                                        staticViews[index].position = value.location
                                    } else {
                                        lines.removeAll()
                                        print("Not found")
                                    }
                                    // Pass dynamic size to the alignment function
                                    checkAlignment2(parentSize: geometry.size,
                                                    currentDragPosition: staticView.position,
                                                    staticSize: staticView.size, currentStaticView: staticView)
                                }
                                .onEnded { _ in
                                    lines.removeAll()
                                }
                        )
                }
                
                
                
                // Alignment lines
                ForEach(lines, id: \.id) { line in
                    Path { path in
                        path.move(to: line.start)
                        path.addLine(to: line.end)
                    }
                    .stroke(Color.red, lineWidth: 1.0)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
    }
    
    // For the draggable view (green) using dynamic dragSize
    private func checkAlignment(parentSize: CGSize) {
        lines.removeAll()
        let dragFrame = CGRect(x: dragPosition.x - dragSize.width / 2,
                               y: dragPosition.y - dragSize.height / 2,
                               width: dragSize.width,
                               height: dragSize.height)
        
        // Check parent center alignment first
        checkParentCenterAlignment(parentSize: parentSize, dragFrame: dragFrame)
        
        // Check alignment with other static views
        for staticView in staticViews {
            let staticFrame = CGRect(x: staticView.position.x - staticView.size.width / 2,
                                     y: staticView.position.y - staticView.size.height / 2,
                                     width: staticView.size.width,
                                     height: staticView.size.height)
          //  checkVerticalAlignments(dragFrame: dragFrame, staticFrame: staticFrame)
            checkHorizontalAlignments(dragFrame: dragFrame, staticFrame: staticFrame)
        }
    }
    
    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .init(rawValue: Int(0.06))!) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()  // Prepare the generator for immediate feedback
        generator.impactOccurred()
    }
    
    // For static views (blue) being dragged; uses the dynamic size from the view model
    private func checkAlignment2(parentSize: CGSize, currentDragPosition: CGPoint, staticSize: CGSize,currentStaticView:StaticView) {
        lines.removeAll()
        let dragFrame = CGRect(x: currentDragPosition.x - staticSize.width / 2,
                               y: currentDragPosition.y - staticSize.height / 2,
                               width: staticSize.width,
                               height: staticSize.height)
        
        // Check parent center alignment first
        checkParentCenterAlignment(parentSize: parentSize, dragFrame: dragFrame)
        
        // Check alignment with other static views
        for staticView in staticViews {
            if staticView.id == currentStaticView.id {
                continue
            }
            
            let staticFrame = CGRect(x: staticView.position.x - staticView.size.width / 2,
                                     y: staticView.position.y - staticView.size.height / 2,
                                     width: staticView.size.width,
                                     height: staticView.size.height)
            checkVerticalAlignments(dragFrame: dragFrame, staticFrame: staticFrame, currentStaticView: currentStaticView)
            checkHorizontalAlignments(dragFrame: dragFrame, staticFrame: staticFrame)
        }
    }
    
    
    private func checkParentCenterAlignment(parentSize: CGSize, dragFrame: CGRect) {
        let parentCenter = CGPoint(x: parentSize.width / 2, y: parentSize.height / 2)
        let dragCenter = CGPoint(x: dragFrame.midX, y: dragFrame.midY)
        
        // Vertical center line (full height)
        if abs(dragCenter.x - parentCenter.x) <= 1 {
            lines.append(Line(
                start: CGPoint(x: parentCenter.x, y: 0),
                end: CGPoint(x: parentCenter.x, y: parentSize.height)
            ))
            triggerHapticFeedback()
        }
        
        // Horizontal center line (full width)
        if abs(dragCenter.y - parentCenter.y) <= 1 {
            lines.append(Line(
                start: CGPoint(x: 0, y: parentCenter.y),
                end: CGPoint(x: parentSize.width, y: parentCenter.y)
            ))
            triggerHapticFeedback()
        }
    }
    
    private func checkVerticalAlignments(dragFrame: CGRect, staticFrame: CGRect,currentStaticView:StaticView) {
        let tolerance: CGFloat = 0.6
        
        // First, check if centers are aligned.
        if abs(dragFrame.midX - staticFrame.midX) <= tolerance {
            addVerticalLine(x: dragFrame.midX, staticFrame: staticFrame, dragFrame: dragFrame)
            return
        }
//        else if abs(dragFrame.midX - staticFrame.midX) <= 5 {
//            if let index = staticViews.firstIndex(where: { $0.id == currentStaticView.id }) {
//                staticViews[index].position = CGPoint(x: staticFrame.midX, y: currentStaticView.position.y)
//            }
//        }
        
        // Otherwise, check edge alignments.
        var xPositions = [CGFloat]()
        
        // Left-to-left alignment.
        if abs(dragFrame.minX - staticFrame.minX) <= tolerance {
            xPositions.append(dragFrame.minX)
        }
        
        // Right-to-right alignment.
        if abs(dragFrame.maxX - staticFrame.maxX) <= tolerance {
            xPositions.append(dragFrame.maxX)
        }
        
        // Drag left to static right alignment.
        if abs(dragFrame.minX - staticFrame.maxX) <= tolerance {
            xPositions.append(dragFrame.minX)
        }
        
        // Drag right to static left alignment.
        if abs(dragFrame.maxX - staticFrame.minX) <= tolerance {
            xPositions.append(dragFrame.maxX)
        }
        
        // Draw a vertical line at the center of the aligned edge positions.
        if !xPositions.isEmpty {
            let centerX = xPositions.reduce(0, +) / CGFloat(xPositions.count)
            addVerticalLine(x: centerX, staticFrame: staticFrame, dragFrame: dragFrame)
        }
    }

    private func checkHorizontalAlignments(dragFrame: CGRect, staticFrame: CGRect) {
        let tolerance: CGFloat = 0.6
        
        // First, check if centers are aligned.
        if abs(dragFrame.midY - staticFrame.midY) <= tolerance {
            addHorizontalLine(y: dragFrame.midY, staticFrame: staticFrame, dragFrame: dragFrame)
            return
        }
        
        // Otherwise, check edge alignments.
        var yPositions = [CGFloat]()
        
        // Top-to-top alignment.
        if abs(dragFrame.minY - staticFrame.minY) <= tolerance {
            yPositions.append(dragFrame.minY)
        }
        
        // Bottom-to-bottom alignment.
        if abs(dragFrame.maxY - staticFrame.maxY) <= tolerance {
            yPositions.append(dragFrame.maxY)
        }
        
        // Drag top to static bottom alignment.
        if abs(dragFrame.minY - staticFrame.maxY) <= tolerance {
            yPositions.append(dragFrame.minY)
        }
        
        // Drag bottom to static top alignment.
        if abs(dragFrame.maxY - staticFrame.minY) <= tolerance {
            yPositions.append(dragFrame.maxY)
        }
        
        // Draw a horizontal line at the center of the aligned edge positions.
        print("yPositions \(yPositions)")
        if !yPositions.isEmpty {
            let centerY = yPositions.reduce(0, +) / CGFloat(yPositions.count)
            
            addHorizontalLine(y: centerY, staticFrame: staticFrame, dragFrame: dragFrame)
            
        }
    }

    
    private func addVerticalLine(x: CGFloat, staticFrame: CGRect, dragFrame: CGRect) {
        let minY = min(staticFrame.minY, dragFrame.minY)
        let maxY = max(staticFrame.maxY, dragFrame.maxY)
        lines.append(Line(
            start: CGPoint(x: x, y: minY),
            end: CGPoint(x: x, y: maxY)
        ))
        triggerHapticFeedback()
    }
    
    private func addHorizontalLine(y: CGFloat, staticFrame: CGRect, dragFrame: CGRect) {
        let minX = min(staticFrame.minX, dragFrame.minX)
        let maxX = max(staticFrame.maxX, dragFrame.maxX)
        lines.append(Line(
            start: CGPoint(x: minX, y: y),
            end: CGPoint(x: maxX, y: y)
        ))
        triggerHapticFeedback()
    }
}



