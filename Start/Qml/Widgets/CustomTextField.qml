import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
  id: root
  property alias title: label.text
  property alias text: textField.text
  property alias error: error.text
  property alias validator: regValidator.regularExpression
  property alias cursorPosition: textField.cursorPosition
  property alias echoMode: textField.echoMode
  width: 300
  signal editingBeginning();
  signal editinFinished();
  signal textEdited();
  
  property bool readOnly: parent !== undefined ? parent.readOnly : false
  
  spacing: 3
  
  Label {
    id: label
    visible: text !== ""
    font.pixelSize: 11
  }
  
  TextField {
    id: textField
    readOnly: root.readOnly
    Layout.fillWidth: true
    
    validator: RegularExpressionValidator {
      id: regValidator
    }
    
    onFocusChanged: function() {
      if (focus)
        root.editingBeginning();
    }

    /*
    background: Rectangle {
      implicitHeight: 40
      implicitWidth: root.width
      color: textField.palette.base
      border.color: error.text !== textField.palette.base ? "red" : (textField.activeFocus ? textField.palette.highlight : textField.palette.mid)
      border.width: textField.activeFocus ? 2 : 1
    }*/
    onTextEdited: root.textEdited();
    onEditingFinished: root.editinFinished();
  }
  Label {
    id: error
    visible: text !== ""
    color: "#951512"
    Layout.fillWidth: true
    wrapMode: Text.Wrap
  }
}
