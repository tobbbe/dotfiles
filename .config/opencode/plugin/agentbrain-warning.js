import path from "node:path"
import { existsSync } from "node:fs"

function getWarning(directory) {
  const project = path.basename(directory)
  const linkPath = path.join(directory, ".claude.local.md")

  if (existsSync(linkPath)) {
    return null
  }

  const targetPath = path.join(process.env.HOME || "", "dev/agentbrain/projects", `${project}.md`)
  return [
    `Missing .claude.local.md for ${directory}`,
    "Create it with:",
    `ln -s \"${targetPath}\" \"${linkPath}\"`,
  ].join("\n")
}

export const AgentbrainWarningPlugin = async ({ client, directory }) => {
  return {
    event: async ({ event }) => {
      if (event.type !== "session.created") {
        return
      }

      const message = getWarning(directory)
      if (!message) {
        return
      }

      await client.tui.showToast({
        url: "/tui/show-toast",
        query: { directory },
        body: {
          title: "Missing .claude.local.md",
          message,
          variant: "warning",
          duration: 20000,
        },
      }).catch(() => {})

      await client.tui.publish({
        url: "/tui/publish",
        query: { directory },
        body: {
          type: "tui.prompt.append",
          properties: {
            text: `${message}\n\n`,
          },
        },
      }).catch(() => {})
    },
  }
}
