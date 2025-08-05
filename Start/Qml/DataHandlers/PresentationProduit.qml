import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "../Widgets"
import "../Utils/functions.mjs" as Functions

import core


Frame {
  id: root
  property string name: "Presentation Produit"
  property bool readOnly: false
  property string ean13: "-1"
  property alias codeProduitFieldText: codeProduitField.text
  
  signal openStock(idVal: var)
  
  required property var modelEAN13
  onModelEAN13Changed: function () {
    setEan13(modelEAN13);
  }
  
  signal deleteDone();
  
  property string tableName: "presentation_produit"
  property var columns: ["ean_13", "code_produit", "libelle",
                         "description"]
  
  function setEan13(ean13) {
    if (ean13 === "-1") {
      root.ean13 = "-1";
      ean13Field.text = "";
      codeProduitField.text = "";
      libelleField.text = "";
      descriptionField.text = "";
      image.source = "";
    } else {
      if (fillFields(ean13)) {
        root.ean13 = ean13;
        image.source = "image://imageProvider/db://"+ root.tableName +"/ean_13/" + ean13
      } else {
        setEan13("-1");
      }
    }
  }
  
  function fillFields(ean13) {
    var result = sqlEngine.select(root.tableName, root.columns, "ean_13", ean13);
    if (result.length === 1) {
      ean13Field.text = result[0][0];
      codeProduitField.text = result[0][1];
      libelleField.text = result[0][2];
      descriptionField.text = result[0][3];
      return true;
    }
    return false;
  }
  
  function save() {
    if (!validate()) return false;
    var values = [ean13Field.text, codeProduitField.text,
                  libelleField.text, descriptionField.text];
    
    var saved = false;
    if (ean13 === "-1") {
      saved = Functions.save(tableName, columns, values, "ean_13",
                             ean13Field.text);
    } else {
      saved = Functions.update(tableName, columns, values, "ean_13", ean13);
    }
    if (saved) root.ean13 = ean13Field.text;
    
    var str = image.source.toString();
    if (saved && str.includes("file://")) {
      image.source = "";
      image.source = str;
      imageProviderObject.save(tableName, "ean_13", root.ean13);
    }
    
    return saved;
  }
  
  function validate() {
    if (ean13Field.text === "") {
      ean13Field.error = "Le code EAN 13 ne doit pas être vide.";
      return false;
    } else {
      ean13Field.error = "";
    }
    return true;
  }
  
  contentItem: ColumnLayout {
    property bool readOnly: root.readOnly        
    CustomTextLabelField {
      id: ean13Field
      title: "EAN CIP13"
      validator: /\d{13}/
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: codeProduitField
      title: "Code Prodtui"
      visible: false
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: libelleField
      title: "Libelle"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: descriptionField
      title: "Description"
      Layout.fillWidth: true
    }
    
    Label {
      visible: !root.readOnly || image.sourceSize.width > 1
      text: "Image"
      font.pixelSize: 11
    }
    Frame {
      id: imgFrame
      visible: !root.readOnly || image.sourceSize.width > 1
      Layout.preferredHeight: image.sourceSize.width > 1 ? 300 :
        (40 + topPadding + bottomPadding)
      Layout.fillWidth: true
      Image {
        id: image
        anchors.fill: parent
        cache: false
        
        Row {
          visible: !root.readOnly
          anchors {
            right: parent.right
            rightMargin: 3
            bottom: parent.bottom
            bottomMargin: 3
          }
          spacing: 4
          
          ToolButton {
            icon.source: "qrc:/icons/svgs/solid/pen.svg"
            icon.width: 13
            icon.height: 13
            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Choisir une image.")
            onClicked: fileDialog.open()
          }
          ToolButton {
            icon.source: "qrc:/icons/svgs/solid/xmark.svg"
            icon.width: 13
            icon.height: 13
            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Supprimer l'image.")
            onClicked: function() {
              onClicked: xmark.open()
            }
          }
        }
      }
    }

    ColumnLayout {
      visible: table.tableView.rows > 0 && !root.readOnly
      Layout.fillWidth: true
      Label {
        text: "Stock"
      }
      Frame {
        Layout.fillWidth: true
        Layout.preferredHeight: 150
        Table {
          id: table
          anchors.fill: parent
          tableView.model: TableModel {
            id: tableModel
            query: "SELECT id, quantite, restant, date_acquisition FROM entres_stock WHERE deleted = 0 AND code_CIP13 = " + root.ean13
            horizontalHeader: [qsTr("Id"), qsTr("Quantite"), qsTr("Restant"), qsTr("Acquisition")]
            columnsWidth: [40, 65, 65, 100]
            datesColumns: [3]
          }
          
          contextMenuItems: ListModel {          
            ListElement {
              title: qsTr("Voir")
              func: function() {
                root.openStock(root.ean13);
              }
            }
          }
          
          onActivated: function() {
            root.openStock(root.ean13);
          }
        }
      }
    }

    Button {
      visible: ! root.readOnly
      enabled: table.tableView.rows === 0
      text: "Supprimer la presentation"
      ToolTip.visible: hovered && !enabled
      ToolTip.delay: 1000
      ToolTip.timeout: 5000
      ToolTip.text: qsTr("Cette presentation est dans le stock.")
      onClicked: confirmSuppression.open();
    }
  }
  
  Dialog {
    id: confirmSuppression
    anchors.centerIn: parent
    standardButtons: Dialog.Cancel | Dialog.Ok
    Label {
      text: qsTr("Confirmez vous la suppression ?")
    }
    onAccepted: function() {
      var ok = false;
      if (root.ean13 === "-1") {
        ok = true;
      } else {
        var result = sqlEngine.select("entres_stock", ["id"], "code_CIP13", root.ean13);
        if (result.length > 0)
          ok = sqlEngine.update(root.tableName, ["deleted"], [1], "ean_13", root.ean13);
        else
          ok = sqlEngine.deleteRow(root.tableName, "ean_13", root.ean13);
      }
      if (ok) root.deleteDone();
    }
  }
  
  Dialog {
    id: xmark
    title: "Supprimer l'image"
    standardButtons: Dialog.Ok | Dialog.Cancel
    anchors.centerIn: parent
    Label {
      text: qsTr("Confirmer la suppression de l'image.")
    }
    onAccepted: function() {
      imageProviderObject.deleteImage("presentation_produit", "ean_13", root.ean13);
      image.source = "";
    }
  }
  
  FileDialog {
    id: fileDialog
    title: "Choisir une Image"
    nameFilters: [
      "Images (*.bmp *.gif *.jpg *.jpeg *.png *.pbm *.pgm *.ppm *.xbm *.xpm *.svg *.tiff *.tif *.webp *.ico *.heif *.heic *.jxl)",
      "Tous les fichiers (*)"
    ]
    onAccepted: function() {
      image.source = "image://imageProvider/" + selectedFile
    }
  }
}
