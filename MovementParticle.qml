import QtQuick 2.9
import QtQuick.Particles 2.0

Item {
    objectName: "Movement Scene"
    width: 50
    height: 50
    property var emitter1: movementEmitter1
    property var emitter2: movementEmitter2

    ParticleSystem {
        id: movementSystem
    }

    ImageParticle {
        objectName: "PieceMovementElectricity"
        groups: ["PieceMovementParticles"]
        source: "qrc:///images/particles/bfgboltarc.png"
        color: "#00aaff"
        colorVariation: 0
        alpha: 1
        alphaVariation: 0
        redVariation: 0
        greenVariation: 0
        blueVariation: 0
        rotation: 0
        rotationVariation: 0
        autoRotation: false
        rotationVelocity: 0
        rotationVelocityVariation: 0
        entryEffect: ImageParticle.Fade
        system: movementSystem
    }

    ImageParticle {
        objectName: "PieceMovementGlow"
        groups: ["PieceMovementParticleGlow"]
        source: "qrc:///images/particles/plasma.png"
        //color: "#00aaff"
        colorVariation: 0
        alpha: 0.4
        alphaVariation: 0
        redVariation: 0
        greenVariation: 0
        blueVariation: 0
        rotation: 0
        rotationVariation: 0
        autoRotation: false
        rotationVelocity: 0
        rotationVelocityVariation: 0
        entryEffect: ImageParticle.Fade
        system: movementSystem
    }

    TrailEmitter {

        id: movementEmitter1
        objectName: "PieceMovementTrailEmitter"
        x: 15
        y: 15
        width: 50
        height: 10
        enabled: false
        group: "PieceMovementParticleGlow"
        emitRate: 14
        maximumEmitted: 4
        startTime: 0
        lifeSpan: 200
        lifeSpanVariation: 0
        size: 20
        sizeVariation: 1
        endSize: 30
        velocityFromMovement: 13
        system: movementSystem
        velocity: PointDirection {
            x: 35
            xVariation: 22
            y: 1
            yVariation: 4
        }
        acceleration: PointDirection {
            x: 11
            xVariation: 0
            y: 3
            yVariation: 0
        }
        shape: EllipseShape {
            fill: false
        }
    }

    Emitter {
        id: movementEmitter2
        objectName: "pieceMovementGlowEmitter"
        x: 0
        y: 0
        width: 20
        height: 20
        enabled: false
        group: "PieceMovementParticleGlow"
        emitRate: 81
        maximumEmitted: 20
        startTime: 0
        lifeSpan: 1000
        lifeSpanVariation: 0
        size: 37
        sizeVariation: 7
        endSize: 100
        velocityFromMovement: 26
        system: movementSystem
        velocity: PointDirection {
            x: 0
            xVariation: 0
            y: 0
            yVariation: 0
        }
        acceleration: PointDirection {
            x: 0
            xVariation: 0
            y: 0
            yVariation: 0
        }
        shape: MaskShape {
            source: "qrc:///images/particles/expbase.png"
        }
    }
}
