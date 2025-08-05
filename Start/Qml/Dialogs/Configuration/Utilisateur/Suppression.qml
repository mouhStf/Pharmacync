import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../../Widgets"

import core

Dialog {
    title: "Suppression"
    id: confirmSupress
    anchors.centerIn: parent
    width: 500
    property int idVal
    property string pseudo
    property bool hasFactures
    property bool actif

    function setId(val) {
        voirFactures.checked = false;
        var result = sqlEngine.select("utilisateur", ["pseudo", "actif"], "id", val);
        if (result.length !== 1) {
            idVal = -1;
            return;
        }
        idVal = val;
        pseudo = result[0][0];
        actif = (result[0][1] === 1);

        result = sqlEngine.select("facture", ["id"], "id_user", idVal);
        hasFactures = result.length > 0;
    }

    ColumnLayout {
        id: factures
        anchors.fill: parent
        Label {
            visible: !confirmSupress.hasFactures
            font.pixelSize: 15
            Layout.fillWidth: true
            wrapMode: Label.Wrap
            text: "Êtes-vous sûre de vouloir supprimer le compte de " + confirmSupress.pseudo + " ?"
        }

        Label {
            visible: confirmSupress.hasFactures && !confirmSupress.actif
            font.pixelSize: 15
            Layout.fillWidth: true
            wrapMode: Label.Wrap
            text: "Plusieurs factures ont été enregistrées par cet utilisateur (" + confirmSupress.pseudo +"). "
                  + " Et son compte est innactif (il ne peut pas se connecter). voulez vous quand meme le supprimer ?"
        }

        Label {
            visible: confirmSupress.hasFactures && confirmSupress.actif
            font.pixelSize: 15
            Layout.fillWidth: true
            wrapMode: Label.Wrap
            text: "Plusieurs factures ont été enregistrées par cet utilisateur (" + confirmSupress.pseudo +"). "
                  + " Préférez-vous désactiver cet utilisateur ?"
        }

        Button {
            Layout.alignment: Qt.AlignRight
            visible: confirmSupress.hasFactures && confirmSupress.actif
            text: "Supprimer " + confirmSupress.pseudo
            onClicked: function() {
                if (sqlEngine.deleteRow("utilisateur", "id", idVal))
                    accept();
            }
        }

        CheckBox {
            id: voirFactures
            text: "Voir les factures"
            visible: confirmSupress.hasFactures
            checked: false
        }

        ColumnLayout {
            visible: voirFactures.checked
            Layout.fillWidth: true
            spacing: 3
            Label {
                text: "Liste des factures enregistres par l'utilisateur " + confirmSupress.pseudo
            }

            Rectangle {
                Layout.fillWidth: true
                height: 250
                border.width: 1
                border.color: "gray"
                Table {
                    anchors{
                        fill: parent
                        margins: 1
                    }
                    tableView.model: TableModel {
                        query: "SELECT id, date, paye, donne, rendu, devis FROM facture WHERE id_user = '"+ confirmSupress.idVal +"'"
                        datesColumns: [1]
                        horizontalHeader: ["Id", "Date", "Paye", "Donne", "Rendu", "Devis"]
                        columnsWidth: [80, 100, 80, 80, 80, 50]
                    }
                }
            }
            Item {
                height: 10
                width: 10
            }
        }

    }

    footer: DialogButtonBox {
        standardButtons: Dialog.Cancel
        Button {
            text: (confirmSupress.hasFactures && confirmSupress.actif) ?
                      ("Desactiver le compte de " + confirmSupress.pseudo) :
                      ("Supprimer " + confirmSupress.pseudo)

            onClicked: function() {
                if (confirmSupress.hasFactures && confirmSupress.actif) {
                    if (sqlEngine.update("utilisateur", ["actif"], [0], "id", confirmSupress.idVal))
                        accept();
                } else {
                    if (sqlEngine.deleteRow("utilisateur", "id", idVal))
                        accept();
                }
            }
        }
    }

    onAccepted: function() {
        updateQuery();
    }
}
