//
//  YYSliderView.swift
//  BitStoreGlobal
//
//  Created by ChuanqingYang on 2022/6/27.
//

import SwiftUI

struct YYSliderView: View {
    
    @Binding var currentValue:CGFloat
    @State var showPopover:Bool = false
    @State var popoverDirection:Popover_Direction = .top
    
    @State var minColors:[Color] = [.red,.blue]
    @State var lineHeight:CGFloat = 6
    @State var loca:CGPoint = .zero
    @State var isEdting:Bool = false
    @State var popOverFrame:CGRect = .zero
    @State var popOverPading:CGFloat = 10
    @State var thumbWidth:CGFloat = 25
    @State var popOverAnchorPading:CGFloat = 20
    @State var popOverCornerRadius:CGFloat = 12
    @State var popOverArrowSize:CGSize = CGSize(width: 20, height: 15)
    
    @State var anchorLeadingTrailing:CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: Alignment.leading) {
                
                // 背景条
                RoundedRectangle(cornerRadius: lineHeight / 2)
                    .frame(height:lineHeight)
                    .padding(.leading,self.anchorLeadingTrailing)
                    .padding(.trailing,self.anchorLeadingTrailing)
                    .foregroundColor(.gray)
                    
                    
                
                // 前景条
                RoundedRectangle(cornerRadius: lineHeight / 2)
                    .frame(height:lineHeight)
                    .padding(.leading,self.anchorLeadingTrailing)
                    .padding(.trailing,self.anchorLeadingTrailing)
                    .foregroundStyle(.linearGradient(colors: minColors, startPoint: .leading, endPoint: .trailing))
                    .frame(width:self.loca.x + self.anchorLeadingTrailing)
                
                Circle()
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    .frame(width: thumbWidth, height: thumbWidth, alignment: .center)
                    .position(x:self.loca.x,y: geo.size.height / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged({ dragValue in
                                self.isEdting = true
                                if dragValue.location.x <= self.anchorLeadingTrailing || dragValue.location.x >= geo.size.width - self.anchorLeadingTrailing{
                                }else {
                                    self.loca = dragValue.location
                                }
                            })
                            .onEnded({ dragValue in
                                self.isEdting = true
                            })
                    ).onAppear {
                        self.anchorLeadingTrailing = self.popOverPading + self.popOverCornerRadius + self.popOverArrowSize.width / 2
                        self.loca = CGPoint(x: self.anchorLeadingTrailing, y: 0)
                    }
                
                if isEdting && showPopover{
                    VStack(spacing:0) {
                        if self.popoverDirection == .bottom {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height:self.popOverArrowSize.height)
                                .fixedSize()
                            
                            Text("\(getRate(with:geo))")
                                .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .lineLimit(1)
                        }
                        
                        if self.popoverDirection == .top {
                            Text("\(getRate(with:geo))")
                                .padding(.init(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .lineLimit(1)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height:self.popOverArrowSize.height)
                                .fixedSize()
                        }
                    }
                    .background {
                        PopoverShape(anchorPoint: CGPoint(x: getAnchorX(geo: geo), y: 0),cornerRadius:self.popOverCornerRadius,arrowSize:self.popOverArrowSize,direction:self.popoverDirection)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)
                    }
                    .frameReader(rect: { frame in
                        self.popOverFrame = frame
                    })
                    .position(x: getPopoverX(geo: geo), y:getPopoverY(geo: geo))

                }
            }
            .background(.white)
            .animation(.linear(duration: 0.25), value: self.isEdting)
        }
    }
    
    func getAnchorX(geo:GeometryProxy) -> CGFloat {
        
        let minLeading = self.popOverFrame.width / 2 + self.popOverPading
        if self.loca.x < minLeading {
            return self.loca.x - self.popOverArrowSize.width / 2
        }
        
        let minTrailing = geo.size.width - minLeading
        if self.loca.x >  minTrailing {
            return self.popOverFrame.width / 2 + (self.loca.x - minTrailing)
        }
        
        return self.popOverFrame.width / 2
    }
    
    func getPopoverX(geo:GeometryProxy) -> CGFloat {
        let minLeading = self.popOverFrame.width / 2 + self.popOverPading
        if self.loca.x < minLeading {
            return minLeading
        }
        
        let minTrailing = geo.size.width - minLeading
        if self.loca.x >  minTrailing {
            return minTrailing
        }
                
        return self.loca.x
    }
    
    func getPopoverY(geo:GeometryProxy) -> CGFloat {
        
        if self.popoverDirection == .bottom {
            return geo.size.height / 2 + thumbWidth + popOverAnchorPading
        }
        
        if self.popoverDirection == .top {
            return geo.size.height / 2 - thumbWidth - popOverAnchorPading
        }
        
        return 0
    }
    
    func getRate(with geo:GeometryProxy) -> String {
        var posi = self.loca.x - self.anchorLeadingTrailing
        if posi < 0 {
            posi = 0
        }
        let rate = posi / (geo.size.width - self.anchorLeadingTrailing * 2)
        let rateStr = "\(rate)".formateRate()
        self.currentValue = Double(rateStr) ?? 0
        
        guard let rateDouble = Double(rateStr) else { return "" }
        
        let intRate = Int(rateDouble * 100)
        
        return "\(intRate) %"
    }

}

