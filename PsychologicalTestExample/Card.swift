//
//  Card.swift
//  PsychologicalTestExample
//
//  Created by myoungho on 22/01/2017.
//  Copyright © 2017 myoungho. All rights reserved.
//

import Foundation
import SpriteKit

class Card: SKSpriteNode {
    
    var front: SKTexture
    var back: SKTexture
    var touched = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(cardName:String) {
        self.front = SKTexture(imageNamed: cardName)
        self.back = SKTexture(imageNamed: cardName+"_back")
        
        super.init(texture: self.front, color: UIColor.white, size: self.front.size())
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let liftUp = SKAction.scale(to: CardDisplayScene.cardScale * 1.3, duration: 0.2)
        run(liftUp)
        
        let rotateCCW = SKAction.rotate(toAngle: CGFloat(-M_1_PI / 10), duration: 0.1)
        let rotateCW = SKAction.rotate(toAngle: CGFloat(M_1_PI / 10), duration: 0.1)
        
        let rotate = SKAction.sequence([rotateCCW, rotateCW])
        let rotateRepeat = SKAction.repeatForever(rotate)
        run(rotateRepeat, withKey: "rotate")
        
        self.texture = self.back
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let dropDown = SKAction.scale(to: CardDisplayScene.cardScale, duration: 0.2)
        run(dropDown)
        
        removeAction(forKey: "rotate")
        let rotate = SKAction.rotate(toAngle: 0, duration: 0)
        run(rotate)
        
        self.texture = self.back
        
        if !self.touched {
            
            let fold = SKAction.scaleX(to: 0.0, duration: 0.4)
            let unfold = SKAction.scaleX(to: CardDisplayScene.cardScale, duration: 0.4)
            
            run(fold, completion: {
                self.texture = self.back
                self.run(unfold)
                
                if let sparkParticlePath: String = Bundle.main.path(forResource: "CardSpark", ofType: "sks") {
                    let sparkParticleNode = NSKeyedUnarchiver.unarchiveObject(withFile: sparkParticlePath) as! SKEmitterNode
                    sparkParticleNode.position = CGPoint(x: 0, y: 0)
                    sparkParticleNode.zPosition = 10
                    self.addChild(sparkParticleNode)
                }
            })
            self.touched = true
            
        } else {
            let alert = UIAlertController(title: "알림", message: "결과를 공유하시겠습니까?", preferredStyle: .alert )
            
            let actionOK = UIAlertAction(title: "Yes",
                                         style: UIAlertActionStyle.default,
                                         handler: {(action)->Void in self.shareHandler(action, alert: alert)})
            
            let actionCandel = UIAlertAction(title: "No",
                                             style: UIAlertActionStyle.default,
                                             handler: {(action)->Void in alert.dismiss(animated: true, completion: nil)})
            
            alert.addAction(actionOK)
            alert.addAction(actionCandel)
            
            self.scene?.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func shareHandler(_ action:UIAlertAction, alert:UIAlertController) {
        alert.dismiss(animated: true, completion: nil)
        let shareText = "당신은 나에게 이런 의미입니다."
        let shareImg = UIImage(cgImage: (self.texture?.cgImage())!)
        let shareItems = [shareText,shareImg] as [Any]
        let activityController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        self.scene?.view?.window?.rootViewController?.present(activityController, animated: true, completion: nil)
    }
}
