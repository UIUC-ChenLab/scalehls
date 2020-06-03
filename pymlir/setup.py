from setuptools import setup, find_packages

with open("README.md", "r") as fp:
    long_description = fp.read()

setup(
    name='pymlir',
    version='0.3',
    url='https://github.com/spcl/pymlir',
    author='SPCL @ ETH Zurich',
    author_email='talbn@inf.ethz.ch',
    description='',
    long_description=long_description,
    long_description_content_type='text/markdown',
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: BSD License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
    packages=find_packages(
        exclude=["*.tests", "*.tests.*", "tests.*", "tests"]),
    package_data={
        '': ['lark/mlir.lark']
    },
    include_package_data=True,
    install_requires=[
        'lark-parser', 'parse'
    ],
    tests_require=['pytest', 'pytest-cov'],
    test_suite='pytest',
    scripts=[])
