import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../Widgets"

Page {
  title: "Dictionnaire"
  StackLayout {
    anchors.fill: parent
    currentIndex: bar.currentIndex

    DictionnaireMedicament {}

    DictionnaireProduit {}
  }

  footer: TabBar {
    id: bar
    TabButton {
      text: qsTr("Medicaments")
    }
    TabButton {
      text: qsTr("Produits")
    }
  }
}
