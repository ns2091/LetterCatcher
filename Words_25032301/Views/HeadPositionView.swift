/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A RealityKit view that creates an entity that follows the device transform.
*/

import SwiftUI
import RealityKit

/// An immersive view that creates a flat window that smoothly translates to always be in front of the device.
struct HeadPositionView: View {
    /// The tracker that contains the logic to handle real-time transformations from the device.
    @StateObject var headTracker = HeadPositionTracker()
    
    var body: some View {
        RealityView(make: { content in
            /// The entity representation of the world origin.
            let root = Entity()
            
            /// The dimensions of the floating window.
            let width: Float = 0.3
            let height: Float = 0.2
            let thickness: Float = 0.005
            
            /// The material for the floating window.
            let material = SimpleMaterial(color: .white, roughness: 0.2, isMetallic: false)
//            material.baseColor = UIColor(white: 1.0, alpha: 0.9)
            
            /// The window panel entity.
            let floatingWindow = ModelEntity(
                mesh: .generateBox(width: width, height: height, depth: thickness),
                materials: [material]
            )
            
            // テキスト「Test」を追加
            let textMesh = MeshResource.generateText(
                "Test",
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: 0.05), // サイズを適切に調整
                alignment: .center // テキストのアライメントを中央に
            )
            
            let textMaterial = SimpleMaterial(color: .gray, roughness: 0, isMetallic: false) // ここでテキストの色を青に指定しています
            let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
            
            // テキストの境界ボックスを取得
            let bounds = textMesh.bounds
            
            // テキストをウィンドウの中央に配置
            textEntity.position = [
                -bounds.center.x, // X軸の中央位置を調整
                -bounds.center.y, // Y軸の中央位置を調整
                thickness / 2 + 0.005 // Z軸はウィンドウの前に少し浮かせる
            ]
            
            // テキストをウィンドウに追加
            floatingWindow.addChild(textEntity)
            
            // Add the floating window to the root entity.
            root.addChild(floatingWindow)
            
            /// The distance that the content extends out from the device.
            let distance: Float = 1.0
            
            // Set the closure component to the root, enabling the window to update over time.
            root.components.set(ClosureComponent(closure: { deltaTime in
                /// The current position of the device.
                guard let currentTransform = headTracker.originFromDeviceTransform() else {
                    return
                }

                /// The target position in front of the device.
                let targetPosition = currentTransform.translation() - distance * currentTransform.forward()
                
                // ウィンドウを右上に調整するためのオフセット（Y軸プラス、X軸プラス）
                let verticalOffset: Float = 0.2   // 上方向へのオフセット
                let horizontalOffset: Float = 0.3 // 右方向へのオフセット
                let adjustedPosition = targetPosition + [horizontalOffset, verticalOffset, 0]

                /// The interpolation ratio for smooth movement.
                let ratio = Float(pow(0.5, deltaTime / (16 * 1E-3)))

                /// The new position of the floating window.
                let newPosition = ratio * floatingWindow.position(relativeTo: nil) + (1 - ratio) * adjustedPosition
                
                // Update the position of the floating window.
                floatingWindow.setPosition(newPosition, relativeTo: nil)
                floatingWindow.components.set(BillboardComponent())
                
                // Make the window face the user by aligning it with the device orientation
                // (以前の lookAt による回転コードを削除)
            }))

            // Add the root entity to the `RealityView`.
            content.add(root)
        }, update: { _ in })
    }
    // var billboard = BillboardComponent()
    // billboard.RealityView = 1.0
    // entity.components.set(billboard)
}

#Preview(windowStyle: .automatic) {
    HeadPositionView()
}

