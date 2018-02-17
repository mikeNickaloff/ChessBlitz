import QtQuick 2.9
import QtQuick.Particles 2.0

Item {

    id: explosionScene
    objectName: "ExplosionScene"
    z: 99
    width: 50
    height: 50
    property var emitter1: explosionEmitter
    property var emitter2: explosionEmitter2

    ParticleSystem {
        id: particleSystem
    }

    ImageParticle {
        objectName: "explosion"
        groups: ["explosion"]
        source: "qrc:///images/particles/explode1.png"
        color: "#fff2af"
        colorVariation: 0
        alpha: 0.4
        alphaVariation: 0.6
        redVariation: 0
        greenVariation: 0.1
        blueVariation: 0.4
        rotation: 2
        rotationVariation: 221
        autoRotation: false
        rotationVelocity: 0
        rotationVelocityVariation: 2
        entryEffect: ImageParticle.Fade
        system: particleSystem
    }
    ImageParticle {
        objectName: "explosion2"
        groups: ["explosion2"]
        source: "qrc:///images/particles/explode4.png"
        color: "#fff2af"
        colorVariation: 0
        alpha: 0.4
        alphaVariation: 0.6
        redVariation: 0
        greenVariation: 0.1
        blueVariation: 0.4
        rotation: 2
        rotationVariation: 221
        autoRotation: false
        rotationVelocity: 0
        rotationVelocityVariation: 0
        entryEffect: ImageParticle.Scale
        system: particleSystem
    }
    Emitter {
        id: explosionEmitter
        objectName: "explosion"
        x: 25
        y: 25
        width: 10
        height: 10
        enabled: false
        group: "explosion"
        emitRate: 50
        maximumEmitted: 6
        startTime: 0
        lifeSpan: 470
        lifeSpanVariation: 0
        size: 1
        sizeVariation: 75
        endSize: 135
        velocityFromMovement: 0
        system: particleSystem
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
        shape: EllipseShape {
            fill: false
        }
    }
    Emitter {
        id: explosionEmitter2
        objectName: "explosion2"
        x: 25
        y: 25
        width: 10
        height: 10
        enabled: false
        group: "explosion2"
        emitRate: 50
        maximumEmitted: 1
        startTime: 0
        lifeSpan: 300
        lifeSpanVariation: 0
        size: 125
        sizeVariation: 0
        endSize: 180
        velocityFromMovement: 0
        system: particleSystem
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
        shape: EllipseShape {
            fill: false
        }
    }
    TrailEmitter {
        id: fireballFlame
        group: "explosion2"

        emitRatePerParticle: 48
        lifeSpan: 500
        emitWidth: 8
        emitHeight: 8

        size: 100
        sizeVariation: 8
        endSize: 200
    }

    TrailEmitter {
        id: fireballSmoke
        group: "explosion2"

        // ![lit]
        emitRatePerParticle: 120
        lifeSpan: 500
        emitWidth: 16
        emitHeight: 16

        velocity: PointDirection {
            yVariation: 0
            xVariation: 0
        }
        acceleration: PointDirection {
            y: -16
        }

        size: 124
        sizeVariation: 8
        endSize: 200
    }
    ImageParticle {
        id: smoke
        anchors.fill: parent
        groups: ["explosion"]
        source: "qrc:///images/particles/smoke1.png"
        colorVariation: 0
        color: "#00111111"
        system: particleSystem
    }

    ImageParticle {
        objectName: "smoke1"
        groups: ["explosion1"]
        source: "qrc:///images/particles/smoke1.png"
        color: "#000000"
        colorVariation: 0
        alpha: 0.2
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
        system: particleSystem
    }

    ImageParticle {
        objectName: "smoke2"
        groups: ["explosion2"]
        source: "qrc:///images/particles/smoke2.png"
        color: "#000000"
        colorVariation: 0
        alpha: 0.2
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
        system: particleSystem
    }

    ImageParticle {
        objectName: "smoke3"
        groups: ["explosion3"]
        source: "qrc:///images/particles/smoke3.png"
        color: "#000000"
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
        system: particleSystem
    }

    ImageParticle {
        objectName: "smoke4"
        groups: ["explosion4"]
        source: "qrc:///images/particles/smoke4.png"
        color: "#000000"
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
        system: particleSystem
    }

    /*Emitter {
        objectName: "smoke"
        x: 92
        y: 375
        width: 20
        height: 20
        enabled: true
        group: "explosion"
        emitRate: 1
        maximumEmitted: 1
        startTime: 0
        lifeSpan: 20000
        lifeSpanVariation: 11000
        size: 31
        sizeVariation: 7
        endSize: 211
        velocityFromMovement: 20
        system: particleSystem
        velocity: AngleDirection {
            angle: 270
            angleVariation: 5
            magnitude: 25
            magnitudeVariation: 0
        }
        acceleration: AngleDirection {
            angle: 0
            angleVariation: 0
            magnitude: 0
            magnitudeVariation: 0
        }
        shape: EllipseShape {
            fill: false
        }
    }

    Emitter {
        objectName: "smoke3"
        x: 95
        y: 455
        width: 20
        height: 20
        enabled: true
        group: "explosion"
        emitRate: 5
        maximumEmitted: 1
        startTime: 0
        lifeSpan: 4000
        lifeSpanVariation: 2000
        size: 0
        sizeVariation: 0
        endSize: 49
        velocityFromMovement: 0
        system: particleSystem
        velocity: PointDirection {
            x: 0
            xVariation: 1
            y: -69
            yVariation: 0
        }
        acceleration: PointDirection {
            x: 0
            xVariation: 0
            y: 0
            yVariation: -2
        }
        shape: EllipseShape {
            fill: false
        }
    } */
}
