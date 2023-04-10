//
//  ContentView.swift
//  ProveOfConceptRI
//
//  Created by Bruno Thuma on 29/03/23.
//

import SwiftUI

struct ContentView: View {
    let deepLinkURLString = "stage://deeplink?param1=value1&param2=UrlToTheDummy"
    
    @State var param1: String?
    @State var param2: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                if let p1 = param1, let p2 = param2 {
                    VStack {
                        Text("Received parameters")
                        Text(p1)
                        Text(p2)
                    }
                } else {
                    Text("No parameters received")
                }
                NavigationLink(
                    "Go to CameraView",
                    destination: CameraView())
                .buttonStyle(.borderedProminent)
                Button("Open Stage") {
                    if let deepLinkURL = URL(string: deepLinkURLString) {
                                    UIApplication.shared.open(deepLinkURL, options: [:], completionHandler: nil)
                                }
                }
            }
        }
        .onOpenURL { url in
            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let params = urlComponents.queryItems {
                param1 = params.first(where: { $0.name == "param1" })?.value
                param2 = params.first(where: { $0.name == "param2" })?.value
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
