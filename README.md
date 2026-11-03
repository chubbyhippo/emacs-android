# emacs-android

## install early-init.el

### run this in M-x eshell

```eshell
(progn (make-directory (expand-file-name "~/.emacs.d") t) (url-copy-file "https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/.emacs.d/early-init.el" (expand-file-name "~/.emacs.d/early-init.el") t))
```

## get signed termux

```shell
curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/signedtermux.sh | sh
```

## get emacs.keystore

https://github.com/emacs-mirror/emacs/raw/refs/heads/master/java/emacs.keystore

## get emacs

https://ftp.gnu.org/gnu/emacs/android/termux

## get termux

https://f-droid.org/repo/com.termux_1022.apk

## sign termux

```shell
apksigner sign --v2-signing-enabled --ks emacs.keystore -debuggable-apk-permitted --ks-pass pass:emacs1 com.termux_1022.apk
```

## get signed emacs

Requires `apktool` and `apksigner` on PATH. Run it after `signedtermux.sh`, because Emacs must be signed with the same
keystore as Termux to share its user ID.

```shell
curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/signedemacs.sh | sh
```

The script adds `android:sharedUserId="com.termux"` to the Emacs manifest, adds the `shared_user_label` string, rebuilds
the APK as `emacs_for_termux.apk`, and signs it with `emacs.keystore`.

## get both apps

Runs `signedtermux.sh` then `signedemacs.sh` in order. Requires `apktool` and `apksigner` on PATH.

```shell
curl -fsSL https://raw.githubusercontent.com/chubbyhippo/emacs-android/refs/heads/main/getapps.sh | sh
```

## references

https://github.com/johanwiden/termux-for-android-emacs  
https://marek-g.github.io/posts/tips_and_tricks/emacs_on_android/  
https://snow-dev.com/posts/Emacs/bring_your_emacs_to_android  
https://www.reddit.com/r/emacs/comments/1q4xhcw/bring_your_emacs_to_android/  
