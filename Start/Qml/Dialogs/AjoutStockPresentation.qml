import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../DataHandlers"
import "../Widgets"

import core

// TODO When you choose an image the height is augmented

Dialog {
  id: root
  title: qsTr("Ajouter une présentation") + " (" + prev.code_CIS + ")"
  anchors.centerIn: parent
  standardButtons: Dialog.Close
  signal saved(codeCIP13: var)
  
  function setCodeCIS(codeCIS) {
    prev.setCodeCIS(codeCIS)
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
              property string code_CIS
              
              function setCodeCIS(codeCIS) {
                var result = sqlEngine.select(
                  "specialite JOIN composition on specialite.code_CIS = composition.code_CIS",
                  ["denomination_du_medicament", "forme_pharmaceutique", "voies_dadministration",
                   "titulaires", "designation_de_lelement_pharmaceutique",
                   "denomination_de_la_substance", "dosage_de_la_substance",
                   "referene_de_ce_dosage", "specialite.code_CIS"],
                  "specialite.code_CIS", codeCIS);
                
                if (result.length === 1) {
                  code_CIS = codeCIS;
                  denominationField.text = result[0][0];
                  formeField.text = result[0][1];
                  voiesField.text = result[0][2];
                  titulairesField.text = result[0][3];
                  
                  elementField.text = result[0][4];
                  denominationSubstanceField.text = result[0][5];
                  dosageField.text = result[0][6];
                  referenceField.text = result[0][7];      
                } else {
                  code_CIS = "-1"
                  denominationField.text = "";
                  formeField.text = "";
                  voiesField.text = "";
                  titulairesField.text = "";
                  
                  elementField.text = "";
                  denominationSubstanceField.text = "";
                  dosageField.text = "";
                  referenceField.text = "";
                }
              }
              
              CustomTextLabelField {
                id: denominationField
                title: qsTr("Dénomination du médicament")
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: formeField
                title: qsTr("Forme Pharmaceutique")
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: voiesField
                title: "Voies d'administration"
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: titulairesField
                title: qsTr("Titulaires")
                Layout.fillWidth: true
              }
              Rectangle {
                implicitHeight: 2
                color: "black"
                visible: elementField.visible || denominationSubstanceField.visible ||
                  dosageField.visible || referenceField.visible
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: elementField
                title: qsTr("Element pharmaceutique")
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: denominationSubstanceField
                title: qsTr("Denomination de la substance")
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: dosageField
                title: qsTr("Dosage")
                Layout.fillWidth: true
              }
              CustomTextLabelField {
                id: referenceField
                title: qsTr("Reference")
                Layout.fillWidth: true
              }
            }
            
          }
        }
        
        Presentation {
          modelCIP13: -1
          codeCISFieldText: prev.code_CIS
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
          root.saved(setup.codeCIP13);
        }
      }
    }
  }
}
