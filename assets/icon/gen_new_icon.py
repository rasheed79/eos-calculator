"""
New app icon concept: Dark Premium Coin
Completely different from current white-UI-screenshot style
"""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import numpy as np
import os

S = 1024  # output size
SS = 2048  # supersampling canvas

def make_icon(size):
    canvas = SS
    scale = canvas // size

    img = Image.new('RGBA', (canvas, canvas), (0, 0, 0, 0))
    arr = np.zeros((canvas, canvas, 4), dtype=np.uint8)

    # -- Background: radial gradient dark navy --
    y, x = np.ogrid[:canvas, :canvas]
    cx, cy = canvas * 0.42, canvas * 0.38
    dist = np.sqrt((x - cx)**2 + (y - cy)**2)
    t = np.clip(dist / (canvas * 0.72), 0, 1)
    # Center: #1A2E4A  →  Edges: #060B14
    arr[:,:,0] = (26  * (1-t) + 6  * t).astype(np.uint8)
    arr[:,:,1] = (46  * (1-t) + 11 * t).astype(np.uint8)
    arr[:,:,2] = (74  * (1-t) + 20 * t).astype(np.uint8)
    arr[:,:,3] = 255

    # Rounded rect mask
    bg_img = Image.fromarray(arr, 'RGBA')
    mask = Image.new('L', (canvas, canvas), 0)
    md = ImageDraw.Draw(mask)
    r = int(canvas * 0.218)
    md.rounded_rectangle([0, 0, canvas, canvas], radius=r, fill=255)
    bg_img.putalpha(mask)

    draw = ImageDraw.Draw(bg_img)

    half = canvas // 2

    # -- Shadow under coin --
    shadow_r = int(canvas * 0.348)
    shadow_cx, shadow_cy = half, half + int(canvas * 0.03)
    for i in range(30, 0, -1):
        alpha = int(120 * (i/30)**2)
        r_s = shadow_r + int(canvas * 0.01 * (31-i)/30)
        draw.ellipse(
            [shadow_cx - r_s, shadow_cy - r_s + int(canvas*0.02),
             shadow_cx + r_s, shadow_cy + r_s + int(canvas*0.02)],
            fill=(0, 0, 0, alpha)
        )

    # -- Gold coin with gradient (vectorized) --
    coin_r = int(canvas * 0.335)
    coin_cx, coin_cy = half, half

    y2, x2 = np.ogrid[:canvas, :canvas]
    dist_coin = np.sqrt((x2 - coin_cx)**2 + (y2 - coin_cy)**2)
    coin_mask = dist_coin <= coin_r

    # Gradient: top-left bright gold → bottom-right dark gold
    t_grad = ((x2 - coin_cx + coin_r) + (y2 - coin_cy + coin_r)) / (4 * coin_r)
    t_grad = np.clip(t_grad, 0, 1)

    gold_r = (252 * (1-t_grad) + 180 * t_grad)
    gold_g = (196 * (1-t_grad) + 120 * t_grad)
    gold_b = (48  * (1-t_grad) + 10  * t_grad)

    coin_arr = np.array(bg_img)
    coin_arr[coin_mask, 0] = gold_r[coin_mask].astype(np.uint8)
    coin_arr[coin_mask, 1] = gold_g[coin_mask].astype(np.uint8)
    coin_arr[coin_mask, 2] = gold_b[coin_mask].astype(np.uint8)
    coin_arr[coin_mask, 3] = 255

    # -- Inner ring (slightly darker) --
    inner_r = int(coin_r * 0.87)
    inner_mask = dist_coin <= inner_r
    border_mask = coin_mask & ~inner_mask
    coin_arr[border_mask, 0] = (coin_arr[border_mask, 0] * 0.72).astype(np.uint8)
    coin_arr[border_mask, 1] = (coin_arr[border_mask, 1] * 0.72).astype(np.uint8)
    coin_arr[border_mask, 2] = (coin_arr[border_mask, 2] * 0.72).astype(np.uint8)

    bg_img = Image.fromarray(coin_arr, 'RGBA')
    draw = ImageDraw.Draw(bg_img)

    # -- Inner face gradient (slightly lighter than coin edge) --
    inner2_r = int(coin_r * 0.84)
    inner2_mask = dist_coin <= inner2_r
    t_inner = ((x2 - coin_cx + inner2_r) + (y2 - coin_cy + inner2_r)) / (4 * inner2_r)
    t_inner = np.clip(t_inner, 0, 1)
    gold_r2 = (255 * (1-t_inner) + 195 * t_inner)
    gold_g2 = (210 * (1-t_inner) + 140 * t_inner)
    gold_b2 = (60  * (1-t_inner) + 18  * t_inner)
    inner_arr = np.array(bg_img)
    inner_arr[inner2_mask, 0] = gold_r2[inner2_mask].astype(np.uint8)
    inner_arr[inner2_mask, 1] = gold_g2[inner2_mask].astype(np.uint8)
    inner_arr[inner2_mask, 2] = gold_b2[inner2_mask].astype(np.uint8)
    bg_img = Image.fromarray(inner_arr, 'RGBA')
    draw = ImageDraw.Draw(bg_img)

    # -- Coin highlight arc (top-left) --
    hl_r = int(inner2_r * 0.96)
    draw.arc(
        [coin_cx - hl_r, coin_cy - hl_r, coin_cx + hl_r, coin_cy + hl_r],
        start=200, end=300,
        fill=(255, 245, 180, 160), width=int(canvas * 0.018)
    )

    # -- Central text: ﷼ (riyal symbol) --
    font_size = int(canvas * 0.33)
    font_paths = [
        'C:/Windows/Fonts/tradbdo.ttf',
        'C:/Windows/Fonts/trado.ttf',
        'C:/Windows/Fonts/arabtype.ttf',
        'C:/Windows/Fonts/aldhabi.ttf',
        'C:/Windows/Fonts/arial.ttf',
    ]
    font = None
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                font = ImageFont.truetype(fp, font_size)
                break
            except:
                continue

    riyal_text = '﷼'
    if font:
        bbox = draw.textbbox((0, 0), riyal_text, font=font)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        tx = coin_cx - tw // 2 - bbox[0]
        ty = coin_cy - th // 2 - bbox[1]
        # Shadow
        draw.text((tx + int(canvas*0.005), ty + int(canvas*0.007)),
                  riyal_text, font=font, fill=(120, 80, 0, 140))
        # Main white text
        draw.text((tx, ty), riyal_text, font=font, fill=(255, 255, 255, 240))

    # -- Small "ر.س" label below if riyal char doesn't render --
    # Try secondary font fallback label
    label_font_size = int(canvas * 0.115)
    label_font = None
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                label_font = ImageFont.truetype(fp, label_font_size)
                break
            except:
                continue

    # -- Decorative dots on coin ring (compass points) --
    dot_r = int(canvas * 0.012)
    for angle_deg in [0, 90, 180, 270]:
        angle = np.radians(angle_deg)
        dot_cx = int(coin_cx + (inner2_r * 0.95) * np.cos(angle))
        dot_cy = int(coin_cy + (inner2_r * 0.95) * np.sin(angle))
        draw.ellipse(
            [dot_cx - dot_r, dot_cy - dot_r, dot_cx + dot_r, dot_cy + dot_r],
            fill=(255, 240, 150, 200)
        )

    # -- Green checkmark badge (bottom-right) --
    badge_r = int(canvas * 0.115)
    badge_cx = coin_cx + int(coin_r * 0.685)
    badge_cy = coin_cy + int(coin_r * 0.685)

    # Badge shadow
    draw.ellipse(
        [badge_cx - badge_r - 4, badge_cy - badge_r + 6,
         badge_cx + badge_r + 4, badge_cy + badge_r + 14],
        fill=(0, 0, 0, 80)
    )
    # Badge
    draw.ellipse(
        [badge_cx - badge_r, badge_cy - badge_r,
         badge_cx + badge_r, badge_cy + badge_r],
        fill=(22, 163, 74)
    )
    # Badge inner
    bi = int(badge_r * 0.82)
    draw.ellipse(
        [badge_cx - bi, badge_cy - bi, badge_cx + bi, badge_cy + bi],
        fill=(34, 197, 94)
    )
    # Checkmark
    ck = int(badge_r * 0.5)
    pts = [
        badge_cx - ck + int(ck*0.1), badge_cy,
        badge_cx - int(ck*0.12), badge_cy + int(ck*0.72),
        badge_cx + ck, badge_cy - int(ck*0.55),
    ]
    draw.line(pts, fill=(255, 255, 255), width=int(canvas * 0.022))

    # -- Subtle background texture lines --
    for i in range(8):
        angle = np.radians(i * 22.5)
        x1 = int(half + canvas * 0.48 * np.cos(angle))
        y1 = int(half + canvas * 0.48 * np.sin(angle))
        x2 = int(half + canvas * 0.52 * np.cos(angle))
        y2 = int(half + canvas * 0.52 * np.sin(angle))
        draw.line([(x1, y1), (x2, y2)], fill=(255, 255, 255, 12), width=int(canvas*0.004))

    # Downscale for anti-aliasing
    final = bg_img.resize((size, size), Image.LANCZOS)
    return final


