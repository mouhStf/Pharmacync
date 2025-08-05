import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "../Widgets"
import "../Utils/functions.mjs" as Functions

import core

Frame {
  id: root
  property string name: "Presentation"
  property bool readOnly: false
  property string codeCIP13: "-1"
  property alias codeCISFieldText: codeCISField.text
  
  signal openStock(idVal: var)
  
  required property var modelCIP13
  onModelCIP13Changed: function () {
    setCodeCIP13(modelCIP13);
  }
  
  signal deleteDone();
  
  property string tableName: "presentation"  
  property var columns: ["code_CIP13", "libelle_de_la_presentation",
                         "code_CIP7", "code_CIS"]

  
  function setCodeCIP13(codeCIP13) {
    if (codeCIP13 === "-1") {
      root.codeCIP13 = "-1";
      codeCIP13Field.text = "";
      libelleField.text = "";
      codeCIP7Field.text = "";
      codeCISField.text = "";
      image.source = "";
    } else {
      if (fillFields(codeCIP13)) {
        root.codeCIP13 = codeCIP13;
        image.source = "image://imageProvider/db://presentation/code_CIP13/" + codeCIP13
      } else {
        setCodeCIP13("-1");
      }
    }
  }
  
  function fillFields(codeCIP13) {
    var result = sqlEngine.select(root.tableName, root.columns, "code_CIP13", codeCIP13);
    if (result.length === 1) {
      codeCIP13Field.text = result[0][0];
      libelleField.text = result[0][1];
      codeCIP7Field.text = result[0][2];
      codeCISField.text = result[0][3];
      return true;
    }
    return false;
  }
  
  function save() {
    if (!validate()) return false;
    var values = [codeCIP13Field.text, libelleField.text,
                  codeCIP7Field.text, codeCISField.text];
    
    var saved = false;
    if (codeCIP13 === "-1") {
      saved = Functions.save(tableName, columns, values, "code_CIP13",
                             codeCIP13Field.text);
    } else {
      saved = Functions.update(tableName, columns, values, "code_CIP13", codeCIP13);
    }
    if (saved) root.codeCIP13 = codeCIP13Field.text;
    
    var str = image.source.toString();
    if (saved && str.includes("file://")) {
      image.source = "";
      image.source = str;
      imageProviderObject.save(tableName, "code_CIP13", root.codeCIP13);
    }
    
    return saved;
  }
  
  function validate() {
    if (codeCIP13Field.text === "") {
      codeCIP13Field.error = "Le code CIP13 ne doit pas être vide.";
      return false;
    } else {
      codeCIP13Field.error = "";
    }
    
    if (codeCIP7Field.text === "") {
      codeCIP7Field.error = "Le code CIP7 ne doit pas être vide.";
      return false;
    } else {
      codeCIP7Field.error = "";
    }
    return true;
  }

  contentItem: ColumnLayout {
    property bool readOnly: root.readOnly
    CustomTextLabelField {
      id: codeCIP13Field
      title: "Code CIP13"
      validator: /\d{13}/
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: libelleField
      title: "Libellé de la présentation"
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: codeCIP7Field
      title: "Code CIP7"
      validator: /\d{7}/
      Layout.fillWidth: true
    }
    CustomTextLabelField {
      id: codeCISField
      title: "Code CIS"
      visible: false
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
      Layout.preferredHeight: image.sourceSize.width > 1 ? width :
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
            query: "SELECT id, quantite, restant, date_acquisition FROM entres_stock WHERE deleted = 0 AND code_CIP13 = " + root.codeCIP13
            horizontalHeader: [qsTr("Id"), qsTr("Quantite"), qsTr("Restant"), qsTr("Acquisition")]
            columnsWidth: [40, 65, 65, 100]
            datesColumns: [3]
          }
          
          contextMenuItems: ListModel {          
            ListElement {
              title: qsTr("Voir")
              func: function() {
                root.openStock(root.codeCIP13);
              }
            }
          }
          
          onActivated: function() {
            root.openStock(root.codeCIP13);
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
      if (root.codeCIP13 === "-1") {
        ok = true;
      } else {
        var result = sqlEngine.select("entres_stock", ["id"], "code_CIP13", root.codeCIP13);
        if (result.length > 0)
          ok = sqlEngine.update(root.tableName, ["deleted"], [1], "code_CIP13", root.codeCIP13);
        else
          ok = sqlEngine.deleteRow(root.tableName, "code_CIP13", root.modelCIP13);
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
      imageProviderObject.deleteImage("presentation", "code_CIP13", root.codeCIP13);
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
