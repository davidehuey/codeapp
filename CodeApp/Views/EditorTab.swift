//
//  editorTab.swift
//  Code
//
//  Created by Ken Chung on 16/5/2021.
//

import SwiftUI

struct EditorTab: View {

    @EnvironmentObject var App: MainApp
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var currentEditor: EditorInstance
    // This is used for force updating the view.
    @State private var lastUpdateTime: Date = Date()

    var isActive: Bool
    var index: Int
    var onOpenEditor: () -> Void
    var onCloseEditor: () -> Void
    var onSaveEditor: () -> Void

    static private func keyForInt(int: Int) -> KeyEquivalent {
        if int < 10 {
            return KeyEquivalent.init(String(int).first!)
        }
        return KeyEquivalent.init("0")
    }

    var body: some View {
        Group {
            HStack(spacing: 4) {
                // TODO: File Icons for extensions
                FileIcon(url: currentEditor.title, iconSize: 12, type: .file)
                Button(action: {
                    onOpenEditor()
                }) {
                    Group {
                        if let editorURL = (currentEditor as? EditorInstanceWithURL)?.url,
                            let status = App.gitTracks[editorURL]
                        {
                            FileDisplayName(
                                gitStatus: status,
                                name: currentEditor.title)
                        } else {
                            FileDisplayName(
                                gitStatus: nil, name: currentEditor.title)
                        }
                        if let textEditor = currentEditor as? TextEditorInstance,
                            textEditor.isDeleted
                        {
                            Text("(deleted)").italic()
                        }
                    }
                    .lineLimit(1)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(
                        Color.init(id: isActive ? "tab.activeForeground" : "tab.inactiveForeground")
                    )
                }.keyboardShortcut(EditorTab.keyForInt(int: index + 1), modifiers: .command)

                Group {
                    if let textEditor = currentEditor as? TextEditorInstance,
                        textEditor.currentVersionId != textEditor.lastSavedVersionId
                    {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 7))
                            .foregroundColor(
                                Color.init(
                                    id: isActive ? "tab.activeForeground" : "tab.inactiveForeground"
                                )
                            )
                            .frame(width: 18, height: 18)
                            .contentShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                            .hoverEffect(.highlight)
                            .if(isActive) {
                                $0.onTapGesture {
                                    onCloseEditor()
                                }
                            }
                    } else if isActive {
                        Image(systemName: "xmark")
                            .font(.system(size: 8))
                            .foregroundColor(
                                Color.init(
                                    id: isActive ? "tab.activeForeground" : "tab.inactiveForeground"
                                )
                            )
                            .frame(width: 26, height: 26)
                    }

                }
                .contentShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                .hoverEffect(.highlight)
                .onTapGesture {
                    onCloseEditor()
                }

            }
            .frame(height: 40)
            .padding(.horizontal, 8)
            .if(isActive) {
                $0.background(Color(id: "tab.activeBackground"))
            }
            .cornerRadius(10, corners: [.topLeft, .topRight])
        }
    }
}