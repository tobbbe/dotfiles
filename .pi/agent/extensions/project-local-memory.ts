import fs from "node:fs/promises";
import path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

async function readAgentbrainLink(cwd: string): Promise<string | null> {
	const linkPath = path.join(cwd, ".claude.local.md");

	try {
		const content = await fs.readFile(linkPath, "utf8");
		const trimmed = content.trim();
		return trimmed ? trimmed : null;
	} catch {
		return null;
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) {
			return;
		}

		const scriptPath = path.join(process.env.HOME ?? "", "dev/dotfiles/agents/agent-brain/check-agentbrain-link.sh");
		const result = await pi.exec("sh", [scriptPath, ctx.cwd]).catch(() => null);
		const message = result?.stdout?.trim();

		if (!message) {
			ctx.ui.setStatus("agentbrain-link", undefined);
			return;
		}

		ctx.ui.notify(message, "warning");
		ctx.ui.setStatus("agentbrain-link", "Missing .claude.local.md");
	});

	pi.on("before_agent_start", async (event, ctx) => {
		const content = await readAgentbrainLink(ctx.cwd);
		if (!content) {
			return;
		}

		return {
			systemPrompt: `${event.systemPrompt}\n\n## Project local memory (.claude.local.md)\n\n${content}`,
		};
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		if (!ctx.hasUI) {
			return;
		}

		ctx.ui.setStatus("agentbrain-link", undefined);
	});
}
