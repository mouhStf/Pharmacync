pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

Pane {
  id: root
  property alias tableView: tableView
  property alias currentRow: tableView.currentRow
  property alias currentIndex: ism.currentIndex
  property ListModel contextMenuItems: ListModel {}
  property int columnsWidth
  
  signal activated(idVal: var)
  
  function selectRow(rw) {
    ism.setCurrentIndex(tableView.index(rw, 1), ItemSelectionModel.Select);
  }
  
  function clearSelection() {
    ism.clearSelection();
    ism.clearCurrentIndex();
  }  

  // Sinon il ya un espace blacn entre la table et le rest
  padding: 0

  HorizontalHeaderView {
    id: horizontalHeader
    anchors{
      top: parent.top
      left: parent.left
      right: parent.right
    }
    syncView: tableView
    textRole: "display"
    clip: true
  }
  
  TableView {
    id: tableView
    anchors{
      top: horizontalHeader.bottom
      bottom: parent.bottom
      left: parent.left
      right: parent.right
    }
    boundsBehavior: Flickable.OvershootBounds
    focus: true
    clip: true
    
    interactive: true
    selectionBehavior: TableView.SelectRows
    selectionMode: TableView.SingleSelection

    selectionModel: ItemSelectionModel {
      id: ism
      }
    
    Keys.onReturnPressed: function() {
      root.activated(model.getIdVal(currentRow));
    }

    delegate: TableViewDelegate {
      id: delegate
      property int columnWidth: tableView.model.columnWidth(column)
      implicitWidth: columnWidth > 0 ? columnWidth : Math.max(
        tableView.model.columnWidth(column+1), // meaning column is the last one and that way columnWidht(columns+1) return the actual width set by user
        root.width + columnWidth)
      implicitHeight: 50
      selected: row === tableView.currentRow
      clip: true

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function(mouse) {
          tableView.forceActiveFocus();
          ism.setCurrentIndex(tableView.index(delegate.row, delegate.column), ItemSelectionModel.NoUpdate);
          
          if (mouse.button === Qt.RightButton) {
            contextMenu.currentRow = delegate.row;
            if (root.contextMenuItems.count > 0) {
              contextMenu.popup(delegate.x + mouseX, delegate.y + horizontalHeader.height + mouseY);
            }
          }
        }
        onDoubleClicked: function() {
          root.activated(tableView.model.getIdVal(delegate.row));
        }
      }
      
      contentItem: Text {
        text: delegate.model.display
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        elide: Text.ElideRight
      }
    }

    ScrollBar.vertical: ScrollBar {}
    ScrollBar.horizontal: ScrollBar {}
  }  
  
  
  Menu {
    id: contextMenu
    property int currentRow: -1
    
    Instantiator {
      id: instantiator
      model: root.contextMenuItems
      delegate: MenuItem {
        required property int index
        required property string title
        required property var func

        text: title
        onTriggered: func(tableView.model.getIdVal(contextMenu.currentRow));
      }
      
      onObjectAdded: (index, object) => contextMenu.addItem(object);
      onObjectRemoved: (index, object) => contextMenu.removeItem(object)
    }
  }
}
