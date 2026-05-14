/**
 * OpenAI-compatible connection slots may store multiple bearer API keys in
 * `config.api_keys` (with `OPENAI_API_KEYS[i]` holding the primary key for
 * backward compatibility). These helpers normalize that shape and pick the
 * next key for client-side direct-connection round-robin.
 */

export function collectOpenAIConnectionBearerKeys(
	flatKey: string | undefined | null,
	apiConfig: { api_keys?: unknown } | undefined | null
): string[] {
	const raw = apiConfig?.api_keys;
	if (Array.isArray(raw)) {
		const keys = raw.map((k) => String(k).trim()).filter(Boolean);
		if (keys.length) return keys;
	}
	const fk = (flatKey ?? '').trim();
	return fk ? [fk] : [];
}

const directKeyRoundRobin: Record<number, number> = {};

/** Next API key for this direct-connection slot (browser-side). */
export function pickRotatingDirectConnectionApiKey(
	urlIdx: number,
	flatKey: string | undefined | null,
	apiConfig: { api_keys?: unknown; auth_type?: string } | undefined | null
): string {
	const keys = collectOpenAIConnectionBearerKeys(flatKey, apiConfig);
	if (!keys.length) return '';
	if (keys.length === 1) return keys[0];
	const c = directKeyRoundRobin[urlIdx] ?? 0;
	const picked = keys[c % keys.length];
	directKeyRoundRobin[urlIdx] = c + 1;
	return picked;
}
