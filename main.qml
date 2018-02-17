import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtWebSockets 1.0
import com.chessblitz 1.0
import QtQuick.Particles 2.0

Window {

    id: o_window
    visible: true
    width: 800
    height: 800
    Component.onCompleted: {
        showFullScreen()
    }

    //title: qsTr("Chess Blitz")
    property var gameType
    ClientConnection {
        id: socket
        board: board
    }
    Row {
        Rectangle {
            width: o_window.width * 0.10
        }
        Column {
            Rectangle {

                height: o_window.height * 0.10
            }

            Board {
                id: board

                width: o_window.height * 0.50
                height: o_window.height * 0.50
                function reset() {

                    board.assign_piece(0, 0, 3, 1, false)
                    board.assign_piece(0, 7, 3, 1, false)
                    board.assign_piece(0, 1, 2, 1, false)
                    board.assign_piece(0, 6, 2, 1, false)
                    board.assign_piece(0, 2, 1, 1, false)
                    board.assign_piece(0, 5, 1, 1, false)
                    board.assign_piece(0, 3, 5, 1, false)
                    board.assign_piece(0, 4, 4, 1, false)
                    for (var i = 0; i < 8; i++) {
                        board.assign_piece(1, i, 0, 1, false)
                        board.assign_piece(6, i, 0, 0, false)
                    }

                    board.assign_piece(7, 0, 3, 0, false)
                    board.assign_piece(7, 7, 3, 0, false)
                    board.assign_piece(7, 1, 2, 0, false)
                    board.assign_piece(7, 6, 2, 0, false)
                    board.assign_piece(7, 2, 1, 0, false)
                    board.assign_piece(7, 5, 1, 0, false)
                    board.assign_piece(7, 3, 5, 0, false)
                    board.assign_piece(7, 4, 4, 0, false)
                }
                Component.onCompleted: {
                    board.reset()
                    board.changedBoard.connect(socket.f_sendTextMessage)
                    mainMenuPopup.visible = true
                    board.try_reconnect.connect(socket.try_reconnect)
                    board.verify_board.connect(socket.f_sendTextMessage)
                }
                Grid {
                    id: chessGrid
                    rows: 8
                    columns: 8
                    spacing: 0

                    anchors.fill: parent

                    // ChessBoard
                    Repeater {
                        model: 8 * 8

                        Rectangle {
                            height: o_window.height / 8
                            width: o_window.width / 8
                            id: rect
                            border.width: 2
                            border.color: "black"
                            property var idx: index
                            property var normalColor: {
                                var row = Math.floor(index / 8)
                                var column = index % 8
                                if ((row + column) % 2 == 1) {
                                    //"#8B4513"
                                    "#435e84"
                                } else {
                                    //"#FFE4B5"
                                    "#6b6b6b"
                                }
                            }
                            color: normalColor

                            Component.onCompleted: {


                                //rect.normalColor = rect.color
                                //console.log(rect.normalColor + " " + rect.color)
                            }
                            Square {
                                id: squareObj
                                anchors.fill: parent
                                anchors.centerIn: parent
                                z: 50
                                function setHighlight(should) {
                                    if (should === true) {
                                        //       rect.normalColor = rect.color
                                        rect.color = "#e2d73f"
                                        //     console.log("got " + should + " so setting color to " + rect.color)
                                    } else {
                                        var row = Math.floor(rect.idx / 8)
                                        var column = rect.idx % 8
                                        if ((row + column) % 2 == 1) {
                                            //rect.color = "#8B4513"
                                            rect.color = "#435e84"
                                        } else {
                                            //rect.color = "#FFE4B5"
                                            rect.color = "#6b6b6b"
                                        }
                                        //console.log("got " + should + " so setting color to "
                                        // + rect.color + " (" + rect.normalColor + ")")
                                    }
                                }

                                Component.onCompleted: {
                                    var row = Math.floor(index / 8)
                                    var column = index % 8
                                    board.init_square(row, column, squareObj)

                                    if (((row * column) % 3) == 0) {
                                        pieceObj.setPlayer(2)
                                        figImage.setSource("")
                                    } else {
                                        pieceObj.setPlayer(2)
                                        figImage.setSource("")
                                        //coolDownProgressBar.opacity = 0
                                    }
                                    squareObj.setPiece(pieceObj)
                                    pieceObj.rank = Math.round(col / 2)

                                    pieceObj.update_image_name()
                                    squareObj.highlight_changed.connect(
                                                squareObj.setHighlight)
                                }
                                Piece {
                                    id: pieceObj
                                    anchors.fill: parent
                                    anchors.centerIn: parent
                                    property var isDead: false
                                    Component.onCompleted: {

                                    }
                                    onExplodingChanged: {
                                        explodingParticle.emitter1.enabled = pieceObj.exploding
                                        explodingParticle.emitter2.enabled = pieceObj.exploding
                                        // movementParticle.emitter1.enabled = pieceObj.exploding
                                        //movementParticle.emitter2.enabled = pieceObj.exploding
                                        if (pieceObj.exploding === true) {
                                            debrisParticle.create_debis()
                                        }
                                    }
                                    onAttackIsReady: {

                                    }
                                    onPlayerChanged: {
                                        if (pieceObj.player < 2) {
                                            coolDownProgressBar.visible = true
                                        } else {
                                            coolDownProgressBar.visible = false
                                        }
                                    }
                                    Image {
                                        id: figImage
                                        anchors.centerIn: parent
                                        asynchronous: true // we are loading svg
                                        source: pieceObj.imageName
                                        rotation: board.rotation
                                        function setSource(new_src) {
                                            debrisParticle.img_src = figImage.source
                                            figImage.source = new_src

                                            if (board.rotation == 180) {
                                                figImage.rotation = 180
                                                coolDownProgressBar.rotation = 180
                                            } else {
                                                figImage.rotation = 0
                                                coolDownProgressBar.rotation = 0
                                            }
                                            //console.log("setting source to " + new_src)
                                            /* if (new_src.length < 2) {
                                        coolDownProgressBar.visible = false
                                    } else {
//                                        coolDownProgressBar.visible = true
                                    }*/
                                        }

                                        Component.onCompleted: {
                                            pieceObj.imageNameChanged.connect(
                                                        setSource)
                                            pieceObj.taken.connect(setSource)
                                            /* pieceObj.imageNameChanged.connect(
                                                pieceObj.explosion)*/
                                        }
                                        sourceSize.width: squareObj.width * 0.95
                                        sourceSize.height: squareObj.height * 0.95
                                    }
                                    DebrisParticle {
                                        id: debrisParticle
                                        anchors.centerIn: parent
                                        img_src: figImage.source
                                    }
                                    ExplosionParticle {
                                        id: explodingParticle
                                        anchors.centerIn: parent
                                    }
                                    MovementParticle {
                                        id: movementParticle
                                        anchors.centerIn: parent
                                    }
                                }
                                ProgressBar {
                                    id: coolDownProgressBar
                                    from: 0
                                    to: 1
                                    value: 0.5
                                    width: squareObj.width * 0.90
                                    visible: true
                                    x: (0.5 * (squareObj.width * 0.10))
                                    anchors.bottom: squareObj.bottom
                                    Component.onCompleted: {
                                        pieceObj.attackReadySet.connect(
                                                    coolDownProgressBar.start_cooldown_timer)
                                        pieceObj.attackIsReady.connect(
                                                    coolDownProgressBar.end_cooldown_timer)
                                    }
                                    function start_cooldown_timer(timeLength) {

                                        coolDownProgressBar.value = 0
                                        coolDownProgressBar.to = timeLength
                                        //coolDownTimer.running = true
                                        coolDownTimer.triggered.connect(
                                                    coolDownProgressBar.increment)
                                        coolDownProgressBarRect.color = "#e4534e"
                                    }
                                    function end_cooldown_timer() {
                                        //console.log("Attack is Ready")
                                        coolDownProgressBar.value = coolDownProgressBar.to
                                        //coolDownTimer.running = false
                                        coolDownTimer.triggered.disconnect(
                                                    coolDownProgressBar.increment)
                                        coolDownProgressBarRect.color = "#17a81a"
                                    }
                                    function increment() {
                                        coolDownProgressBar.value += 0.15
                                    }
                                    padding: 0

                                    background: Rectangle {
                                        implicitWidth: squareObj.width * 0.90
                                        implicitHeight: 6
                                        color: "#e6e6e6"
                                        radius: 3
                                    }

                                    contentItem: Item {
                                        implicitWidth: squareObj.width * 0.90
                                        implicitHeight: 8

                                        Rectangle {
                                            id: coolDownProgressBarRect
                                            width: coolDownProgressBar.visualPosition * parent.width
                                            height: parent.height
                                            radius: 2
                                            color: "white"
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {

                                        board.select_square(squareObj)
                                        socket.f_sendTextMessage(
                                                    "HL " + squareObj.row + " " + squareObj.col)
                                        console.log("HL " + squareObj.row + " " + squareObj.col)
                                        if (gameType === "PRACTICE") {
                                            board.stopWaiting("")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Timer {
                        id: coolDownTimer
                        running: true
                        interval: 150
                        repeat: true
                        onTriggered: {


                            //coolDownProgressBar.value += 0.195
                        }
                    }
                }
                onWaitChanged: {
                    if (board.isWaiting() === true) {
                        busyIndicator.running = true
                    } else {
                        busyIndicator.running = false
                    }
                }

                BusyIndicator {
                    id: busyIndicator
                    running: false
                    anchors.centerIn: board
                    height: board.height / 2
                    width: board.width / 2
                }

                Item {
                    id: mainMenuPopup
                    property int targetLogoEmit: 5000
                    property int targetLogoSideEmit: 1000
                    property int targetTextEmit: 3000
                    property int targetTextSideEmit: 1000
                    height: Screen.height
                    width: Screen.width

                    Rectangle {
                        anchors.fill: mainMenuPopup
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00
                                color: "#000000"
                            }
                            GradientStop {
                                position: 0.83
                                color: "#ffffff"
                            }
                            GradientStop {
                                position: 0.85
                                color: "#ffffff"
                            }
                            GradientStop {
                                position: 0.93
                                color: "#ffffff"
                            }
                        }
                        border.color: "black"
                    }
                    Item {
                        anchors.centerIn: mainMenuPopup
                        anchors.fill: mainMenuPopup
                        Rectangle {
                            color: "black"
                            anchors.fill: parent
                            ParticleSystem {
                                id: ps
                                anchors.fill: parent
                                scale: 1.15

                                ImageParticle {
                                    id: logoParticle
                                    source: "images/particle.png"
                                    groups: ["logo"]
                                    z: 7
                                    anchors.fill: parent
                                    color: "#66af36"
                                    alpha: 0
                                    colorVariation: 0.4
                                    scale: 15.0
                                    //            greenVariation: 0.2
                                }

                                ImageParticle {
                                    id: logoSideParticle
                                    source: "images/particle.png"
                                    groups: ["logoSide"]
                                    z: 2
                                    anchors.fill: parent
                                    color: "#0b471e"
                                    alpha: 0
                                    colorVariation: 0.0
                                    greenVariation: 0.1
                                    rotationVariation: 180
                                    scale: 5.0
                                }

                                ImageParticle {
                                    source: "images/particle.png"
                                    groups: ["logoText"]
                                    z: 2
                                    anchors.fill: parent
                                    color: "white"
                                    alpha: 0.5
                                    alphaVariation: 0.4
                                    colorVariation: 0.3
                                    rotationVelocity: 50
                                    rotationVelocityVariation: 100
                                }

                                ImageParticle {
                                    id: textSideParticle
                                    source: "images/star.png"
                                    groups: ["textSide"]
                                    z: 7
                                    anchors.fill: parent
                                    color: "#0b471e"
                                    alpha: 0
                                    colorVariation: 0.3
                                    //            greenVariation: 0.8
                                    rotationVariation: 9
                                }

                                Emitter {
                                    id: logoEmitter
                                    z: 5
                                    anchors.fill: parent
                                    group: "logo"
                                    emitRate: mainMenuPopup.targetLogoEmit
                                    lifeSpan: 550
                                    size: 30
                                    endSize: 2
                                    sizeVariation: 80
                                    //! [0]
                                    shape: MaskShape {
                                        source: "images/logo-shape.png"
                                    }
                                    //! [0]
                                }

                                Emitter {
                                    id: logoSideEmitter
                                    z: 4
                                    //enabled: false
                                    anchors.fill: parent
                                    group: "logoSide"
                                    emitRate: mainMenuPopup.targetLogoSideEmit
                                    lifeSpan: 700
                                    size: 45
                                    sizeVariation: 15
                                    //! [0]
                                    shape: MaskShape {
                                        source: "qrc:///images/particles/smoke4.png"
                                    }
                                    //! [0]
                                }

                                Emitter {
                                    id: textEmitter
                                    anchors.fill: parent
                                    group: "logoText"
                                    emitRate: 15
                                    lifeSpan: 500
                                    size: 1
                                    sizeVariation: 0

                                    //! [0]
                                    shape: MaskShape {
                                        source: "images/c_wr.svg"
                                    }
                                    //! [0]
                                }

                                Emitter {
                                    id: textSideEmitter
                                    anchors.fill: parent
                                    group: "textSide"
                                    emitRate: 10
                                    lifeSpan: 750
                                    size: 1
                                    sizeVariation: 0
                                    //! [0]
                                    shape: MaskShape {
                                        source: "images/c_wr_side.svg"
                                    }
                                    //! [0]
                                }

                                Image {
                                    id: logoTextImage
                                    source: "images/c_wr.svg"
                                    opacity: 0
                                    z: 4
                                    anchors.fill: parent
                                }

                                Loader {
                                    id: ageAffectorLoader
                                    enabled: true
                                    sourceComponent: ageAffector
                                }

                                Component {
                                    id: ageAffector
                                    Age {
                                        system: ps
                                        y: 800 - height
                                        width: 665
                                        height: 800
                                        //                lifeLeft: 60
                                        enabled: true
                                    }
                                }

                                Turbulence {
                                    anchors.fill: parent
                                    strength: 500
                                }
                                Gravity {
                                    anchors.fill: parent
                                    magnitude: 800
                                    angle: -90
                                }
                                Gravity {
                                    anchors.fill: parent
                                    magnitude: 100
                                    angle: 180
                                }
                            }

                            SequentialAnimation {
                                running: true
                                ParallelAnimation {

                                    SequentialAnimation {
                                        //                PauseAnimation { duration: 600 }
                                        NumberAnimation {
                                            target: ageAffectorLoader.item
                                            property: "height"
                                            to: 1
                                            duration: 1500
                                            easing.type: Easing.InOutSine
                                        }
                                        ScriptAction {
                                            script: ageAffectorLoader.sourceComponent = undefined
                                        }
                                    }
                                    SequentialAnimation {

                                        ParallelAnimation {
                                            NumberAnimation {
                                                targets: [logoParticle, logoSideParticle]
                                                properties: "alpha"
                                                to: 0
                                                duration: 1000
                                            }

                                            NumberAnimation {
                                                targets: [logoParticle, logoSideParticle]
                                                properties: "scale"
                                                from: 15.0
                                                to: 2.0
                                                duration: 3000
                                            }
                                            NumberAnimation {
                                                targets: [logoParticle, logoSideParticle]
                                                properties: "greenVariation"

                                                to: 0.8
                                                duration: 3000
                                            }
                                            NumberAnimation {
                                                target: textEmitter
                                                property: "emitRate"
                                                to: mainMenuPopup.targetTextEmit
                                                duration: 2000
                                                easing.type: Easing.InSine
                                            }
                                            NumberAnimation {
                                                targets: [textEmitter, textSideEmitter]
                                                properties: "size"
                                                to: 140
                                                duration: 2500
                                                easing.type: Easing.InElastic
                                            }
                                            NumberAnimation {
                                                targets: [textEmitter, textSideEmitter]
                                                properties: "sizeVariation"
                                                to: 40
                                                duration: 2500
                                                easing.type: Easing.InElastic
                                            }
                                            NumberAnimation {
                                                target: textSideEmitter
                                                property: "emitRate"
                                                to: mainMenuPopup.targetTextSideEmit
                                                duration: 3000
                                                easing.type: Easing.InSine
                                            }
                                            ColorAnimation {
                                                targets: [logoParticle, logoSideParticle, textSideParticle]
                                                property: "color"
                                                to: "#6fadac"
                                                duration: 3000
                                            }
                                        }
                                    }
                                }
                                NumberAnimation {
                                    target: logoTextImage
                                    properties: "opacity"
                                    from: 0
                                    to: 1.0
                                    duration: 1000
                                }
                                NumberAnimation {
                                    target: menuColumn
                                    property: "opacity"
                                    duration: 1500
                                    to: 1.0
                                    easing.type: Easing.InElastic
                                }
                            }
                        }
                        Column {
                            id: menuColumn
                            opacity: 0
                            anchors.centerIn: parent
                            spacing: 12
                            padding: 12
                            Text {
                                text: "Chess Blitz"
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Button {
                                implicitWidth: board.width * 0.75
                                padding: 15
                                contentItem: Text {
                                    text: "Find Opponent"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    color: "#8bcedd"
                                    implicitWidth: 120
                                    implicitHeight: 40
                                    opacity: enabled ? 1 : 0.3
                                    border.color: "#5224ad"
                                    border.width: 1
                                    radius: 2
                                }
                                onClicked: {
                                    gameType = "MATCH"
                                    mainMenuPopup.visible = false
                                    socket.active = true
                                    board.reset()
                                }
                            }
                            Button {
                                implicitWidth: board.width * 0.75
                                padding: 15
                                contentItem: Text {
                                    text: "Practice vs CPU"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                onClicked: {
                                    gameType = "PRACTICE"
                                    mainMenuPopup.visible = false
                                    socket.active = true
                                    board.reset()
                                }
                                background: Rectangle {
                                    color: "#8bcedd"
                                    implicitWidth: 120
                                    implicitHeight: 40
                                    opacity: enabled ? 1 : 0.3
                                    border.color: "#5224ad"
                                    border.width: 1
                                    radius: 2
                                }
                            }

                            Button {
                                implicitWidth: board.width * 0.75
                                padding: 15
                                contentItem: Text {
                                    text: "Play vs Friend"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    color: "#8bcedd"
                                    implicitWidth: 120
                                    implicitHeight: 40
                                    opacity: enabled ? 1 : 0.3
                                    border.color: "#5224ad"
                                    border.width: 1
                                    radius: 2
                                }
                            }
                            Button {
                                implicitWidth: board.width * 0.75
                                padding: 15
                                contentItem: Text {
                                    text: "Join Friend's Game"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                background: Rectangle {
                                    color: "#8bcedd"
                                    implicitWidth: 120
                                    implicitHeight: 40
                                    opacity: enabled ? 1 : 0.3
                                    border.color: "#5224ad"
                                    border.width: 1
                                    radius: 2
                                }
                            }
                        }
                    }
                }
                Popup {
                    modal: true
                    height: Screen.height
                    width: Screen.width
                    dim: true
                    id: gameOverPopup
                    background: Item {
                        Rectangle {
                            color: "black"
                        }
                    }
                    contentItem: Item {
                        anchors.centerIn: parent
                        Text {
                            text: "Game Over"
                            font.pointSize: 64
                            color: "white"
                        }
                    }
                    Component.onCompleted: {
                        board.gameOver.connect(gameOverPopup.open)
                        gameOverPopup.close()
                    }
                }
                Rectangle {

                    height: o_window.height * 0.10
                }
            }
            Rectangle {
                width: o_window.width * 0.10
            }
        }
    }
}
