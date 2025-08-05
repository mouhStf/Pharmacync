import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"
import "../Dialogs"

Frame {
  id: root
  padding: 5
    
  ColumnLayout {
    anchors.fill: parent
    TableAndFilter {
      id: table
      Layout.fillHeight: true
      Layout.fillWidth: true
      query: "SELECT code_produit, titulaire, designation "
        + "FROM produits WHERE code_produit like '%" + search
        + "%' or titulaire like '%" + search
        + "%' or designation like '%" + search + "%'"
      horizontalHeader: ["Code", "Titulaire", "Denomination"]
      columnsWidth: [80, 200, 250]
      
      onActivated: function(idVal) {
        dialog.setCodeProduit(idVal);
        dialog.readOnly = true;
        dialog.open();
      }
      
      contextMenuItems: ListModel {
        ListElement {
          title: qsTr("Voir")
          func: function(idVal) {
            dialog.setCodeProduit(idVal);
            dialog.readOnly = true;
            dialog.open();
          }
        }
        ListElement {
          title: qsTr("Editer")
          func: function(row) {
            var idVal = tableModel.getIdVal(row);
            dialog.setCodeProduit(idVal);
            dialog.readOnly = false;
            dialog.open();
          }
        }        
      }
      
      onCurrentRowChanged: function() {
        editerButton.enabled = currentRow >= 0;
      }
    }
    
    ToolBar {
      Layout.fillWidth: true
      RowLayout {
        ToolButton {
          text: qsTr("Ajouter")
          onClicked: function() {
            dialog.setNew();
            dialog.readOnly = false;
            dialog.open();
          }
        }
        ToolButton {
          id: editerButton
          enabled: false
          text: qsTr("Editer")
          onClicked: function() {
            var idVal = table.getIdVal(table.currentRow);
            dialog.setCodeProduit(idVal);
            dialog.readOnly = false;
            dialog.open()
          }
        }
      }
    }
  }
  
  DictionnaireProduitDialog {
    id: dialog
    anchors.centerIn: parent
    onClosed: table.refresh();
  }
}
