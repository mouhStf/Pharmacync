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
      query: "select code_CIS, titulaires, denomination_du_medicament"
        + " from specialite WHERE deleted = 0 AND (code_CIS like '%"
        + search + "%' or denomination_du_medicament like '%"
        + search + "%' or titulaires like '%" + search + "%')"
      horizontalHeader: ["CIS", "Titulaire", "Denomination"]
      columnsWidth: [120, 300, 450]

      onActivated: function(idVal) {
        dialog.setCode_CIS(idVal);
        dialog.readOnly = true;
        dialog.open();
      }
      contextMenuItems: ListModel {
        ListElement {
          title: qsTr("Voir")
          func: function(idVal) {
            dialog.setCode_CIS(idVal);
            dialog.readOnly = true;
            dialog.open();
          }
        }
        ListElement {
          title: qsTr("Editer")
          func: function(idVal) {
            dialog.setCode_CIS(idVal);
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
            dialog.setCode_CIS(idVal);
            dialog.readOnly = false;
            dialog.open()
          }
        }
      }
    }
  }
  
  DictionnaireMedicamentDialog {
    id: dialog
    anchors.centerIn: parent
    onClosed: table.refresh()
  }
}
