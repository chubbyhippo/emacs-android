# emacs-android
## get emacs.keystore
https://github.com/emacs-mirror/emacs/raw/refs/heads/master/java/emacs.keystore
## sign termux
```shell
apksigner sign --v2-signing-enabled --ks emacs.keystore -debuggable-apk-permitted --ks-pass pass:emacs1 com.termux_1022.apk
```
## references
https://sourceforge.net/projects/android-ports-for-gnu-emacs/files/termux/  
https://github.com/johanwiden/termux-for-android-emacs
