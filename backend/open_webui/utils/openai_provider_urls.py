"""Provider-aware URL and model-id helpers for OpenAI-compatible upstreams."""

from urllib.parse import urlparse


def resolve_openai_chat_completions_upstream_url(base_url: str) -> str:
    """
    Return the POST URL for chat (streaming or not).

    Free.ai documents ``POST /v1/chat/`` (with trailing slash) instead of
    OpenAI's ``/v1/chat/completions``. Same request/response shape as chat
    completions; only the path differs.
    """
    base = base_url.rstrip('/')
    host = (urlparse(base).hostname or '').lower()
    if host == 'api.free.ai':
        return f'{base}/chat/'
    return f'{base}/chat/completions'


def resolve_openai_provider_model_id(base_url: str, model_id: str, prefix_id: str | None = None) -> str:
    """
    Normalize model IDs before sending upstream.

    - strips configured ``prefix_id.`` decoration (Open WebUI display prefix)
    - applies vendor-specific normalization where needed
    """
    model = (model_id or '').strip()
    if not model:
        return model

    if prefix_id:
        model = model.removeprefix(f'{prefix_id}.')

    host = (urlparse((base_url or '').rstrip('/')).hostname or '').lower()
    if host == 'integrate.api.nvidia.com':
        # NVIDIA model ids are vendor/model (slash), not dotted display ids.
        if model.startswith('nvidia.'):
            model = model.removeprefix('nvidia.')
        if '/' not in model and '.' in model:
            left, right = model.split('.', 1)
            model = f'{left}/{right}'

    return model
