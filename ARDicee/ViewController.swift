//
//  ViewController.swift
//  ARDicee
//
//  Created by Anastasia Lenina on 10.05.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var diceArray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        //Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
  
    func addDice(atLocation location: ARRaycastResult ){
        if let diceScene = SCNScene(named: "diceCollada.scn"){
            if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
  
                diceNode.position = SCNVector3(
                    x: location.worldTransform.columns.3.x,
                    y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                    z: location.worldTransform.columns.3.z)
                diceArray.append(diceNode)
                sceneView.scene.rootNode.addChildNode(diceNode)
                roll(dice: diceNode)
              
            }
        }
    }
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice: dice)
            }
        }
    }

    func roll(dice: SCNNode){
        let randomX = (Float(Int.random(in: 1...4)) * (Float.pi)/2)
        let randomZ = (Float(Int.random(in: 1...4)) * (Float.pi)/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 3),
                                              y: 0,
                                              z: CGFloat(randomZ * 3),
                                              duration: 0.5))
    }
    @IBAction func deleteAll(_ sender: Any) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
            diceArray.removeAll()
        }
        
        
    }
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .any)
                    
            else {
                return
            }
            
            let results = sceneView.session.raycast(query)
            guard let hitTestResult = results.first
            else {
                print("No surface found")
                return
            }
            print("touched")
            addDice(atLocation: hitTestResult)
           
        }
    }
    //MARK: - ARKSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.addChildNode( createPlane(with: planeAnchor))
    }
    //MARK: - Plane Rendering Methods
    
    func createPlane(with planeAnchor: ARPlaneAnchor ) -> SCNNode{
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]

        let planeNode = SCNNode()

        planeNode.geometry = plane
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        return planeNode
    }
}

