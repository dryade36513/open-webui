"""Helpers for OpenAI-compatible connection API keys (multi-key round-robin)."""

from __future__ import annotations

import threading

_OPENAI_KEY_RR_LOCK = threading.Lock()
_OPENAI_KEY_RR_COUNTERS: dict[int, int] = {}


def collect_openai_connection_bearer_keys(flat_key: str | None, api_config: dict | None) -> list[str]:
    """Normalize bearer/API keys for one connection slot (legacy flat + optional ``api_keys`` list)."""
    cfg = api_config or {}
    extra = cfg.get('api_keys')
    if isinstance(extra, list):
        keys = [str(k).strip() for k in extra if k is not None and str(k).strip()]
        if keys:
            return keys
    fk = (flat_key or '').strip()
    return [fk] if fk else []


def pick_rotating_openai_api_key(request, idx: int) -> str | None:
    """Pick the next API key for this connection index (round-robin when multiple keys are configured)."""
    if idx < 0:
        return None
    urls = request.app.state.config.OPENAI_API_BASE_URLS
    keys_flat = request.app.state.config.OPENAI_API_KEYS
    if idx >= len(urls):
        return None
    flat = keys_flat[idx] if idx < len(keys_flat) else ''
    url = urls[idx]
    api_config = request.app.state.config.OPENAI_API_CONFIGS.get(
        str(idx),
        request.app.state.config.OPENAI_API_CONFIGS.get(url, {}),
    )
    key_list = collect_openai_connection_bearer_keys(flat, api_config)
    if not key_list:
        return None
    if len(key_list) == 1:
        return key_list[0]
    with _OPENAI_KEY_RR_LOCK:
        ctr = _OPENAI_KEY_RR_COUNTERS.get(idx, 0)
        picked = key_list[ctr % len(key_list)]
        _OPENAI_KEY_RR_COUNTERS[idx] = ctr + 1
    return picked
