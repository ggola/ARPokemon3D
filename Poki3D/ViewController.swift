//
//  ViewController.swift
//  Poki3D
//
//  Created by Giulio Gola on 17/06/2019.
//  Copyright © 2019 Giulio Gola. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
    }
    
    // Session configuration here
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ARImageTrackingConfiguration: looking for images in the real world
        let configuration = ARImageTrackingConfiguration()
        // Create image reference. Tells the app which images to track
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pokemon Cards", bundle: Bundle.main) {
            // Set configuration.trackingImages = images to detect and track in the user's environment.
            configuration.trackingImages = imageToTrack
            // Tells the renderer how many images to track
            configuration.maximumNumberOfTrackedImages = 2
            print("Images successfully added")
        }
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate: renderer - gets called every time a card in imageToTrack gets detected
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        // Check that the detected anchor in the real world is an image
        if let imageAnchor = anchor as? ARImageAnchor {
            // See which image we have detected
            print(imageAnchor.referenceImage.name!)
            // Create a new plane sitting right on the image based on image size specified in the attribute inspector
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            // Make plane a little transparent so we can see the image below
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            // Create a plane node with the AR object "plane"
            let planeNode = SCNNode(geometry: plane)
            // Rotate the plane node 90 degrees anti-clockwise (-) around the x-axis to make it horizontal
            planeNode.eulerAngles.x = -.pi/2
            // To render 3D model they must be in the format .usdz
            // Display model corresponding to card and attach it to the planeNode: eevee-card
            if imageAnchor.referenceImage.name == "eevee-card" {
                // Create a new scene which is made by using the eevee.scn file
                if let pokiScene = SCNScene(named: "art.scnassets/eevee.scn") {
                    // Create a node from the scene looking at the first (optional) of the childnode (after flatten selection)
                    if let pokiNode = pokiScene.rootNode.childNodes.first {
                        // Rotate node so it is vertical (90 degrees clockwise)
                        pokiNode.eulerAngles.x = .pi/2
                        // Add pokiNode to planeNode
                        planeNode.addChildNode(pokiNode)
                    }
                }
            }
            if imageAnchor.referenceImage.name == "oddish-card" {
                if let pokiScene = SCNScene(named: "art.scnassets/oddish.scn") {
                    if let pokiNode = pokiScene.rootNode.childNodes.first {
                        pokiNode.eulerAngles.x = .pi/2
                        planeNode.addChildNode(pokiNode)
                    }
                }
            }
            // Add the planeNode to the main node
            node.addChildNode(planeNode)
        }
        return node
    }
}
