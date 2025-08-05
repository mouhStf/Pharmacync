import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

import core

Dialog {
  id: root
  title: "Packet " + idVal
  anchors.centerIn: parent
  property bool readOnly
  property int idVal
  
  function setId(id) {
    quantiteField.minVal = 0; // to avoid miscaculation on restant and quantite
    root.idVal = id;
    sqlEngine.updateEntresStockIndex(id);
    var result = sqlEngine.select("entres_stock",
                                  ["id_fournisseur", "quantite", "restant",
                                   "prix_d_achat", "prix_de_vente",
                                   "date_peremption", "code_CIP13"],
                                  "id", id);

    if (result.length === 1) {
      fournisseurBox.currentIndex = fournisseurBox.indexOfValue(result[0][0]);
      quantiteField.value = result[0][1];
      restantField.value = result[0][2];
      venteField.value = result[0][4];
      achatField.value = result[0][3];
      peremptionField.text = sqlEngine.dateFromSec(result[0][5]);
    } else return;

    result = sqlEngine.select("flux", ["restant"], "id_entres_stock", id);
    var gone = 0;
    for (var i = 0; i < result.length; i++) {
      gone += result[i][0];
    }
    quantiteField.minVal = gone;
  }

  function achatVenteErrorCheck() {
    if (root.readOnly) return;
    if (achatField.value > venteField.value) {
      venteField.error = qsTr("Le prix de vente est plus petit que le prix d'achat.");
      achatField.error = " ";
    }
    else {
      venteField.error = "";
      achatField.error = "";
    }
  }
  
  Component.onCompleted: function() {
    var result = sqlEngine.select("fournisseur", ["id", "nom"]);
    var fournisseurs = [];
    for (var i = 0; i < result.length; i++) {
      fournisseurs.push({"value": result[i][0], "text": result[i][1].toString()});
    }
    fournisseurBox.model = fournisseurs;
  }
  
  width: leftPadding + frame.leftPadding + leftFrame.leftPadding
    + leftFrame.width + leftFrame.rightPadding + rrw.spacing
    + tableFrame.leftPadding +  230 + tableFrame.rightPadding
    + frame.rightPadding + rightPadding
  height: topPadding + header.height + frame.topPadding + leftFrame.topPadding
    + column.height + leftFrame.bottomPadding + frame.bottomPadding
    + footer.height + bottomPadding
  
  contentItem: Frame {
    id: frame
    padding: 5
    clip: true
    
    RowLayout {
      id: rrw
      spacing: 15
      clip: true
      anchors.fill: parent

      Frame {
        id: leftFrame
        Layout.preferredWidth: 150
        Layout.fillHeight: true
        clip: true

        Flickable {
          id: flick
          anchors.fill: parent
          contentWidth: width
          contentHeight: column.height
          ScrollBar.vertical: ScrollBar {}
          ColumnLayout {
            id: column
            width: parent.width            
            property bool readOnly: root.readOnly
            z: 10
            ColumnLayout {
              Layout.fillWidth: true
              spacing: 3
              Label {
                text: "Fournisseur"
                font.pixelSize: 11
              }
              ComboBox {
                valueRole: "value"
                textRole: "text"
                id: fournisseurBox
                Layout.fillWidth: true
              }
            }
            //Item {
            //z: 10
            //Layout.fillWidth: true
            //Layout.preferredHeight: quantiteField.height
            CNumberField {
              id: quantiteField
              title: "Quantite"
              property int minVal
              Layout.fillWidth: true
              //readOnly: root.readOnly
              //width: parent.width
              
              onValueChanged: function() {
                if (value < 0)
                  error = qsTr("La quantite ne peut pas être negative");
                else if (value < minVal)
                  error = qsTr("La valeur minimale est de ") + quantiteField.minVal + qsTr(", car ") + quantiteField.minVal + qsTr(" unités ont déjà été vendues.")
                else
                  error = "";
                restantField.value = quantiteField.value - minVal;
              }
            }
            //}
            CNumberField {
              id: restantField
              title: "Restant"
              Layout.fillWidth: true
              onValueChanged: function() {
                quantiteField.value = restantField.value + quantiteField.minVal;
                if (value < 0)
                  error = qsTr("Le restant ne peut pas etre negatif");
                else error = "";
              }
            }            
            CNumberField {
              id: achatField
              title: "Prix d'achat"
              Layout.fillWidth: true
              onValueChanged: root.achatVenteErrorCheck();
            }
            CNumberField {
              id: venteField
              title: "Prix de vente"
              Layout.fillWidth: true
              readOnly: table.rowCount() > 0 || parent.readOnly
              onValueChanged: root.achatVenteErrorCheck();
            }
            CustomTextField {
              id: peremptionField
              title: qsTr("Date de péremption")
              Layout.preferredWidth: 80
              property string old: text
              text: "__/__/____"
              onEditinFinished: function() {
                if (!sqlEngine.isDateValid(text))
                  error = "Date invalide";
                else error = "";
              }
              onEditingBeginning: function() {
                var cp = cursorPosition;
                while (cp > 0 && (text[cp-1] === "_" || text[cp-1] === "/")) {
                  cp = cp - 1;
                  if (text[cp] === "/" && text[cp-1] !== "_") {
                    cp += 1;
                    break
                  }
                }
                if (cursorPosition !== cp)
                  cursorPosition = cp;
              }
              onTextEdited: function() {
                var txt = text.replace(/\//g, "");
                var t = old.replace(/\//g, "");
                var cp = cursorPosition
                var s = txt.length - t.length;
                var p = cp - (text.slice(0, cp).match(/\//g) || []).length;
                var i = 0;
                if (s>0) {
                  for (i = 0; i < s; i++)
                    t = (t.slice(0,p-s+i) + txt[p -s + i] + t.slice(p-s+i+1)).slice(0,8);
                  
                  if (cp - s === 2 || cp - s === 5)
                    cp++;
                  if (cp === 2 || cp === 5)
                    cp++;
                } else if (s < 0) {
                  for (i = 0; i < -s; i++)
                    t = t.slice(0,p-s-i-1) + "_" + t.slice(p-s-i)
                  
                  if (cp === 3 || cp === 6)
                    cp--;
                }
                
                text = t.slice(0,2) + "/" + t.slice(2,4) + "/" + t.slice(4);
                old = text;
                cursorPosition = Math.min(cp,10);
              }
            }
          }
        }
      }
      
      Frame {
        id: tableFrame
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        
        ColumnLayout {
          anchors.fill: parent
          spacing: 0

          TableAndFilter { // width 230
            id: table
            Layout.fillHeight: true
            Layout.fillWidth: true
            query: "SELECT id_facture, flux.restant, facture.date FROM flux "
              + "join facture on flux.id_facture = facture.id "
              + "where id_entres_stock = " + root.idVal + " AND flux.restant > 0"
            
            horizontalHeader: ["Facture", "Qt", "Date"]
            columnsWidth: [80, 50, 100]
            datesColumns: [2]
            
            onCurrentRowChanged: function() {
              voirFacture.enabled = currentRow !== -1
            }
            
            onActivated: function(idVal) {
              facture.setId(idVal);
              factureDialog.open();              
            }
            
            contextMenuItems: ListModel {
              ListElement {
                title: "Voir"
                func: function(idVal) {
                  facture.setId(idVal);
                  factureDialog.open();
                }
              }
              ListElement {
                title: "Editer"
                func: function(idVal) {
                  editDialog.setId(idVal);
                  if (editDialog.idVal !== -1)
                    editDialog.open();
                }
              }
            }
          }
                    
          Label {
            Layout.fillWidth: true
            visible: quantiteField.minVal > 0
            text: quantiteField.minVal + " unites vendues"
            horizontalAlignment: Label.AlignHCenter
          }        
          ToolBar {
            Layout.fillWidth: true
            RowLayout {
              ToolButton {
                id: voirFacture
                enabled: false
                text: qsTr("Voir la facture")
                onClicked: function() {
                  var idVal = table.getIdVal(table.currentRow);
                  facture.setId(idVal);
                  factureDialog.open();
                }
              }
            }
          }

        }        
      }      
    }
  }

  Dialog {
    id: factureDialog
    title: "Facture " + facture.numero
    anchors.centerIn: parent

    onClosed: function() {
      table.refresh();
      root.setId(root.idVal);
    }

    width: 500
    height: 500

    Frame {
      anchors.fill: parent
      ColumnLayout {
        anchors.fill: parent
        Frame {
          Layout.fillHeight: true
          Layout.fillWidth: true
          Facture {
            id: facture
            anchors.fill: parent
          }
        }
        ToolBar {
          Layout.fillWidth: true
          RowLayout {
            anchors.right: parent.right
            
            ToolButton {
              icon.source: "qrc:/icons/svgs/solid/print.svg"
              text: "Imprimer"
              onClicked: function() {
                painterEngine.printFacture(facture.numero);
              }
            }
            ToolButton {
              icon.source: "qrc:/icons/svgs/solid/pen.svg"
              text: "Editer"
              onClicked: function() {
                editDialog.setId(facture.numero);
                if (editDialog.idVal !== -1)
                  editDialog.open();
              }
            }
            ToolButton {
              icon.source: "qrc:/icons/svgs/solid/xmark.svg"
              text: "Supprimer"
              onClicked: function() {
                confirmSuppression.open();
              }
            }
          }
        }
      }
    }
    standardButtons: Dialog.Close
  }

  Dialog {
    id: confirmSuppression
    title: qsTr("Suppression de la facture nº") + facture.numero
    property bool err: true
    anchors.centerIn: parent
    contentItem: ColumnLayout{
      Label {
        Layout.preferredWidth: _df3b.width
        wrapMode: Label.Wrap
        font.pixelSize: 14
        text: qsTr("Cette suppression sera engistre telle une erreur de facturation. S'il sagit d'un retour client, faite la suppression de puis le menu des ventes.")
      }
      Label {
        id: _df3b
        wrapMode: Label.Wrap
        horizontalAlignment: Label.AlignHCenter
        text: qsTr("Les produits seront retournes dans le stock.")
      }
    }

    onAccepted: function() {
      factureDialog.accept();
    }

    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        text: qsTr("Confirmer")
        onClicked: function() {
          var prods = {};

          var good = true;
          for (var i = 0; i < facture.products.count; i++) {
            good = good && sqlEngine.doRetour(facture.products.get(i).idFlux, facture.products.get(i).quantite, confirmSuppression.err);
          }
          if (good)
            good = sqlEngine.deleteRow("facture", "id", facture.numero);
          if (good)
            confirmSuppression.accept();
        }
      }
    }
  }
  
  Edit {
    id: editDialog
    err: true
    anchors.centerIn: parent
    onAccepted: function() {
      if (factureDialog.opened)
        facture.setId(idVal);
      table.refresh();
      root.setId(root.idVal);
    }
  }

  footer: DialogButtonBox {
    standardButtons: root.readOnly ? Dialog.Close : Dialog.Cancel
    Button {
      visible: !root.readOnly
      text: "Ok"
      enabled: quantiteField.error === "" && restantField.error === "" && achatField.error === "" && venteField.error === "" && peremptionField.error === ""
      onClicked: function() {
        if (sqlEngine.update("entres_stock",
                             ["restant", "quantite", "prix_d_achat", "prix_de_vente", "date_peremption"],
                             [restantField.value, quantiteField.value, achatField.value, venteField.value, sqlEngine.dateTimeToSecSinceEpoch(peremptionField.text).toFixed(0)],
                             "id", root.idVal))
          accept();
      }
    }  
  }
}
