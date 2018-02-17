import QtQuick 2.9
import QtQuick.Particles 2.0

Item {
    width: 150
    height: 150
    id: root
    property var img_src
    property var emitter1: emitter
    function create_debis() {
        emitter.burst(3000)
    }
    ParticleSystem {
        id: sys
        Turbulence {
            anchors.fill: parent
            strength: 700
        }
        Gravity {
            anchors.fill: parent
            magnitude: 150
            angle: 90
        }
    }

    CustomParticle {
        system: sys
        property real maxWidth: root.width * 0.70
        property real maxHeight: root.height * 0.75
        ShaderEffectSource {
            id: pictureSource
            sourceItem: picture
            hideSource: true
        }
        Image {
            id: picture
            //source: "../../images/starfish_3.png"
            // source: "file:///home/mike/build/ChessBlitz/images/c_bb.svg"
            source: img_src
        }
        ShaderEffectSource {
            id: particleSource
            sourceItem: particle
            hideSource: true
        }
        Image {
            id: particle
            //source: "qrc:///particleresources/"
            source: "qrc:///images/star.png"
        }
        //! [vertex]
        vertexShader: "
uniform highp float maxWidth;
uniform highp float maxHeight;
varying highp vec2 fTex2;
varying lowp float fFade;
uniform lowp float qt_Opacity;

void main() {

fTex2 = vec2(qt_ParticlePos.x, qt_ParticlePos.y);
//Uncomment this next line for each particle to use full texture, instead of the solid color at the center of the particle.
fTex2 = fTex2 + ((- qt_ParticleData.z / 2. + qt_ParticleData.z) * qt_ParticleTex); //Adjusts size so it's like a chunk of image.
fTex2 = fTex2 / vec2(maxWidth, maxHeight);
highp float t = (qt_Timestamp - qt_ParticleData.x) / qt_ParticleData.y;
fFade = min(t*4., (1.-t*t)*.95) * qt_Opacity;
defaultMain();
}
"
        //! [vertex]
        property variant particleTexture: particleSource
        property variant pictureTexture: pictureSource
        //! [fragment]
        fragmentShader: "
uniform sampler2D particleTexture;
uniform sampler2D pictureTexture;
varying highp vec2 qt_TexCoord0;
varying highp vec2 fTex2;
varying lowp float fFade;
void main() {
gl_FragColor = texture2D(pictureTexture, fTex2) * texture2D(particleTexture, qt_TexCoord0).w * fFade;
}"
        //! [fragment]
    }

    Emitter {
        id: emitter
        system: sys
        enabled: false
        lifeSpan: 4400
        maximumEmitted: 1000
        anchors.fill: parent
        size: 50
        sizeVariation: 8
        acceleration: PointDirection {
            xVariation: 322
            yVariation: 292
        }
    }
}
