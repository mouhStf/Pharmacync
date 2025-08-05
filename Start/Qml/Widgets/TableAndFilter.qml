import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import core

Frame {
  id: root
  padding: 2
  topPadding: 2
  bottomPadding: 2
  spacing: 2

  property string query
  property var horizontalHeader
  property var columnsWidth
  property var datesColumns: []
  property alias search: searchField.text
  property alias currentRow: table.currentRow
  property alias currentIndex: table.currentIndex
  property alias contextMenuItems: table.contextMenuItems

  function refresh() {
    tableModel.refresh();
  }

  function getIdVal(row: int) : var {
    return tableModel.getIdVal(row);
  }

  function getVal(row: int, col: int) : var {
    return tableModel.getVal(row, col);
  }

  function clearSelection() {
    table.clearSelection();
  }
  
  function selectRow(row: int) {
    table.selectRow(row);
  }
  function rowCount() {
    return tableModel.rowCount();
  }
  signal activated(idVal: var);

  ColumnLayout {
    anchors.fill: parent    
    Table {
      id: table
      Rectangle {
        anchors.fill: parent
        visible: table.tableView.rows <= 0
        Text {
          anchors.centerIn: parent
          text: "Aucun élément."
        }
      }

      Layout.fillHeight: true
      Layout.fillWidth: true
      onActivated: function (idVal) {
        root.activated(idVal);
      }
      tableView.model: TableModel {
        id: tableModel
        query: root.query
        horizontalHeader: root.horizontalHeader
        columnsWidth: root.columnsWidth
        datesColumns: root.datesColumns
      }
    }
    
    Pane {
      Layout.fillWidth: true
      padding: 5
      RowLayout {
        anchors.fill: parent
        
        TextField {
          id: searchField
          Layout.fillWidth: true
          //enabled: table.tableView.rows > 0
          placeholderText: "Filtrer"
        }
      }
    }
  }
}
