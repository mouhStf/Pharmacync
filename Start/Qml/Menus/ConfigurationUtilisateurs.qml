import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../Dialogs"
import "../Dialogs/Configuration/Utilisateur"

import core

Pane {

    function updateQuery() {
        tableModel.query = "SELECT id, pseudo, titre, prenom, nom, actif FROM utilisateur";
    }

    Dialog {
        id: idag
        title: "Erreur"
        anchors.centerIn: parent
        width: 340
        standardButtons: Dialog.Ok
        Label {
            wrapMode: Text.Wrap
            text: "Vous ne pouvez pas supprimer votre propre compte pendant que vous ete connecte"
            width: 300
        }
    }

    Suppression {
        id: confirmSupress
    }

    ColumnLayout {
        anchors.centerIn: parent
        Label {
            Layout.alignment: Qt.AlignCenter
            font.pixelSize: 20
            text: "Utilisateurs"
        }

        Rectangle {
            width: 580
            height: 300
            border.width: 5
            border.color: "gray"
            color: "green"
            Table {
                id: table
                anchors.fill: parent
                anchors.margins: 1
                onCurrentIndexChanged: function() {
                    editerButton.enabled = true;
                    supprimerButton.enabled = true;
                }

                tableView.model: TableModel {
                    id: tableModel
                    query: "SELECT id, pseudo, titre, prenom, nom, actif FROM utilisateur"
                    horizontalHeader: ["Id", "Login", "Titre", "Prenom", "Nom", "Actif"]
                    columnsWidth: [50, 80, 50, 210, 110, 80]
                    boolsColumns: [5]
                }

                onActivated: function(idVal) {
                    dialog.setId(idVal);
                    dialog.readOnly = true;
                    dialog.open();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Item {
                Layout.fillWidth: true
            }

            RoundButton {
                Layout.preferredWidth: 100
                text: "Ajouter"
                icon.source: "qrc:/icons/svgs/solid/user-plus.svg"

                onClicked: function() {
                    dialog.readOnly = false;
                    dialog.setId(-1);
                    dialog.open();
                }
            }
            RoundButton {
                id: editerButton
                enabled: false
                Layout.preferredWidth: 100
                text: "Editer"
                icon.source: "qrc:/icons/svgs/solid/user-gear.svg"

                onClicked: function() {
                    var idVal = tableModel.getIdVal(table.tableView.currentRow);
                    dialog.setId(idVal);
                    dialog.readOnly = false;
                    dialog.open();
                }
            }
            RoundButton {
                id: supprimerButton
                enabled: false
                Layout.preferredWidth: 100
                text: "Supprimer"
                icon.source: "qrc:/icons/svgs/solid/user-minus.svg"

                onClicked: function() {
                    var idVal = tableModel.getIdVal(table.tableView.currentRow);
                    if (idVal === sqlEngine.getUserId()) {
                        idag.open();
                        return;
                    }
                    confirmSupress.setId(idVal);
                    confirmSupress.open();
                }
            }
        }
    }

    UtilisateurDialog {
        id: dialog
        onAccepted: function() {
            updateQuery();
        }
    }
}

