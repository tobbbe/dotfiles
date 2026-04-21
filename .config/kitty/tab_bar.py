from kitty.fast_data_types import wcswidth
from kitty.tab_bar import as_rgb, draw_title


LEFT_ROUND = ""
RIGHT_ROUND = ""
ELLIPSIS = "…"

SESSION_BG = as_rgb(0x15280F)
SESSION_FG = as_rgb(0x7BD65A)


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


def _draw_session_segment(draw_data, screen, tab):
    session_name = tab.session_name or tab.active_session_name
    if not session_name:
        return 0

    original_bold = screen.cursor.bold
    original_italic = screen.cursor.italic

    screen.cursor.bg = _default_bg(draw_data)
    screen.cursor.fg = SESSION_BG
    screen.draw(LEFT_ROUND)

    screen.cursor.bg = SESSION_BG
    screen.cursor.fg = SESSION_FG
    screen.cursor.bold = True
    screen.cursor.italic = False
    screen.draw(f" {session_name} ")

    screen.cursor.bold = original_bold
    screen.cursor.italic = original_italic
    return wcswidth(session_name) + 3


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
    session_width = 0
    if index == 1:
        session_width = _draw_session_segment(draw_data, screen, tab)

    if index == 1:
        prev_bg = SESSION_BG if session_width else _default_bg(draw_data)
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

    fixed_width = session_width + 1 + 2 + (1 if is_last else 0)
    title_width = max_tab_length - fixed_width
    _draw_clipped_title(draw_data, screen, tab, index, title_width)

    screen.draw(" ")
    if is_last:
        screen.cursor.fg = tab_bg
        screen.cursor.bg = _default_bg(draw_data)
        screen.draw(RIGHT_ROUND)

    return screen.cursor.x
