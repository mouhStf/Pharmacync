import engines
import QtQuick
import QtQuick.Controls

Pane {
  id: root
  
  //color: "#EAEAEA"

  signal connected(titre: string, prenom: string, nom: string, niveau: int)

  LoginEngine {
    id: loginEngine

    onConnected: function(userId, titre, prenom, nom, niveau) {
      sqlEngine.setUserId(userId);
      root.connected(titre, prenom, nom, niveau);
    }

    onErrorOccured: function(message) {
      errorLabel.text = message;
    }
  }

  Frame {
    id: connectionPane
    width: 280
    height: 283
    anchors.centerIn: parent

    TextField {
      id: usernameField
      x: 8
      anchors{
        left: parent.left
        right: parent.right
        top: connexionTitle.bottom
        leftMargin: 8
        rightMargin: 8
        topMargin: 20
      }
      placeholderText: qsTr("Nom d'utilisateur")

      onAccepted: connectionButton.click()
    }

    TextField {
      id: passwordField
      x: 8
      anchors{
        left: parent.left
        right: parent.right
        top: usernameField.bottom
        leftMargin: 8
        rightMargin: 8
        topMargin: 14
      }
      echoMode: TextInput.Password
      mouseSelectionMode: TextInput.SelectWords
      placeholderText: qsTr("Mot de passe")

      onAccepted: connectionButton.click()
    }

    Button {
      id: connectionButton
      text: qsTr("Se connecter")
      anchors{
        top: passwordField.bottom
        topMargin: 14
        horizontalCenter: parent.horizontalCenter
      }
      onClicked: function() {
        if (usernameField.text === "" && passwordField.text === "") {
          errorLabel.text = "Remplissez les champs"
          return
        }

        if (usernameField.text === "") {
          errorLabel.text = "Le nom d'utilisateur doit etre rempli"
          return
        }
        if (passwordField.text === "") {
          errorLabel.text = "Le mot de passe doit etre rempli"
          return
        }

        errorLabel.text = ""
        loginEngine.checkAccess(usernameField.text, passwordField.text)
      }       
    }

    Label {
      id: connexionTitle
      text: qsTr("Connexion")
      anchors{
        horizontalCenterOffset: 0
        horizontalCenter: parent.horizontalCenter
      }
      font.pointSize: 17
    }
    Label {
      id: errorLabel
      y: 231
      height: 42
      color: "#951512"
      anchors{
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        leftMargin: 8
        rightMargin: 8
        bottomMargin: 0
      }
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.Wrap
    }
  }
}
