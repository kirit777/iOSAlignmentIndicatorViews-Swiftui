import SwiftUI




struct StaticView: Identifiable {
    let id = UUID()
    var position: CGPoint
}

struct Line: Identifiable {
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
    @State private var lines: [Line] = []
    
    
    // Predefined positions for static views
    @State var staticViews: [StaticView] = [
        StaticView(position: CGPoint(x: 50, y: 50)),   // view1
                   StaticView(position: CGPoint(x: 250, y: 50)),  // view2
                   StaticView(position: CGPoint(x: 50, y: 250)),  // view3
                   StaticView(position: CGPoint(x: 250, y: 250)), // view4
                   StaticView(position: CGPoint(x: 150, y: 150)),  // view5
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
                        .frame(width: 50, height: 50)
                        .position(staticView.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if let index = staticViews.firstIndex(where: { $0.id == staticView.id }) {
                                        staticViews[index].position =  value.location
                                    } else {
                                        print("Not found")
                                    }
                                    checkAlignment(parentSize: geometry.size)
                                }
                                .onEnded { _ in
                                    lines.removeAll()
                                }
                        )
                }
                
                // Draggable view
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 50, height: 50)
                    .position(dragPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragPosition = value.location
                                checkAlignment(parentSize: geometry.size)
                            }
                            .onEnded { _ in
                                lines.removeAll()
                            }
                    )
                
                // Alignment lines
                ForEach(lines, id: \.id) { line in
                    Path { path in
                        path.move(to: line.start)
                        path.addLine(to: line.end)
                    }
                    .stroke(Color.red, lineWidth: 0.6)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func checkAlignment(parentSize: CGSize) {
        lines.removeAll()
        let dragFrame = CGRect(x: dragPosition.x - 25, y: dragPosition.y - 25, width: 50, height: 50)
        let parentCenter = CGPoint(x: parentSize.width/2, y: parentSize.height/2)
        
        // Check parent center alignment
        checkParentCenterAlignment(dragFrame: dragFrame, parentCenter: parentCenter)
        
        // Check alignment with other views
        for staticView in staticViews {
            let staticFrame = CGRect(x: staticView.position.x - 25,
                                     y: staticView.position.y - 25,
                                     width: 50, height: 50)
            checkVerticalAlignments(dragFrame: dragFrame, staticFrame: staticFrame)
            checkHorizontalAlignments(dragFrame: dragFrame, staticFrame: staticFrame)
        }
    }
    
    private func checkParentCenterAlignment(dragFrame: CGRect, parentCenter: CGPoint) {
        let dragCenter = CGPoint(x: dragFrame.midX, y: dragFrame.midY)
        
        // Vertical center line
        if abs(dragCenter.x - parentCenter.x) <= 1 {
            lines.append(Line(
                start: CGPoint(x: parentCenter.x, y: 0),
                end: CGPoint(x: parentCenter.x, y: dragFrame.maxY)
            ))
        }
        
        // Horizontal center line
        if abs(dragCenter.y - parentCenter.y) <= 1 {
            lines.append(Line(
                start: CGPoint(x: 0, y: parentCenter.y),
                end: CGPoint(x: dragFrame.maxX, y: parentCenter.y)
            ))
        }
    }
    
    private func checkVerticalAlignments(dragFrame: CGRect, staticFrame: CGRect) {
        // Left edges
        if abs(dragFrame.minX - staticFrame.minX) <= 1 {
            addVerticalLine(x: dragFrame.minX, staticFrame: staticFrame, dragFrame: dragFrame)
        }
        
        // Right edges
        if abs(dragFrame.maxX - staticFrame.maxX) <= 1 {
            addVerticalLine(x: dragFrame.maxX, staticFrame: staticFrame, dragFrame: dragFrame)
        }
        
        // Left-Right
        if abs(dragFrame.minX - staticFrame.maxX) <= 1 {
            addVerticalLine(x: dragFrame.minX, staticFrame: staticFrame, dragFrame: dragFrame)
        }
        
        // Right-Left
        if abs(dragFrame.maxX - staticFrame.minX) <= 1 {
            addVerticalLine(x: dragFrame.maxX, staticFrame: staticFrame, dragFrame: dragFrame)
        }
    }
    
    private func checkHorizontalAlignments(dragFrame: CGRect, staticFrame: CGRect) {
        // Top edges
        if abs(dragFrame.minY - staticFrame.minY) <= 1 {
            addHorizontalLine(y: dragFrame.minY, staticFrame: staticFrame, dragFrame: dragFrame)
        }
        
        // Bottom edges
        if abs(dragFrame.maxY - staticFrame.maxY) <= 1 {
            addHorizontalLine(y: dragFrame.maxY, staticFrame: staticFrame, dragFrame: dragFrame)
        }
        
        // Top-Bottom
        if abs(dragFrame.minY - staticFrame.maxY) <= 1 {
            addHorizontalLine(y: dragFrame.minY, staticFrame: staticFrame, dragFrame: dragFrame)
        }
        
        // Bottom-Top
        if abs(dragFrame.maxY - staticFrame.minY) <= 1 {
            addHorizontalLine(y: dragFrame.maxY, staticFrame: staticFrame, dragFrame: dragFrame)
        }
    }
    
    private func addVerticalLine(x: CGFloat, staticFrame: CGRect, dragFrame: CGRect) {
        let minY = min(staticFrame.minY, dragFrame.minY)
        let maxY = max(staticFrame.maxY, dragFrame.maxY)
        lines.append(Line(
            start: CGPoint(x: x, y: minY),
            end: CGPoint(x: x, y: maxY)
        ))
    }
    
    private func addHorizontalLine(y: CGFloat, staticFrame: CGRect, dragFrame: CGRect) {
        let minX = min(staticFrame.minX, dragFrame.minX)
        let maxX = max(staticFrame.maxX, dragFrame.maxX)
        lines.append(Line(
            start: CGPoint(x: minX, y: y),
            end: CGPoint(x: maxX, y: y)
        ))
    }
    
}


