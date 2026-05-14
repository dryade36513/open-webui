/** Provider-aware chat/model normalization for OpenAI-compatible upstreams. */

export function resolveOpenAIChatCompletionsUrl(baseUrl: string): string {
	const base = baseUrl.replace(/\/+$/, '');
	try {
		const host = new URL(base).hostname.toLowerCase();
		if (host === 'api.free.ai') {
			return `${base}/chat/`;
		}
	} catch {
		// invalid baseUrl — fall through
	}
	return `${base}/chat/completions`;
}

export function resolveOpenAIProviderModelId(
	baseUrl: string,
	modelId: string,
	prefixId?: string | null
): string {
	let model = (modelId ?? '').trim();
	if (!model) return model;

	if (prefixId) {
		model = model.replace(new RegExp(`^${prefixId.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\.`), '');
	}

	try {
		const host = new URL(baseUrl.replace(/\/+$/, '')).hostname.toLowerCase();
		if (host === 'integrate.api.nvidia.com') {
			if (model.startsWith('nvidia.')) {
				model = model.slice('nvidia.'.length);
			}
			if (!model.includes('/') && model.includes('.')) {
				const [left, right] = model.split('.', 2);
				model = `${left}/${right}`;
			}
		}
	} catch {
		// Ignore malformed URL and return best-effort model id.
	}

	return model;
}
