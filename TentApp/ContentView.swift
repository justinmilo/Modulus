//
//  ContentView.swift
//  CanvasTester
//
//  Created by Justin Smith Nussli on 12/14/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

@testable import GrippableView
import Interface
import Modular

struct ContentView: View { 
    var body: some View {
      NavigationView{
        List {
          Section(header:Text("Simple")) {
            NavigationLink(destination: SimpleSpriteUI()
              .edgesIgnoringSafeArea(.all)
              .navigationBarTitle(Text("Simple Sprite Tester")
              )
            ) {
              Text("Simple Sprite")
            }
          }
          Section(header:Text("Sprite")) {
            NavigationLink(destination: SpriteDriverViewUI()
              .edgesIgnoringSafeArea(.all)
              .navigationBarTitle(Text("Sprite Tester")
              )
            ) {
              Text("Sprite Tester")
            }
          }
          Section(header:Text("Combined")) {
            NavigationLink(destination: TentView()
              //.edgesIgnoringSafeArea(.all)
              .navigationBarTitle(Text("Tent View"))
            ){
              Text("Tent View")
            }
            NavigationLink(destination: QuadTentView()
              .edgesIgnoringSafeArea(.all)
              .navigationBarTitle(Text("Quad View"))
            ){
              Text("Quad View")
            }
          }
        }.navigationBarTitle(Text("Hmm"))
      }

  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

