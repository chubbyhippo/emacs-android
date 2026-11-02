# emacs-android

```shell
curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/signedtermux.sh | sh
```

## get emacs.keystore

https://github.com/emacs-mirror/emacs/raw/refs/heads/master/java/emacs.keystore

## get termux

https://f-droid.org/repo/com.termux_1022.apk

## sign termux

```shell
apksigner sign --v2-signing-enabled --ks emacs.keystore -debuggable-apk-permitted --ks-pass pass:emacs1 com.termux_1022.apk
```

## get early-init.el

```shell
mkdir -p ~/.emacs.d && curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/.emacs.d/early-init.el -o ~/.emacs.d/early-init.el
```

## references

https://github.com/johanwiden/termux-for-android-emacs  
https://marek-g.github.io/posts/tips_and_tricks/emacs_on_android/  
https://snow-dev.com/posts/Emacs/bring_your_emacs_to_android