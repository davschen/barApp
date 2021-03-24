//
//  UIUtils.swift
//  Bar
//
//  Created by David Chen on 12/20/20.
//

import Foundation
import SwiftUI
import UIKit
import Combine
import SDWebImageSwiftUI
import FirebaseStorage

struct BGColor: View {
    var body: some View {
        Color("Midnight")
            .edgesIgnoringSafeArea(.all)
    }
}

struct FS {
    public func sizeNum(fontstyle: Fontstyle) -> CGFloat {
        switch fontstyle {
        case .small, .smallBold, .smallDemiBold, .smallItalics: return 10
        case .medium, .mediumBold, .mediumDemiBold, .mediumItalics: return 16
        case .large, .largeBold, .largeDemiBold, .largeItalics: return 20
        case .header, .headerBold, .headerDemiBold, .headerItalics: return 30
        case .jumbo, .jumboBold, .jumboDemiBold, .jumboItalics: return 36
        default: return 12
        }
    }
    public func fontName(fontstyle: Fontstyle) -> String {
        switch fontstyle {
        case .smallDemiBold, .regularDemiBold, .mediumDemiBold, .largeDemiBold, .headerDemiBold, .jumboDemiBold: return "Avenir Next Demi Bold"
        case .smallBold, .regularBold, .mediumBold, .largeBold, .headerBold, .jumboBold: return "Avenir Next Bold"
        case .smallItalics, .regularItalics, .mediumItalics, .largeItalics, .headerItalics, .jumboItalics: return "Avenir Next Italic"
        default: return "Avenir Next"
        }
    }
}

struct SystemText: View {
    let text: String
    let fontstyle: Fontstyle
    
    var body: some View {
        let fontsizeNum = FS().sizeNum(fontstyle: fontstyle)
        let font = FS().fontName(fontstyle: fontstyle)
        Text("\(text)")
            .font(Font.custom(font, size: fontsizeNum))
            .foregroundColor(.white)
            .tracking(0)
    }
}

struct SystemTextTracking: View {
    let text: String
    let fontstyle: Fontstyle
    
    var body: some View {
        let fontsizeNum = FS().sizeNum(fontstyle: fontstyle)
        let tracking = CGFloat(fontsizeNum / 7)
        let font = FS().fontName(fontstyle: fontstyle)
        Text("\(text)")
            .tracking(tracking)
            .font(Font.custom(font, size: fontsizeNum))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
            .minimumScaleFactor(0.5)
    }
}

enum Fontstyle {
    case small, regular, medium, large, header, jumbo
    case smallDemiBold, regularDemiBold, mediumDemiBold, largeDemiBold, headerDemiBold, jumboDemiBold
    case smallBold, regularBold, mediumBold, largeBold, headerBold, jumboBold
    case smallItalics, regularItalics, mediumItalics, largeItalics, headerItalics, jumboItalics
}

struct SystemImage: View {
    let name: String
    let radius: CGFloat
    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, minHeight: 0)
            .cornerRadius(radius)
            .clipped()
    }
}

struct BarWebImage: View {
    let url: String
    let radius: CGFloat
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, minHeight: 0)
            .cornerRadius(radius)
            .clipped()
    }
}

struct StandardButtonView: View {
    let text: String
    var body: some View {
        Text(text)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .font(Font.custom("Avenir Next Bold", size: 12))
            .foregroundColor(.white)
            .background(Color("Pink"))
            .clipShape(Capsule())
    }
}

//SliderValue to restrict double range: 0.0 to 1.0
struct TwoSliderView: View {
    @State var leftHandleViewState = CGSize.zero
    @State var rightHandleViewState = CGSize.zero
    var body: some View {
        let leftHandleDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x >= 0 else {
                    return
                }
                self.leftHandleViewState.width = value.location.x
        }
        let rightHandleDragGesture = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged { value in
                guard value.location.x <= 0 else {
                    return
                }
                self.rightHandleViewState.width = value.location.x
        }
        return HStack(spacing: 0) {
            Circle()
                .fill(Color.white)
                .frame(width: 27, height: 27, alignment: .center)
                .offset(x: leftHandleViewState.width, y: 0)
                .gesture(leftHandleDragGesture)
                .zIndex(1)
            Rectangle()
                .frame(width: CGFloat(300.0), height: CGFloat(4.0), alignment: .center)
                .foregroundColor(Color("Pink"))
                .clipShape(Capsule())
                .zIndex(0)
            Circle()
                .fill(Color.white)
                .frame(width: 27, height: 27, alignment: .center)
                .offset(x: rightHandleViewState.width, y: 0)
                .gesture(rightHandleDragGesture)
                .zIndex(1)
        }
    }
}

struct ExampleView_Previews: PreviewProvider {
    @State private static var show = true
    static var previews: some View {
        ZStack {
            BGColor()
            VStack {
                TwoSliderView()
            }
        }
    }
}


