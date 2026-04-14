import path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async (event, ctx) => {
		if (!ctx.hasUI) {
			return;
		}

		const assistantMessages = event.messages.filter((message) => message.role === "assistant");
		const lastAssistantMessage = assistantMessages[assistantMessages.length - 1];
		if (!lastAssistantMessage || lastAssistantMessage.stopReason !== "stop") {
			return;
		}

		const notifyScript = path.join(process.env.HOME ?? "", "dev/dotfiles/scripts/agent-notifications.sh");
		const title = path.basename(ctx.cwd) || "pi";
		const message = pi.getSessionName()?.trim() || "completed";

		await pi.exec("sh", [notifyScript, title, message]).catch(() => {});
	});
}
