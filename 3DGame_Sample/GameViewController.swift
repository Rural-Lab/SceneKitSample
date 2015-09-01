import UIKit
import QuartzCore
import SceneKit

import CoreMotion
import CoreLocation

class GameViewController: UIViewController ,CLLocationManagerDelegate, SCNSceneRendererDelegate {
    
    var tmpint=0
    
    var lm: CLLocationManager! = nil
    
    // create instance of MotionManager
    let motionManager: CMMotionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // シーンオブジェクトを作成。これ以降シーンオブジェクトのルートノードに
        // 子ノードを追加していくことでシーンにオブジェクトを追加していく。
        // ここではdaeファイル(3Dデータ)の読み込みを行っている。
        let scene = SCNScene(named: "art.scnassets/ship.dae")
        
        scene!.background.contents = [
            UIImage(named: "envmap_interstellar/right.tga")!,
            UIImage(named: "envmap_interstellar/left.tga")!,
            UIImage(named: "envmap_interstellar/top.tga")!,
            UIImage(named: "envmap_interstellar/bottom.tga")!,
            UIImage(named: "envmap_interstellar/front.tga")!,
            UIImage(named: "envmap_interstellar/back.tga")!
        ]
        
        // シーンオブジェクトを撮影するためのノードを作成
        let cameraNode = SCNNode()
        // カメラノードにカメラオブジェクトを追加
        cameraNode.camera = SCNCamera()
        // シーンのルートノードにカメラノードを追加
        scene!.rootNode.addChildNode(cameraNode)
        
        // カメラの位置を設定する。
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
        // シーンに光を与える為のノードを作成
        let lightNode = SCNNode()
        // ライトノードに光を表すライトオブジェクトを追加
        lightNode.light = SCNLight()
        // ライトオブジェクトの光属性を全方位への光を表す属性とする
        lightNode.light!.type = SCNLightTypeOmni
        // ライトオブジェクトの位置を設定する
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        // シーンのルートノードにライトノードを追加
        scene!.rootNode.addChildNode(lightNode)
        
        // シーンに環境光を与える為に環境光ノードを作成
        let ambientLightNode = SCNNode()
        // 環境光ノードにライトオブジェクトを追加
        ambientLightNode.light = SCNLight()
        // ライトオブジェクトの光属性を環境光を表す属性とする
        ambientLightNode.light!.type = SCNLightTypeAmbient
        // 環境光の色を設定する
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        // シーンのルートノードに環境光ノードを追加
        scene!.rootNode.addChildNode(ambientLightNode)
        
        // ノード名を指定してshipのノードをシーンから取得する
        let ship = scene!.rootNode.childNodeWithName("ship", recursively: true)!
        // shipに対してアニメーションを設定する。ここではy軸を中心とした永続的な回転を設定している。
        
        // シーンを表示するためのビューへの参照を取得
        let scnView = self.view as! SCNView
        
        // ビューのシーンに今までオブジェクトを追加してきたシーンを代入
        scnView.scene = scene
        
        // シーンに追加されたカメラを単純に操作できるようにする
        scnView.allowsCameraControl = true
        
        // ビューのフレーム数等のパフォーマンスに関わる統計情報をビューの下部に表示
        scnView.showsStatistics = true
        
        // ビューの背景色を黒に指定
        scnView.backgroundColor = UIColor.blackColor()
        
        // ビューがタップされた時のメソッドを指定してリコグナイザを作成し、ビューのジェスチャに追加する
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        let gestureRecognizers = NSMutableArray()
        gestureRecognizers.addObject(tapGesture)
        if let existingGestureRecognizers = scnView.gestureRecognizers {
            gestureRecognizers.addObjectsFromArray(existingGestureRecognizers)
        }
        scnView.gestureRecognizers = gestureRecognizers as [AnyObject]
        
        lm = CLLocationManager()
        // 位置情報を取るよう設定
        
        // ※ 初回は確認ダイアログ表示
        lm.requestAlwaysAuthorization()
        lm.delegate = self
        lm.distanceFilter = 1.0 // 1m毎にGPS情報取得
        lm.desiredAccuracy = kCLLocationAccuracyBest // 最高精度でGPS取得
        lm.startUpdatingLocation() // 位置情報更新機能起動
        lm.startUpdatingHeading() // コンパス更新機能起動
        
        // Initialize MotionManager
        motionManager.deviceMotionUpdateInterval = 0.05 // 20Hz
        
        // Start motion data acquisition
        motionManager.startDeviceMotionUpdatesToQueue( NSOperationQueue.currentQueue(), withHandler:{
            deviceManager, error in
            
            var attitude: CMAttitude = deviceManager.attitude
            
            var quaternion: CMQuaternion = attitude.quaternion
            
            cameraNode.rotation = SCNQuaternion(x: Float32(quaternion.x), y: Float32(quaternion.y), z: Float32(quaternion.z), w: Float32(quaternion.w))

            let gq1 = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0)
            let gq2 = GLKQuaternionMake(Float(quaternion.x), Float(quaternion.y), Float(quaternion.z), Float(quaternion.w))
            let qp = GLKQuaternionMultiply(gq1, gq2)
            let rq = SCNVector4Make(qp.x, qp.y, qp.z, qp.w)
            
            cameraNode.orientation = rq
        })
    }
    
    // ビューがタップされた時の挙動を規定する
    func handleTap(gestureRecognize: UIGestureRecognizer) {
        
        // シーンが追加されたビューへの参照を取得
        let scnView = self.view as! SCNView
        
        // ビューのどの位置がタップされたかを読み込む
        let p = gestureRecognize.locationInView(scnView)
        // シーンのオブジェクトへのタップ結果をSCNHitTestResultの配列を返すことで取得する
        let hitResults = scnView.hitTest(p, options: nil)
        
        // タップ結果が一つでもあればアニメーション処理を行う
        if hitResults!.count > 0 {
            
            // タップ結果の初めのオブジェクト（箱型オブジェクト）を取り出す
            let result: AnyObject! = hitResults
            
            // 箱型オブジェクトのマテリアルを取り出す
            let material = result!.node!.geometry!.firstMaterial
            
            // 旧来のUIView AnimationAPIの使い方のようにしてマテリアルを赤く染めるアニメーションを設定する
            SCNTransaction.begin()
            SCNTransaction.setAnimationDuration(0.5)
            
            // アニメーションが終わった時の挙動を指定する
            SCNTransaction.setCompletionBlock {
                SCNTransaction.begin()
                SCNTransaction.setAnimationDuration(0.5)
                
                material!.emission.contents = UIColor.blackColor()
                
                SCNTransaction.commit()
            }
            
            material!.emission.contents = UIColor.redColor()
            
            SCNTransaction.commit()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
