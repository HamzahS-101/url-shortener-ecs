"""
Redis cache for short code lookups.

Set REDIS_URL to enable. Without it, or if Redis is unreachable, lookups go to the database.
"""

import os
import logging

logger = logging.getLogger(__name__)

CACHE_TTL_SECONDS = 86400

_redis_client = None


def _get_redis():
    global _redis_client
    if _redis_client is not None:
        return _redis_client

    redis_url = os.environ.get("REDIS_URL")
    if not redis_url:
        return None

    import redis
    _redis_client = redis.Redis.from_url(
        redis_url,
        decode_responses=True,
        socket_connect_timeout=0.5,
        socket_timeout=0.5,
    )
    return _redis_client


def get_cached_url(short_id: str):
    client = _get_redis()
    if not client:
        return None
    try:
        return client.get(f"url:{short_id}")
    except Exception as e:
        logger.warning(f"Redis get failed, using database: {e}")
        return None


def cache_url(short_id: str, url: str):
    client = _get_redis()
    if not client:
        return
    try:
        client.set(f"url:{short_id}", url, ex=CACHE_TTL_SECONDS)
    except Exception as e:
        logger.warning(f"Redis set failed: {e}")
