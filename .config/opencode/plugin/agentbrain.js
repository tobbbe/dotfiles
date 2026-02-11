// Injects agentbrain project knowledge at session start.

export const AgentbrainPlugin = async ({ client, $, directory }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.created") {
        const home = process.env.HOME
        const project = directory.split("/").pop()

        let content
        try {
          content = await $`cat ${home}/dev/agentbrain/projects/${project}.md`.text()
          if (!content.trim()) return
        } catch {
          return
        }

        let topics = ""
        try {
          topics = "\n# Available Agentbrain topics\n" + await $`ls ${home}/dev/agentbrain/topics`.text()
        } catch {}

        // 🚨 Keep in sync with: .claude/hooks/load-agentbrain.sh
        const text = `# Agentbrain for current cwd\n\n${content}${topics}`

        await client.session.prompt({
          path: { id: event.properties.info.id },
          body: {
            noReply: true,
            parts: [{ type: "text", text }],
          },
        })
      }
    },
  }
}
