from kitty.fast_data_types import get_boss, wcswidth
from kitty.tab_bar import as_rgb, draw_title

# Minimal flat tab bar to mirror the tmux status line:
#   - session name on the far left, in green
#   - inactive windows as plain text, separated by a single space
#   - active window drawn as a "reverse" box (colors come from active_tab_* in kitty.conf)
#   - the N/M split indicator kept, right-aligned
#
# The old rounded/centered renderer is preserved in tab_bar.rounded.py.bak.

ELLIPSIS = "…"
INDICATOR_FG = as_rgb(0x7F7F7F)
SESSION_FG = as_rgb(0xA6E3A1)  # green session label; tweak to taste

VISIBLE_TABS = {}


def _default_bg(draw_data):
    return as_rgb(int(draw_data.default_bg))


def _tab_bg(draw_data, tab):
    return as_rgb(draw_data.tab_bg(tab))


def _tab_fg(draw_data, tab):
    return as_rgb(draw_data.tab_fg(tab))


def _draw_clipped_title(draw_data, screen, tab, index, available_width):
    available_width = max(1, available_width)
    if available_width == 1:
        screen.draw(ELLIPSIS)
        return

    before = screen.cursor.x
    draw_title(draw_data, screen, tab, index, available_width)
    extra = screen.cursor.x - before - available_width
    if extra > 0:
        if extra + 1 < screen.cursor.x:
            screen.cursor.x -= extra + 1
        else:
            screen.cursor.x = before
        screen.draw(ELLIPSIS)


def _active_window_indicator(tab):
    boss = get_boss()
    live_tab = boss.tab_for_id(tab.tab_id)
    if live_tab and tab.is_active and live_tab.num_window_groups > 1:
        return f"{live_tab.windows.active_group_idx + 1}/{live_tab.num_window_groups}"
    return ""


def _is_first_tab_in_session(tab, extra_data):
    return bool(tab.session_name) and (
        extra_data.prev_tab is None or extra_data.prev_tab.session_name != tab.session_name
    )


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    if extra_data.for_layout:
        if index == 1:
            VISIBLE_TABS[tab.os_window_id] = []
        VISIBLE_TABS[tab.os_window_id].append(tab)

    default_bg = _default_bg(draw_data)

    # With a single tab, show only the session name and hide the lone window tab.
    # (tab_bar_min_tabs would hide the whole bar, session name included — we don't
    # want that.) index == 1 and is_last means there is exactly one tab on the bar.
    show_session = _is_first_tab_in_session(tab, extra_data)
    hide_tab = (index == 1 and is_last) and show_session

    # single-space separator before every tab except the very first on the bar
    if extra_data.prev_tab is not None:
        screen.cursor.bg = default_bg
        screen.cursor.fg = _tab_fg(draw_data, tab)
        screen.draw(" ")

    # green session label at the start of each session group (like tmux status-left)
    if show_session:
        screen.cursor.bg = default_bg
        screen.cursor.fg = SESSION_FG
        screen.draw(tab.session_name)
        if not hide_tab:
            screen.draw(" ")

    if not hide_tab:
        if tab.is_active:
            # reverse box: " title " padded; colors come from active_tab_* in kitty.conf
            tab_bg = _tab_bg(draw_data, tab)
            tab_fg = _tab_fg(draw_data, tab)
            screen.cursor.bg = tab_bg
            screen.cursor.fg = tab_fg
            screen.draw(" ")
            _draw_clipped_title(draw_data, screen, tab, index, max(1, max_tab_length - 2))
            screen.draw(" ")
        else:
            # plain inactive window name
            screen.cursor.bg = default_bg
            screen.cursor.fg = _tab_fg(draw_data, tab)
            _draw_clipped_title(draw_data, screen, tab, index, max_tab_length)

    # right-aligned N/M split indicator after the last tab
    if is_last:
        visible_tabs = VISIBLE_TABS.get(tab.os_window_id, [tab])
        indicator = ""
        for current_tab in visible_tabs:
            indicator = _active_window_indicator(current_tab)
            if indicator:
                break
        if indicator:
            pad = screen.columns - screen.cursor.x - wcswidth(indicator)
            screen.cursor.bg = default_bg
            if pad > 0:
                screen.cursor.fg = _tab_fg(draw_data, tab)
                screen.draw(" " * pad)
            screen.cursor.fg = INDICATOR_FG
            screen.draw(indicator)

    return screen.cursor.x
