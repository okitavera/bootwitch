<h1 align="center">bootwitch</h1>
<h3 align="center">Magisk-powered Android Kernel Installer</h3>
<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/version-0.1-blue.svg?cacheSeconds=2592000" />
  <a href="https://github.com/okitavera/bootwitch/blob/master/LICENSE">
    <img alt="License: BSD 3-Clause" src="https://img.shields.io/badge/License-BSD%203--Clause-red.svg" target="_blank" />
  </a>
  <a href="https://twitter.com/okitavera">
    <img alt="okitavera" src="https://img.shields.io/twitter/follow/okitavera.svg?style=social" target="_blank" />
  </a>
</p>

## 🏗 Setup

### magiskboot

Although bootwitch are powered by `magiskboot`, it doesn't comes with the `magiskboot` binary by default.
The main purpose of it is so you can decide what version of `magiskboot` do you use (arm/x86).
So, you need to put your preffered `magiskboot` binary file inside the `external/` folder.

### kernel related files

Like anykernel2, you can put your `Image.gz-dtb` (and `dtbo.img` if you also want to flash that) to the root of bootwitch folder.

### Specific kernel configuration (kernel.conf)

There is several things that you can configure in the `kernel.conf`.

```sh
kernelid=
```
Used by `buildzip.sh` for naming your zip files. required if you're using `buildzip.sh` for building zip file.

```
kernelname=
kernelver=
kernelauthor=
```
Informations of your kernel release. it will be displayed in the installation process.

```
blk_boot=
src_kernel=
```
Define your kernel filename, and where the `boot` device block on it.

```
with_dtbo=
blk_dtbo=
src_dtbo=
```
If your kernel release also provide the `dtbo.img`, you can enable `with_dtbo=true`.
Don't forget to set the `dtbo` device block on `blk_dtbo`, and dtbo filename on `src_dtbo`.
If not, then just set it to `false`.

## 📦 Building zip file

bootwitch comes with `buildzip.sh` to generate zip easily.
If you're already setup all things (`kernel.conf`, `external/magiskboot`, `Image.gz-dtb`, and maybe `dtbo.img`),
you can just run the script directly in your `bootwitch` folder.

```sh
./buildzip.sh
```

## Author

👤 **Nanda Oktavera**

* Twitter: [@okitavera](https://twitter.com/okitavera)
* Github: [@okitavera](https://github.com/okitavera)

## 🤝 Contributing

Contributions, issues and feature requests are welcome!<br />Feel free to check [issues page](https://github.com/okitavera/bootwitch/issues).

## Show your support

Give a ⭐️ if this project helped you!

## 📝 License

Copyright © 2019 [Nanda Oktavera](https://github.com/okitavera).<br />
This project is [BSD 3-Clause](LICENSE) licensed.

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_