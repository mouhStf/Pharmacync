import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    title: "Inventaire"
    StackLayout {
        anchors.fill: parent
        clip: true

        currentIndex: bar.currentIndex

        InventaireMedicament {
          Component.onCompleted: function() {
            stats();
          }
        }

        InventaireProduit {}
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
