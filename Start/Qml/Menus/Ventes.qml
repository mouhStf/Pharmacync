import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
  title: "Ventes"

  StackLayout {
    anchors.fill: parent
    currentIndex: bar.currentIndex
    CreationVente {
      onUpdatedQuery: facts.updateQuery()
    }
    Factures {
      id: facts
    }
  }

  footer: TabBar {
    id: bar
    TabButton {
      text: qsTr("Caisse")
      icon.source: "qrc:/icons/svgs/solid/cash-register.svg"
    }
    TabButton {
      text: qsTr("Factures")
      icon.source: "qrc:/icons/svgs/solid/receipt.svg"
    }
  }
}
