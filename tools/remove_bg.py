# -*- coding: utf-8 -*-
"""批量抠图:白/灰底游戏素材 → 透明背景 PNG。
方法:从四角采样背景色,按颜色距离 + 连通性(flood fill from edges)抠图,
保留主体内部的浅色(如白衣、月白色树冠),边缘做柔和 alpha 渐变。
"""
from PIL import Image, ImageFilter
from collections import deque
import os, sys

def remove_bg(src, dst, tol=42, edge_soften=1.2):
    im = Image.open(src).convert("RGB")
    w, h = im.size
    px = im.load()

    # 背景参考色:四角平均
    cs = [px[2,2], px[w-3,2], px[2,h-3], px[w-3,h-3]]
    br = sum(c[0] for c in cs)//4; bg_ = sum(c[1] for c in cs)//4; bb = sum(c[2] for c in cs)//4

    def is_bg(x, y):
        r, g, b = px[x, y]
        d = ((r-br)**2 + (g-bg_)**2 + (b-bb)**2) ** 0.5
        return d < tol

    # 从边缘 flood fill,只清与边缘连通的背景(保护主体内部浅色)
    visited = bytearray(w*h)
    q = deque()
    for x in range(w):
        for y in (0, h-1):
            if is_bg(x, y) and not visited[y*w+x]:
                visited[y*w+x] = 1; q.append((x, y))
    for y in range(h):
        for x in (0, w-1):
            if is_bg(x, y) and not visited[y*w+x]:
                visited[y*w+x] = 1; q.append((x, y))
    while q:
        x, y = q.popleft()
        for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
            nx, ny = x+dx, y+dy
            if 0 <= nx < w and 0 <= ny < h and not visited[ny*w+nx] and is_bg(nx, ny):
                visited[ny*w+nx] = 1
                q.append((nx, ny))

    out = im.convert("RGBA")
    opx = out.load()
    for y in range(h):
        row = y*w
        for x in range(w):
            if visited[row+x]:
                opx[x, y] = (0, 0, 0, 0)

    # 边缘柔化:对 alpha 轻微高斯模糊,再压回硬边附近,消除白边
    a = out.getchannel("A").filter(ImageFilter.GaussianBlur(edge_soften))
    a = a.point(lambda v: 0 if v < 40 else (255 if v > 210 else int((v-40)*255/170)))
    out.putalpha(a)

    # 裁掉全透明边
    bbox = out.getbbox()
    if bbox:
        out = out.crop(bbox)
    out.save(dst)
    return out.size

def main():
    base = r"C:\黑客松\素材包"
    outbase = r"C:\黑客松\素材包_抠图"
    jobs = []
    for root, _, files in os.walk(base):
        for f in files:
            if not f.lower().endswith((".png", ".jpg", ".jpeg")):
                continue
            src = os.path.join(root, f)
            rel = os.path.relpath(src, base)
            # 跳过 UI 包(本身带透明)与已抠过的
            if "像素 UI 包" in rel or "夜景视差背景" in rel or "__MACOSX" in rel:
                continue
            dst_rel = os.path.splitext(rel)[0] + ".png"
            jobs.append((src, os.path.join(outbase, dst_rel)))

    os.makedirs(outbase, exist_ok=True)
    ok = fail = skip = 0
    for src, dst in jobs:
        im = Image.open(src)
        # 已有透明通道且确实有透明像素的,直接复制
        if im.mode in ("RGBA", "LA"):
            a = im.convert("RGBA").getchannel("A")
            if a.getextrema()[0] < 250:
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                im.convert("RGBA").save(dst)
                skip += 1
                continue
        try:
            im.load()  # 验证可识别,失败走 except
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            size = remove_bg(src, dst)
            ok += 1
            print(f"OK  {os.path.relpath(dst, outbase)} -> {size}")
        except Exception as e:
            fail += 1
            print(f"FAIL {src}: {e}")
    print(f"\ndone: {ok} processed, {skip} copied(alpha already), {fail} failed")
    print(f"output: {outbase}")

if __name__ == "__main__":
    main()
