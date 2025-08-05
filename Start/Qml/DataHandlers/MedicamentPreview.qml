import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

Frame {
  id: root
  property string idStock: "-1"
  property alias packetEnCours: packetField.text
  property alias nombrePacket: nombrePacketField.text

  clip: true

  function setId(id) {
    var result = sqlEngine.select(
      "presentation JOIN specialite ON presentation.code_CIS = specialite.code_CIS "
        + "JOIN composition on presentation.code_CIS = composition.code_CIS",
      ["denomination_du_medicament", "forme_pharmaceutique", "voies_dadministration",
       "titulaires", "designation_de_lelement_pharmaceutique",
       "denomination_de_la_substance", "dosage_de_la_substance",
       "referene_de_ce_dosage", "libelle_de_la_presentation",
       "code_CIP7", "code_CIP13", "presentation.code_CIS"],
      "presentation.code_CIP13", id);
    
    if (result.length === 1) {
      root.idStock = id;
      denominationField.text = result[0][0];
      formeField.text = result[0][1];
      voiesField.text = result[0][2];
      titulairesField.text = result[0][3];
      
      elementField.text = result[0][4];
      denominationSubstanceField.text = result[0][5];
      dosageField.text = result[0][6];
      referenceField.text = result[0][7];
      
      libelleField.text = result[0][8];
      codeCIP7Field.text = result[0][9];
      codeCIP13Field.text = result[0][10];
      image.source = "image://imageProvider/db://presentation/code_CIP13/" + result[0][10];
    } else {
      root.idStock = "-1"
      denominationField.text = "";
      formeField.text = "";
      voiesField.text = "";
      titulairesField.text = "";
      
      elementField.text = "";
      denominationSubstanceField.text = "";
      dosageField.text = "";
      referenceField.text = "";
      
      libelleField.text = "";
      codeCIP7Field.text = "";
      codeCIP13Field.text = "";
      
      packetField.text = "";
    }
    
  }
  
  Flickable {
    id: flickable
    anchors.fill: parent
    contentWidth: width
    contentHeight: layout.implicitHeight
    clip: true

    ColumnLayout {
      id: layout
      spacing: 10
      width: parent.width

      CustomLabelField {
        id: nombrePacketField
        Layout.fillWidth: true
        title: qsTr("Nombre packets")
        visible: text !== ""
      }
      CustomLabelField {
        id: packetField
        Layout.fillWidth: true
        title: qsTr("Id packet en cours")
        visible: text !== "" && text !== "-1"
      }
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 2
        color: "black"
      }
      CustomLabelField {
        id: denominationField
        Layout.fillWidth: true
        title: qsTr("Denomination du medicament")
      }
      CustomLabelField {
        id: formeField
        Layout.fillWidth: true
        title: qsTr("Forme Pharmaceutique")
      }
      CustomLabelField {
        id: voiesField
        Layout.fillWidth: true
        title: "Voies d'administration"
      }
      CustomLabelField {
        id: titulairesField
        Layout.fillWidth: true
        title: qsTr("Titulaires")
      }
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 2
        color: "black"
        visible: elementField.visible || denominationSubstanceField.visible ||
          dosageField.visible || referenceField.visible
      }
      CustomLabelField {
        id: elementField
        Layout.fillWidth: true
        title: qsTr("Element pharmaceutique")
      }
      CustomLabelField {
        id: denominationSubstanceField
        Layout.fillWidth: true
        title: qsTr("Denomination de la substance")
      }
      CustomLabelField {
        id: dosageField
        Layout.fillWidth: true
        title: qsTr("Dosage")
      }
      CustomLabelField {
        id: referenceField
        Layout.fillWidth: true
        title: qsTr("Reference")
      }
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 2
        color: "black"
        visible: libelleField.visible || codeCIP7Field.visible || codeCIP13Field.visible
      }
      CustomLabelField {
        id: libelleField
        Layout.fillWidth: true
        title: qsTr("Libelle de la presentation")
      }
      CustomLabelField {
        id: codeCIP7Field
        Layout.fillWidth: true
        title: qsTr("Code CIP7")
      }
      CustomLabelField {
        id: codeCIP13Field
        Layout.fillWidth: true
        title: qsTr("Code CIP13")
      }
      Image {
        id: image
        cache: false
        Layout.fillWidth: true
      }
    }

    ScrollBar.vertical: ScrollBar {}
  }
}
