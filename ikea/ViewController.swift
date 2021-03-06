//
//  ViewController.swift
//  ikea
//
//  Created by Mauricio Hernandez on 29/12/17.
//  Copyright © 2017 Mac User. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,ARSCNViewDelegate {
    let itemsArray:[String]=["cup","vase","boxing","table"]
    @IBOutlet var planeDetected: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var itemCollectionView: UICollectionView!
    var selectedItem:String?
    
    let configuration=ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.sceneView.debugOptions=[ARSCNDebugOptions.showFeaturePoints,ARSCNDebugOptions.showWorldOrigin]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.itemCollectionView.dataSource=self
        self.itemCollectionView.delegate=self
        self.sceneView.delegate=self
        self.registerGestureRecognizers()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerGestureRecognizers(){
        let tapGestureRecognizer=UITapGestureRecognizer(target:self,action:#selector (tapped))
        let pinchGestureRecognizer=UIPinchGestureRecognizer(target:self,action:#selector(pinch))
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    @objc func pinch(sender:UIPinchGestureRecognizer){
        let sceneView=sender.view as! ARSCNView
        let pinchLocation=sender.location(in: sceneView)
        let hitTest=sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty{
            let results=hitTest.first!
            let node=results.node
            let pinchAction=SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale=1.0
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    @objc func tapped(sender:UITapGestureRecognizer){
        let sceneView=sender.view as! ARSCNView
        let tapLocation=sender.location(in: sceneView)
        let hitTesting=sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        if !hitTesting.isEmpty{
            self.addItem(hitTestResult: hitTesting.first!)
          
        }
        else{
         
        }
    }
    
    func addItem(hitTestResult: ARHitTestResult){
        if let selectedItem=self.selectedItem{
            let scene=SCNScene(named:"Models.scnassets/\(selectedItem).scn")
            let node=(scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
            let transform=hitTestResult.worldTransform
            let thirdColumn=transform.columns.3
            node.position=SCNVector3(thirdColumn.x,thirdColumn.y,thirdColumn.z)
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! itemCell
        cell.itemLabel.text=self.itemsArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        self.selectedItem=itemsArray[indexPath.row]
        cell?.backgroundColor=UIColor.green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor=UIColor.orange
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else{return}
        DispatchQueue.main.async {
            self.planeDetected.isHidden=false
            DispatchQueue.main.asyncAfter(deadline: .now()+3){
                self.planeDetected.isHidden=true
            }
        }
       
    }

}

