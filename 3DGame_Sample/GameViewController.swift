import UIKit
import QuartzCore
import SceneKit

import CoreMotion
import CoreLocation

class GameViewController: UIViewController ,CLLocationManagerDelegate {
    
    var lm: CLLocationManager! = nil
    
    // create instance of MotionManager
    let motionManager: CMMotionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // シーンオブジェクトを作成。これ以降シーンオブジェクトのルートノードに
        // 子ノードを追加していくことでシーンにオブジェクトを追加していく。
        // ここではdaeファイル(3Dデータ)の読み込みを行っている。
        let scene = SCNScene(named: "art.scnassets/ship.dae")
        
        // シーンオブジェクトを撮影するためのノードを作成
        let cameraNode = SCNNode()
        // カメラノードにカメラオブジェクトを追加
        cameraNode.camera = SCNCamera()
        // シーンのルートノードにカメラノードを追加
        scene!.rootNode.addChildNode(cameraNode)
        
        // カメラの位置を設定する。
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        cameraNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 0)
        
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
//        ship.position = SCNVector3(x: 0, y: -10, z: 0)
        // shipに対してアニメーションを設定する。ここではy軸を中心とした永続的な回転を設定している。
//        ship.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 2, z: 0, duration: 1)))
        
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
            //            var accel: CMAcceleration = deviceManager.userAcceleration
            //            self.acc_x.text = String(format: "%.2f", accel.x)
            //            self.acc_y.text = String(format: "%.2f", accel.y)
            //            self.acc_z.text = String(format: "%.2f", accel.z)
            //
            //            var gyro: CMRotationRate = deviceManager.rotationRate
            //            self.gyro_x.text = String(format: "%.2f", gyro.x)
            //            self.gyro_y.text = String(format: "%.2f", gyro.y)
            //            self.gyro_z.text = String(format: "%.2f", gyro.z)
            //
            var attitude: CMAttitude = deviceManager.attitude
            //            self.attitude_roll.text = String(format: "%.2f", attitude.roll)
            //            self.attitude_pitch.text = String(format: "%.2f", attitude.pitch)
            //            self.attitude_yaw.text = String(format: "%.2f", attitude.yaw)
            
            var quaternion: CMQuaternion = attitude.quaternion
            
//            self.attitude_x.text = String(format: "%.2f", quaternion.x)
//            self.attitude_y.text = String(format: "%.2f", quaternion.y)
//            //            self.attitude_z.text = String(format: "%.2f", quaternion.z)
//            self.attitude_w.text = String(format: "%.2f", quaternion.w)
//            println("x:\(quaternion.x) y:\(quaternion.y) z:\(quaternion.z) w:\(quaternion.w) ")
            println("x:\(cameraNode.rotation.x),y:\(cameraNode.rotation.y),z:\(cameraNode.rotation.z)")
            println("x:\(cameraNode.position.x),y:\(cameraNode.position.y),z:\(cameraNode.position.z)")
            println("------------------------------------")
            
            cameraNode.rotation = SCNVector4(x: Float((quaternion.x+1)*180), y: Float((quaternion.y+1)*180), z: Float((quaternion.z+1)*180), w: Float(quaternion.w+1))
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
        // Release any cached data, images, etc that aren't in use.
    }
    
}
