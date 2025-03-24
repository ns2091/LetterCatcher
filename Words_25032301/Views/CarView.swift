import Foundation
import SwiftUI
import RealityKit
import SceneKit

extension Notification.Name {
    static let tappedBall = Notification.Name("tappedBall")
    static let wordCompleted = Notification.Name("wordCompleted")
}

func playSoundEndlessly(for entity: Entity, audioName: String, minDelay: TimeInterval, maxDelay: TimeInterval) {
    // ランダムな遅延時間を決定
    let randomDelay = Double.random(in: minDelay...maxDelay)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
        let configuration = AudioFileResource.Configuration(shouldLoop: false)
        guard let audio = try? AudioFileResource.load(named: audioName, configuration: configuration) else {
            print("Failed to load audio file.")
            return
        }
        // 音声を再生
        entity.playAudio(audio)
        
        // 再帰呼び出しで次の再生をスケジュール
        playSoundEndlessly(for: entity, audioName: audioName, minDelay: minDelay, maxDelay: maxDelay)
    }
}

func setRandomPosition(for entity: Entity, for modelEntity: Entity) {
    // ランダムな位置を割り当て
    let x = Float.random(in: -1.5...1.5)
    let y = Float.random(in: 1.5...1.8)
    let z = Float.random(in: -1.5...1.5)
    entity.position      = SIMD3<Float>(x, y, z)
    modelEntity.position = SIMD3<Float>(x, y, z)
    modelEntity.components.set(BillboardComponent())
}

struct CarView: View {
    
    @State private var entities: [Entity] = []
    @State private var modelEntities: [Entity] = []

    /// The gain value of the audio source.
    @State private var gain: Audio.Decibel = .zero
    
    @StateObject var headTracker = HeadPositionTracker()

    /// The direct signal that emits from the audio source.
    @State private var directLevel: Audio.Decibel = .zero
    @State private var baseTextEntity: ModelEntity? = nil

    /// The reverb of the audio source.
    @State private var reverbLevel: Audio.Decibel = .zero
    
    /// Track if the model is loaded
    @State private var isModelLoaded = false
    
    @State private var text: String = ""
    @State private var bonusChara: Entity? = nil
    @State private var shouldAddBonusChara = false
    
    private let answers: [String] = [
        "ASTRONAUT",
        "ROBOT"
    ]
    
