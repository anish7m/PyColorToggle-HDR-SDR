# -*- mode: python ; coding: utf-8 -*-

import os


block_cipher = None

project_dir = os.path.abspath(SPECPATH)


a = Analysis(
    ['PyAutoActions.py'],
    pathex=[project_dir],
    binaries=[
        (os.path.join(project_dir, 'Dependency', 'HDRSwitch.dll'), 'Dependency'),
    ],
    datas=[
        (os.path.join(project_dir, 'Resources'), 'Resources'),
        (os.path.join(project_dir, 'processlist.ini'), '.'),
    ],
    hiddenimports=[
        'pythoncom',
        'pywintypes',
        'win32com.client',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='PyColorToggle-HDR-SDR',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    contents_directory='.',
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=os.path.join(project_dir, 'Resources', 'main.ico'),
    version=os.path.join(project_dir, 'file_version_info.txt'),
    uac_admin=False,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='PyColorToggle-HDR-SDR',
)
