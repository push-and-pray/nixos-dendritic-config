import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string gameName: ""
    property int percent: 0
    property string progressText: ""
    property bool active: false

    function triggerUpdate() {
        var scriptUrl = Qt.resolvedUrl("fossilize_status.sh").toString();
        var scriptPath = scriptUrl.replace("file://", "");
        statusProcess.command = ["bash", scriptPath];
        statusProcess.running = true;
    }

    Timer {
        id: updateTimer
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.triggerUpdate()
    }

    Process {
        id: statusProcess
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    if (data.status === "replaying" && data.running) {
                        root.active = true;
                        root.gameName = data.game;
                        root.percent = data.percent;
                        root.progressText = data.progress;
                    } else {
                        root.active = false;
                    }
                } catch (e) {
                    root.active = false;
                }
            }
        }
    }

    horizontalBarPill: Component {
        MouseArea {
            implicitWidth: row.implicitWidth
            implicitHeight: row.implicitHeight
            onClicked: root.triggerUpdate()

            Row {
                id: row
                spacing: Theme.spacingXS
                visible: root.active
                anchors.fill: parent

                DankIcon {
                    name: "download"
                    size: Theme.iconSize - 6
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: root.gameName + " " + root.percent + "%"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceVariantText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    verticalBarPill: Component {
        MouseArea {
            implicitWidth: col.implicitWidth
            implicitHeight: col.implicitHeight
            onClicked: root.triggerUpdate()

            Column {
                id: col
                spacing: Theme.spacingXS
                visible: root.active
                anchors.fill: parent

                DankIcon {
                    name: "download"
                    size: Theme.iconSize - 6
                    color: Theme.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    text: root.percent + "%"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceVariantText
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
