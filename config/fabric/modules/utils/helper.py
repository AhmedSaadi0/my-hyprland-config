def truncate_string(s: str | None, max_length: int) -> str:
    """
    Truncate a string to a specified maximum length, adding '...' if truncated.

    :param s: The string to truncate. If None, returns an empty string.
    :param max_length: The maximum allowed length for the string.
    :return: The truncated string with '...' appended if necessary.
    """
    if s is None:
        return ""

    if len(s) <= max_length:
        return s
    else:
        return s[:max_length] + "..."
