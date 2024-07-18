from setuptools import setup, find_packages, Extension
from setuptools.command.build_ext import build_ext
import subprocess
import os


# Custom Extension class to add sourcedir attribute
class CMakeExtension(Extension):
    def __init__(self, name, sourcedir=''):
        Extension.__init__(self, name, sources=[])
        self.sourcedir = os.path.abspath(sourcedir)


class CMakeBuild(build_ext):
    def run(self):
        try:
            subprocess.check_call(['cmake', '--version'])
        except:
            raise RuntimeError("CMake must be installed to build the following extensions: " + ", ".join(
                e.name for e in self.extensions))

        for ext in self.extensions:
            self.build_extension(ext)

    def build_extension(self, ext):
        extdir = self.get_ext_fullpath(ext.name)
        extdir = os.path.abspath(os.path.dirname(extdir))
        cfg = 'Debug' if self.debug else 'Release'

        cmake_args = [
            '-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=' + extdir,
            '-DCMAKE_BUILD_TYPE=' + cfg
        ]

        build_args = ['--config', cfg]

        if not os.path.exists(self.build_temp):
            os.makedirs(self.build_temp)

        subprocess.check_call(['cmake', ext.sourcedir] + cmake_args, cwd=self.build_temp)
        subprocess.check_call(['cmake', '--build', '.'] + build_args, cwd=self.build_temp)


ext_modules = [
    CMakeExtension(
        name='triton._C.libtriton',
        sourcedir='src/triton/_C/libtriton'  # Directory containing your C++ source files
    ),
]

setup(
    name='triton',
    version='0.1.0',
    package_dir={'': 'src'},
    packages=find_packages(where='src'),
    include_package_data=True,
    install_requires=[
        # List your dependencies here
    ],
    ext_modules=ext_modules,
    cmdclass={'build_ext': CMakeBuild},
    entry_points={
        'console_scripts': [],
    },
)
