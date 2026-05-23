import math
import os
import struct
import sys
import zlib

import numpy as np
from PIL import Image


MI_INT8 = 1
MI_UINT8 = 2
MI_INT16 = 3
MI_UINT16 = 4
MI_INT32 = 5
MI_UINT32 = 6
MI_SINGLE = 7
MI_DOUBLE = 9
MI_INT64 = 12
MI_UINT64 = 13
MI_MATRIX = 14
MI_COMPRESSED = 15

DTYPES = {
    MI_INT8: ("i1", 1),
    MI_UINT8: ("u1", 1),
    MI_INT16: ("<i2", 2),
    MI_UINT16: ("<u2", 2),
    MI_INT32: ("<i4", 4),
    MI_UINT32: ("<u4", 4),
    MI_SINGLE: ("<f4", 4),
    MI_DOUBLE: ("<f8", 8),
    MI_INT64: ("<i8", 8),
    MI_UINT64: ("<u8", 8),
}


def pad8(n):
    return (8 - (n % 8)) % 8


def read_tag(buf, offset):
    raw = struct.unpack_from("<I", buf, offset)[0]
    small_type = raw & 0xFFFF
    small_size = raw >> 16
    if small_size:
        data_offset = offset + 4
        next_offset = offset + 8
        return small_type, small_size, data_offset, next_offset
    dtype, size = struct.unpack_from("<II", buf, offset)
    data_offset = offset + 8
    next_offset = data_offset + size + pad8(size)
    return dtype, size, data_offset, next_offset


def parse_numeric(buf, dtype, size, data_offset, shape=None):
    if dtype not in DTYPES:
        return None
    np_dtype, item_size = DTYPES[dtype]
    count = size // item_size
    arr = np.frombuffer(buf, dtype=np.dtype(np_dtype), count=count, offset=data_offset).copy()
    if shape is not None and arr.size == int(np.prod(shape)):
        arr = arr.reshape(tuple(shape), order="F")
    return arr


def parse_matrix(buf):
    offset = 0

    dtype, size, data_offset, next_offset = read_tag(buf, offset)
    offset = next_offset

    dtype, size, data_offset, next_offset = read_tag(buf, offset)
    dims = parse_numeric(buf, dtype, size, data_offset).astype(int)
    offset = next_offset

    dtype, size, data_offset, next_offset = read_tag(buf, offset)
    name_bytes = buf[data_offset:data_offset + size]
    name = name_bytes.decode("utf-8", errors="ignore")
    offset = next_offset

    dtype, size, data_offset, next_offset = read_tag(buf, offset)
    data = parse_numeric(buf, dtype, size, data_offset, dims)
    return name, data


def load_mat_v5_numeric(path):
    with open(path, "rb") as f:
        data = f.read()
    endian = data[126:128]
    if endian != b"IM":
        raise ValueError("Only little-endian MATLAB v5 files are supported")

    out = {}
    offset = 128
    while offset + 8 <= len(data):
        dtype, size, data_offset, next_offset = read_tag(data, offset)
        payload = data[data_offset:data_offset + size]
        if dtype == MI_COMPRESSED:
            inflated = zlib.decompress(payload)
            inner_type, inner_size, inner_data_offset, _ = read_tag(inflated, 0)
            if inner_type == MI_MATRIX:
                name, arr = parse_matrix(inflated[inner_data_offset:inner_data_offset + inner_size])
                if arr is not None:
                    out[name] = np.squeeze(arr)
        elif dtype == MI_MATRIX:
            name, arr = parse_matrix(payload)
            if arr is not None:
                out[name] = np.squeeze(arr)
        offset = next_offset
    return out


def moving_average(y, window):
    window = max(1, min(int(window), len(y)))
    if window <= 1:
        return y.copy()
    half = window // 2
    out = np.empty_like(y, dtype=float)
    for idx in range(len(y)):
        start = max(0, idx - half)
        stop = min(len(y), idx + half + 1)
        out[idx] = np.mean(y[start:stop])
    return out


def lorentzian_dip(p, x):
    baseline, height, center, gamma = p
    return baseline - height / (1.0 + ((x - center) / gamma) ** 2)


def sse(p, x, y):
    return float(np.sum((lorentzian_dip(p, x) - y) ** 2))


