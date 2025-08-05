import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

Dialog {
    id: root
    title: "Utilisateur"
    anchors.centerIn: parent
    property int idVal: -1
    property bool actif
    property alias readOnly: content.readOnly

    function setId(idVal) {
        advancedConfig.visible = false;
        if (idVal === -1) {
            root.idVal = -1;
            titreBox.setValue("Mr");
            prenomField.text = "";
            nomField.text = "";
            pseudoField.text = "";
            passField.text = "";
            niveauBox.setValue(1);
        } else {
            root.idVal = idVal;
            var result = sqlEngine.select("utilisateur",
                                          ["titre", "prenom", "nom", "pseudo", "niveau", "actif"],
                                          "id", idVal);
            if (result.length !== 1) {
                setId(-1);
                return;
            }

            titreBox.setValue(result[0][0]);
            prenomField.text = result[0][1];
            nomField.text = result[0][2];
            pseudoField.text = result[0][3];
            passField.text = "";
            niveauBox.setValue(result[0][4]);
            root.actif = (result[0][5] === 1);
            actifCheckBox.checked = (result[0][5] === 1);
        }
    }

    contentItem: Flickable {
        implicitWidth: content.width
        implicitHeight: content.height
        contentWidth: content.width
        contentHeight: content.height

        ScrollBar.vertical: ScrollBar{}
        ScrollBar.horizontal: ScrollBar{}

        ColumnLayout {
            id: content
            property bool readOnly: false
            spacing: 6

            RowLayout {
                visible: false
                Layout.fillWidth: true
                Rectangle {
                    Layout.fillWidth: true
                    color: palette.base
                    border.width: 1
                    border.color: "gray"
                    Label {
                        font.pixelSize: 14
                        anchors.fill: parent
                        wrapMode: Label.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "Ce compte est " + (root.actif ? "actif" : "innactif")
                    }
                }
                Button {
                    text: root.actif ? "Desactiver" : "Activer"
                    onClicked: function() {
                        var val = 1;
                        if (root.actif) val = 0;
                        if (sqlEngine.update("utilisateur", ["actif"], [val], "id", confirmSupress.idVal))
                            setId(root.idVal);
                    }
                }
            }

            CustomComboBox {
                id: titreBox
                title: "Titre"
                model: ListModel {
                    ListElement { value: "Pr"; text: "Pr" }
                    ListElement { value: "Dr"; text: "Dr" }
                    ListElement { value: "Mr"; text: "Mr" }
                    ListElement { value: "Mme"; text: "Mme" }
                    ListElement { value: "Mlle"; text: "Mlle" }
                }
            }
            CustomTextField {
                id: prenomField
                title: "Prenom"
            }
            CustomTextField {
                id: nomField
                title: "Nom"
            }
            CustomTextField {
                id: pseudoField
                title: "Pseudo"
            }
            CustomTextField {
                id: passField
                visible: (!content.readOnly)  && (root.idVal !== sqlEngine.getUserId())
                title: "Mot de passe"
                echoMode: TextInput.Password
            }


            CustomComboBox {
                id: niveauBox
                visible:  root.idVal !== sqlEngine.getUserId()
                title: "Niveau d'autorisation"
                model: ListModel {
                    ListElement {
                        value: 0
                        text: "Administrateur"
                    }
                    ListElement {
                        value: 1
                        text: "Vendeur"
                    }
                }
            }

            ColumnLayout {
                visible: (!root.readOnly && root.idVal !== -1) && (root.idVal !== sqlEngine.getUserId())
                Layout.fillWidth: true
                spacing: 3
                Label {
                    font.pixelSize: 11
                    text: (!advancedConfig.visible ? "▶" : "▼") + " Configuration avances"
                    color: area.containsMouse ? palette.highlightedText : palette.text
                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: advancedConfig.visible = !advancedConfig.visible
                    }
                }

                Frame {
                    id: advancedConfig
                    Layout.fillWidth: true
                    CheckBox {
                        id: actifCheckBox
                        text: "Ce compte est " + (root.actif ? "actif.\nDecocher pour le desactiver." : "innactif, cocher pour l'activer.")
                    }
                }
            }
        }

        Dialog {
            id: confirmDialog
            anchors.centerIn: parent
            function resetIt() {
                confirmPassField.text = "";
            }

            ColumnLayout {
                property bool readOnly: false
                spacing: 3
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: "Pour confirmer veuillez entrez le mot de passe actuel"
                }
                CustomTextField {
                    id: confirmPassField
                    Layout.fillWidth: true
                    echoMode: TextField.Password
                }
            }
            footer: DialogButtonBox {
                standardButtons: Dialog.Cancel
                Button {
                    text: "Ok"
                    onClicked: function() {
                        var result = sqlEngine.select("utilisateur", ["id", "pass"], "id", root.idVal);
                        if (result.length !== 1) {
                            confirmPassField.error = "Utilisateur introuvable"
                            return
                        } else confirmPassField.error = ""

                        if (result[0][1] === confirmPassField.text) {
                            var cols = ["titre", "prenom", "nom", "pseudo", "niveau", "actif"];
                            var vals = [titreBox.getValue(), prenomField.text, nomField.text,
                                        pseudoField.text, niveauBox.getValue(), actifCheckBox.checked ? 1 : 0];
                            if (passField.text !== "") {
                                cols.push("pass");
                                vals.push(passField.text);
                            }

                            var saved = sqlEngine.update("utilisateur", cols, vals, "id", root.idVal);
                            if (saved) {
                                root.accept();
                                confirmDialog.accept();
                            }
                        } else {
                            confirmPassField.error = "Mot de passe incorecte";
                        }
                    }
                }
            }
        }
    }

    footer: DialogButtonBox {
        standardButtons: root.readOnly ? Dialog.Close : Dialog.Cancel
        Button {
            visible: !root.readOnly
            text: "Ok"
            onClicked: function() {
                if (pseudoField.text === "") {
                    pseudoField.error = "Ce champ doit etre remplie";
                    return;
                } else
                    pseudoField.error = "Ce champ doit etre remplie"

                var result = sqlEngine.select("utilisateur", ["id"], "pseudo", pseudoField.text);
                var idPresent = -1;
                if (result.length > 0) {
                    idPresent = result[0][0];
                }

                if (idPresent !== root.idVal) {
                    pseudoField.error = "Un utilisateur avec le meme pseudo existe deja";
                    return;
                } else pseudoField.error = "";

                if (root.idVal === -1) {
                    var saved = sqlEngine.insert("utilisateur",
                                                 ["titre", "prenom", "nom", "pseudo", "niveau", "pass"],
                                                 [titreBox.getValue(), prenomField.text, nomField.text,
                                                  pseudoField.text, niveauBox.getValue(), passField.text
                                                  ]);
                    if (saved)
                        root.accept();
                } else {
                    confirmDialog.resetIt();
                    confirmDialog.open();
                }
            }
        }
    }
}
