"""A12-1 TLSR8208 ADC linearity analysis (stdlib only).

usage: python a12_analyze.py sweep_buf1_xxx.csv [sweep_buf0_xxx.csv ...]
           [--fit-min MV] [--fit-max MV] [--vref MV] [--nocal-vref 1175]

True voltage of each point:
  rows with a meter reading (dmm_mv) give a straight-line fit dmm = a*dac_code + b,
  separately for buffer on / off; without meter readings the ideal
  dac_code * vref / 4095 is used (gain/offset of the DAC then go into the result).
Linearity: least-squares line adc_code_mean = k*V + c over the fit range;
  residual / k = INL in mV.
Outputs <first csv>_result.txt, <first csv>_points.csv, <first csv>_inl.svg.
"""
import argparse
import csv
import math
import os


def linfit(xs, ys):
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    sxx = sum((x - mx) ** 2 for x in xs)
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    k = sxy / sxx
    return k, my - k * mx


def load(path):
    vref = None
    rows = []
    with open(path, newline='') as f:
        lines = [ln for ln in f]
    for ln in lines:
        if ln.startswith('#') and 'vref_mv=' in ln:
            vref = int(ln.split('vref_mv=')[1].split()[0])
    for r in csv.DictReader(ln for ln in lines if not ln.startswith('#')):
        rows.append({
            'target_mv': int(r['target_mv']),
            'dac_code': int(r['dac_code']),
            'buffer': int(r['buffer']),
            'code': float(r['adc_code_mean']),
            'std': float(r['adc_code_std']),
            'mv': float(r['adc_mv_mean']),
            'dmm': float(r['dmm_mv']) if r['dmm_mv'].strip() else None,
            'vref': vref,
        })
    return rows