if __name__ == '__main__':
    base = os.path.dirname(os.path.abspath(__file__))
    project = os.path.join(base, '..', '..')

    # Master 1024
    icon_1024 = make_icon(1024)
    out_1024 = os.path.join(base, 'icon_v2.png')
    icon_1024.save(out_1024, 'PNG')
    print(f'Saved icon_v2.png (1024x1024)')

    # Play Store 512
    icon_512 = make_icon(512)
    ps_rgb = Image.new('RGB', (512, 512), (0, 0, 0))
    ps_rgb.paste(icon_512, mask=icon_512.split()[3])
    ps_path = os.path.join(base, 'play_store_512_v2.png')
    ps_rgb.save(ps_path, 'PNG')
    print(f'Saved play_store_512_v2.png')

    # Export all sizes
    export_dir = os.path.join(base, 'export_v2')
    os.makedirs(export_dir, exist_ok=True)

    sizes = {
        'icon_48x48.png': 48,
        'icon_72x72.png': 72,
        'icon_96x96.png': 96,
        'icon_144x144.png': 144,
        'icon_192x192.png': 192,
        'icon_512x512.png': 512,
        'icon_1024x1024.png': 1024,
    }
    for name, sz in sizes.items():
        img = make_icon(sz)
        img.save(os.path.join(export_dir, name), 'PNG')
        print(f'Saved export_v2/{name}')

    print('\nDone.')
