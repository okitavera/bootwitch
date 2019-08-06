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

Although bootwitch are powered by `magiskboot`, it doesn't comes with the `magiskboot` binary by default.<br />
The main purpose of it is so you can decide what version of `magiskboot` by yourself.<br />
So, before anything else, you need to put your preferred `magiskboot` binary file inside the `external/` folder.

### kernel related files

Like anykernel2, you can put your `Image.gz-dtb` (and `dtbo.img` if you also want to flash that) to the root of bootwitch folder.

### Specific kernel configuration (kernel.conf)

There is several things that you can configure in the [`kernel.conf`](kernel.conf).

```sh
kernelid=
```
Used by [`buildzip.sh`](buildzip.sh) for naming your zip files. required if you're using [`buildzip.sh`](buildzip.sh) for building zip file.

```
kernelname=
kernelver=
kernelauthor=
```
Informations of your kernel release. it will be displayed in the installation process. OR :

```
banner_mode=
```
If you want to use your own banner at [`banner.txt`](banner.txt), you can set `banner_mode` to `custom`.<br />
It will display the content of [`banner.txt`](banner.txt) instead the default information.

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
If your kernel release also provide the `dtbo.img`, you can enable `with_dtbo=true`.<br />
Don't forget to set the `dtbo` device block on `blk_dtbo`, and dtbo filename on `src_dtbo`.<br />
If not, then just set it to `false`.

```
preserve_magisk=
```
Mostly, custom kernel on system-as-root devices doesn't patch their initramfs.c ([@okitavera](https://github.com/okitavera) does, hehehe).<br />
Basically, in order preserve magisk functionality on system-as-root device, you need to hexpatch it like Magisk does.<br />
But don't worry, we got you.<br />
You just need to set it `true` to let the witch (and of course, `magiskboot`) does the job.

## 📦 Building zip file

bootwitch comes with [`buildzip.sh`](buildzip.sh) to generate zip easily.<br />
If you're already setup all things ([`kernel.conf`](kernel.conf), `external/magiskboot`, `Image.gz-dtb`, and maybe `dtbo.img`),<br />
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