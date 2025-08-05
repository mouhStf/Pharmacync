pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "Screens"
import "Widgets"
import "Menus"

ApplicationWindow {
  width: 1100
  height: 650
  visible: true
  title: "PharmaCync"
  id: window
    
  header: ToolBar {
    visible: stack.depth > 1
    RowLayout {
      anchors.fill: parent
      ToolButton {
        onClicked: stack.pop()
        visible: stack.depth > 2
        icon.source: "qrc:/icons/svgs/solid/arrow-left.svg"
        display: Button.IconOnly
      }
      Label {
        text: stack.currentItem.title
        elide: Label.ElideRight
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        Layout.fillWidth: true
      }
      ToolButton {
        text: qsTr("Deconnecter")
        onClicked: function() {
          sqlEngine.setUserId(-1);
          stack.popToIndex(0);
        }
      }
    }
  }
  
  StackView {
    id: stack
    anchors.fill: parent
    //initialItem: loginComponent
    initialItem: menuComponent
  }
  
  Component {
    id: loginComponent
    
    Login {
      property string title: "Connexion"
      onConnected: function() {
        stack.push(menuComponent)
        console.log("connected from main")
      }
    }
  }
  
  Component {
    id: menuComponent
    
    Menu {
      property string title: "Menu"
      
      onVenteClicked: function() {
        stack.push(venteComponent)
      }
      onStockClicked: function() {
        stack.push(stockComponent)
      }
      onDictionnaireClicked: function() {
        stack.push(dictionnaireComponent)
      }
      onConfigurationClicked: function() {
        stack.push(configurationComponent)
      }
      onInventaireClicked: function() {
        stack.push(inventaireComponent);
      }
    }
  }
  
  Component {
    id: venteComponent
    Ventes {}
  }
  
  Component {
    id: stockComponent
    Stock {}
  }
  
  Component {
    id: inventaireComponent
    Inventaire {}
  }
  
  Component {
    id: dictionnaireComponent
    Dictionnaire {}
  }  
  
  Component {
    id: configurationComponent
    Configuration {}
  }
}