    private let characters: [Character] = [
        Character(char: "A", modelFile: "A_alphabet_lore.usdz",     soundFile: "A.mp3", scale: 0.15, rotate: .pi/8),
        Character(char: "B", modelFile: "B_albhabet_lore.usdz",     soundFile: "B.mp3", scale: 0.15, rotate: .pi/8),
        Character(char: "N", modelFile: "N_Alphabet_Lore.usdz",     soundFile: "N.mp3", scale: 0.15, rotate: .pi/8),
        Character(char: "O", modelFile: "O_Alt_Alphabet_Lore.usdz", soundFile: "O.mp3", scale: 0.15, rotate: .pi/8),
        Character(char: "R", modelFile: "R_Alphabet_Lore.usdz",     soundFile: "R.mp3", scale: 0.15, rotate: .pi/8),
        Character(char: "S", modelFile: "S_Alphabet_Lore.usdz",     soundFile: "S.mp3", scale: 0.15, rotate: .pi/8),
        Character(char: "T", modelFile: "T_Alphabet_Lore.usdz",     soundFile: "T.mp3", scale: 0.15, rotate: .pi/8),
    ]
    
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                if let name = value.entity.name as String? {
                    text += name
                    for _ in 0..<characters.count {
//                        setRandomPosition(for: entities[i], for: modelEntities[i])
                    }
                    
                    NotificationCenter.default.post(name: .tappedBall, object: "Tapped: \(name)")
                    print("Text: \(text)")
                    
                    if answers.contains(text) {
                        print("reached!")
                        NotificationCenter.default.post(name: .wordCompleted, object: text)
                        
                        let bonusChara = Entity()
                                                
                        // 最後にタップされた文字の位置を取得
                        var clearCharaPos:SIMD3<Float> = entities.first( where: {$0.name == name })?.position ?? [0, 0, 0]
                        
                        // ボーナスキャラクターをその位置に設定
                        bonusChara.position = clearCharaPos
                        bonusChara.components.set(BillboardComponent())
                        
                        Task {
                            do {
                                // robot_walk_idle.usdzを読み込む
                                let model = try await Entity.loadModel(named: "robot_walk_idle.usdz")
                                
                                // モデルサイズを適切に設定
                                if let modelComponent = model.components[ModelComponent.self] as? ModelComponent {
                                    let boundingBox = modelComponent.mesh.bounds
                                    let currentSize = boundingBox.extents
                                    
                                    // ロボットモデルに適したサイズに調整
                                    let targetHeight: Float = 0.4
                                    let scaleFactor = targetHeight / currentSize.y
                                    
                                    // アスペクト比を維持してスケール
                                    model.scale = [scaleFactor, scaleFactor, scaleFactor]
                                }

                                // モデルの位置を原点に設定（bonusCharaの位置を基準にするため）
                                model.position = [0.0, 0.0, 1.5]
                                
                                // モデルをy軸周りに少し回転
                                model.orientation = simd_quatf(angle: .pi/6, axis: [1, 0, 0])
                                
                                // モデルをボーナスキャラクターの子として追加
                                bonusChara.addChild(model)
                                
                                // ステートを更新
                                await MainActor.run {
                                    self.bonusChara = bonusChara
                                    self.shouldAddBonusChara = true // 追加のフラグをセット
                                    print("ボーナスキャラクターの位置: \(clearCharaPos)")
                                }
                                
                            } catch {
                                print("Failed to load 3D model: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
    }
    
    var body: some View {
        RealityView(make: { content in
            let sphereCount = 7
            
            for _ in 0..<sphereCount {
                let entity      = Entity()
                let modelEntity = Entity()
                entities.append(entity)
                modelEntities.append(modelEntity)
            }
            
            for i in 0..<sphereCount {
                entities[i].name      = "chara_\(i)"
                modelEntities[i].name = "\(characters[i].char)"
                
                setRandomPosition(for: entities[i], for: modelEntities[i])
                
                /// The name of the audio source.
                let audioName: String = characters[i].soundFile
                
                /// The configuration to loop the audio file continously.
                let configuration = AudioFileResource.Configuration(shouldLoop: true)
                
                // Load the audio source and set its configuration.
                guard let audio = try? AudioFileResource.load(
                    named: audioName,
                    configuration: configuration
                ) else {
                    // Handle the error if the audio file fails to load.
                    print("Failed to load audio file.")
                    return
                }
                
                /// The focus for the directivity of the spatial audio.
                let focus: Double = 0.5
                
                // Add a spatial component to the entity that emits in the forward direction.
                entities[i].spatialAudio = SpatialAudioComponent(directivity: .beam(focus: focus))
                
                // Set the entity to play audio.
//                entities[i].playAudio(audio)
                playSoundEndlessly(for: entities[i], audioName: audioName, minDelay:Double(1), maxDelay:Double(5))
                
                // Load the 3D model
                Task {
                    do {
                        let model = try await Entity.loadModel(named: characters[i].modelFile)
                        
                        // モデルサイズを非常に小さく設定
                        if let modelComponent = model.components[ModelComponent.self] as? ModelComponent {
                            let boundingBox = modelComponent.mesh.bounds
                            let currentSize = boundingBox.extents
                            
                            // より小さいサイズに調整（以前の半分程度）
                            let targetHeight: Float = 0.15
                            let scaleFactor = targetHeight / currentSize.y
                            
                            // アスペクト比を維持してスケール
                            model.scale = [scaleFactor, scaleFactor, scaleFactor]
                        }
                        
                        // モデルの位置を少し前に出して目立たせる
                        model.position = [0, 0, -0.2]
                        
                        // モデルを少し回転させて見やすくする
                        model.orientation = simd_quatf(angle: .pi/8, axis: [0, 1, 0])
                        
                        // Add the model to the modelEntity
                        modelEntities[i].addChild(model)
                        
                        // Update the UI state
                        await MainActor.run {
                            self.isModelLoaded = true
                        }
                        
                    } catch {
                        print("Failed to load 3D model: \(error.localizedDescription)")
                    }
                }
                
                modelEntities[i].components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: SIMD3<Float>(0.2, 0.3, 0.1))]))
                modelEntities[i].components.set(InputTargetComponent())
                
                
                content.add(entities[i])
                content.add(modelEntities[i])
                }
            
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
                    "\(text)",
                    extrusionDepth: 0.001,
                    font: .systemFont(ofSize: 0.05), // サイズを適切に調整
                    alignment: .center // テキストのアライメントを中央に
                )
            
                let textMaterial = SimpleMaterial(color: .gray, roughness: 0, isMetallic: false) // ここでテキストの色を青に指定しています
                let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
                
                if self.baseTextEntity == nil {
                    self.baseTextEntity = textEntity
                }
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
                    
                    // ウィンドウを右上に調整するためのオフセット（Y軸プラス、X軸プラス）の
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
            
        }, update: { content in
            // ここでbonusCharaの更新を処理します
            if shouldAddBonusChara, let bonusChara = bonusChara {
                // すでに追加されているかチェック
                if bonusChara.parent == nil {
                    content.add(bonusChara)
                    print("ボーナスキャラクターを追加しました: 位置=\(bonusChara.position)")
                    // フラグをリセット
                    shouldAddBonusChara = false
                }
            }}
        )
        .onChange(of: text) { newText in
            guard let textEntity = self.baseTextEntity else { return }
            let newMesh = MeshResource.generateText(
                "\(newText)",
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: 0.05),
                alignment: .center
            )
            if var modelComponent = textEntity.model {
                modelComponent.mesh = newMesh
                textEntity.model = modelComponent
            }
            let bounds = newMesh.bounds
            let thickness: Float = 0.005
            textEntity.position = [
                -bounds.center.x,
                -bounds.center.y,
                thickness / 2 + 0.005
            ]
        }
        .onChange(of: gain) {
            for i in 0..<entities.count {
                entities[i].spatialAudio?.gain = gain
            }
        }
        .onChange(of: directLevel) {
            for i in 0..<entities.count {
                entities[i].spatialAudio?.directLevel = directLevel
            }
        }
        .onChange(of: reverbLevel) {
            for i in 0..<entities.count {
                entities[i].spatialAudio?.reverbLevel = reverbLevel
            }
        }
        .gesture(tapGesture)
    }
}
