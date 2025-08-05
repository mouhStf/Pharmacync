import QtQuick
import QtQuick.Controls

Pane {
  id: root
  signal venteClicked()
  signal stockClicked()
  signal inventaireClicked()
  signal dictionnaireClicked()
  signal configurationClicked()

  Grid {
    id: topGrid
    width: 470
    height: 150
    anchors{
      horizontalCenter: parent.horizontalCenter
      bottom: centerer.top
      bottomMargin: 5
    }
    spacing: 10
    columns: 3

    Button {
      height: 150
      width: 150
      text: qsTr("Vente")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/cash-register.svg"
      display: Button.TextUnderIcon
      onClicked: root.venteClicked();
    }
    
    Button {
      height: 150
      width: 150
      text: qsTr("Stock")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/store.svg"
      display: Button.TextUnderIcon
      onClicked: root.stockClicked();
    }
    
    Button {
      height: 150
      width: 150
      text: qsTr("Inventaire")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/book.svg"
      display: Button.TextUnderIcon
      onClicked: root.inventaireClicked();
    }
  }
  
  Item {
    id: centerer
    anchors.centerIn: parent
  }
  
  Grid {
    id: grid
    width: 310
    height: 150
    anchors{
      horizontalCenter: parent.horizontalCenter
      top: centerer.bottom
      topMargin: 5
    }
    spacing: 10
    columns: 2
    
    Button {
      id: dictionnaire
      height: 150
      width: 150
      text: qsTr("Dictionnaire")
      icon.height: 50
      icon.width: 50
      icon.source: "qrc:/icons/svgs/solid/book.svg"
      display: Button.TextUnderIcon
      onClicked: root.dictionnaireClicked();
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
      onClicked: root.configurationClicked();
    }
  }
}