def fit_lorentzian_grid_refine(x, y):
    order = np.argsort(x)
    x = x[order].astype(float)
    y = y[order].astype(float)

    ys = moving_average(y, 5)
    n = len(y)
    dx = float(np.median(np.abs(np.diff(x))))
    scan_width = float(np.max(x) - np.min(x))

    sorted_y = np.sort(ys)
    baseline_pool = sorted_y[max(0, int(round(0.25 * n))):max(1, int(round(0.90 * n)))]
    baseline0 = float(np.median(baseline_pool))
    noise = 1.4826 * float(np.median(np.abs(baseline_pool - np.median(baseline_pool))))
    noise = max(noise, np.finfo(float).eps)

    edge_skip = min(max(3, window_safe_edge(5)), max(0, n // 4))
    search_start = edge_skip
    search_stop = n - edge_skip
    if search_stop <= search_start:
        search_start = 0
        search_stop = n
    dip_idx = search_start + int(np.argmin(ys[search_start:search_stop]))
    fit_half_width = max(6 * dx, min(scan_width / 5.0, 9 * dx))
    mask = np.abs(x - x[dip_idx]) <= fit_half_width
    if int(np.sum(mask)) < 7:
        mask[:] = False
        mask[max(0, dip_idx - 3):min(n, dip_idx + 4)] = True

    xf = x[mask]
    yf = y[mask]
    height0 = max(baseline0 - float(ys[dip_idx]), np.finfo(float).eps)

    center_grid = np.linspace(max(np.min(xf), x[dip_idx] - 3 * dx),
                              min(np.max(xf), x[dip_idx] + 3 * dx), 31)
    gamma_grid = np.linspace(max(dx / 2.0, scan_width / 500.0), fit_half_width, 35)

    best = None
    for center in center_grid:
        for gamma in gamma_grid:
            profile = 1.0 / (1.0 + ((xf - center) / gamma) ** 2)
            A = np.column_stack([np.ones_like(profile), -profile])
            baseline, height = np.linalg.lstsq(A, yf, rcond=None)[0]
            if height < 0:
                continue
            pred = baseline - height * profile
            err = float(np.sum((pred - yf) ** 2))
            if best is None or err < best[0]:
                best = [err, baseline, height, center, gamma]

    err, baseline, height, center, gamma = best

    steps = np.array([noise, max(height, noise) / 5.0, dx, dx], dtype=float)
    p = np.array([baseline, height, center, gamma], dtype=float)
    lower = np.array([np.min(yf), 0.0, np.min(xf), dx / 2.0])
    upper = np.array([np.max(yf) + 2 * height0, max(3 * height0, 3 * np.ptp(yf)), np.max(xf), fit_half_width])

    for _ in range(80):
        improved = False
        current = sse(p, xf, yf)
        for j in range(4):
            for sign in (-1.0, 1.0):
                trial = p.copy()
                trial[j] += sign * steps[j]
                trial = np.minimum(np.maximum(trial, lower), upper)
                trial_err = sse(trial, xf, yf)
                if trial_err < current:
                    p = trial
                    current = trial_err
                    improved = True
        if not improved:
            steps *= 0.55
            if np.all(steps < np.array([noise, noise, dx, dx]) * 1e-4):
                break

    yfit_local = lorentzian_dip(p, xf)
    yfit = lorentzian_dip(p, x)
    ss_res = float(np.sum((yf - yfit_local) ** 2))
    ss_tot = float(np.sum((yf - np.mean(yf)) ** 2))
    fit_r2 = 1.0 - ss_res / ss_tot if ss_tot > 0 else float("nan")

    baseline, height, center, gamma = map(float, p)
    linewidth = 2.0 * abs(gamma)
    contrast = height / max(abs(baseline), np.finfo(float).eps)
    snr = height / noise
    score = snr / max(linewidth, np.finfo(float).eps) * max(fit_r2, 0.0)

    return {
        "x": x,
        "y": y,
        "fit_mask": mask,
        "fit_y": yfit,
        "baseline": baseline,
        "height": height,
        "center": center,
        "gamma": abs(gamma),
        "linewidth": linewidth,
        "contrast": contrast,
        "noise": noise,
        "snr": snr,
        "fit_r2": fit_r2,
        "score": score,
        "dip_min_x": float(x[dip_idx]),
        "dip_min_y_smooth": float(ys[dip_idx]),
    }


def window_safe_edge(window):
    return max(1, int(math.ceil(window / 2.0)))


def main():
    if len(sys.argv) > 1:
        mat_path = sys.argv[1]
    else:
        mat_path = os.path.join("data", "magnet_odmr_optimization", "magnet_odmr_0004_X12.5000_Y10.5000_Zfixed.mat")

    vars_ = load_mat_v5_numeric(mat_path)
    print("Loaded variables:", ", ".join(sorted(vars_.keys())))
    if "x" in vars_ and "y" in vars_:
        x = np.asarray(vars_["x"])
        y = np.asarray(vars_["y"])
        source = "mat numeric x/y"
    else:
        png_path = os.path.splitext(mat_path)[0] + ".png"
        print("No numeric x/y found in .mat; digitizing paired PNG:", png_path)
        x, y = digitize_odmr_png(png_path)
        source = "digitized png"

    result = fit_lorentzian_grid_refine(x, y)
    print("\nLorentzian dip fit for", mat_path)
    print("data source       :", source)
    print("local dip seed   : %.9g Hz, y=%.6g" % (result["dip_min_x"], result["dip_min_y_smooth"]))
    print("center           : %.9g Hz (%.6f GHz)" % (result["center"], result["center"] / 1e9))
    print("FWHM linewidth   : %.9g Hz (%.6f MHz)" % (result["linewidth"], result["linewidth"] / 1e6))
    print("height/depth     : %.9g" % result["height"])
    print("baseline         : %.9g" % result["baseline"])
    print("contrast         : %.6g" % result["contrast"])
    print("noise MAD        : %.9g" % result["noise"])
    print("SNR              : %.6g" % result["snr"])
    print("local fit R2     : %.6g" % result["fit_r2"])
    print("score            : %.9g" % result["score"])
    print("fit points       : %d / %d" % (int(np.sum(result["fit_mask"])), len(result["x"])))


def digitize_odmr_png(png_path):
    img = Image.open(png_path).convert("RGB")
    arr = np.asarray(img)
    h, w, _ = arr.shape

    dark = np.all(arr < 80, axis=2)
    row_counts = dark.sum(axis=1)
    col_counts = dark.sum(axis=0)
    rows = np.where(row_counts > 0.25 * w)[0]
    cols = np.where(col_counts > 0.25 * h)[0]
    if rows.size < 2 or cols.size < 2:
        raise RuntimeError("Could not detect axes box in PNG")
    y_top, y_bottom = int(rows[0]), int(rows[-1])
    x_left, x_right = int(cols[0]), int(cols[-1])

    crop = arr[y_top:y_bottom + 1, x_left:x_right + 1, :]
    r = crop[:, :, 0].astype(int)
    g = crop[:, :, 1].astype(int)
    b = crop[:, :, 2].astype(int)
    blue = (b > 120) & (g > 70) & (r < 80) & ((b - r) > 60)

    xs_pix = []
    ys_pix = []
    for cx in range(blue.shape[1]):
        yy = np.where(blue[:, cx])[0]
        if yy.size:
            xs_pix.append(cx)
            ys_pix.append(float(np.median(yy)))
    if len(xs_pix) < 10:
        raise RuntimeError("Could not digitize enough blue ODMR pixels")

    xs_pix = np.asarray(xs_pix, dtype=float)
    ys_pix = np.asarray(ys_pix, dtype=float)

    # The generated MATLAB plot for this run uses these visible axis limits.
    x_min, x_max = 1.7e9, 1.8e9
    y_min, y_max = 0.60, 1.05
    x = x_min + xs_pix / max(1.0, (x_right - x_left)) * (x_max - x_min)
    y = y_max - ys_pix / max(1.0, (y_bottom - y_top)) * (y_max - y_min)

    # Collapse columns into a moderate number of points to reduce marker/line thickness bias.
    bins = np.linspace(x_min, x_max, 80)
    xb = []
    yb = []
    for i in range(len(bins) - 1):
        mask = (x >= bins[i]) & (x < bins[i + 1])
        if np.any(mask):
            xb.append(float(np.mean(x[mask])))
            yb.append(float(np.median(y[mask])))
    return np.asarray(xb), np.asarray(yb)


if __name__ == "__main__":
    main()