struct YYSliderView_Previews: PreviewProvider {
    static var previews: some View {
        YYSliderView(currentValue: .constant(0))
    }
}

/**-----------------------------------------------------------------------Shape--------------------------------------------------------------------------------------------*/

enum Popover_Direction {
    case top
    case bottom
}

struct PopoverShape: Shape {
    
    let anchorPoint:CGPoint
    let cornerRadius:CGFloat
    let arrowSize:CGSize
    let direction:Popover_Direction
    
    func path(in rect: CGRect) -> Path {
        
        if direction == .bottom {
            let bezierPath = drawPopoverBottomPath(in: rect)
            let path = Path(bezierPath.cgPath)
            return path
        }
        
        let bezierPath = drawPopoverTopPath(in: rect)
        let path = Path(bezierPath.cgPath)
        return path
    }
    
    func drawPopoverTopPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        // anchor 顶点
        path.move(to: CGPoint(x: anchorPoint.x, y: rect.size.height))
        // anchor 三角右边
        path.addLine(to: CGPoint(x: anchorPoint.x + arrowSize.width / 2, y:rect.size.height - arrowSize.height))
        // 右下边
        path.addLine(to: CGPoint(x: rect.size.width - cornerRadius, y: rect.size.height - arrowSize.height))
        // 右下角
        path.addArc(withCenter: CGPoint(x: rect.size.width - cornerRadius, y:rect.size.height - arrowSize.height - cornerRadius), radius: cornerRadius, startAngle: .pi / 2, endAngle: 0, clockwise: false)
        // 右边
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.origin.y + cornerRadius))
        // 左上角
        path.addArc(withCenter: CGPoint(x: rect.size.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi * 3 / 2, clockwise: false)
        // 上边
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.origin.y))
        // 左上角
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi * 3 / 2, endAngle: .pi, clockwise: false)
        // 左边
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.size.height - arrowSize.height - cornerRadius))
        // 左下角
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: rect.size.height - arrowSize.height - cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi / 2, clockwise: false)
        // 左下边
        path.addLine(to: CGPoint(x: anchorPoint.x - arrowSize.width / 2, y: rect.size.height - arrowSize.height))
        
        path.lineJoinStyle = .round
        path.close()
        
        return path
    }
    
    func drawPopoverBottomPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        // anchor 顶点
        path.move(to: anchorPoint)
        // anchor 三角左边
        path.addLine(to: CGPoint(x: anchorPoint.x - arrowSize.width / 2, y: arrowSize.height))
        // 左上边
        path.addLine(to: CGPoint(x: rect.origin.x + cornerRadius, y: arrowSize.height))
        // 左上角
        path.addArc(withCenter: CGPoint(x: rect.origin.x + cornerRadius, y: arrowSize.height + cornerRadius), radius: cornerRadius, startAngle: .pi * 3 / 2, endAngle: .pi, clockwise: false)
        // 左边
        path.addLine(to: CGPoint(x: rect.origin.x, y: rect.size.height - cornerRadius))
        // 左下角
        path.addArc(withCenter: CGPoint(x: rect.origin.x + cornerRadius, y: rect.size.height - cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi / 2, clockwise: false)
        // 底边
        path.addLine(to: CGPoint(x: rect.size.width - cornerRadius, y: rect.size.height))
        // 右下角
        path.addArc(withCenter: CGPoint(x: rect.size.width - cornerRadius, y: rect.size.height - cornerRadius), radius: cornerRadius, startAngle: .pi / 2, endAngle: 0, clockwise: false)
        // 右边
        path.addLine(to: CGPoint(x: rect.size.width, y: arrowSize.height + cornerRadius))
        // 右上角
        path.addArc(withCenter: CGPoint(x: rect.size.width - cornerRadius, y: arrowSize.height + cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi * 3 / 2, clockwise: false)
        // 右上边
        path.addLine(to: CGPoint(x: anchorPoint.x + arrowSize.width / 2, y: arrowSize.height))
        
        path.lineJoinStyle = .round
        path.close()
        
        return path
    }
}

