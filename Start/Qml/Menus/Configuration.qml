import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../Dialogs"

import core

Page {
    title: "Configuration"

    FontLoader {
        id: fontAwesome
        source: "qrc:/fa-solid-900.otf" // Path to the Font Awesome file
    }

    Frame {
        id: menu
        anchors{
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: 200

        ColumnLayout {
            width: parent.width
            height: b1.height
            anchors.centerIn: parent
            RoundButton {
                id: b1
                Layout.fillWidth: true
                radius: 20
                text: "Utilisateurs"

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: 15
                        verticalCenter: parent.verticalCenter
                    }
                    font.family: fontAwesome.name
                    text: "user"
                }
            }
        }
    }

    StackLayout {
        id: stack
        anchors{
            left: menu.right
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        clip: true

        ConfigurationUtilisateurs {
        }
    }
}
