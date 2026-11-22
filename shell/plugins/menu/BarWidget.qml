import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "{C}"
    foreground: Commons.Color.accent
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("codeswot-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
      else root.bar.run("xdg-terminal-exec")
    }
  }
}

