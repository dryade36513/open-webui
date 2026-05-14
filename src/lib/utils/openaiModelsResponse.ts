/** Normalize GET /models JSON (OpenAI `data` vs Free.ai-style `models`). */

export function normalizeOpenAIModelsListPayload(input: unknown): {
	object?: string;
	data: unknown[];
} & Record<string, unknown> {
	if (input === null || input === undefined) {
		return { object: 'list', data: [] };
	}
	if (Array.isArray(input)) {
		return { object: 'list', data: input };
	}
	if (typeof input !== 'object') {
		return { object: 'list', data: [] };
	}
	const o = input as Record<string, unknown>;
	if (Array.isArray(o.data)) {
		return { ...o, object: typeof o.object === 'string' ? o.object : 'list', data: o.data };
	}
	if (Array.isArray(o.models)) {
		return { ...o, object: 'list', data: o.models };
	}
	return { ...o, object: 'list', data: [] };
}

export function extractModelIdsFromModelsPayload(input: unknown): string[] {
	const norm = normalizeOpenAIModelsListPayload(input);
	const rows = norm.data;
	const ids: string[] = [];
	for (const row of rows) {
		if (row && typeof row === 'object' && 'id' in row) {
			const id = (row as { id: unknown }).id;
			if (typeof id === 'string' && id.trim()) {
				ids.push(id.trim());
			}
		}
	}
	return ids;
}
