"""Normalize OpenAI-compatible GET .../models payloads.

Some providers (e.g. Free.ai at https://free.ai/api/) return a top-level
``models`` array instead of OpenAI's ``data`` list. Downstream code expects
``data``; this module maps those shapes without dropping extra metadata.
"""


def normalize_openai_compatible_models_payload(payload):
    """
    Return a dict with a ``data`` list of model objects when possible.

    - ``{"data": [...]}`` — ensure ``object`` defaults to ``"list"``.
    - ``{"models": [...]}`` — copy to ``data`` (Free.ai and similar).
    - bare ``list`` — wrap as ``{"object": "list", "data": payload}``.
    """
    if payload is None:
        return None
    if isinstance(payload, list):
        return {'object': 'list', 'data': payload}
    if not isinstance(payload, dict):
        return payload

    data = payload.get('data')
    if isinstance(data, list):
        out = dict(payload)
        out.setdefault('object', 'list')
        return out

    models = payload.get('models')
    if isinstance(models, list):
        out = dict(payload)
        out['object'] = payload.get('object', 'list')
        out['data'] = models
        return out

    return payload
