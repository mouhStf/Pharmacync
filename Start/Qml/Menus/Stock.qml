import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    title: "Stock"
    StackLayout {
        anchors.fill: parent
        clip: true

        currentIndex: bar.currentIndex

        StockMedicament {}

        StockProduit {}
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
