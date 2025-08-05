pragma Singleton
import QtQuick

QtObject {
    readonly property int width: 1024
    readonly property int height: 768

    property string relativeFontDirectory: "fonts"

    /* Edit this comment to add your custom font */
    readonly property font font: Qt.font({
                                             family: Application.font.family,
                                             pixelSize: Application.font.pixelSize
                                         })
    readonly property font largeFont: Qt.font({
                                                  family: Application.font.family,
                                                  pixelSize: Application.font.pixelSize * 1.6
                                              })

    readonly property color backgroundColor: "#EAEAEA"



}
