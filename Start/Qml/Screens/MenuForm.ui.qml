import QtQuick
import QtQuick.Controls

Pane {
  id: rectangle
  property alias configuration: configuration
  property alias dictionnaire: dictionnaire
  property alias stock: stock
  property alias vente: vente
  
  Grid {
    id: grid
    width: 310
    height: 310
    anchors.centerIn: parent
    spacing: 10
    columns: 2

    //verticalItemAlignment: Grid.AlignTop
    //horizontalItemAlignment: Grid.AlignHCenter
    
    Button {
      id: vente
      height: 150
      width: 150
      text: qsTr("Vente")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/cash-register.svg"
      display: Button.TextUnderIcon
    }
    
    Button {
      id: stock
      height: 150
      width: 150
      text: qsTr("Stock")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/store.svg"
      display: Button.TextUnderIcon
    }
    
    Button {
      id: dictionnaire
      height: 150
      width: 150
      text: qsTr("Dictionnaire")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/book.svg"
      display: Button.TextUnderIcon
    }

    Button {
      id: configuration
      height: 150
      width: 150
      text: qsTr("Configuration")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/gear.svg"
      display: Button.TextUnderIcon
    }
  }
}
