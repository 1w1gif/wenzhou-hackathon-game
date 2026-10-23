# -*- coding: utf-8 -*-
"""抠图 v2:处理带复杂背景的 AI 生成素材。
B5(柜台):浅灰白底 → flood fill 即可。
B7(方桌长凳):上半是深色夜空背景(带月亮/山云),下半白底。
   用户只要桌凳主体 → 先 flood fill 清白底,再清除"上部深色区":
   深色区与主体以桌面的木色分界,直接把 y < 主体顶部边界 且 颜色接近夜空(青黑/月亮金/云青)的区域清掉。
   更稳的做法:检测"桌面顶边"——从上往下扫描每行,找到第一行"非背景色占比突增"的行,
   该行以上整块清除(AI 的夜景背景严格位于桌面上方,左右延伸至全宽)。
"""
from PIL import Image, ImageFilter
from collections import deque
import os

def flood_clear_bg(im, tol_bright=42, tol_dark=48):
    """清除与图像边缘连通的背景(亮底与暗底都试,取能清更多的那种)。"""
    w, h = im.size
    px = im.load()

    def clear_with(seed_pred):
        visited = bytearray(w*h)
        q = deque()
        for x in range(w):
            for y in (0, h-1):
                if seed_pred(x, y) and not visited[y*w+x]:
                    visited[y*w+x] = 1; q.append((x, y))
        for y in range(h):
            for x in (0, w-1):
                if seed_pred(x, y) and not visited[y*w+x]:
                    visited[y*w+x] = 1; q.append((x, y))
        while q:
            x, y = q.popleft()
            for dx, dy in ((1,0),(-1,0),(0,1),(0,-1)):
                nx, ny = x+dx, y+dy
                if 0 <= nx < w and 0 <= ny < h and not visited[ny*w+nx] and seed_pred(nx, ny):
                    visited[ny*w+nx] = 1; q.append((nx, ny))
        return visited

    # 亮背景
    def bright(x, y):
        r, g, b = px[x, y][:3]
        return r > 200 and g > 200 and b > 200
    # 暗背景(夜空色:深青黑,低亮度)
    def dark(x, y):
        r, g, b = px[x, y][:3]
        return (r+g+b) < 170

    vb = clear_with(bright)
    vd = clear_with(dark)
    cnt_b = sum(vb)
    cnt_d = sum(vd)
    use = vb if cnt_b >= cnt_d else vd
    out = im.convert("RGBA")
    opx = out.load()
    for i in range(w*h):
        if use[i]:
            opx[i % w, i // w] = (0, 0, 0, 0)
    return out, max(cnt_b, cnt_d) / (w*h)

def clear_dark_sky_region(im):
    """B7 专用:清除桌面上方的整块夜空背景。
    思路:夜空区特征 = 颜色接近(青黑/云青/月亮金/星白)且位于图像上半部。
    先找到主体的最高点(保留区 alpha>0 的最小 y 中"成行"的起点),
    从该点向上,把所有"夜空色"像素清掉(不考虑连通性,因为月亮/星星/云与主背景同色系)。"""
    w, h = im.size
    px = im.load()
    # 主体最高点:跳过顶部零散的星星,找连续 30 行都有不透明像素的起点
    rows = []
    for y in range(h):
        cnt = sum(1 for x in range(0, w, 4) if px[x, y][3] > 0)
        rows.append(cnt)
    main_top = 0
    run = 0
    for y in range(h):
        if rows[y] > (w // 4) * 0.5:  # 该行超过一半都有内容 → 桌面/主体
            # 回溯验证:连续 20 行都密
            if all(rows[yy] > (w // 4) * 0.3 for yy in range(y, min(y+20, h))):
                main_top = y
                break
    if main_top == 0:
        return im  # 没找到,不动
    # 从 main_top 向上,清掉夜空系颜色
    def is_sky(r, g, b):
        # 深青黑 / 云青 / 月亮金 / 星白 都算;但保护可能的主体色(暖木色亮度高且偏红)
        lum = (r+g+b)/3
        if lum < 180 and not (r > g and r > b and lum > 90):  # 深色非暖木
            return True
        if g > 120 and b > 120 and r < g:  # 青色云
            return True
        if r > 190 and g > 160 and b < 140:  # 月亮金
            return True
        return False
    for y in range(main_top):
        for x in range(w):
            if px[x, y][3] == 0:
                continue
            r, g, b = px[x, y][:3]
            if is_sky(r, g, b):
                px[x, y] = (0, 0, 0, 0)
    return im

def soften_and_crop(im, edge_soften=1.0):
    a = im.getchannel("A").filter(ImageFilter.GaussianBlur(edge_soften))
    a = a.point(lambda v: 0 if v < 40 else (255 if v > 210 else int((v-40)*255/170)))
    im.putalpha(a)
    # 清掉孤立小残留(即梦AI水印在右下角):8连通去小块
    from collections import deque as dq
    w, h = im.size
    px = im.load()
    seen = bytearray(w*h)
    comps = []
    for y0 in range(0, h, 2):
        for x0 in range(0, w, 2):
            i0 = y0*w+x0
            if seen[i0] or px[x0, y0][3] == 0:
                continue
            comp = []
            q = dq([(x0, y0)])
            seen[i0] = 1
            while q:
                x, y = q.popleft()
                comp.append((x, y))
                for dx, dy in ((1,0),(-1,0),(0,1),(0,-1),(1,1),(-1,-1),(1,-1),(-1,1)):
                    nx, ny = x+dx, y+dy
                    if 0 <= nx < w and 0 <= ny < h:
                        ii = ny*w+nx
                        if not seen[ii] and px[nx, ny][3] > 0:
                            seen[ii] = 1
                            q.append((nx, ny))
            comps.append(comp)
    total = sum(len(c) for c in comps) or 1
    for comp in comps:
        if len(comp) < total * 0.002:  # 小于主体 0.2% 的孤立块删掉
            for x, y in comp:
                px[x, y] = (0, 0, 0, 0)
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)
    return im

def main():
    d = r"C:\Users\WJH\Desktop\新增素材"
    outd = r"C:\Users\WJH\Desktop\新增素材_抠图"
    os.makedirs(outd, exist_ok=True)
    jobs = {
        "B5. 酒馆柜台(.png": "flood",
        "B7. 方桌长凳.png": "bench",
    }
    for fname, mode in jobs.items():
        src = os.path.join(d, fname)
        im = Image.open(src).convert("RGB")
        im, ratio = flood_clear_bg(im)
        print(f"{fname}: flood cleared {ratio:.1%}")
        if mode == "bench":
            im = clear_dark_sky_region(im)
        im = soften_and_crop(im)
        dst = os.path.join(outd, os.path.splitext(fname)[0] + ".png")
        im.save(dst)
        print(f"  -> {dst} {im.size}")

if __name__ == "__main__":
    main()
