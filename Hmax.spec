# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['hmax_launcher.py'],
    pathex=[],
    binaries=[],
    datas=[('F1_LS_3_1_0.ahk', '.'), ('Pass64_original.exe', '.'), ('Pass32.exe', '.'), ('Hmaxlogo.ico', '.'), ('Hmaxlogo.png', '.'), ('UX', 'UX')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='Hmax',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=['Hmaxlogo.ico'],
)
