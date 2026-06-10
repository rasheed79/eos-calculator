"""
Export V4 icon to all required sizes for Google Play Console + Android mipmap.
"""
from PIL import Image
import os, shutil

base = os.path.dirname(os.path.abspath(__file__))
project = os.path.join(base, '..', '..')

src = os.path.join(base, 'icon_v4_preview.png')
img = Image.open(src).convert('RGBA')
print(f'Source: {img.size}')

# -- Export all sizes --
export_dir = os.path.join(base, 'export_v4')
os.makedirs(export_dir, exist_ok=True)

sizes = {
    'icon_48x48.png':     48,
    'icon_72x72.png':     72,
    'icon_96x96.png':     96,
    'icon_144x144.png':  144,
    'icon_192x192.png':  192,
    'icon_512x512.png':  512,
    'icon_1024x1024.png': 1024,
}

for name, sz in sizes.items():
    out = img.resize((sz, sz), Image.LANCZOS)
    out.save(os.path.join(export_dir, name), 'PNG')
    print(f'  Saved export_v4/{name}')

# -- Play Store 512x512 (RGB, no alpha) --
ps = img.resize((512, 512), Image.LANCZOS)
ps_rgb = Image.new('RGB', (512, 512), (0, 0, 0))
ps_rgb.paste(ps, mask=ps.split()[3])
ps_path = os.path.join(base, 'play_store_512_v4.png')
ps_rgb.save(ps_path, 'PNG')
print(f'  Saved play_store_512_v4.png')

# -- Apply to Android mipmap directories --
mipmap = {
    'mipmap-mdpi':    48,
    'mipmap-hdpi':    72,
    'mipmap-xhdpi':   96,
    'mipmap-xxhdpi':  144,
    'mipmap-xxxhdpi': 192,
}

res_dir = os.path.join(project, 'android', 'app', 'src', 'main', 'res')
applied = 0
for folder, sz in mipmap.items():
    target_dir = os.path.join(res_dir, folder)
    if os.path.isdir(target_dir):
        out = img.resize((sz, sz), Image.LANCZOS)
        # ic_launcher — RGBA is fine for adaptive icon foreground
        out_rgb = Image.new('RGB', (sz, sz), (7, 14, 27))
        out_rgb.paste(out, mask=out.split()[3])
        dst = os.path.join(target_dir, 'ic_launcher.png')
        out_rgb.save(dst, 'PNG')
        print(f'  Applied {sz}x{sz} → {folder}/ic_launcher.png')
        applied += 1
    else:
        print(f'  SKIP: {target_dir} not found')

# Also update web/favicon and web icons
web_dir = os.path.join(project, 'web')
if os.path.isdir(web_dir):
    fav = img.resize((32, 32), Image.LANCZOS)
    fav_rgb = Image.new('RGB', (32, 32), (7, 14, 27))
    fav_rgb.paste(fav, mask=fav.split()[3])
    fav_rgb.save(os.path.join(web_dir, 'favicon.png'), 'PNG')
    print(f'  Updated web/favicon.png')

    for wname, wsz in [('Icon-192.png', 192), ('Icon-512.png', 512),
                       ('Icon-maskable-192.png', 192), ('Icon-maskable-512.png', 512)]:
        wpath = os.path.join(web_dir, 'icons', wname)
        if os.path.exists(wpath):
            wi = img.resize((wsz, wsz), Image.LANCZOS)
            wi_rgb = Image.new('RGB', (wsz, wsz), (7, 14, 27))
            wi_rgb.paste(wi, mask=wi.split()[3])
            wi_rgb.save(wpath, 'PNG')
            print(f'  Updated web/icons/{wname}')

print(f'\nDone. {applied} mipmap directories updated.')
print(f'Upload play_store_512_v4.png to Google Play Console → Store listing → App icon')
