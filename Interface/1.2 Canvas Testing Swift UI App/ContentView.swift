//
//  ContentView.swift
//  CanvasTester
//
//  Created by Justin Smith  on 12/14/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

@testable import GrippableView

struct ContentView: View {
    var body: some View {
      NavigationView{
        List {
          Section(header:Text("Handles")) {
          NavigationLink(destination: OldHandleTesterUI()
            .navigationBarTitle(Text("Handle Tester"))
          ) {
            // existing contents…
            Text("Handle Tester")
          }
          NavigationLink(destination: SimpleHandleViewTesterUI()
            .navigationBarTitle(Text("Simple Handle View Tester"))

          ) {
            // existing contents…
            Text("Simple Handle View Tester")
          }
          NavigationLink(destination: BoundedHandleViewTesterUI()
            .navigationBarTitle(Text("Bounded Handle Tester"))
          ) {
            // existing contents…
            Text("Bounded Handle View Tester")
            
          }
          NavigationLink(destination: HandleGroupTesterUI()
            .navigationBarTitle(Text("Handle Group Tester"))
          ) {
            Text("Handle Group Tester")
          }
          NavigationLink(destination: RectGroupTesterUI()
            .navigationBarTitle(Text("Rect Group Tester"))

          ) {
            Text("Rect Group Tester")
          }
          }
          
          Section(header:Text("Scroll")){
            
            NavigationLink(destination:
              GrowUI()
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle(Text("Grow Tester UI"))
            ){
              Text("Grow Tester UI")
            }
            NavigationLink(destination:
              GrowCenteredUI()
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle(Text("Grow Centered UI"))
            ){
              Text("Grow Centered UI")
            }
            NavigationLink(destination:
              ContentScrollUI()
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle(Text("Content Scroll UI"))
            ){
              Text("Content Scroll UI")
            }
          }
          Section(header:Text("Combined")){
            NavigationLink(destination:
              CanvasSelectionUI()
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle(Text("Canvas Selection UI"))
            ){
              Text("Canvas Selection UI")
            }
          }
        }.navigationBarTitle(Text("Some Different Scroll States"))
      }

  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