def svg_plot(path, pts, title):
    w, h, ml, mr, mt, mb = 900, 420, 70, 20, 40, 50
    xs = [p['v'] for p in pts]
    ys = [p['inl_mv'] for p in pts]
    x0, x1 = min(xs), max(xs)
    ylim = max(5.0, max(abs(y) for y in ys) * 1.1)
    sx = lambda x: ml + (x - x0) / (x1 - x0) * (w - ml - mr)
    sy = lambda y: mt + (ylim - y) / (2 * ylim) * (h - mt - mb)
    out = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" font-family="sans-serif" font-size="12">' % (w, h),
           '<rect width="100%" height="100%" fill="white"/>',
           '<text x="%d" y="22" font-size="14">%s</text>' % (ml, title)]
    for g in (-ylim, -ylim / 2, 0, ylim / 2, ylim):
        out.append('<line x1="%d" x2="%d" y1="%.1f" y2="%.1f" stroke="#ddd"/>' % (ml, w - mr, sy(g), sy(g)))
        out.append('<text x="%d" y="%.1f" text-anchor="end">%.1f</text>' % (ml - 6, sy(g) + 4, g))
    for k in range(0, 7):
        xv = x0 + (x1 - x0) * k / 6
        out.append('<text x="%.1f" y="%d" text-anchor="middle">%.0f</text>' % (sx(xv), h - mb + 18, xv))
    out.append('<text x="%d" y="%d" text-anchor="middle">input voltage (mV)</text>' % ((ml + w - mr) // 2, h - 10))
    out.append('<text x="16" y="%d" transform="rotate(-90 16 %d)" text-anchor="middle">INL (mV)</text>' % (h // 2, h // 2))
    colors = {1: '#1f6fb4', 0: '#d0632b'}
    for b in (1, 0):
        seg = [p for p in pts if p['buffer'] == b]
        if seg:
            d = ' '.join('%.1f,%.1f' % (sx(p['v']), sy(p['inl_mv'])) for p in seg)
            out.append('<polyline fill="none" stroke="%s" stroke-width="1.2" points="%s"/>' % (colors[b], d))
    out.append('<text x="%d" y="%d" fill="%s">buffer on</text>' % (w - 170, mt + 14, colors[1]))
    out.append('<text x="%d" y="%d" fill="%s">buffer off</text>' % (w - 90, mt + 14, colors[0]))
    out.append('</svg>')
    with open(path, 'w', encoding='ascii') as f:
        f.write('\n'.join(out))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('csv', nargs='+')
    ap.add_argument('--fit-min', type=float, default=None)
    ap.add_argument('--fit-max', type=float, default=None)
    ap.add_argument('--vref', type=int, default=None, help='override VREF+ mV of the NUCLEO')
    ap.add_argument('--nocal-vref', type=int, default=1175)
    a = ap.parse_args()

    rows = []
    for p in a.csv:
        rows += load(p)
    log = []

    # true voltage per buffer mode
    for b in (1, 0):
        sel = [r for r in rows if r['buffer'] == b]
        if not sel:
            continue
        cal = [r for r in sel if r['dmm'] is not None]
        if len(cal) >= 2:
            ka, kb = linfit([r['dac_code'] for r in cal], [r['dmm'] for r in cal])
            res = [r['dmm'] - (ka * r['dac_code'] + kb) for r in cal]
            log.append('buffer %d: meter fit V = %.6f * code %+.2f mV from %d points, residual max %.2f mV'
                       % (b, ka, kb, len(cal), max(abs(x) for x in res)))
            for r in sel:
                r['v'] = ka * r['dac_code'] + kb
        else:
            vref = a.vref or sel[0]['vref'] or 3300
            log.append('buffer %d: NO meter readings, ideal V = code * %d / 4095 (DAC gain/offset not removed)' % (b, vref))
            for r in sel:
                r['v'] = r['dac_code'] * vref / 4095.0

    fit = [r for r in rows if r['code'] > 0
           and (a.fit_min is None or r['v'] >= a.fit_min)
           and (a.fit_max is None or r['v'] <= a.fit_max)]
    k, c = linfit([r['v'] for r in fit], [r['code'] for r in fit])
    for r in rows:
        r['inl_code'] = r['code'] - (k * r['v'] + c)
        r['inl_mv'] = r['inl_code'] / k
        r['err_cal'] = r['mv'] - r['v']
        r['err_nocal'] = r['code'] * 8 * a.nocal_vref / 8192.0 - r['v']

    inl = [r['inl_mv'] for r in fit]
    log.append('fit range %.0f..%.0f mV, %d points' % (min(r['v'] for r in fit), max(r['v'] for r in fit), len(fit)))
    log.append('slope %.5f code/mV (1 code = %.3f mV), intercept %.2f code (%.2f mV)' % (k, 1 / k, c, -c / k))
    log.append('INL max %+.2f / %+.2f mV, rms %.2f mV' % (max(inl), min(inl), math.sqrt(sum(x * x for x in inl) / len(inl))))
    log.append('ADC noise: mean per-point std %.2f code' % (sum(r['std'] for r in rows) / len(rows)))
    ec = [r['err_cal'] for r in fit]
    en = [r['err_nocal'] for r in fit]
    log.append('driver mV (with OTP cal) - true: %+.1f .. %+.1f mV' % (min(ec), max(ec)))
    log.append('code*8*%d/8192 (no cal) - true: %+.1f .. %+.1f mV' % (a.nocal_vref, min(en), max(en)))
    zero = [r for r in rows if r['code'] == 0]
    if zero:
        log.append('code 0 (clipped) up to %.0f mV' % max(r['v'] for r in zero))

    base = os.path.splitext(a.csv[0])[0] + ('_combined' if len(a.csv) > 1 else '')
    with open(base + '_result.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(log) + '\n')
    with open(base + '_points.csv', 'w', newline='') as f:
        w = csv.writer(f)
        w.writerow(['buffer', 'dac_code', 'v_true_mv', 'adc_code_mean', 'adc_code_std', 'inl_mv', 'err_cal_mv', 'err_nocal_mv'])
        for r in sorted(rows, key=lambda r: r['v']):
            w.writerow([r['buffer'], r['dac_code'], '%.2f' % r['v'], '%.2f' % r['code'], '%.2f' % r['std'],
                        '%.2f' % r['inl_mv'], '%.1f' % r['err_cal'], '%.1f' % r['err_nocal']])
    svg_plot(base + '_inl.svg', sorted(rows, key=lambda r: r['v']), 'TLSR8208 ADC INL, PB0, 1/8 prescaler')
    print('\n'.join(log))
    print('->', base + '_result.txt / _points.csv / _inl.svg')


if __name__ == '__main__':
    main()
