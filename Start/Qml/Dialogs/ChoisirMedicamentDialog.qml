import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Widgets"

import core

Dialog {
  id: root
  title: "Choisir le medicament"
  anchors.centerIn: parent
  property string selected: "-1"

  footer: DialogButtonBox {
    standardButtons: Dialog.Cancel
    Button {
      id: okButtton
      text: "Ok"
      enabled: false
      onClicked: function() {
        root.accept();
      }
    }
  }
  
  contentItem: Frame {
    padding: 5
    ColumnLayout {
      anchors.fill: parent
      spacing: 0

      TableAndFilter {
        id: table
        Layout.fillHeight: true
        Layout.fillWidth: true
        query: "SELECT code_CIP13, denomination_du_medicament || '\n' || "
          + "libelle_de_la_presentation as nom from presentation join "
          + "specialite on presentation.code_CIS = specialite.code_CIS "
          + "WHERE code_CIP13 like '%" + search + "%' OR nom like '%"
          + search + "%'"
        horizontalHeader: ["CIP13", qsTr("Médicament")]
        columnsWidth: [120, 400]
        onActivated: function(idVal) {
          root.selected = getIdVal(currentIndex.row);
          root.accept();
        }

        onCurrentRowChanged: function() {
          if (currentRow === -1) {
            root.selected = "-1"
            okButtton.enabled = false;
          } else {
            root.selected = getIdVal(currentRow)
            okButtton.enabled = true;
          }
        }
      }
      
      ToolBar {
        Layout.fillWidth: true
        RowLayout {
          ToolButton {
            id: ajouterButton
            text: qsTr("Ajouter une présentation")
            onClicked: function() {
              codeCISDial.open();
            }
          }
        }
      }
    }
  }
    
  Dialog {
    id: codeCISDial
    title: qsTr("Ajouter une présentation")
    onOpened: function() {
      tableC.search = "";
      tableC.clearSelection();
    }
    anchors.centerIn: parent
    contentWidth: 500
    contentHeight: 300

    contentItem: Frame {
      padding: 5
      ColumnLayout {
        anchors.fill: parent
        Label {
          text: qsTr("Entrez le code CIS ou la denomination du medicament")
        }
        TableAndFilter {
          id: tableC
          Layout.fillWidth: true
          Layout.fillHeight: true
          
          query: "SELECT code_CIS, denomination_du_medicament FROM specialite "
            + "WHERE code_CIS like '%" + search + "%' "
            + "OR denomination_du_medicament like '%" + search + "%'"
          horizontalHeader: ["Code CIS", "Denomination"]
          columnsWidth: [100, 400]

          onCurrentRowChanged: function() {
            choisir.enabled = currentRow >= 0
          }

          onActivated: function(idVal) {
            codeCISDial.choisirCIS(idVal);
          }
        }
      }
    }

    function choisirCIS(idVal) {
      dialog.codeCIP13 = "";
      dialog.setCodeCIS(idVal);
      dialog.open();
    }
    
    footer: DialogButtonBox {
      standardButtons: Dialog.Cancel
      Button {
        id: choisir
        text: qsTr("Choisir")
        onClicked: function() {
          var idVal = tableC.getIdVal(tableC.currentRow);
          codeCISDial.choisirCIS(idVal);
        }
      }
    }
  }

  AjoutStockPresentation {
    id: dialog
    property string codeCIP13: ""
    onSaved: function(cip13) {
      root.selected = cip13;
      dialog.accept();
      codeCISDial.accept();
      root.accept();
    }
  }
}
