import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

Frame {
  id: root
  property string idStock: "-1"
  property alias packetEnCours: packetField.text

  clip: true
  
  function setId(id) {
    var result = sqlEngine.select(
      "presentation_produit JOIN produits ON presentation_produit.code_produit = produits.code_produit",
      ["designation", "produits.code_produit", "titulaire",
       "detail", "technical_data_sheet", "ean_13", "libelle",
       "description"],
      "ean_13", id);
    
    if (result.length === 1) {
      root.idStock = id;
      designationField.text = result[0][0];
      codeProduitField.text = result[0][1];
      titulairesField.text = result[0][2];
      detailsField.text = result[0][3];
      dataField.text = result[0][4];
      
      ean13Field.text = result[0][5];
      libelleField.text = result[0][6];
      descriptionField.text = result[0][7];
      
      image.source = "image://imageProvider/db://presentation_produit/ean_13/" + result[0][5];
    } else {
      root.idStock = "-1"
      designationField.text = "";
      codeProduitField.text = "";
      titulairesField.text = "";
      detailsField.text = "";
      dataField.text = "";
      
      ean13Field.text = "";
      libelleField.text = "";
      descriptionField.text = "";
      
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
        id: packetField
        Layout.fillWidth: true
        title: "Id packet en cours"
        visible: text !== "" && text !== "-1"
      }
      Rectangle {
        implicitWidth: parent.width
        implicitHeight: 2
        color: "black"
      }
      CustomLabelField {
        id: designationField
        Layout.fillWidth: true
        title: qsTr("Designation")
      }
      CustomLabelField {
        id: codeProduitField
        Layout.fillWidth: true
        title: qsTr("Code produit")
      }
      CustomLabelField {
        id: titulairesField
        Layout.fillWidth: true
        title: qsTr("Titulaires")
      }
      CustomLabelField {
        id: detailsField
        Layout.fillWidth: true
        title: qsTr("Details")
      }
      CustomLabelField {
        id: dataField
        Layout.fillWidth: true
        title: qsTr("Donnes techniques")
      }
      Rectangle {
        implicitWidth: parent.width
        implicitHeight: 2
        color: "black"
        visible: ean13Field.visible || libelleField.visible || descriptionField.visible
      }
      CustomLabelField {
        id: ean13Field
        Layout.fillWidth: true
        title: qsTr("EAN 13")
      }
      CustomLabelField {
        id: libelleField
        Layout.fillWidth: true
        title: qsTr("Libelle de la presentation")
      }
      CustomLabelField {
        id: descriptionField
        Layout.fillWidth: true
        title: qsTr("Description")
      }
      Image {
        id: image
        cache: false
        Layout.fillWidth: true
      }
    }

    ScrollBar.vertical: ScrollBar{}
  }
}
