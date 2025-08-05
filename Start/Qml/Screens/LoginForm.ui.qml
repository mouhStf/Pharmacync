

/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML. If you edit
this file manually, you might introduce QML code that is not supported by Qt Design Studio.
Check out https://doc.qt.io/qtcreator/creator-quick-ui-forms.html for details on .ui.qml files.
*/
import QtQuick
import QtQuick.Controls

Rectangle {
    id: rectangle

    color: "#EAEAEA"
    property alias usernameField: usernameField
    property alias connectionButton: connectionButton
    property alias passwordField: passwordField
    property alias errorLabel: errorLabel

    Pane {
        id: connectionPane
        width: 280
        height: 283
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter

        TextField {
            id: usernameField
            x: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: connexionTitle.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 20
            placeholderText: qsTr("Nom d'utilisateur")

            Connections {
                target: usernameField
                onAccepted: connectionButton.click()
            }
        }

        TextField {
            id: passwordField
            x: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: usernameField.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.topMargin: 14
            echoMode: TextInput.Password
            mouseSelectionMode: TextInput.SelectWords
            placeholderText: qsTr("Mot de passe")

            Connections {
                target: passwordField
                onAccepted: connectionButton.click()
            }
        }

        Button {
            id: connectionButton
            text: qsTr("Se connecter")
            anchors.top: passwordField.bottom
            anchors.topMargin: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: connexionTitle
            text: qsTr("Connexion")
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 17
        }
        Label {
            id: errorLabel
            y: 231
            height: 42
            color: "#951512"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            anchors.bottomMargin: 0
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}