/**-----------------------------------------------------------------------utls--------------------------------------------------------------------------------------------*/

extension String {
    func formateRate() -> String {
//        guard let user = currentUser else {return "--%"}
        let format = NumberFormatter.init()
        format.locale = Locale.init(identifier: "en")
        format.usesGroupingSeparator = true
        format.numberStyle = .decimal
        format.minimumFractionDigits = 2
        format.maximumFractionDigits = 2
        format.roundingMode = .halfUp
        
        guard let doubleValue = Double(self) else { return "--%" }
        
        guard let num = format.string(from: NSNumber.init(value: doubleValue)) else { return "--%" }
        
        return num
    }
}

public extension View {
    /// Read a view's frame. From https://stackoverflow.com/a/66822461/14351818
    func frameReader(in coordinateSpace: CoordinateSpace = .global, rect: @escaping (CGRect) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentFrameReaderPreferenceKey.self, value: geometry.frame(in: coordinateSpace))
                    .onPreferenceChange(ContentFrameReaderPreferenceKey.self) { newValue in
                        DispatchQueue.main.async {
                            rect(newValue)
                        }
                    }
            }
            .hidden()
        )
    }

    /**
     Read a view's size. The closure is called whenever the size itself changes, or the transaction changes (in the event of a screen rotation.)

     From https://stackoverflow.com/a/66822461/14351818
     */
    func sizeReader(transaction: Transaction? = nil, size: @escaping (CGSize) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentSizeReaderPreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newValue in
                        DispatchQueue.main.async {
                            size(newValue)
                        }
                    }
                    .onValueChange(of: transaction?.animation) { _, _ in
                        DispatchQueue.main.async {
                            size(geometry.size)
                        }
                    }
            }
            .hidden()
        )
    }
}

struct ContentFrameReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect { return CGRect() }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

struct ContentSizeReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize { return CGSize() }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

/// Detect changes in bindings (fallback of `.onChange` for iOS 13+). From https://stackoverflow.com/a/64402663/14351818
struct ChangeObserver<Content: View, Value: Equatable>: View {
    let content: Content
    let value: Value
    let action: (Value, Value) -> Void

    init(value: Value, action: @escaping (Value, Value) -> Void, content: @escaping () -> Content) {
        self.value = value
        self.action = action
        self.content = content()
        _oldValue = State(initialValue: value)
    }

    @State private var oldValue: Value

    var body: some View {
        DispatchQueue.main.async {
            if oldValue != value {
                action(oldValue, value)
                oldValue = value
            }
        }
        return content
    }
}

public extension View {
    /// Detect changes in bindings (fallback of `.onChange` for iOS 13+).
    func onValueChange<Value: Equatable>(
        of value: Value,
        perform action: @escaping (_ oldValue: Value, _ newValue: Value) -> Void
    ) -> some View {
        ChangeObserver(value: value, action: action) {
            self
        }
    }
}


