pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../DataHandlers"

import "../Utils/functions.mjs" as Functions

Dialog {
  id: root
  title: "Medicament"
  anchors.centerIn: parent
  property int codeProduit
  property bool readOnly: false
  property string addedPresentationEAN13: "-1"
  
  Component.onCompleted: function() {
    Functions.setSqlEngine(sqlEngine);    
  }

  function setAddingPresentation(code_produit) {
    root.readOnly = true;
    root.setCodeProduit(code_produit);
    presentationRepeater.model.unshift({"modelEAN13": "-1"});
    presentationRepeater.itemAt(0).readOnly = false;
    root.addedPresentationEAN13 = Qt.binding(function() {
      return presentationRepeater.itemAt(0).ean13;
    });
    okButton.visible = true;
  }
  
  function refresh() {
    setCodeProduit(root.codeProduit);
  }
  
  function setCodeProduit(codeProduit) {
    if (!codeProduit)
      return;
    
    root.codeProduit = codeProduit;
    produit.setCodeProduit(codeProduit);

    var presentations = [];
    if (codeProduit !== -1) 
      presentations = sqlEngine.select("presentation_produit", ["ean_13"],
                                       "code_produit", codeProduit);
    
    presentationRepeater.model = [];
    for (var i = 0; i < presentations.length; i++) {
      presentationRepeater.model.push({"modelEAN13": presentations[i][0]});
    }
  }
  
  function setNew() {
    setCodeProduit(-1);
  }
  
  width: Math.min(
    parent.width - 20,
    leftPadding + frame.leftPadding + layout.width
      + frame.rightPadding + rightPadding
  )
  height: Math.min(
    parent.height - 20,
    topPadding + implicitHeaderHeight + frame.topPadding + layout.height
      + (toolBar.visible ? colLayout.spacing + toolBar.height : 0)
      + frame.bottomPadding + implicitFooterHeight + bottomPadding
  )
  
  contentItem: Frame {
    id: frame
    padding: 5

    ColumnLayout {
      anchors.fill: parent
      id: colLayout
      Flickable {
        id: flickable
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: layout.width
        contentHeight: layout.height
        clip: true
        
        Row {
          id: layout
          spacing: 15

          ColumnLayout {
            id: produitLayout
            width: 300
            Label {
              font.pixelSize: 13
              font.bold: true
              text: qsTr("Produit")
            }
            Produit {
              id: produit
              readOnly: root.readOnly
              Layout.fillWidth: true
            }
          }
          ColumnLayout {
            width: 300
            height: produitLayout.height
            Label {
              font.pixelSize: 13
              font.bold: true
              text: qsTr("Présentations")
            }
            Frame {
              Layout.fillWidth: true
              Layout.fillHeight: true
              Flickable {
                anchors.fill: parent
                contentWidth: width
                contentHeight: presentationLayout.height
                clip: true

                ColumnLayout {
                  id: presentationLayout
                  width: parent.width
                  Repeater {
                    id: presentationRepeater
                    Layout.fillWidth: true
                    PresentationProduit {
                      id: presentation
                      required property int index
                      readOnly: root.readOnly
                      implicitWidth: presentationLayout.width

                      onDeleteDone: function() {
                        presentationRepeater.model.splice(index, 1);
                      }
                      onOpenStock: function(idVal) {
                        stockProduitDialog.setId(idVal);
                        stockProduitDialog.open();
                      }
                    }
                  }
                }
              }
            }
            ToolBar {
              Layout.fillWidth: true
              visible: ! root.readOnly

              ToolButton {
                text: qsTr("Ajouter une présentation")
                onClicked: function() {
                  presentationRepeater.model.push({"modelEAN13": "-1"});
                }
              }
            }
          }
        }

        
        ScrollBar.horizontal: ScrollBar {}
        ScrollBar.vertical: ScrollBar {}
      }

      ToolBar {
        id: toolBar
        Layout.fillWidth: true
        visible: !root.readOnly && root.codeProduit !== -1

        RowLayout {
          ToolButton {
            enabled: presentationRepeater.model ? presentationRepeater.model.length === 0 : false
            text: qsTr("Supprimer le produit")
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.text: qsTr("Vous devez d'abord supprimer tous les présentations.")
            ToolTip.visible: hovered && !enabled
            onClicked: suppressionDialog.open()
          }
        }
      }
    }
  }
  StockProduitDialog {
    id: stockProduitDialog
    anchors.centerIn: parent
    onClosed: root.refresh();
  }  
  
  footer: DialogButtonBox {
    standardButtons: root.readOnly ? Dialog.Close : Dialog.Cancel
    Button {
      id: okButton
      visible: !root.readOnly
      text: qsTr("Ok")
      onClicked: function() {
        var saved = true;
        saved = saved && produit.save();
        
        for (var i = 0; i < presentationRepeater.model.length; i++) {
          presentationRepeater.itemAt(i).codeProduitFieldText = produit.codeProduitFieldText;
          saved = saved && presentationRepeater.itemAt(i).save();
        }
        if (saved) {
          root.codeProduit = produit.codeProduit;
          root.accept();
        }
      }
    }
  }
}
