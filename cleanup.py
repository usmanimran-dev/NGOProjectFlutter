import os
import shutil

paths = [
    r'c:\usman\NGOProjectFlutter\lib\features',
    r'c:\usman\NGOProjectFlutter\lib\models',
    r'c:\usman\NGOProjectFlutter\lib\screens',
    r'c:\usman\NGOProjectFlutter\lib\widgets',
    r'c:\usman\NGOProjectFlutter\lib\providers',
    r'c:\usman\NGOProjectFlutter\lib\routes'
]

for p in paths:
    if os.path.exists(p):
        try:
            shutil.rmtree(p)
            print(f'Deleted: {p}')
        except Exception as e:
            print(f'Failed to delete {p}: {e}')
    else:
        print(f'Path not found: {p}')
