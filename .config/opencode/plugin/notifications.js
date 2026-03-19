import { promises as fs } from "node:fs"
import path from "node:path"

const sessionRoot = path.join(process.env.HOME || "", ".local/share/opencode/storage/session")

async function readSessionName(directory) {
  try {
    const projectDirectories = await fs.readdir(sessionRoot)
    let latestSession = null

    for (const projectDirectory of projectDirectories) {
      const projectPath = path.join(sessionRoot, projectDirectory)
      const stats = await fs.stat(projectPath)
      if (!stats.isDirectory()) {
        continue
      }

      const sessionFiles = await fs.readdir(projectPath)
      for (const sessionFile of sessionFiles) {
        if (!sessionFile.endsWith(".json")) {
          continue
        }

        const sessionPath = path.join(projectPath, sessionFile)
        const session = JSON.parse(await fs.readFile(sessionPath, "utf8"))
        if (session.directory !== directory) {
          continue
        }

        if (!latestSession || session.time.updated > latestSession.time.updated) {
          latestSession = session
        }
      }
    }

    if (!latestSession) {
      return null
    }

    const title = latestSession.title
    return title && !title.startsWith("New session -") ? title : null
  } catch {
    return null
  }
}

export const NotificationPlugin = async ({ $, directory }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        const cwd = path.basename(directory)
        const sessionName = await readSessionName(directory)
        const notifyScript = path.join(process.env.HOME || "", "dev/dotfiles/scripts/agent-notifications.sh")
        $`sh ${notifyScript} ${cwd} ${sessionName || "completed"}`.catch(() => {})
      }
    },
  }
}
