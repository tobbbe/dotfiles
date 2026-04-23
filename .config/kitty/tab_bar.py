from kitty.fast_data_types import get_boss, wcswidth
from kitty.tab_bar import as_rgb, draw_title


LEFT_ROUND = ""
RIGHT_ROUND = ""
ELLIPSIS = "…"
INDICATOR_FG = as_rgb(0x7F7F7F)

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


def _display_tab(tab, extra_data):
    title = tab.session_name if _is_first_tab_in_session(tab, extra_data) else tab.title
    return tab._replace(title=title)


def _tab_width(tab, prev_tab, is_last):
    title = tab.session_name if (tab.session_name and (prev_tab is None or prev_tab.session_name != tab.session_name)) else tab.title
    return 1 + 1 + wcswidth(title) + 1 + (1 if is_last else 0)


def _bar_layout(screen, tabs):
    total_tabs_width = 0
    prev_tab = None
    for idx, current_tab in enumerate(tabs):
        total_tabs_width += _tab_width(current_tab, prev_tab, idx == len(tabs) - 1)
        prev_tab = current_tab

    indicator = ""
    for current_tab in tabs:
        indicator = _active_window_indicator(current_tab)
        if indicator:
            break

    indicator_width = wcswidth(indicator)
    left_pad = max(0, (screen.columns - total_tabs_width) // 2)
    right_gap = max(0, screen.columns - left_pad - total_tabs_width - indicator_width)
    return left_pad, right_gap, indicator


def _draw_left_boundary(draw_data, screen, tab, prev_bg, overlay):
    tab_bg = _tab_bg(draw_data, tab)
    if overlay:
        screen.cursor.bg = prev_bg
        screen.cursor.fg = tab_bg
        screen.draw(LEFT_ROUND)
    else:
        screen.cursor.bg = tab_bg
        screen.cursor.fg = prev_bg
        screen.draw(RIGHT_ROUND)


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
    if extra_data.for_layout:
        if index == 1:
            VISIBLE_TABS[tab.os_window_id] = []
        VISIBLE_TABS[tab.os_window_id].append(tab)

    visible_tabs = VISIBLE_TABS.get(tab.os_window_id, [tab])
    left_pad, right_gap, indicator = _bar_layout(screen, visible_tabs)

    display_tab = _display_tab(tab, extra_data)

    if index == 1 and left_pad > 0:
        screen.cursor.bg = _default_bg(draw_data)
        screen.draw(" " * left_pad)

    if extra_data.prev_tab is None:
        prev_bg = _default_bg(draw_data)
        overlay = True
    elif tab.is_active:
        prev_bg = _tab_bg(draw_data, extra_data.prev_tab)
        overlay = True
    else:
        prev_bg = _tab_bg(draw_data, extra_data.prev_tab)
        overlay = False

    _draw_left_boundary(draw_data, screen, tab, prev_bg, overlay)

    tab_bg = _tab_bg(draw_data, tab)
    tab_fg = _tab_fg(draw_data, tab)
    screen.cursor.bg = tab_bg
    screen.cursor.fg = tab_fg
    screen.draw(" ")

    fixed_width = 1 + 2 + (1 if is_last else 0)
    title_width = max_tab_length - fixed_width
    _draw_clipped_title(draw_data, screen, display_tab, index, title_width)

    screen.draw(" ")
    if is_last:
        screen.cursor.fg = tab_bg
        screen.cursor.bg = _default_bg(draw_data)
        screen.draw(RIGHT_ROUND)
        if right_gap > 0:
            screen.cursor.bg = _default_bg(draw_data)
            screen.draw(" " * right_gap)
        if indicator:
            screen.cursor.bg = _default_bg(draw_data)
            screen.cursor.fg = INDICATOR_FG
            screen.draw(indicator)

    return screen.cursor.x
