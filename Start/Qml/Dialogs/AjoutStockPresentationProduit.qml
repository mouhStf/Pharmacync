import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../DataHandlers"
import "../Widgets"

import core

// TODO When you choose an image the height is augmented

Dialog {
  id: root
  title: qsTr("Ajouter une présentation") + " (" + prev.code_produit + ")"
  anchors.centerIn: parent
  standardButtons: Dialog.Close
  signal saved(codeCIP13: var)

  function setCodeProduit(codeProduit) {
    prev.setCodeProduit(codeProduit)
  }
  
  contentWidth: frame.leftPadding + 300 + layout.spacing + 300 + frame.rightPadding
  contentHeight: frame.topPadding + setup.height + frame.bottomPadding
  
  contentItem: Frame {
    id: frame
    padding: 5
    
    Flickable {
      anchors.fill: parent
      contentWidth: layout.width
      contentHeight: layout.height
      clip: true
      
      RowLayout {
        id: layout
        spacing: 15
        clip: true
        height: setup.height

        Frame {
          Layout.preferredWidth: 300
          Layout.fillHeight: true
          Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: prev.height
            clip: true

            ScrollBar.vertical: ScrollBar{}

            ColumnLayout {
              id: prev
              width: parent.width
              property bool readOnly: true
              property string code_produit
              
              function setCodeProduit(codeProduit) {
                var result = sqlEngine.select(
                  "produits JOIN categories on produits.category = categories.id",
                  ["designation", "titulaire", "detail", "technical_data_sheet",
                   "categories.category"],
                  "produits.code_produit", codeProduit);
                
                if (result.length === 1) {
                  code_produit = codeProduit;
                  designationField.text = result[0][0];
                  titulaireField.text = result[0][1];
                  detailsField.text = result[0][2];
                  donneesField.text = result[0][3];
                  
                  categoryField.text = result[0][4];
                } else {
                  code_produit = "-1";
                  designationField.text = "";
                  titulaireField.text = "";
                  detailsField.text = "";
                  donneesField.text = "";
                  
                  categoryField.text = "";
                }
              }
              
              CustomTextLabelField {
                id: designationField
                title: qsTr("Désignation")
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: titulaireField
                title: qsTr("Titulaire")
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: detailsField
                title: "Détails"
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: donneesField
                title: qsTr("Données techniques")
                Layout.fillWidth: true
              }
              Rectangle {
                implicitHeight: 2
                color: "black"
                visible: categoryField.visible
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: categoryField
                title: qsTr("Catégorie")
                Layout.fillWidth: true
              }              
            }            
          }
        }

        PresentationProduit {
          modelEAN13: -1
          codeProduitFieldText: prev.code_produit
          id: setup
          implicitWidth: 300
        }
      }
      ScrollBar.horizontal: ScrollBar {}
    }
  }
  footer: DialogButtonBox {
    standardButtons: Dialog.Cancel
    Button {
      text: "Ok"
      onClicked: function() {
        if (setup.save()) {
          root.saved(setup.ean13);
        }
      }
    }
  }
}
