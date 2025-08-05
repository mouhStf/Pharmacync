import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
  id: root
  property alias title: label.text
  property string text
  property alias error: error.text
  property alias validator: regValidator.regularExpression
  property alias cursorPosition: textField.cursorPosition
  property alias echoMode: textField.echoMode
  signal editingBeginning();
  signal editinFinished();
  signal textEdited();

  // This is for plugging in some kind of controls (...)
  property bool readOnly: parent !== undefined ? parent.readOnly : false
  
  spacing: 3
  
  Label {
    id: label
    visible: text !== ""
    font.pixelSize: 11
    Layout.fillWidth: true
  }

  Label {
    visible: root.readOnly
    font.pixelSize: 15
    wrapMode: Text.Wrap
    Layout.fillWidth: true
    text: root.text
  }
  
  TextField {
    id: textField
    visible: !root.readOnly
    Layout.fillWidth: true
    text: root.text
    
    validator: RegularExpressionValidator {
      id: regValidator
    }
    
    onFocusChanged: function() {
      if (focus)
        root.editingBeginning();
    }
    
    onTextEdited: function() {
      root.text = text;
      root.textEdited();
    }
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
